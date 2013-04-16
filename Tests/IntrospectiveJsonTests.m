//
//  IntrospectiveJsonTests.m
//  SBJson
//
//  Created by Alex McCarrier on 7/30/11.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import "IntrospectiveJsonTests.h"
#import "TestObj.h"
#import "SBJson.h"
#import "TestComplexObj.h"
#import "JsonCollectionMap.h"

@implementation IntrospectiveJsonTests

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)testCreationSimple {
    NSMutableDictionary *outgoing = [[NSMutableDictionary alloc] init];
    [outgoing setValue:@"I am foo value" forKey:@"foo"];
    [outgoing setValue:@"I am bar value" forKey:@"bar"];
    NSString *json = [outgoing JSONRepresentation];
    TestObj *incoming = [[TestObj alloc] initWithJson:json];
    STAssertNotNil(incoming, @"should not have returned a nil class");
    STAssertNotNil(incoming.foo, @"foo should not be nil");
    STAssertNotNil(incoming.bar, @"foo should not be bar");
}

- (void)testMarshallingSimple {
    TestObj *outgoing = [[TestObj alloc] init];
    
    outgoing.foo = @"i am foo";
    outgoing.bar = @"i am bar";

    NSString *json = [outgoing json];
    STAssertNotNil(json, @"json string should have a value");

    NSDictionary *incoming = [json JSONValue];
    
    STAssertNotNil(incoming, @"incoming should exist");
    STAssertNotNil([incoming valueForKey:@"foo"], @"foo should have a value");
    STAssertNotNil([incoming valueForKey:@"bar"], @"bar should have a value");
    
    STAssertEqualObjects([incoming valueForKey:@"foo"], outgoing.foo, @"foo should match outgoing value");
    STAssertEqualObjects([incoming valueForKey:@"bar"], outgoing.bar, @"bar should match outgoing value");
    
}

- (NSString *)buildComplexJson {
    TestComplexObj *obj = [[TestComplexObj alloc] initWithTestData];
    TestComplexObj *obj2 = [[TestComplexObj alloc] initWithTestData];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:obj2 forKey:@"aComplexObject"];
    obj.myDictionary = dict;
    
    
    NSString *json = [obj json];
    return json;
}

- (NSMutableArray *)buildTestArray {
  NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[[TestComplexObj alloc] initWithTestData]];
    [arr addObject:[[TestComplexObj alloc] initWithTestData]];
  return arr;
}

- (void)testArrayCreation {
    NSString *json = [[self buildTestArray] json];
    NSArray *arrayOfComplexObjs = (NSArray *)[[TestComplexObj alloc] initWithJson:json];
    STAssertTrue([arrayOfComplexObjs count] == 2, @"should be 2 entries in array");
}

- (void)testMarshallingArray {
    NSMutableArray *arr;
    arr = [self buildTestArray];

    NSString *json = [arr json];
    NSLog(@"%@", json);
    STAssertTrue(json.length > 2, @"array should not be empty");
}

- (void)testCreationComplex {
    NSString *json = [self buildComplexJson];
    STAssertNotNil(json, @"json string should not be nil");
    
    TestComplexObj *obj = [[TestComplexObj alloc] initWithJson:json 
                                             andCollectionMaps:
                                                [JsonCollectionMap map:@"myArray" toClass:TestObj.class], 
                                                [JsonCollectionMap map:@"myDictionary" toClass:TestComplexObj.class], 
                           nil];
        
    STAssertNotNil(obj, @"obj should not be nil");
    STAssertNotNil(obj.myArray, @"array should not be nil");
    
    for (int i = 0; i < [obj.myArray count]; i++) {
        TestObj *arrElem = [obj.myArray objectAtIndex:i];
        NSString *expected = [NSString stringWithFormat:@"foo %d", i];
        NSString *actual = arrElem.foo;
        STAssertEqualObjects(expected, actual, [NSString stringWithFormat:@"expected %@, actual %@", expected, actual]);
    }
    
    STAssertEquals(obj.myInt, 7, @"int value not correct");
    STAssertEquals(obj.myDouble, 22.2, @"double values do not match");
    STAssertTrue([obj.decimalNumber compare:[NSDecimalNumber decimalNumberWithString:@"25.5"]] == NSOrderedSame, @"decimal number has unexpected value");
    STAssertNotNil(obj.myTestObj, @"test object should not be nil");
    STAssertTrue([obj.myTestObj isKindOfClass:TestObj.class], @"associate class is not an instance of it's actual class");
    STAssertNotNil(obj.myDictionary, @"dictionary should not be nil");
    TestComplexObj *aComplexObj = [obj.myDictionary valueForKey:@"aComplexObject"];
    STAssertNotNil(aComplexObj, @"dictionary should not be empty");
    STAssertEqualObjects(@"foo value", aComplexObj.myTestObj.foo, @"foo does not match dictionary value");
}

- (void)testMarshallingComplex {
    TestComplexObj *obj = [[TestComplexObj alloc] initWithTestData];
    TestComplexObj *obj2 = [[TestComplexObj alloc] initWithTestData];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:obj2 forKey:@"aComplexObject"];
    obj.myDictionary = dict;
    
    
    NSString *json = [obj json];
    NSLog(@"%@", json);
    
}

@end
