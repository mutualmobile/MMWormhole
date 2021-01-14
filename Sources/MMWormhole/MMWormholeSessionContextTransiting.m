//
// MMWormholeSessionContextTransiting.m
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

#import "MMWormholeSessionContextTransiting.h"

#import <WatchConnectivity/WatchConnectivity.h>

@interface MMWormholeSessionContextTransiting ()
@property (nonatomic, strong) WCSession *session;
@property (nonatomic, strong) NSMutableDictionary *lastContext;
@end

@implementation MMWormholeSessionContextTransiting

- (instancetype)initWithApplicationGroupIdentifier:(nullable NSString *)identifier
                                 optionalDirectory:(nullable NSString *)directory {
    if ((self = [super initWithApplicationGroupIdentifier:identifier optionalDirectory:directory])) {
        // Setup transiting with the default session
        _session = [WCSession defaultSession];
        
        // Ensure that the MMWormholeSession's delegate is set to enable message sending
        NSAssert(_session.delegate != nil, @"WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole using the MMWormholeSessionTransiting classes.");
    }
    
    return self;
}

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return NO;
    }
    
    if ([WCSession isSupported] == false) {
        return NO;
    }
    
    if (messageObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
        
        if (data == nil) {
            return NO;
        }
        
        NSMutableDictionary *applicationContext = [self.session.applicationContext mutableCopy];
        
        if (applicationContext == nil) {
            applicationContext = [NSMutableDictionary new];
        }
        
        if (self.lastContext == nil) {
            self.lastContext = applicationContext;
        }
        
        NSMutableDictionary *currentContext = applicationContext;
        [currentContext addEntriesFromDictionary:self.lastContext];
        currentContext[identifier] = data;
        
        self.lastContext = currentContext;
        
        [self.session updateApplicationContext:currentContext error:nil];
    }
    
    return NO;
}

- (nullable id<NSCoding>)messageObjectForIdentifier:(nullable NSString *)identifier {
    NSDictionary *receivedContext = self.session.receivedApplicationContext;
    NSData *data = receivedContext[identifier];
    
    if (data == nil) {
        NSDictionary *currentContext = self.session.applicationContext;
        data = currentContext[identifier];
        
        if (data == nil) {
            return nil;
        }
    }
    
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
}

- (void)deleteContentForIdentifier:(nullable NSString *)identifier {
    [self.lastContext removeObjectForKey:identifier];
    
    NSMutableDictionary *currentContext = [self.session.applicationContext mutableCopy];
    [currentContext removeObjectForKey:identifier];
    
    [self.session updateApplicationContext:currentContext error:nil];
}

- (void)deleteContentForAllMessages {
    [self.lastContext removeAllObjects];
    [self.session updateApplicationContext:@{} error:nil];
}

@end
