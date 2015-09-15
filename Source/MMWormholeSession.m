//
// MMWormholeSession.m
//
// Copyright (c) 2015 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMWormholeSession.h"

@interface MMWormholeSession ()
@property (nonatomic, strong) WCSession *session;
@end

@implementation MMWormholeSession

+ (instancetype)sharedListeningSession {
    static MMWormholeSession *sharedSession = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSession = [[self alloc] initWithApplicationGroupIdentifier:nil
                                                       optionalDirectory:nil];
        
        sharedSession.session = [WCSession defaultSession];
        sharedSession.session.delegate = sharedSession;
    });
    
    return sharedSession;
}


#pragma mark - Public Interface Methods

- (void)activateSessionListening {
    [self.session activateSession];
}


#pragma mark - Subclass Methods

- (void)passMessageObject:(nullable id <NSCoding>)messageObject identifier:(nullable NSString *)identifier {
    NSAssert(NO, @"Message passing is not supported in MMWormholeSession. Please use MMWormhole with an MMWormholeSessionTransiting type to pass messages using WatchConnectivity.");
}


- (nullable id)messageWithIdentifier:(nullable NSString *)identifier {
    NSAssert(NO, @"Message passing is not supported in MMWormholeSession. Please use MMWormhole with an MMWormholeSessionTransiting type to pass messages using WatchConnectivity.");
    return nil;
}

- (void)clearMessageContentsForIdentifier:(nullable NSString *)identifier {
    NSAssert(NO, @"Message passing is not supported in MMWormholeSession. Please use MMWormhole with an MMWormholeSessionTransiting type to pass messages using WatchConnectivity.");
}

- (void)clearAllMessageContents {
    NSAssert(NO, @"Message passing is not supported in MMWormholeSession. Please use MMWormhole with an MMWormholeSessionTransiting type to pass messages using WatchConnectivity.");
}


#pragma mark - Private Subclass Methods

- (void)registerForNotificationsWithIdentifier:(nullable NSString *)identifier {
    // MMWormholeSession uses WatchConnectivity delegate callbacks and does not support Darwin Notification Center notifications.
}

- (void)unregisterForNotificationsWithIdentifier:(nullable NSString *)identifier {
    // MMWormholeSession uses WatchConnectivity delegate callbacks and does not support Darwin Notification Center notifications.
}


#pragma mark - WCSessionDelegate Methods

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message {
    for (NSString *identifier in message.allKeys) {
        NSData *data = message[identifier];
        id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [self notifyListenerForMessageWithIdentifier:identifier message:messageObject];
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext {
    for (NSString *identifier in applicationContext.allKeys) {
        NSData *data = applicationContext[identifier];
        id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [self notifyListenerForMessageWithIdentifier:identifier message:messageObject];
    }
}

- (void)session:(nonnull WCSession *)session didReceiveFile:(nonnull WCSessionFile *)file {
    NSString *identifier = file.metadata[@"identifier"];
    
    NSData *data = [NSData dataWithContentsOfURL:file.fileURL];
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [self notifyListenerForMessageWithIdentifier:identifier message:messageObject];
    
    MMWormholeFileTransiting *wormholeMessenger = self.wormholeMessenger;
    
    if ([wormholeMessenger respondsToSelector:@selector(filePathForIdentifier:)] == NO) {
        return;
    }
    
    if (messageObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
        
        NSString *filePath = [wormholeMessenger filePathForIdentifier:identifier];
        
        if (data == nil || filePath == nil) {
            return;
        }
        
        [data writeToFile:filePath atomically:YES];
    }
}

@end

