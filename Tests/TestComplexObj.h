//
//  TestComplexObj.h
//  SBJson
//
//  Created by Alex McCarrier on 7/30/11.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestObj;

@interface TestComplexObj : NSObject 

@property (nonatomic, assign) int myInt;
@property (nonatomic, assign) double myDouble;
@property (nonatomic, assign) BOOL myBool;
@property (nonatomic, retain) NSArray *myArray;
@property (nonatomic, retain) TestObj *myTestObj;
@property (nonatomic, retain) NSDictionary *myDictionary;
@property (nonatomic, copy) NSDecimalNumber *decimalNumber;

- (id)initWithTestData;

@end
