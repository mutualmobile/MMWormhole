//
// MMWormholeFileTransiting.h
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

#import "MMWormhole.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 This class is a default implementation of the MMWormholeTransiting protocol that implements
 message transiting by archiving and unarchiving messages that are written and read to files on
 disk in an optional directory in the given app group. This default implementation has a relatively
 naive implementation of file writing, and simply uses the built in NSData file operations.
 
 This class is able to be subclassed to provide slightly different file reading and writing behavior
 while still maintaining the logic for naming a file within the given directory and app group.
 */
@interface MMWormholeFileTransiting : NSObject <MMWormholeTransiting>

/**
 Designated Initializer. This method must be called with an application group identifier that will
 be used to contain passed messages. It is also recommended that you include a directory name for
 messages to be read and written, but this parameter is optional.
 
 @param identifier An application group identifier
 @param directory An optional directory to read/write messages
 */
- (instancetype)initWithApplicationGroupIdentifier:(NSString *)identifier
                                 optionalDirectory:(nullable NSString *)directory NS_DESIGNATED_INITIALIZER;

/**
 This method returns the full file path for the message passing directory, including the optional
 directory passed in the designated initializer. Subclasses can use this method to provide custom
 implementations.
 
 @return The full path to the message passing directory.
 */
- (nullable NSString *)messagePassingDirectoryPath;

/**
 This method returns the full file path for the file associated with the given message identifier. 
 It includes the optional directory passed in the designated initializer if there is one. Subclasses 
 can use this method to provide custom implementations.
 
 @return The full path to the file associated with the given message identifier.
 */
- (nullable NSString *)filePathForIdentifier:(nullable NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
