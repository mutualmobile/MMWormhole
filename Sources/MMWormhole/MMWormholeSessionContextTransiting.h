//
// MMWormholeSessionContextTransiting.h
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
 This class provides support for the WatchConnectivity framework's Application Context message
 reading and writing ability. This class will pass it's messages directly via the
 -updateApplicationContext method, and read message values from application context.
 
 This class also uses a local mutable dictionary for maintaining a more consistent version of your
 wormhole-based application context. The contents of the local dictionary are merged with the
 application context for passing messages. Clearing message contents on a wormhole using this
 transiting implementation will clear both the applicationContext as well as the local mutable
 dictionary.
 
 @discussion This class should be treated as the default MMWormholeTransiting implementation for
 applications wanting to leverage the WatchConnectivity framework within MMWormhole. The application
 context provides the best of both real time message passing and baked in state persistence for
 setting up your UI.
 */
@interface MMWormholeSessionContextTransiting : MMWormholeFileTransiting

@end
