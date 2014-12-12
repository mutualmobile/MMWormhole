//
//  ViewController.m
//  MMWormhole
//
//  Created by Conrad Stoll on 12/6/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import "ViewController.h"

#import "MMWormhole.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) MMWormhole *wormhole;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize the wormhole
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.mutualmobile.wormhole"
                                                         optionalDirectory:@"wormhole"];
    
    // Obtain an initial message from the wormhole
    id messageObject = [self.wormhole messageWithIdentifier:@"button"];
    NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
    
    self.numberLabel.text = [number stringValue];
    
    // Become a listener for changes to the wormhole for the button message
    [self.wormhole listenForMessageWithIdentifier:@"button" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
        self.numberLabel.text = [number stringValue];
    }];
    
    [self segmentedControlValueDidChange:self.segmentedControl];
}

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segmentedControl {
    NSString *title = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    
    // Pass a message for the selection identifier. The message itself is a NSCoding compliant object
    // with a single value and key called selectionString.
    [self.wormhole passMessageObject:@{@"selectionString" : title} identifier:@"selection"];
}

@end
