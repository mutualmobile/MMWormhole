//
// MMWormhole.m
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
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

#import "MMWormhole.h"

#include <CoreFoundation/CoreFoundation.h>

static NSString * const MMWormholeNotificationName = @"MMWormholeNotificationName";

@interface MMWormhole ()

@property (nonatomic, copy) NSString *applicationGroupIdentifier;
@property (nonatomic, copy) NSString *directory;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableDictionary *listenerBlocks;

@end

@implementation MMWormhole

- (id)init {    
    return nil;
}

- (instancetype)initWithApplicationGroupIdentifier:(NSString *)identifier
                                 optionalDirectory:(NSString *)directory {
    if ((self = [super init])) {
        _applicationGroupIdentifier = [identifier copy];
        _directory = [directory copy];
        _fileManager = [[NSFileManager alloc] init];
        _listenerBlocks = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMessageNotification:)
                                                     name:MMWormholeNotificationName
                                                   object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}


#pragma mark - Private File Operation Methods

- (NSString *)messagePassingDirectoryPath {
    NSURL *appGroupContainer = [self.fileManager containerURLForSecurityApplicationGroupIdentifier:self.applicationGroupIdentifier];
    NSString *appGroupContainerPath = [appGroupContainer path];
    NSString *directoryPath = appGroupContainerPath;
    
    if (self.directory != nil) {
        directoryPath = [appGroupContainerPath stringByAppendingPathComponent:self.directory];
    }
    
    [self.fileManager createDirectoryAtPath:directoryPath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
    
    return directoryPath;
}

- (NSString *)jsonFilePathForIdentifier:(NSString *)identifier {
    NSString *directoryPath = [self messagePassingDirectoryPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.json", identifier];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

- (NSString *)archiveFilePathForIdentifier:(NSString *)identifier {
    NSString *directoryPath = [self messagePassingDirectoryPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.archive", identifier];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

- (NSData *)encodedDataForMessageObject:(id)messageObject {
    NSData *data = nil;
    
    if ([messageObject conformsToProtocol:@protocol(NSCoding)]) {
        data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
    }
    
    return data;
}

- (void)writeMessageObject:(id)messageObject toFileWithIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return;
    }
    
    NSData *data = nil;
    NSString *filePath = nil;
    
    if ([NSJSONSerialization isValidJSONObject:messageObject]) {
        data = [NSJSONSerialization dataWithJSONObject:messageObject
                                               options:NSJSONWritingPrettyPrinted
                                                 error:NULL];
        filePath = [self jsonFilePathForIdentifier:identifier];
    } else {
        data = [self encodedDataForMessageObject:messageObject];
        filePath = [self archiveFilePathForIdentifier:identifier];
    }
    
    if (data == nil) {
        return;
    }
    
    BOOL success = [data writeToFile:filePath atomically:YES];
    
    if (success) {
        [self sendNotificationForMessageWithIdentifier:identifier];
    }
}

- (id)messageObjectFromFileWithIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return nil;
    }
    
    id messageObject = nil;
    
    NSData *data = [NSData dataWithContentsOfFile:[self jsonFilePathForIdentifier:identifier]];
    
    if (data != nil) {
        messageObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];

        if (messageObject != nil) {
            return messageObject;
        }
    }
    
    data = [NSData dataWithContentsOfFile:[self archiveFilePathForIdentifier:identifier]];
    
    if (data == nil) {
        return nil;
    }
    
    messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
}

- (void)deleteFileForIdentifier:(NSString *)identifier {
    [self.fileManager removeItemAtPath:[self jsonFilePathForIdentifier:identifier] error:NULL];
    [self.fileManager removeItemAtPath:[self archiveFilePathForIdentifier:identifier] error:NULL];
}


#pragma mark - Private Notification Methods

- (void)sendNotificationForMessageWithIdentifier:(NSString *)identifier {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFDictionaryRef const userInfo = NULL;
    BOOL const deliverImmediately = YES;
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterPostNotification(center, str, NULL, userInfo, deliverImmediately);
}

- (void)registerForNotificationsWithIdentifier:(NSString *)identifier {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    wormholeNotificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)unregisterForNotificationsWithIdentifier:(NSString *)identifier {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterRemoveObserver(center,
                                       (__bridge const void *)(self),
                                       str,
                                       NULL);
}

void wormholeNotificationCallback(CFNotificationCenterRef center,
                               void * observer,
                               CFStringRef name,
                               void const * object,
                               CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    [[NSNotificationCenter defaultCenter] postNotificationName:MMWormholeNotificationName
                                                        object:nil
                                                      userInfo:@{@"identifier" : identifier}];
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    typedef void (^MessageListenerBlock)(id messageObject);
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *identifier = [userInfo valueForKey:@"identifier"];
    
    if (identifier != nil) {
        MessageListenerBlock listenerBlock = [self.listenerBlocks valueForKey:identifier];

        if (listenerBlock) {
            id messageObject = [self messageObjectFromFileWithIdentifier:identifier];

            listenerBlock(messageObject);
        }
    }
}


#pragma mark - Public Interface Methods

- (void)passMessageObject:(id)messageObject identifier:(NSString *)identifier {
    [self writeMessageObject:messageObject toFileWithIdentifier:identifier];
}


- (id)messageWithIdentifier:(NSString *)identifier {
    id messageObject = [self messageObjectFromFileWithIdentifier:identifier];
    
    return messageObject;
}

- (void)clearMessageContentsForIdentifier:(NSString *)identifier {
    [self deleteFileForIdentifier:identifier];
}

- (void)clearAllMessageContents {
    if (self.directory != nil) {
        NSArray *messageFiles = [self.fileManager contentsOfDirectoryAtPath:[self messagePassingDirectoryPath] error:NULL];
        
        for (NSString *path in messageFiles) {
            [self.fileManager removeItemAtPath:path error:NULL];
        }
    }
}

- (void)listenForMessageWithIdentifier:(NSString *)identifier
                              listener:(void (^)(id messageObject))listener {
    if (identifier != nil) {
        [self.listenerBlocks setValue:listener forKey:identifier];
        [self registerForNotificationsWithIdentifier:identifier];
    }
}

- (void)stopListeningForMessageWithIdentifier:(NSString *)identifier {
    if (identifier != nil) {
        [self.listenerBlocks setValue:nil forKey:identifier];
        [self unregisterForNotificationsWithIdentifier:identifier];
    }
}

@end
