//
//  TestComplexObj.h
//  SBJson
//
//  Created by Alex McCarrier on 7/30/11.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestObj;

@interface TestComplexObj : NSObject {
    int myInt;
    double myDouble;
    NSArray *myArray;
    TestObj *myTestObj;
    NSDictionary *myDictionary;
    BOOL myBool;
}

@property (nonatomic, assign) int myInt;
@property (nonatomic, assign) double myDouble;
@property (nonatomic, assign) BOOL myBool;
@property (nonatomic, retain) NSArray *myArray;
@property (nonatomic, retain) TestObj *myTestObj;
@property (nonatomic, retain) NSDictionary *myDictionary;

- (id)initWithTestData;

@end
