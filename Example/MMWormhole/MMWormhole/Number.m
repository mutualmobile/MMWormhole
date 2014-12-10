//
//  Number.m
//  MMWormhole
//
//  Created by Conrad Stoll on 12/10/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import "Number.h"

@implementation Number

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.number = [decoder decodeObjectForKey:@"number"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.number forKey:@"number"];
}

@end
