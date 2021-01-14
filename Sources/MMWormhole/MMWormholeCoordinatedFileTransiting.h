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

#import "MMWormholeFileTransiting.h"

/**
 This class inherits from the default implementation of the MMWormholeTransiting protocol 
 and implements message transiting in a similar way but using NSFileCoordinator for its file
 reading and writing.
 */
@interface MMWormholeCoordinatedFileTransiting : MMWormholeFileTransiting

/**
 The default file writing option is NSDataWritingAtomic. It may be important for your app to use
 additional file writing options to control the specific data protection class for message files
 being written by your application. When you create your file transiting object, set this property
 to the additional writing options you want to use.
 */
@property (nonatomic, assign) NSDataWritingOptions additionalFileWritingOptions;

@end
