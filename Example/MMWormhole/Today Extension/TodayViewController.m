//
//  TodayViewController.m
//  Today Extension
//
//  Created by Conrad Stoll on 12/10/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "MMWormhole.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) MMWormhole *wormhole;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.mutualmobile.wormhole"
                                                         optionalDirectory:@"wormhole"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.preferredContentSize = CGSizeMake(320.0f, 40.0f);
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

// Pass messages each time a button is tapped using the identifier button
// The messages contain a single number value with the buttonNumber key
- (IBAction)didTapOne:(id)sender {
    [self.wormhole passMessageObject:@{@"buttonNumber" : @(1)} identifier:@"button"];
}

- (IBAction)didTapTwo:(id)sender {
    [self.wormhole passMessageObject:@{@"buttonNumber" : @(2)} identifier:@"button"];
}

@end
