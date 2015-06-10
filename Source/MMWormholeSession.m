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

#import "MMWormholeFileTransiting.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface MMWormholeSessionTransiting : MMWormholeFileTransiting <WCSessionDelegate>
@property (nonatomic, strong) WCSession *session;
@end

@implementation MMWormholeSessionTransiting

- (instancetype)initWithSession:(WCSession *)session {
    if ((self = [super initWithApplicationGroupIdentifier:nil optionalDirectory:nil])) {
        _session = session;
    }
    
    return self;
}


#pragma mark - MMWormholeFileTransiting Subclass Methods

- (nullable NSString *)messagePassingDirectoryPath {
    return nil;
}


#pragma mark - MMWormholeTransiting Protocol Methods

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return NO;
    }
    
    if (messageObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
        
        if (data == nil) {
            return NO;
        }
        
        if ([self.session isReachable]) {
            [self.session sendMessage:@{identifier : data} replyHandler:nil errorHandler:nil];
        }
        
        NSMutableDictionary *currentContext = [self.session.applicationContext mutableCopy];
        currentContext[identifier] = data;
        
        NSError *error = nil;
        
        [self.session updateApplicationContext:currentContext error:&error];
    }
    
    return NO;
}

- (nullable id<NSCoding>)messageObjectForIdentifier:(nullable NSString *)identifier {
    NSDictionary *currentContext = self.session.receivedApplicationContext;
    NSData *data = currentContext[identifier];
    
    if (data == nil) {
        return nil;
    }
    
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
}

- (void)deleteContentForIdentifier:(nullable NSString *)identifier {
    NSMutableDictionary *currentContext = [self.session.applicationContext mutableCopy];
    [currentContext removeObjectForKey:identifier];
    [self.session updateApplicationContext:currentContext error:nil];
}

- (void)deleteContentForAllMessages {
    [self.session updateApplicationContext:@{} error:nil];
}

@end


@interface MMWormholeSession () <WCSessionDelegate>
@property (nonatomic, strong) WCSession *session;
@end

@implementation MMWormholeSession

- (instancetype)init {
    if ((self = [super initWithApplicationGroupIdentifier:nil optionalDirectory:nil])) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];

        self.wormholeMessenger = [[MMWormholeSessionTransiting alloc] initWithSession:[WCSession defaultSession]];
    }
    
    return self;
}


#pragma mark - WCSessionDelegate Methods

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message {
    for (NSString *identifier in message.allKeys) {
        NSData *data = message[identifier];
        id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [self notifyListenerForMessageWithIdentifier:identifier message:messageObject];
    }
}

@end

