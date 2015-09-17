##[2.0.0](https://github.com/mutualmobile/MMWormhole/milestones/2.0.0) (Tuesday, September 15th, 2015)
**NEW**
* Added support for the WatchConnectivity framework. (Conrad Stoll)

**Fixed**
* **FIXED** an issue ([#53](https://github.com/mutualmobile/MMWormhole/pull/53)) with an assertion warning on release builds. (Timothy Sanders)
* **FIXED** an issue ([#59](https://github.com/mutualmobile/MMWormhole/pull/59)) with the Carthage build configuration. (Thomas Guthrie, Stephen Wu)


##[1.2.0](https://github.com/mutualmobile/MMWormhole/milestones/1.2.0) (Tuesday, June 2nd, 2015)
**NEW**
* Added support for sending a notification by passing nil as the message. (Felix Lamouroux)
* Added support for Carthage dependency management. (Lei Wang)
* Added support for subclassing MMWormhole's message passing system via MMWormholeTransiting. (Conrad Stoll)
* Added support for NSFileCoordinator message file writing. (Conrad Stoll
* Added new troubleshooting checks for App Group configuration. (Ernesto Torres)
* Added nullability annotations for better Swift support. (Timothy Sanders)
* Silenced a c function declaration warning. (Wes Ostler)
* Updated README to include Swift examples. (Nate McGuire)

**Fixed**
* **FIXED** an issue ([#36](https://github.com/mutualmobile/MMWormhole/pull/36)) where a listener block could be called multiple times. (Naldikt)
* **FIXED** an issue ([#43](https://github.com/mutualmobile/MMWormhole/issues/43)) where a listener block could be registered and called multiple times. (Peter De Bock)
* **FIXED** a typo in the README. (Marcus Mattsson)


##[1.1.1](https://github.com/mutualmobile/MMWormhole/milestones/1.1.1) (Friday, February 13th, 2015)
**NEW**
* Added support for OS X in CocoaPods. (ConfusedVorlon)
* Cleaned up the public headers and init method. (Jérôme Morissard)
* Removed duplicated space. (Christian Sampaio)
* Updated for latest beta of WatchKit. (Fadhel Chaabane)


##[1.1.0](https://github.com/mutualmobile/MMWormhole/milestones/1.1.0) (Saturday, December 13th, 2014)
**NEW**
* Added support for iOS 7 deployment targets. (Orta Therox)
* Added full support for NSCoding and NSKeyedArchiver. (Martin Blech)
* Added Unit Tests! (Conrad Stoll)

**Fixed**
* **FIXED** an issue([#6](https://github.com/mutualmobile/MMWormhole/pull/6)) where clear all message contents wasn't working properly. (Conrad Stoll)


##1.0.0 (Monday, December 8th, 2014)
 * Initial Library Release