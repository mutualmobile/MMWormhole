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

#import "MMWormholeCoordinatedFileTransiting.h"

@implementation MMWormholeCoordinatedFileTransiting

#pragma mark - MMWormholeTransiting Methods

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return NO;
    }
    
    if (messageObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
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
             success = [data writeToURL:newURL atomically:YES];
         }];
        
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
    
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
}

@end
