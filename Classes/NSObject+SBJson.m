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

// NOTE: Define: SBJSON_DEBUG  to enable some basic debug logging.


#import "NSObject+SBJson.h"
#import "SBJsonWriter.h"
#import "SBJsonParser.h"
#import "JsonCollectionMap.h"

#import <objc/runtime.h>



@implementation NSObject (NSObject_SBJsonWriting)

- (NSString *)JSONRepresentation {
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];    
    NSString *json = [writer stringWithObject:self];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", writer.error);
    return json;
}


#pragma mark - Core Creation Methods

- (void)parseArray:(NSDictionary *)mappingDictionary key:(NSString *)key val:(id)val {
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
                    }
                    [self setValue:newArr forKey:key];
                }
}

- (void)parseDictionary:(NSDictionary *)mappingDictionary key:(NSString *)key val:(id)val {
    Class c = [mappingDictionary valueForKey:key];
    if (c == nil) {
                    [self setValue:val forKey:key];
                } else {
                    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                    for (NSString *subkey in [val keyEnumerator]) {
                        NSDictionary *valueDict = [val valueForKey:subkey];
                        id newVal = [[c alloc] initWithDictionary:valueDict andMappings:mappingDictionary];
                        [newDict setValue:newVal forKey:subkey];
                    }
                    [self setValue:newDict forKey:key];
                }
}

- (void)parseObject:(NSDictionary *)dict mappingDictionary:(NSDictionary *)mappingDictionary key:(NSString *)key className:(NSString *)className {
#ifdef SBJSON_DEBUG
    NSLog(@"class: %@", className);
#endif
    Class c = objc_getClass([className UTF8String]);
    NSDictionary *valueDict = [dict valueForKey:key];
    [self setValue:[[[c alloc] initWithDictionary:valueDict andMappings:mappingDictionary] autorelease] forKey:key];
}

- (id)initWithDictionary:(NSDictionary *)dict andMappings:(NSDictionary *)mappingDictionary {
#ifdef SBJSON_DEBUG
    NSLog(@"%@", dict);
#endif
    for (NSString *key in [dict keyEnumerator]) {
        objc_property_t prop = class_getProperty(self.class, [key UTF8String]);
        if (prop == nil) { // class does not match dictionary
            continue;
        }
        NSString *attribs = [NSString stringWithUTF8String:property_getAttributes(prop)];
        id val = [dict valueForKey:key];
        if (val == [NSNull null]) continue; // ignore empty values
        
        if ([attribs characterAtIndex:1] == '@') {
            NSArray *propsArray = [attribs componentsSeparatedByString:@","];
            NSString *classDescription = [propsArray objectAtIndex:0];
            NSString *className = [[classDescription componentsSeparatedByString:@"\""] objectAtIndex:1];
            if ([className isEqualToString:@"NSArray"]) {
                [self parseArray:mappingDictionary key:key val:val];
            } else if ([className isEqualToString:@"NSDictionary"]) {
                [self parseDictionary:mappingDictionary key:key val:val];
            } else if ([className isEqualToString:@"NSString"]) {
                [self setValue:[self stringFromX:val] forKey:key];
            } else if ([className isEqualToString:@"NSDecimalNumber"]) {
                [self setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", val]] forKey:key];
            } else if ([className isEqualToString:@"NSDate"]) {
                NSDate *date = [self parseDate:val];
                if (date) {
                    [self setValue:date forKey:key];
                }
            } else {
                [self parseObject:dict mappingDictionary:mappingDictionary key:key className:className];
            }
        } else {
            [self setValue:val forKey:key];
        }
    }
    return self;
}

/*!
  Used when the target class is a string. We handle the odd cases where the 
  json is an NSNumber but the field is a string.  The unerlying json parser
  has no wayt to know this so we allow for it.
 */
- (NSString *) stringFromX:(id)val{
    if(val == nil || val == [NSNull null]){
        return nil;
    }
    return [NSString stringWithFormat:@"%@",val];
}

- (NSDate *)parseDate:(NSString *)dateString {
    NSArray *dateFormats = @[
                             @"yyyy-MM-dd",
                             @"yyyy-MM-dd'T'HH:mm:ssZ"
                             ];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDate *result = nil;
    for (NSString *f in dateFormats) {
        fmt.dateFormat = f;
        @try {
            result = [fmt dateFromString:dateString];
            break;
        } @catch (NSException *e) {
            NSLog(@"date format did not match %@", f);
        }
    }
    return result;
}

- (NSString *)iso8601DateString:(NSDate *)date {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return [fmt stringFromDate:date];
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


#pragma mark - Designated Init

/**
 Interal constructor that takes a dict/array from a parsed json string and a started va_list.
 
 Will close this list for you.
 */
-(id)initWIthJsonValueInternal:(id)jsonValue collectionMap:(JsonCollectionMap *) mapping  andVarArgs:(va_list)argList{
    self = [self init];
    if (self) {
        NSMutableDictionary *mappingDict = [[NSMutableDictionary alloc] init];
        if (argList) { // build the mapping dictionary
            for (JsonCollectionMap *singleMap = mapping; singleMap != nil; singleMap = va_arg(argList, JsonCollectionMap *)) {
                [mappingDict setValue:singleMap.clazz forKey:singleMap.fieldName];
            }
            va_end(argList);
        }
        if ([jsonValue isKindOfClass:NSDictionary.class]) {
            NSDictionary *d = (NSDictionary *)jsonValue;
            [self initWithDictionary:d andMappings:mappingDict];
        } else if ([jsonValue isKindOfClass:NSArray.class]) {
            id out = [self initWithArray:jsonValue andMappings:mappingDict]; // return an array of selves, rather than a single self
            // let go of the mapping dict.
            [mappingDict release];
            // Return the new array
            return out;
         }
        [mappingDict release];
    }
    return self;
    
}




#pragma mark - Easy Inits

/**
 Intermediate constuctor that converts the var args to a data structure for final consumption.
 */
- (id)initWithJson:(NSString *)jsonStr andCollectionMaps:(JsonCollectionMap *)mapping, ... {
    // parse that json string
    id jsonVal = [jsonStr JSONValue];
    va_list vaArgs;
    va_start(vaArgs, mapping);
    return [self initWIthJsonValueInternal:jsonVal collectionMap:mapping andVarArgs:vaArgs];
}


/**
 Intermediate constuctor that converts the var args to a data structure for final consumption.
 */
- (id)initWithJsonValue:(id)jsonVal andCollectionMaps:(JsonCollectionMap *)mapping, ...{
    va_list vaArgs;
    va_start(vaArgs, mapping);
    return [self initWIthJsonValueInternal:jsonVal collectionMap:mapping andVarArgs:vaArgs];
}



- (id)initWithJson:(NSString *)json {
    return [self initWithJson:json andCollectionMaps:nil, nil];
}


-(id)initWithJsonValue:(id)jsonValue {
    return [self initWithJsonValue:jsonValue andCollectionMaps:nil,nil];
}








- (id)asJsonCompatibleObject {
    if ([self isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [(NSDictionary *)self keyEnumerator]) {
            NSObject *oldVal = [(NSDictionary *)self objectForKey:key];
            [newDict setValue:[oldVal asJsonCompatibleObject] forKey:key];
        }
        return newDict;
    } else if ([self isKindOfClass:NSArray.class]) {
        NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
        long count = ((NSArray *)self).count;
        NSArray *selfAsArray = (NSArray *)self;
        for (long j = 0; j < count; j++) {
            id arrayObj = [selfAsArray objectAtIndex:j];
            [arr addObject:[arrayObj asJsonCompatibleObject]];
        }
        return arr;
    } else if ([self isKindOfClass:NSString.class]) {
        return self;
    } else if ([self isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)self stringValue];
    } else if ([self isKindOfClass:NSDate.class]) {
        return [self iso8601DateString:(NSDate *)self];
    } else {
        unsigned int propCount;
        objc_property_t *props = class_copyPropertyList(self.class, &propCount);
        NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
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
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id repr = [parser objectWithString:self];
    if (!repr)
        NSLog(@"-JSONValue failed. Error is: %@", parser.error);
    return repr;
}

@end
