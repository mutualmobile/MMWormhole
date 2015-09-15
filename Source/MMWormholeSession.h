//
// MMWormholeSession.h
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

#import <WatchConnectivity/WatchConnectivity.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMWormholeSession : MMWormhole <WCSessionDelegate>

/**
 This method returns a specific instance of MMWormholeSession that should be used for listening. You
 may create your own instances of MMWormholeSession for sending messages, but this is the only object
 that will be able to receive messages.
 
 The reason for this is that MMWormholeSession is based on the WCSession class that is part of the
 WatchConnectivity framework provided by Apple, and WCSession is itself a singleton with a single
 delegate. Therefore, to receive callbacks, only one MMWormholeSession object may register itself
 as a listener.
 */
+ (instancetype)sharedListeningSession;

/**
 This method should be called after all of your initial listeners have been set and you are ready to
 begin listening for messages. There are likely some listeners that your application requires to be
 active so that it won't miss critical messages. You should set up these listeners before calling
 this method so that any already queued messages will be delivered immediately when you activate the
 session. Any listeners you set up after calling this method may miss messages that were already
 queued and waiting to be delivered.
 */
- (void)activateSessionListening;

@end

NS_ASSUME_NONNULL_END