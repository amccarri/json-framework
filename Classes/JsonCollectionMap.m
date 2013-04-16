//
//  JsonCollectionMap.m
//  SBJson
//
//  Created by Alex McCarrier on 7/31/11.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import "JsonCollectionMap.h"

@implementation JsonCollectionMap

@synthesize fieldName;
@synthesize clazz;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (JsonCollectionMap *)map:(NSString *)fieldName toClass:(Class)className {
    JsonCollectionMap *map = [[JsonCollectionMap alloc] init];
    map.fieldName = fieldName;
    map.clazz = className;
    return map;
}

@end
