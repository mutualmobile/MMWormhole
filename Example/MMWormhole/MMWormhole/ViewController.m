//
//  ViewController.m
//  MMWormhole
//
//  Created by Conrad Stoll on 12/6/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import "ViewController.h"

#import "MMWormhole.h"
#import "MMWormholeSession.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) MMWormhole *traditionalWormhole;
@property (nonatomic, strong) MMWormhole *watchConnectivityWormhole;
@property (nonatomic, strong) MMWormholeSession *watchConnectivityListeningWormhole;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize the wormhole
    self.traditionalWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.mutualmobile.wormhole"
                                                                    optionalDirectory:@"wormhole"];
    
    // Initialize the MMWormholeSession listening wormhole.
    // You are required to do this before creating a Wormhole with the Session Transiting Type, as we are below.
    self.watchConnectivityListeningWormhole = [MMWormholeSession sharedListeningSession];
    
    // Initialize the wormhole using the WatchConnectivity framework's application context transiting type
    self.watchConnectivityWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.mutualmobile.wormhole"
                                                                          optionalDirectory:@"wormhole"
                                                                             transitingType:MMWormholeTransitingTypeSessionContext];
    
    // Become a listener for changes to the wormhole for the button message
    [self.traditionalWormhole listenForMessageWithIdentifier:@"button" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
        self.numberLabel.text = [number stringValue];
    }];
    
    // Become a listener for changes to the wormhole for the button message
    [self.watchConnectivityListeningWormhole listenForMessageWithIdentifier:@"button" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
        self.numberLabel.text = [number stringValue];
    }];
    
    // Make sure we are activating the listening wormhole so that it will receive new messages from
    // the WatchConnectivity framework.
    [self.watchConnectivityListeningWormhole activateSessionListening];
    
    [self segmentedControlValueDidChange:self.segmentedControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Obtain an initial message from the wormhole
    id messageObject = [self.traditionalWormhole messageWithIdentifier:@"button"];
    NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
    
    self.numberLabel.text = [number stringValue];
    
    // Obtain an initial message from the wormhole
    messageObject = [self.watchConnectivityWormhole messageWithIdentifier:@"button"];
    number = [messageObject valueForKey:@"buttonNumber"];
    
    self.numberLabel.text = [number stringValue];
}

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segmentedControl {
    NSString *title = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    
    // Pass a message for the selection identifier. The message itself is a NSCoding compliant object
    // with a single value and key called selectionString.
    [self.traditionalWormhole passMessageObject:@{@"selectionString" : title} identifier:@"selection"];
    [self.watchConnectivityWormhole passMessageObject:@{@"selectionString" : title} identifier:@"selection"];
}

@end
