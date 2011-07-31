//
//  JsonCollectionMap.h
//  SBJson
//
//  Created by Alex McCarrier on 7/31/11.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Maps a collection fieldname in JSON to a specific type.  Since obj-c is a dynamic language, 
 there is no way to infer the type from simply introspecting on the target class, so this mapping is 
 needed.
 */
@interface JsonCollectionMap : NSObject {
    NSString *fieldName;
    Class clazz;
}

@property (nonatomic, copy) NSString *fieldName;
@property (nonatomic, assign) Class clazz;

/** Create a collection mapping for a specific fieldName to a specific class. */
+ (JsonCollectionMap *)map:(NSString *)fieldName toClass:(Class)className;

@end
