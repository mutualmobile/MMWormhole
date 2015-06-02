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

- (NSString *)messagePassingDirectoryPath;
- (NSString *)filePathForIdentifier:(NSString *)identifier;
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

- (void)testMessagePassingDirectory {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    NSString *messagePassingDirectoryPath = [wormhole messagePassingDirectoryPath];
    
    NSString *lastComponent = [[messagePassingDirectoryPath pathComponents] lastObject];
    
    XCTAssert([lastComponent isEqualToString:@"testDirectory"], @"Message Passing Directory path should contain optional directory.");
}

- (void)testFilePathForIdentifier {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    NSString *filePathForIdentifier = [wormhole filePathForIdentifier:@"testIdentifier"];
    
    NSString *lastComponent = [[filePathForIdentifier pathComponents] lastObject];
    
    XCTAssert([lastComponent isEqualToString:@"testIdentifier.archive"], @"File Path Identifier should equal the passed identifier with the .archive extension.");
}

- (void)testFilePathForNilIdentifier {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    NSString *filePathForIdentifier = [wormhole filePathForIdentifier:nil];
    
    NSString *lastComponent = [[filePathForIdentifier pathComponents] lastObject];
    
    XCTAssertNil(lastComponent, @"File Path Identifier should be nil if no identifier is provided.");
}

- (void)testPassingMessageWithNilIdentifier {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    [wormhole passMessageObject:@{} identifier:nil];
    
    XCTAssertTrue(YES, @"Message Passing should not crash for nil message identifiers.");
}

- (void)testValidMessagePassing {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    [wormhole deleteFileForIdentifier:@"testIdentifier"];
    
    id messageObject = [wormhole messageObjectFromFileWithIdentifier:@"testIdentifier"];
    
    XCTAssertNil(messageObject, @"Message object should be nil after deleting file.");
    
    NSString *filePathForIdentifier = [wormhole filePathForIdentifier:@"testIdentifier"];
    
    [wormhole passMessageObject:@{} identifier:@"testIdentifier"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePathForIdentifier];
    
    XCTAssertNotNil(data, @"Message contents should not be nil after passing a valid message.");
}

- (void)testFileWriting {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    [wormhole deleteFileForIdentifier:@"testIdentifier"];
    
    id messageObject = [wormhole messageObjectFromFileWithIdentifier:@"testIdentifier"];
    
    XCTAssertNil(messageObject, @"Message object should be nil after deleting file.");
    
    NSString *filePathForIdentifier = [wormhole filePathForIdentifier:@"testIdentifier"];
    
    [wormhole writeMessageObject:@{} toFileWithIdentifier:@"testIdentifier"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePathForIdentifier];
    
    XCTAssertNotNil(data, @"Message contents should not be nil after writing a valid message to disk.");
}

- (void)testClearingIndividualMessage {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    [wormhole passMessageObject:@{} identifier:@"testIdentifier"];
    
    id messageObject = [wormhole messageObjectFromFileWithIdentifier:@"testIdentifier"];
    
    XCTAssertNotNil(messageObject, @"Message contents should not be nil after passing a valid message.");

    [wormhole clearMessageContentsForIdentifier:@"testIdentifier"];
    
    NSString *filePathForIdentifier = [wormhole filePathForIdentifier:@"testIdentifier"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePathForIdentifier];

    XCTAssertNil(data, @"Message file should be gone after deleting message.");
    
    id deletedMessageObject = [wormhole messageObjectFromFileWithIdentifier:@"testIdentifier"];
    
    XCTAssertNil(deletedMessageObject, @"Message object should be nil after deleting message.");
}

- (void)testClearingAllMessages {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    [wormhole passMessageObject:@{} identifier:@"testIdentifier1"];
    [wormhole passMessageObject:@{} identifier:@"testIdentifier2"];
    [wormhole passMessageObject:@{} identifier:@"testIdentifier3"];
    
    [wormhole clearAllMessageContents];

    id deletedMessageObject1 = [wormhole messageObjectFromFileWithIdentifier:@"testIdentifier1"];
    id deletedMessageObject2 = [wormhole messageObjectFromFileWithIdentifier:@"testIdentifier2"];
    id deletedMessageObject3 = [wormhole messageObjectFromFileWithIdentifier:@"testIdentifier3"];

    XCTAssertNil(deletedMessageObject1, @"Message object should be nil after deleting message.");
    XCTAssertNil(deletedMessageObject2, @"Message object should be nil after deleting message.");
    XCTAssertNil(deletedMessageObject3, @"Message object should be nil after deleting message.");
}

- (void)testMessageListening {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Listener should hear something"];
    
    [wormhole listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject, NSString* identifier) {
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
    
    [wormhole1 listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject, NSString* identifier) {
        wormhole1ListenerCounter++;
    }];
    
    
    // Instance 2
    MMWormhole *wormhole2 = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                 optionalDirectory:@"testDirectory"];
    
    [wormhole2 listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject, NSString* identifier) {
        wormhole2ListenerCounter++;
    }];
    
    // Simulate a fake notification since Darwin notifications aren't delivered to the sender
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MMWormholeNotificationName"
                                                        object:wormhole1
                                                      userInfo:@{@"identifier" : @"testIdentifier"}];
    
    XCTAssertTrue( wormhole1ListenerCounter == 1 && wormhole2ListenerCounter == 0 , @"Valid multiple listener blocks  with multiple instances should only be called once, on wormhole1." );
}

- (void)testMessagePassingAndListeningWithMultipleInstances {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wormhole should receive message"];
    
    __block int wormhole1ListenerCounter = 0;
    __block int wormhole2ListenerCounter = 0;
    
    // Instance 1
    MMWormhole *wormhole1 = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                 optionalDirectory:@"testDirectory"];
    
    [wormhole1 listenForMessageWithIdentifier:@"testIdentifierWormhole1" listener:^(id messageObject, NSString* identifier) {
        wormhole1ListenerCounter++;
        [expectation fulfill];
    }];
    
    
    // Instance 2
    MMWormhole *wormhole2 = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                 optionalDirectory:@"testDirectory"];
    
    [wormhole2 listenForMessageWithIdentifier:@"testIdentifierWormhole2" listener:^(id messageObject, NSString* identifier) {
        wormhole2ListenerCounter++;
    }];
    
    // Send a message to one wormhole and verify it is received by that one but not the other
    [wormhole1 passMessageObject:@"message" identifier:@"testIdentifierWormhole1"];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        XCTAssertTrue( wormhole1ListenerCounter == 1 && wormhole2ListenerCounter == 0 , @"Valid multiple listener blocks  with multiple instances should only be called once, on wormhole1." );
    }];
    
}

- (void)testStopMessageListening {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Listener should hear something"];
    
    [wormhole listenForMessageWithIdentifier:@"testIdentifier" listener:^(id messageObject, NSString* identifier) {
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
