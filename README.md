MMWormhole creates a wormhole between a containing iOS application and an extension. The wormhole is meant to be used to pass data or commands back and forth between the two locations. The effect closely resembles interprocess communication between the app and the extension, though this is not really the case. The wormhole supports CFNotificationCenter Darwin Notifications, which act as a bridge between the containing app and the extension. When a message is passed to the wormhole, interested parties can listen and be notified of these changes on either side due to these notifications.


```objective-c
[self.wormhole passMessageObject:@{@"buttonNumber" : @(1)} identifier:@"button"];

[self.wormhole 
listenForMessageWithIdentifier:@"button" 
completion:^(id messageObject) {
    self.numberLabel.text = [messageObject[@"buttonNumber"] stringValue];
}];
```

