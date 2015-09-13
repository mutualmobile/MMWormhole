//
// MMWormholeSessionMessageTransiting.h
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


#import "MMWormholeFileTransiting.h"

/**
 This class provides support for the WatchConnectivity framework's real time message passing ability.
 This is the only version of the MMWormholeSessionTransiting system that will be able to wake up 
 your iPhone app in the background. As such, this class has a very specific purpose. It also means
 that it will most likely be used only by your Apple Watch app, or in very very specific instances
 by your iPhone app. Typically, your iPhone app will want to use the 
 MMWormholeSessionContextTransiting option instead.
 
 @warning Waking up the iPhone app from a Watch app is an expensive operation. You should only use
 this transiting implementation when this action is required for your application. Otherwise you are
 better served by using the MMWormholeSessionContextTransiting implementation.
 
 @warning This transiting implementation does not support reading message contents because real time
 messages are delivered once and not persisted.
 
 @discussion This class should be used in cases where your Apple Watch app needs to ensure your
 iPhone app is running to receive a message and take some action on it. One example of this would be
 to start background location tracking or audio.
 */
@interface MMWormholeSessionMessageTransiting : MMWormholeFileTransiting

@end
