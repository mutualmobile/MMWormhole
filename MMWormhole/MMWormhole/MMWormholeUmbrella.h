//
//  MMWormhole.h
//  MMWormhole
//
//  Created by LEI on 5/11/15.
//  Copyright (c) 2015 MMWormhole. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for MMWormhole.
FOUNDATION_EXPORT double MMWormholeVersionNumber;

//! Project version string for MMWormhole.
FOUNDATION_EXPORT const unsigned char MMWormholeVersionString[];

#import <MMWormhole/MMWormhole.h>
#import <MMWormhole/MMWormholeFileTransiting.h>
#import <MMWormhole/MMWormholeCoordinatedFileTransiting.h>

#if ( ( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000 ) || TARGET_OS_WATCH )
#import <MMWormhole/MMWormholeSession.h>
#import <MMWormhole/MMWormholeSessionContextTransiting.h>
#import <MMWormhole/MMWormholeSessionFileTransiting.h>
#import <MMWormhole/MMWormholeSessionMessageTransiting.h>
#endif

#import <MMWormhole/MMWormholeTransiting.h>