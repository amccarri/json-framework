//
//  TestComplexObj.m
//  SBJson
//
//  Created by Alex McCarrier on 7/30/11.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import "TestComplexObj.h"
#import "TestObj.h"

@interface TestComplexObj (Privates)
- (NSArray *)buildArray;
- (NSDictionary *)buildDictionary;
- (TestObj *)buildTestObj;
@end

@implementation TestComplexObj

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithTestData {
    self = [self init];
    if (self) {
        self.myInt = 7;
        self.myDouble = 22.2;
        self.myArray = [self buildArray];
        self.myTestObj = [self buildTestObj];
        self.myBool = NO;
        self.decimalNumber = [NSDecimalNumber decimalNumberWithString:@"25.5"];
    }
    return self;
}

/** builds an array of test objs*/
- (NSArray *)buildArray {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        TestObj *t = [[TestObj alloc] init];
        t.foo = [NSString stringWithFormat:@"foo %d", i];
        t.bar = [NSString stringWithFormat:@"bar %d", i];
        [arr addObject:t];
    }
    return [NSArray arrayWithArray:arr];
}

- (TestObj *)buildTestObj {
    TestObj *t = [[TestObj alloc] init];
    t.foo = @"foo value";
    t.bar = @"bar value";
    return t;
}

@end
