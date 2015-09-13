//
//  MMWormholeFileTransitingTests.m
//  MMWormhole
//
//  Created by Conrad Stoll on 5/27/15.
//  Copyright (c) 2015 Conrad Stoll. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMWormhole.h"

#define ApplicationGroupIdentifier  @"group.com.mutualmobile.wormhole"

@interface MMWormholeFileTransitingTests : XCTestCase

@end

@implementation MMWormholeFileTransitingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMessagePassingDirectory {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    MMWormholeFileTransiting *transiting = wormhole.wormholeMessenger;
    
    NSString *messagePassingDirectoryPath = [transiting messagePassingDirectoryPath];
    
    NSString *lastComponent = [[messagePassingDirectoryPath pathComponents] lastObject];
    
    XCTAssert([lastComponent isEqualToString:@"testDirectory"], @"Message Passing Directory path should contain optional directory.");
}

- (void)testFilePathForIdentifier {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    MMWormholeFileTransiting *transiting = wormhole.wormholeMessenger;

    NSString *filePathForIdentifier = [transiting filePathForIdentifier:@"testIdentifier"];
    
    NSString *lastComponent = [[filePathForIdentifier pathComponents] lastObject];
    
    XCTAssert([lastComponent isEqualToString:@"testIdentifier.archive"], @"File Path Identifier should equal the passed identifier with the .archive extension.");
}

- (void)testFilePathForNilIdentifier {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    MMWormholeFileTransiting *transiting = wormhole.wormholeMessenger;

    NSString *filePathForIdentifier = [transiting filePathForIdentifier:nil];
    
    NSString *lastComponent = [[filePathForIdentifier pathComponents] lastObject];
    
    XCTAssertNil(lastComponent, @"File Path Identifier should be nil if no identifier is provided.");
}

- (void)testValidMessagePassing {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    MMWormholeFileTransiting *transiting = wormhole.wormholeMessenger;

    [transiting deleteContentForIdentifier:@"testIdentifier"];
    
    id messageObject = [transiting messageObjectForIdentifier:@"testIdentifier"];
    
    XCTAssertNil(messageObject, @"Message object should be nil after deleting file.");
    
    NSString *filePathForIdentifier = [transiting filePathForIdentifier:@"testIdentifier"];
    
    [wormhole passMessageObject:@{} identifier:@"testIdentifier"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePathForIdentifier];
    
    XCTAssertNotNil(data, @"Message contents should not be nil after passing a valid message.");
}

- (void)testFileWriting {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    MMWormholeFileTransiting *transiting = wormhole.wormholeMessenger;

    [transiting deleteContentForIdentifier:@"testIdentifier"];
    
    id messageObject = [transiting messageObjectForIdentifier:@"testIdentifier"];
    
    XCTAssertNil(messageObject, @"Message object should be nil after deleting file.");
    
    NSString *filePathForIdentifier = [transiting filePathForIdentifier:@"testIdentifier"];
    
    [transiting writeMessageObject:@{} forIdentifier:@"testIdentifier"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePathForIdentifier];
    
    XCTAssertNotNil(data, @"Message contents should not be nil after writing a valid message to disk.");
}

- (void)testClearingIndividualMessage {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    MMWormholeFileTransiting *transiting = wormhole.wormholeMessenger;

    [wormhole passMessageObject:@{} identifier:@"testIdentifier"];
    
    id messageObject = [transiting messageObjectForIdentifier:@"testIdentifier"];
    
    XCTAssertNotNil(messageObject, @"Message contents should not be nil after passing a valid message.");
    
    [wormhole clearMessageContentsForIdentifier:@"testIdentifier"];
    
    NSString *filePathForIdentifier = [transiting filePathForIdentifier:@"testIdentifier"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePathForIdentifier];
    
    XCTAssertNil(data, @"Message file should be gone after deleting message.");
    
    id deletedMessageObject = [transiting messageObjectForIdentifier:@"testIdentifier"];
    
    XCTAssertNil(deletedMessageObject, @"Message object should be nil after deleting message.");
}

- (void)testClearingAllMessages {
    MMWormhole *wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:ApplicationGroupIdentifier
                                                                optionalDirectory:@"testDirectory"];
    MMWormholeFileTransiting *transiting = wormhole.wormholeMessenger;

    [wormhole passMessageObject:@{} identifier:@"testIdentifier1"];
    [wormhole passMessageObject:@{} identifier:@"testIdentifier2"];
    [wormhole passMessageObject:@{} identifier:@"testIdentifier3"];
    
    [wormhole clearAllMessageContents];
    
    id deletedMessageObject1 = [transiting messageObjectForIdentifier:@"testIdentifier1"];
    id deletedMessageObject2 = [transiting messageObjectForIdentifier:@"testIdentifier2"];
    id deletedMessageObject3 = [transiting messageObjectForIdentifier:@"testIdentifier3"];
    
    XCTAssertNil(deletedMessageObject1, @"Message object should be nil after deleting message.");
    XCTAssertNil(deletedMessageObject2, @"Message object should be nil after deleting message.");
    XCTAssertNil(deletedMessageObject3, @"Message object should be nil after deleting message.");
}


@end
