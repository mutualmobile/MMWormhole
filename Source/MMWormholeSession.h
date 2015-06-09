//
//  MMWormholeSession.h
//  MMWormhole
//
//  Created by Conrad Stoll on 6/9/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

#import "MMWormhole.h"

@interface MMWormholeSession : MMWormhole

/**
 Designated Initializer. This method may be called with an optional directory name for messages to 
 be read and written. Messages will be stored in this directory after they received. The root of the
 directory will be the application's documents directory.
 
 @param directory An optional directory to read/write messages
 */
- (nullable instancetype)initWithOptionalDirectory:(nullable NSString *)directory NS_DESIGNATED_INITIALIZER;

@end
