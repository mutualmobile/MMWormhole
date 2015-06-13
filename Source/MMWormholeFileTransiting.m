//
// MMWormholeFileTransiting.m
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

#import <Foundation/Foundation.h>

#import "MMWormholeFileTransiting.h"

@interface MMWormholeFileTransiting ()

@property (nonatomic, copy) NSString *applicationGroupIdentifier;
@property (nonatomic, copy) NSString *directory;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation MMWormholeFileTransiting

- (instancetype)initWithApplicationGroupIdentifier:(NSString *)identifier
                       optionalDirectory:(nullable NSString *)directory {
    if ((self = [super init])) {
        _applicationGroupIdentifier = [identifier copy];
        _directory = [directory copy];
        _fileManager = [[NSFileManager alloc] init];
        
        [self checkAppGroupCapabilities];
    }
    
    return self;
}


#pragma mark - Private Check App Group Capabilities

- (void)checkAppGroupCapabilities {
    NSURL *appGroupContainer = [self.fileManager containerURLForSecurityApplicationGroupIdentifier:self.applicationGroupIdentifier];
    NSAssert(appGroupContainer != nil, @"App Group Capabilities may not be correctly configured for your project, or your appGroupIdentifier may not match your project settings. Check Project->Capabilities->App Groups. Three checkmarks should be displayed in the steps section, and the value passed in for your appGroupIdentifier should match the setting in your project file.");
}


#pragma mark - Private File Operation Methods

- (nullable NSString *)messagePassingDirectoryPath {
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

- (nullable NSString *)filePathForIdentifier:(nullable NSString *)identifier {
    if (identifier == nil || identifier.length == 0) {
        return nil;
    }
    
    NSString *directoryPath = [self messagePassingDirectoryPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.archive", identifier];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}


#pragma mark - Public Protocol Methods

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return NO;
    }
    
    if (messageObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
        NSString *filePath = [self filePathForIdentifier:identifier];
        
        if (data == nil || filePath == nil) {
            return NO;
        }
        
        BOOL success = [data writeToFile:filePath atomically:YES];
        
        if (!success) {
            return NO;
        }
    }
    
    return YES;
}

- (id<NSCoding>)messageObjectForIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[self filePathForIdentifier:identifier]];
    
    if (data == nil) {
        return nil;
    }
    
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
}

- (void)deleteContentForIdentifier:(NSString *)identifier {
    [self.fileManager removeItemAtPath:[self filePathForIdentifier:identifier] error:NULL];
}

- (void)deleteContentForAllMessages {
    if (self.directory != nil) {
        NSArray *messageFiles = [self.fileManager contentsOfDirectoryAtPath:[self messagePassingDirectoryPath] error:NULL];
        
        NSString *directoryPath = [self messagePassingDirectoryPath];
        
        for (NSString *path in messageFiles) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:path];
            
            [self.fileManager removeItemAtPath:filePath error:NULL];
        }
    }
}

@end
