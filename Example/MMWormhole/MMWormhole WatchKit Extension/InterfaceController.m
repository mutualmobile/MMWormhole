//
//  InterfaceController.m
//  MMWormhole WatchKit Extension
//
//  Created by Conrad Stoll on 12/6/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import "InterfaceController.h"

#import "MMWormhole.h"

@interface InterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *selectionLabel;
@end


@implementation InterfaceController

//
// Change for compatibility with XCode 6.2 Beta 3
// The WKInterfaceController method initWithContext: has been deprecated.
// Please use awakeWithContext: instead.
//
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Initialize the wormhole
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.mutualmobile.wormhole"
                                                         optionalDirectory:@"wormhole"];
        
    // Obtain an initial value for the selection message from the wormhole
    id messageObject = [self.wormhole messageWithIdentifier:@"selection"];
    NSString *string = [messageObject valueForKey:@"selectionString"];
        
    if (string != nil) {
        [self.selectionLabel setText:string];
    }
        
    // Listen for changes to the selection message. The selection message contains a string value
    // identified by the selectionString key. Note that the type of the key is included in the
    // name of the key.
    [self.wormhole listenForMessageWithIdentifier:@"selection" listener:^(id messageObject) {
        NSString *string = [messageObject valueForKey:@"selectionString"];
        
        if (string != nil) {
            [self.selectionLabel setText:string];
        }
    }];
}


// Pass messages each time a button is tapped using the identifier button
// The messages contain a single number value with the buttonNumber key
- (IBAction)didTapOne:(id)sender {
    [self.wormhole passMessageObject:@{@"buttonNumber" : @(1)} identifier:@"button"];
}

- (IBAction)didTapTwo:(id)sender {
    [self.wormhole passMessageObject:@{@"buttonNumber" : @(2)} identifier:@"button"];
}

- (IBAction)didTapThree:(id)sender {
    [self.wormhole passMessageObject:@{@"buttonNumber" : @(3)} identifier:@"button"];
}

@end



