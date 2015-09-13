//
// MMWormholeTransiting.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 This protocol defines the public interface for classes wishing to support the transiting of data
 between two sides of the wormhole. Transiting is defined as passage between two points, and in this
 case it involves both the reading and writing of messages as well as the deletion of message
 contents.
 */
@protocol MMWormholeTransiting <NSObject>

/**
 This method is responsible for writing a given message object in a persisted format for a given
 identifier. The method should return YES if the message was successfully saved. The message object
 may be nil, in which case YES should also be returned. Returning YES from this method results in a
 notification being fired which will trigger the corresponding listener block for the given
 identifier.
 
 @param messageObject The message object to be passed.
 This object may be nil. In this the method should return YES.
 @param identifier The identifier for the message
 @return YES indicating that a notification should be sent and NO otherwise
 */
- (BOOL)writeMessageObject:(nullable id<NSCoding>)messageObject forIdentifier:(NSString *)identifier;

/**
 This method is responsible for reading and returning the contents of a given message. It should
 understand the structure of messages saved by the implementation of the above writeMessageObject
 method and be able to read those messages and return their contents.
 
 @param identifier The identifier for the message
 */
- (nullable id<NSCoding>)messageObjectForIdentifier:(nullable NSString *)identifier;

/**
 This method should clear the persisted contents of a specific message with a given identifier.
 
 @param identifier The identifier for the message
 */
- (void)deleteContentForIdentifier:(nullable NSString *)identifier;

/**
 This method should clear the contents of all messages passed to the wormhole.
 */
- (void)deleteContentForAllMessages;

@end

@protocol MMWormholeTransitingDelegate <NSObject>

- (void)notifyListenerForMessageWithIdentifier:(nullable NSString *)identifier message:(nullable id<NSCoding>)message;

@end

NS_ASSUME_NONNULL_END