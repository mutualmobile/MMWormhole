//
//  MMWormholeTests.m
//  MMWormholeTests
//
//  Created by Conrad Stoll on 12/6/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MMWormhole.h"

#define ApplicationGroupIdentifier  @"group.com.mutualmobile.wormhole"

@interface MMWormhole (TextExtension)

- (void)writeMessageObject:(id)messageObject toFileWithIdentifier:(NSString *)identifier;
- (id)messageObjectFromFileWithIdentifier:(NSString *)identifier;
- (void)deleteFileForIdentifier:(NSString *)identifier;
- (id)listenerBlockForIdentifier:(NSString *)identifier;

@end

@interface MMWormholeTests : XCTestCase

@end

@implementation MMWormholeTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPassingMessageWithNilIdentifier {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    [wormhole passMessageObject:@{} identifier:nil];
    
    XCTAssertTrue(YES, @"Message Passing should not crash for nil message identifiers.");
}

- (void)testMessageListening {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Listener should hear something"];
    
    [wormhole listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject) {
        XCTAssertNotNil(messageObject, @"Valid message object should not be nil.");
        
        [expectation fulfill];
    }];
    
    // Simulate a fake notification since Darwin notifications aren't delivered to the sender
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MMWormholeNotificationName"
                                                        object:wormhole
                                                      userInfo:@{@"identifier" : @"testIdentifier"}];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testMessageListeningWithMultipleInstances {
    __block int wormhole1ListenerCounter = 0;
    __block int wormhole2ListenerCounter = 0;
    
    // Instance 1
    MMWormhole *wormhole1 = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    [wormhole1 listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject) {
        wormhole1ListenerCounter++;
    }];
    
    
    // Instance 2
    MMWormhole *wormhole2 = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                 optionalDirectory:@"testDirectory"];
    
    [wormhole2 listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject) {
        wormhole2ListenerCounter++;
    }];
    
    // Simulate a fake notification since Darwin notifications aren't delivered to the sender
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MMWormholeNotificationName"
                                                        object:wormhole1
                                                      userInfo:@{@"identifier" : @"testIdentifier"}];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue( wormhole1ListenerCounter == 1 && wormhole2ListenerCounter == 0 , @"Valid multiple listener blocks  with multiple instances should only be called once, on wormhole1." );
    });
}

- (void)testMessagePassingAndListeningWithMultipleInstances {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wormhole should receive message"];
    
    __block int wormhole1ListenerCounter = 0;
    __block int wormhole2ListenerCounter = 0;
    
    // Instance 1
    MMWormhole *wormhole1 = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                 optionalDirectory:@"testDirectory"];
    
    [wormhole1 listenForMessageWithIdentifier:@"testIdentifierWormhole1" listener:^(id messageObject) {
        wormhole1ListenerCounter++;
        [expectation fulfill];
    }];
    
    
    // Instance 2
    MMWormhole *wormhole2 = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                 optionalDirectory:@"testDirectory"];
    
    [wormhole2 listenForMessageWithIdentifier:@"testIdentifierWormhole2" listener:^(id messageObject) {
        wormhole2ListenerCounter++;
    }];
    
    // Send a message to one wormhole and verify it is received by that one but not the other
    [wormhole1 passMessageObject:@"message" identifier:@"testIdentifierWormhole1"];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        XCTAssertTrue(wormhole1ListenerCounter == 1 && wormhole2ListenerCounter == 0 , @"Valid multiple listener blocks  with multiple instances should only be called once, on wormhole1." );
    }];
    
}

- (void)testStopMessageListening {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Listener should hear something"];
    
    [wormhole listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject) {
        XCTAssertNotNil(messageObject, @"Valid message object should not be nil.");
        
        [expectation fulfill];
    }];
    
    // Simulate a fake notification since Darwin notifications aren't delivered to the sender
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MMWormholeNotificationName"
                                                        object:wormhole
                                                      userInfo:@{@"identifier" : @"testIdentifier"}];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        id listenerBlock = [wormhole listenerBlockForIdentifier:@"testIdentifier"];
        
        XCTAssertNotNil(listenerBlock, @"A valid listener block should not be nil.");
        
        [wormhole stopListeningForMessageWithIdentifier:@"testIdentifier"];
        
        id deletedListenerBlock = [wormhole listenerBlockForIdentifier:@"testIdentifier"];
        
        XCTAssertNil(deletedListenerBlock, @"The listener block should be nil after you stop listening.");
    }];    
}

- (void)testMessagePassingDuplicateListeners {
    __block int wormholeListenerCounter = 0;
    
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    XCTestExpectation *validExpectation = [self expectationWithDescription:@"Listener should hear something only once."];
    XCTestExpectation *invalidExpectation = [self expectationWithDescription:@"Listener should not hear something more than once."];

    [wormhole listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject) {
        XCTAssertTrue(NO, @"This listener should never be called.");
    }];
    
    [wormhole listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject) {
        XCTAssertNotNil(messageObject, @"This listener should be called with a valid message object..");
        
        if (wormholeListenerCounter == 0) {
            [validExpectation fulfill];
        }
        
        wormholeListenerCounter++;
        
        if (wormholeListenerCounter > 1) {
            [invalidExpectation fulfill];
        }
    }];
    
    [wormhole passMessageObject:@"message" identifier:@"testIdentifier"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [invalidExpectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        XCTAssertTrue(wormholeListenerCounter == 1, @"The listener for a given identifier should only be called once per message." );
    }];
}

- (void)testMessagePassingPerformance {
    [self measureBlock:^{
        MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                    optionalDirectory:@"testDirectory"];
    
        [wormhole passMessageObject:[self performanceSampleJSONObject] identifier:@"testPerformance"];
    }];
}

- (void)testJSONPerformance {
    [self measureBlock:^{
        [NSJSONSerialization dataWithJSONObject:[self performanceSampleJSONObject] options:0 error:NULL];
    }];
}

- (void)testArchivePerformance {
    [self measureBlock:^{
        [NSKeyedArchiver archivedDataWithRootObject:[self performanceSampleJSONObject]];
    }];
}

- (id)performanceSampleJSONObject {
    return @[@{@"key1" : @"string1", @"key2" : @(1), @"key3" : @{@"innerKey1" : @"innerString1", @"innerKey2" : @(1)}},
             @{@"key1" : @"string1", @"key2" : @(1), @"key3" : @{@"innerKey1" : @"innerString1", @"innerKey2" : @(1)}},
             @{@"key1" : @"string1", @"key2" : @(1), @"key3" : @{@"innerKey1" : @"innerString1", @"innerKey2" : @(1)}},
             @{@"key1" : @"string1", @"key2" : @(1), @"key3" : @{@"innerKey1" : @"innerString1", @"innerKey2" : @(1)}},
             @{@"key1" : @"string1", @"key2" : @(1), @"key3" : @{@"innerKey1" : @"innerString1", @"innerKey2" : @(1)}},
             @{@"key1" : @"string1", @"key2" : @(1), @"key3" : @{@"innerKey1" : @"innerString1", @"innerKey2" : @(1)}},
             @{@"key1" : @"string1", @"key2" : @(1), @"key3" : @{@"innerKey1" : @"innerString1", @"innerKey2" : @(1)}}
             ];
}

@end
