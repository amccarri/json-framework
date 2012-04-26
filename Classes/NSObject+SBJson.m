/*
 Copyright (C) 2009 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSObject+SBJson.h"
#import "SBJsonWriter.h"
#import "SBJsonParser.h"
#import "JsonCollectionMap.h"

#import <objc/runtime.h>

@implementation NSObject (NSObject_SBJsonWriting)

- (NSString *)JSONRepresentation {
    SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];    
    NSString *json = [writer stringWithObject:self];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", writer.error);
    return json;
}

- (id)initWithDictionary:(NSDictionary *)dict andMappings:(NSDictionary *)mappingDictionary {
    NSLog(@"%@", dict);
    for (NSString *key in [dict keyEnumerator]) {
        objc_property_t prop = class_getProperty(self.class, [key UTF8String]);
        if (prop == nil) { // class does not match dictionary
            continue;
        }
        NSString *attribs = [NSString stringWithUTF8String:property_getAttributes(prop)];
        id val = [dict valueForKey:key];
        if (val == [NSNull null]) continue; // ignore empty values
        
        if ([attribs characterAtIndex:1] == '@' &&
            ![val isKindOfClass:NSString.class]) {
            NSArray *propsArray = [attribs componentsSeparatedByString:@","];
            NSString *classDescription = [propsArray objectAtIndex:0];
            NSString *className = [[classDescription componentsSeparatedByString:@"\""] objectAtIndex:1];
            if ([className isEqualToString:@"NSArray"]) {
                Class c = [mappingDictionary valueForKey:key];
                if (c == nil) {
                    [self setValue:val forKey:key];
                } else {
                    NSMutableArray *newArr = [[NSMutableArray alloc] init];
                    for (id obj in val) {
                        id newVal;
                        if (c == NSString.class) {
                            newVal = obj;
                        } else {
                            newVal = [[c alloc] initWithDictionary:obj andMappings:mappingDictionary];
                        }
                        [newArr addObject:newVal];
                        [newVal release];
                    }
                    [self setValue:newArr forKey:key];
                    [newArr release];
                }
            } else if ([className isEqualToString:@"NSDictionary"]) { 
                Class c = [mappingDictionary valueForKey:key];
                if (c == nil) {
                    [self setValue:val forKey:key];
                } else {
                    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                    for (NSString *subkey in [val keyEnumerator]) {
                        NSDictionary *valueDict = [val valueForKey:subkey];
                        id newVal = [[c alloc] initWithDictionary:valueDict andMappings:mappingDictionary];
                        [newDict setValue:newVal forKey:subkey];
                        [newVal release];
                    }
                    [self setValue:newDict forKey:key];
                    [newDict release];
                }
            } else if ([className isEqualToString:@"NSString"]) {
                [self setValue:val forKey:key];
            } else {
                NSLog(@"class: %@", className);
                Class c = objc_getClass([className UTF8String]);
                NSDictionary *valueDict = [dict valueForKey:key];
                [self setValue:[[[c alloc] initWithDictionary:valueDict andMappings:mappingDictionary] autorelease] forKey:key];
            }
        } else {
            [self setValue:val forKey:key];
        }
    }
    return self;
}

- (id)initWithArray:(NSArray *)arr andMappings:(NSDictionary *)mappingDict {
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    for (id obj in arr) {
        if ([self isKindOfClass:NSObject.class]) {
            id newObj = [[self.class alloc] initWithDictionary:obj andMappings:mappingDict];
            [newArray addObject:newObj];
        }
    }
    
    return newArray;
}

- (id)initWithJson:(NSString *)json {
    return [self initWithJson:json andCollectionMaps:nil, nil];
}

- (id)initWithJson:(NSString *)json andCollectionMaps:(JsonCollectionMap *)mapping, ... {
    self = [self init];
    if (self) {
        NSMutableDictionary *mappingDict = [[NSMutableDictionary alloc] init];
        if (mapping) { // build the mapping dictionary
            va_list args;
            va_start(args, mapping);
            for (JsonCollectionMap *singleMap = mapping; singleMap != nil; singleMap = va_arg(args, JsonCollectionMap *)) {
                [mappingDict setValue:singleMap.clazz forKey:singleMap.fieldName];
            }
        }
        id jsonVal = [json JSONValue];
        if ([jsonVal isKindOfClass:NSDictionary.class]) {
            NSDictionary *d = (NSDictionary *)jsonVal;
            [self initWithDictionary:d andMappings:mappingDict];
        } else if ([jsonVal isKindOfClass:NSArray.class]) {
            NSArray *arr = (NSArray *)jsonVal;
            return [self initWithArray:arr andMappings:mappingDict]; // return an array of selves, rather than a single self
        }
        [mappingDict release];
    }
    return self;    
}

- (id)asJsonCompatibleObject {
    if ([self isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *newDict = [[[NSMutableDictionary alloc] init] autorelease];
        for (NSString *key in [(NSDictionary *)self keyEnumerator]) {
            NSObject *oldVal = [(NSDictionary *)self objectForKey:key];
            [newDict setValue:[oldVal asJsonCompatibleObject] forKey:key];
        }
        return newDict;
    } else if ([self isKindOfClass:NSArray.class]) {
        NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
        int count = ((NSArray *)self).count;
        NSArray *selfAsArray = (NSArray *)self;
        for (int j = 0; j < count; j++) {
            id arrayObj = [selfAsArray objectAtIndex:j];
            [arr addObject:[arrayObj asJsonCompatibleObject]];
        }
        return arr;
    } else if ([self isKindOfClass:NSString.class]) {
        return self;
    } else if ([self isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)self stringValue];
    } else {
        unsigned int propCount;
        objc_property_t *props = class_copyPropertyList(self.class, &propCount);
        NSMutableDictionary *d = [[[NSMutableDictionary alloc] init] autorelease];
        for (int i = 0; i < propCount; i++) {
            objc_property_t prop = props[i];
            NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
            NSString *propAttribs = [NSString stringWithUTF8String:property_getAttributes(prop)];
            id val;
            if ([propAttribs characterAtIndex:1] == '@') {
                val = [self valueForKey:propName];
                [d setValue:[val asJsonCompatibleObject] forKey:propName];
            } else {
                [d setValue:[self valueForKey:propName] forKey:propName];
            }
        }
        free(props);
        return d;
    }
}

- (NSString *)json {
    return [[self asJsonCompatibleObject] JSONRepresentation];
}

@end



@implementation NSString (NSString_SBJsonParsing)

- (id)JSONValue {
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    id repr = [parser objectWithString:self];
    if (!repr)
        NSLog(@"-JSONValue failed. Error is: %@", parser.error);
    return repr;
}

@end
