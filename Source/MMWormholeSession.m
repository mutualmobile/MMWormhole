//
//  MMWormholeSession.m
//  MMWormhole
//
//  Created by Conrad Stoll on 6/9/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

#import "MMWormholeSession.h"

#import "MMWormholeFileTransiting.h"
#import <WatchConnectivity/WatchConnectivity.h>


@interface MMWormholeSessionTransiting : MMWormholeFileTransiting <WCSessionDelegate>

@property (nonatomic, copy) NSString *directory;
@property (nonatomic, strong) WCSession *session;

@end

@implementation MMWormholeSessionTransiting

- (instancetype)initWithOptionalDirectory:(nullable NSString *)directory {
    if ((self = [super initWithApplicationGroupIdentifier:nil optionalDirectory:directory])) {
        _directory = [directory copy];
        _session = [WCSession defaultSession];
    }
    
    return self;
}


#pragma mark - MMWormholeFileTransiting Subclass Methods

- (nullable NSString *)messagePassingDirectoryPath {
    if (self.directory == nil) {
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths[0] stringByAppendingPathComponent:self.directory];
    
    [self.fileManager createDirectoryAtPath:directoryPath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
    
    return directoryPath;
}

- (nullable id<NSCoding>)messageObjectForIdentifier:(nullable NSString *)identifier {
    NSDictionary *currentContext = self.session.receivedApplicationContext;
    NSData *data = currentContext[identifier];
    
    if (data == nil) {
        return [super messageObjectForIdentifier:identifier];
    }
    
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
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
        
        NSString *filePath = [(MMWormholeSessionTransiting *)self filePathForIdentifier:identifier];
        BOOL success = NO;
        NSError *error = nil;
        
        if (filePath) {
            success = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        }
        
        NSURL *fileURL = [NSURL URLWithString:filePath];
        
        [self.session transferFile:fileURL metadata:@{@"identifier" : identifier}];
        [self.session sendMessage:@{identifier : data} replyHandler:nil errorHandler:nil];
        
        if ([NSPropertyListSerialization propertyList:data isValidForFormat:NSPropertyListXMLFormat_v1_0]) {
            NSMutableDictionary *currentContext = [self.session.applicationContext mutableCopy];
            currentContext[identifier] = data;
            
            NSError *error = nil;
            
            [self.session updateApplicationContext:currentContext error:&error];
        }
    }
    
    return YES;
}

@end


@interface MMWormholeSession () <WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;

@end

@implementation MMWormholeSession

- (instancetype)initWithApplicationGroupIdentifier:(nullable NSString *)identifier
                                 optionalDirectory:(nullable NSString *)directory {
    if ((self = [self init])) {
        
    }
    
    return nil;
}

- (instancetype)initWithOptionalDirectory:(nullable NSString *)directory {
    if ((self = [super initWithApplicationGroupIdentifier:nil optionalDirectory:directory])) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];

        self.wormholeMessenger = [[MMWormholeSessionTransiting alloc] initWithOptionalDirectory:[directory copy]];
    }
    
    return self;
}


#pragma mark - WCSessionDelegate Methods

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message {
    for (NSString *identifier in message.allKeys) {
        NSData *data = message[identifier];
        
        NSString *filePath = [(MMWormholeSessionTransiting *)self.wormholeMessenger filePathForIdentifier:identifier];
        
        if (filePath) {
            [data writeToFile:filePath atomically:YES];
        }
        
        id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [self notifyListenerForMessageWithIdentifier:identifier message:messageObject];
    }
}

- (void)session:(nonnull WCSession *)session didReceiveFile:(nonnull WCSessionFile *)file {
    NSURL *fileURL = file.fileURL;
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    NSString *identifier = file.metadata[@"identifier"];
    
    [self notifyListenerForMessageWithIdentifier:identifier message:messageObject];
}

- (void)session:(nonnull WCSession *)session didFinishFileTransfer:(nonnull WCSessionFileTransfer *)fileTransfer error:(nullable NSError *)error {
    
}

@end

