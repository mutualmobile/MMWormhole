//
//  InterfaceController.m
//  watchOS Extension
//
//  Created by Conrad Stoll on 6/8/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

#import "InterfaceController.h"

#import "MMWormhole.h"
#import "MMWormholeSession.h"

@interface InterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) MMWormholeSession *listeningWormhole;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *selectionLabel;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // You are required to initialize the shared listening wormhole before creating a
    // WatchConnectivity session transiting wormhole, as we are below.
    self.listeningWormhole = [MMWormholeSession sharedListeningSession];
    
    // Initialize the wormhole
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.mutualmobile.wormhole"
                                                         optionalDirectory:@"wormhole"
                                                            transitingType:MMWormholeTransitingTypeSessionContext];

    // Obtain an initial value for the selection message from the wormhole
    id messageObject = [self.wormhole messageWithIdentifier:@"selection"];
    NSString *string = [messageObject valueForKey:@"selectionString"];
    
    if (string != nil) {
        [self.selectionLabel setText:string];
    }
    
    // Listen for changes to the selection message. The selection message contains a string value
    // identified by the selectionString key. Note that the type of the key is included in the
    // name of the key.
    [self.listeningWormhole listenForMessageWithIdentifier:@"selection" listener:^(id messageObject) {
        NSString *string = [messageObject valueForKey:@"selectionString"];
        
        if (string != nil) {
            [self.selectionLabel setText:string];
        }
    }];
    
    // Make sure we are activating the listening wormhole so that it will receive new messages from
    // the WatchConnectivity framework.
    [self.listeningWormhole activateSessionListening];
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



