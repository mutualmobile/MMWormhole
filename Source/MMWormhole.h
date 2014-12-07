//
//  MMWormhole.h
//  MMWormhole
//
//  Created by Conrad Stoll on 12/6/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class creates a wormhole between a containing iOS application and an extension. The wormhole
 is meant to be used to pass data or commands back and forth between the two locations. The effect
 closely resembles interprocess communication between the app and the extension, though this is not
 really the case. The wormhole does have some disadvantages, including the fact that a contract must
 be determined in advance between the app and the extension that defines the interchange format.
 
 Passing a message to the wormhole can be inferred as a data transfer package or as a command. In
 both cases, the passed message is written as a JSON object to a .json file named with the
 included identifier. As a data transfer, the contents of written .json file can be queried using
 the messageWithIdentifier: method. As a command, the simple existence of the message in the shared
 app group should be taken as proof of the command's invocation. The contents of the message then
 become parameters to be evaluated along with the command. Of course, to avoid confusion later, it
 may be best to clear the contents of the message after recognizing the command. The
 -clearMessageContentsForIdentifier: method is provided for this purpose.
 
 A good wormhole includes wormhole aliens who listen for message changes. This class supports 
 CFNotificationCenter Darwin Notifications, which act as a bridge between the containing app and the
 extension. When a message is passed with an identifier, a notification is fired to the Darwin 
 Notification Center with the given identifier. If you have indicated your interest in the message
 by using the -listenForMessageWithIdentifier:completion: method then your completion block will be
 called when this notification is received, and the contents of the message will be passed as a JSON
 object to the completion block.
 
 It's worth noting that as a best practice to avoid confusing issues or deadlock that messages
 should be passed one way only for a given identifier. The containing app should pass messages to
 one set of identifiers, which are only ever read or listened for by the extension, and vic versa.
 The extension should not then write messages back to the same identifier. Instead, the extension
 should use it's own set of identifiers to associate with it's messages back to the application.
 Passing messages to the same identifier from two locations should be done only at your own risk.
 */
@interface MMWormhole : NSObject

/**
 Designated Initializer. This method must be called with an application group identifier that will
 be used to contain passed messages. It is also recommended that you include a directory name for
 messages to be read and written, but this parameter is optional.
 
 @param identifier An application group identifier
 @param directory An optional directory to read/write messages
 */
- (instancetype)initWithApplicationGroupIdentifier:(NSString *)identifier
                                 optionalDirectory:(NSString *)directory;

/**
 This method passes a message object associated with a given identifier. This is the primary means
 of passing information through the wormhole.
 
 @param messageobject The JSON message object to be passed
 @param identifier The identifier for the message
 */
- (void)passMessageObject:(id)messageObject identifier:(NSString *)identifier;

/**
 This method returns the value of a message with a specific identifier as a JSON object.
 
 @param identifier The identifier for the message
 */
- (id)messageWithIdentifier:(NSString *)identifier;

/**
 This method clears the contents of a specific message with a given identifier.
 
 @param identifier The identifier for the message
 */
- (void)clearMessageContentsForIdentifier:(NSString *)identifier;

/**
 This method begins listening for notifications of changes to a message with a specific identifier.
 If notifications are observed then the given completion block will be called along with the actual
 message as a JSON object.
 
 @param identifier The identifier for the message
 @param completion A completion block called with the JSON messageObject parameter
 */
- (void)listenForMessageWithIdentifier:(NSString *)identifier
                            completion:(void (^)(id messageObject))completion;

/**
 This method stops listening for change notifications for a given message identifier.
 
 NOTE: This method is NOT required to be called. If the wormhole is deallocated then all listeners
 will go away as well.
 
 @param identifier The identifier for the message
 */
- (void)stopListeningForMessageWithIdentifier:(NSString *)identifier;

@end
