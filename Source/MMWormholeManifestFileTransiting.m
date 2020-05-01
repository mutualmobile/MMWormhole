//
// MMWormholeCoordinatedFileTransiting.h
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

#import "MMWormholeManifestFileTransiting.h"

@implementation MMWormholeManifestFileTransiting

#pragma mark - MMWormholeTransiting Methods

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return NO;
    }
    
    if (messageObject) {
        //Insert into manifest
        NSMutableArray *storageArray = nil;
        NSArray *potentialOnDiskArray = (NSArray *)[self _arrayForIdentifier:identifier];
        //Covers edge cases where a crash can occur when changing to using this transit style from other styles
        if ([potentialOnDiskArray isKindOfClass:[NSArray class]]) {
            storageArray = [NSMutableArray arrayWithArray:potentialOnDiskArray];
        } else {
            storageArray = [[NSMutableArray alloc] init];
        }
        [storageArray addObject:messageObject];
        
        //Encode manifest instead of message object
        BOOL success = [self _writeArrayToDisk:storageArray forIdentifier:identifier];
        
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
    
    NSArray *storageArray = [self _arrayForIdentifier:identifier];
    if ([storageArray count] == 0) {
        return nil;
    }
    id messageObject = storageArray[0];
    NSMutableArray *arrayToWrite = [NSMutableArray arrayWithArray:storageArray];
    [arrayToWrite removeObjectAtIndex:0];
    
    //TODO: What to do if this fails?
    [self _writeArrayToDisk:arrayToWrite forIdentifier:identifier];
    
    return messageObject;
}


- (NSInteger)numberOfMessageItemsforIdentifier:(NSString *)identifier {
    NSArray *array = [self _arrayForIdentifier:identifier];
    if ([array isKindOfClass:[NSArray class]]) {
        return array.count;
    }
    return 0;
}

#pragma mark - Helper Methods

- (BOOL)_writeArrayToDisk:(NSArray *)array forIdentifier:(NSString *)identifier{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    NSString *filePath = [self filePathForIdentifier:identifier];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (data == nil || filePath == nil || fileURL == nil) {
        return NO;
    }
    
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    __block BOOL success = NO;
    
    [fileCoordinator
     coordinateWritingItemAtURL:fileURL
     options:0
     error:&error
     byAccessor:^(NSURL *newURL) {
         NSError *writeError = nil;
         
         success = [data writeToURL:newURL
                            options:NSDataWritingAtomic | self.additionalFileWritingOptions
                              error:&writeError];
     }];
    
    return success;
}

- (nullable NSArray*)_arrayForIdentifier:(NSString *)identifier{
    if (identifier == nil) {
        return nil;
    }
    
    NSString *filePath = [self filePathForIdentifier:identifier];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (filePath == nil || fileURL == nil) {
        return nil;
    }
    
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    __block NSData *data = nil;
    
    [fileCoordinator
     coordinateReadingItemAtURL:fileURL
     options:0
     error:&error
     byAccessor:^(NSURL *newURL) {
         data = [NSData dataWithContentsOfURL:newURL];
     }];
    
    if (data == nil) {
        return nil;
    }
    
    //Arguably unsafe as something else could change us on disk
    //TODO: utilize encrypted container with NSSecureCoding to avoid above
    NSArray *storageArray = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return storageArray;
}

@end
