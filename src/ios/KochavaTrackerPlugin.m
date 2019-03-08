//
//  KochavaTrackerPlugin.m
//  KochavaTracker (PhoneGap)
//
//  Copyright (c) 2013 - 2017 Kochava, Inc. All rights reserved.
//
//  Description : This is the plugin class implementation file.
//

#pragma mark - IMPORT

#import "KochavaTrackerPlugin.h"

#pragma mark - CONST

NSString *const KVA_PARAM_IOS_APP_GUID_STRING_KEY = @"iOSAppGUIDString";

#pragma mark - IMPLEMENTATION

@implementation KochavaTrackerPlugin

#pragma mark - GENERAL

// Decodes the attribution dictionary from the callback delegate or getter and returns a string.
+ (NSString *)decodeAttributionDictionary:(NSDictionary *)attributionDictionary {
    // Ensure it is json.
    if (attributionDictionary == nil || ![NSJSONSerialization isValidJSONObject:attributionDictionary])
    {
        return @"";
    }

    // Attempt to decode it into NSData.
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:attributionDictionary options:0 error:&error];
    if(!jsonData) {
        return @"";
    }

    // Convert the NSData into an NSString.
    NSString *attributionString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(attributionString == nil) {
        return @"";
    }

    // If it was valid return the string.
    return attributionString;
}

// Clears the running instance of the KochavaTracker so it is no longer rnning.
+ (void)invalidateKochava
{
    [KochavaTracker.shared performSelector:@selector(invalidate)];
}

// Removes all saved state for the KochavaTracer. Should call invalidate first.
+ (void)removeKochavaUserDefaults
{
    // Remove the NSUserDefaults keys.
    NSArray *keyArray = NSUserDefaults.standardUserDefaults.dictionaryRepresentation.allKeys;
    for (id key in keyArray)
    {
        NSRange kochavaPrefixRange = [key rangeOfString:@"com.kochava"];
        if ( kochavaPrefixRange.location != NSNotFound )
        {
            [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
        }
    }

    // Remove the deviceId backup file.
    NSURL *documentDirectoryURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *kochavaDirectoryURL = [documentDirectoryURL URLByAppendingPathComponent:@"com.kochava.KochavaTracker" isDirectory:true];
    NSURL *backupURL = [kochavaDirectoryURL URLByAppendingPathComponent:@"deviceIdString"];
    
    NSError *error = nil;
    [NSFileManager.defaultManager removeItemAtURL:backupURL error:&error];
}

- (void)sendEventString:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    // Decode the event name
    NSString *nameString = nil;
    id nameObject = [invokedUrlCommand.arguments objectAtIndex:0];
    if([nameObject isKindOfClass:NSString.class])
    {
        nameString = (NSString *)nameObject;
    }

    // Decode the event info
    NSString *infoString = nil;
    id infoObject = [invokedUrlCommand.arguments objectAtIndex:1];
    if([infoObject isKindOfClass:NSString.class])
    {
        infoString = (NSString *)infoObject;
    }
    // Enforce that infoString is never nil.
    if(infoString == nil)
    {
        infoString = @"";
    }
    
    // Only send the event if a valid (not nil or empty) event name was provided.
    if(nameString.length > 0)
    {
        [KochavaTracker.shared sendEventWithNameString:nameString infoString:infoString];
    } else
    {
        NSLog(@"KochavaTrackerPlugin.sendEventString input event name is invalid. Cannot send.");
    }
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)sendEventMapObject:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    // Decode the event name
    NSString *nameString = nil;
    id nameObject = [invokedUrlCommand.arguments objectAtIndex:0];
    if([nameObject isKindOfClass:NSString.class])
    {
        nameString = (NSString *)nameObject;
    }

    // Decode the infoDictionary
    NSDictionary *infoDictionary = nil;
    id infoObject = [invokedUrlCommand.arguments objectAtIndex:1];
    if([infoObject isKindOfClass:NSDictionary.class])
    {
        infoDictionary = (NSDictionary *)infoObject;
    }
    //Enforce that the info dictionary cannot be nil.
    if(infoDictionary == nil)
    {
        infoDictionary = [[NSDictionary alloc] init];
    }

    // Only send the event if a valid (not nil or empty) event name was provided.
    if(nameString.length > 0)
    {
        [KochavaTracker.shared sendEventWithNameString:nameString infoDictionary:infoDictionary];
    } else
    {
        NSLog(@"KochavaTrackerPlugin.sendEventMapObject input event name is invalid. Cannot send.");
    }
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)sendEventAppleAppStoreReceipt:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    // Decode the event name
    id nameObject = [invokedUrlCommand.arguments objectAtIndex:0];
    NSString *nameString = nil;
    if([nameObject isKindOfClass:NSString.class])
    {
        nameString = (NSString *)nameObject;
    }

    // Decode the infoDictionary
    id infoObject = [invokedUrlCommand.arguments objectAtIndex:1];
    NSDictionary *infoDictionary = nil;
    if([infoObject isKindOfClass:NSDictionary.class])
    {
        infoDictionary = (NSDictionary *)infoObject;
    }
    if(infoDictionary == nil)
    {
        infoDictionary = [[NSDictionary alloc] init];
    }

    // Decode the app store receipt
    id appStoreReceiptObject = [invokedUrlCommand.arguments objectAtIndex:2];
    NSString *appStoreReceiptBase64EncodedString = nil;
    if([appStoreReceiptObject isKindOfClass:NSString.class])
    {
        appStoreReceiptBase64EncodedString = (NSString *)appStoreReceiptObject;
    }

    // Only send the event if a valid (not nil or empty) event name was provided.
    if(nameString.length > 0)
    {
        // Build and send the Event
        KochavaEvent *event = [KochavaEvent eventWithEventTypeEnum:KochavaEventTypeEnumCustom];
        event.customEventNameString = nameString;
        event.infoDictionary = infoDictionary;
        event.appStoreReceiptBase64EncodedString = appStoreReceiptBase64EncodedString;
        [KochavaTracker.shared sendEvent:event];
    } else
    {
        NSLog(@"KochavaTrackerPlugin.sendEventAppleAppStoreReceipt input event name is invalid. Cannot send.");
    }
     
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)sendEventGooglePlayReceipt:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    NSLog(@"KOCHAVA - sendEventWithGooglePlayReceiptButton does not apply to this OS");
}

- (void)sendDeepLink:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    // Decode the url
    id deepLinkObject = [invokedUrlCommand.arguments objectAtIndex:0];
    NSString *deepLinkURLString = nil;
    if([deepLinkObject isKindOfClass:NSString.class])
    {
        deepLinkURLString = (NSString *)deepLinkObject;
    }

    // Decode the source app string
    id sourceApplicationObject = [invokedUrlCommand.arguments objectAtIndex:1];
    NSString *sourceApplicationString = nil;
    if([sourceApplicationObject isKindOfClass:NSString.class])
    {
        sourceApplicationString = (NSString *)sourceApplicationObject;
    }
    
    // Create and send the deeplink event.
    KochavaEvent *event = [KochavaEvent eventWithEventTypeEnum:KochavaEventTypeEnumDeepLink];
    event.uriString = deepLinkURLString;
    event.sourceString = sourceApplicationString;
    [KochavaTracker.shared sendEvent:event];
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)setAppLimitAdTracking:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    BOOL appLimitAdTrackingBool = [[invokedUrlCommand.arguments objectAtIndex:0] boolValue];
    [KochavaTracker.shared setAppLimitAdTrackingBool:appLimitAdTrackingBool];
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)setIdentityLink:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    id dictionaryObject = [invokedUrlCommand.arguments objectAtIndex:0];
    if([dictionaryObject isKindOfClass:NSDictionary.class])
    {
        NSDictionary *dictionary = (NSDictionary *)dictionaryObject;
        [KochavaTracker.shared sendIdentityLinkWithDictionary:dictionary];
    }

    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)getAttribution:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    NSDictionary *attributionDictionary = KochavaTracker.shared.attributionDictionary;
    NSString * attributionString = [KochavaTrackerPlugin decodeAttributionDictionary:attributionDictionary];
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:attributionString];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}
    
- (void)getDeviceId:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    NSString *deviceIdString = KochavaTracker.shared.deviceIdString;
    if(deviceIdString == nil)
    {
        deviceIdString = @"";
    }
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceIdString];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)getVersion:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    NSString *sdkVersionString = KochavaTracker.shared.sdkVersionString;
    if(sdkVersionString == nil)
    {
        sdkVersionString = @"";
    }
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:sdkVersionString];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)addPushToken:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    id tokenObject = [invokedUrlCommand.arguments objectAtIndex:0];
    if([tokenObject isKindOfClass:NSString.class])
    {
        NSString *tokenString = (NSString *)tokenObject;
        if(tokenString.length > 0)
        {
            NSData *tokenData = [self.class dataWithHexString:tokenString];
            [KochavaTracker.shared addRemoteNotificationsDeviceToken:tokenData];
        }
    }
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)removePushToken:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    id tokenObject = [invokedUrlCommand.arguments objectAtIndex:0];
    if([tokenObject isKindOfClass:NSString.class])
    {
        NSString *tokenString = (NSString *)tokenObject;
        if(tokenString.length > 0)
        {
            NSData *tokenData = [self.class dataWithHexString:tokenString];
            [KochavaTracker.shared removeRemoteNotificationsDeviceToken:tokenData];
        }
    }
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)setSleep:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    BOOL sleepBool = [[invokedUrlCommand.arguments objectAtIndex:0] boolValue];
    [KochavaTracker.shared setSleepBool:sleepBool];
}

- (void)getSleep:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    BOOL sleepBool = [KochavaTracker.shared sleepBool];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:sleepBool];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)setConsentGranted:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    id consentGrantedObject = [invokedUrlCommand.arguments objectAtIndex:0];
    if([consentGrantedObject isKindOfClass:NSNumber.class])
    {
        NSNumber *consentGranted = (NSNumber *)consentGrantedObject;
        if(consentGranted != nil)
        {
            [KochavaTracker.shared.consent didPromptWithDidGrantBoolNumber:consentGranted];
        }
    }

    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)setConsentRequired:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    BOOL consentRequiredBool = [[invokedUrlCommand.arguments objectAtIndex:0] boolValue];
    KochavaTracker.shared.consent.requiredBool = consentRequiredBool;
    
    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)setConsentPrompted:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    [KochavaTracker.shared.consent willPrompt];

    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

- (void)getConsentStatus:(nullable CDVInvokedUrlCommand *)invokedUrlCommand
{
    NSString *consentStatusString = nil;
    NSObject *consentAsForContextObject = [KochavaTracker.shared.consent kva_asForContextObjectWithContext:KVAContext.sdkWrapper];

    NSDictionary *consentDictionary = [consentAsForContextObject isKindOfClass:NSDictionary.class] ? (NSDictionary *)consentAsForContextObject : nil;
    if(consentDictionary != nil) {
        // ... modify key requirements_known, and ensure it will be a proper boolean when serialized to JSON. 
        // It should be possible to remove this block of code in iOS SDK 3.8.1 or later, following testing to confirm it is still represented as a boolean without it.
        NSMutableDictionary *consentMutableDictionary = consentDictionary.mutableCopy;
        NSObject *requirementsKnownObject = consentMutableDictionary[@"requirements_known"];
        NSNumber *requirementsKnownNumber = [requirementsKnownObject isKindOfClass:NSNumber.class] ? (NSNumber *)requirementsKnownObject : nil;
        consentMutableDictionary[@"requirements_known"] = requirementsKnownNumber.boolValue ? @(YES) : @(NO);
        consentAsForContextObject = consentMutableDictionary;
    } else {
        // The SDK is not started. Inject default values for all the keys.
        consentDictionary = @{
            @"description" : @"",
            @"required" : @(YES),
            @"granted" : @(NO),
            @"response_time" : @0,
            @"should_prompt" : @(NO),
            @"partners" : [[NSArray alloc] init],
            @"requirements_known" : @(NO)
        };
        consentAsForContextObject = consentDictionary;
    }

    if (consentAsForContextObject != nil)
    {
        NSError *error = nil;
        NSData *consentStatusJSONData = [NSJSONSerialization dataWithJSONObject:consentAsForContextObject options:0 error:&error];
        
        if (consentStatusJSONData != nil)
        {
            consentStatusString = [[NSString alloc] initWithData:consentStatusJSONData encoding:NSUTF8StringEncoding];
        }
    }
    
    if(consentStatusString == nil)
    {
        consentStatusString = @"{}";
    }

    // Respond with Result
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:consentStatusString];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

#pragma mark - LIFECYCLE
    
- (void)configure:(CDVInvokedUrlCommand *)invokedUrlCommand
{
    id receivedParametersDictionaryObject = [invokedUrlCommand.arguments objectAtIndex:0];

    NSDictionary *receivedParametersDictionary = nil;
    if ([receivedParametersDictionaryObject isKindOfClass:NSDictionary.class])
    {
        receivedParametersDictionary = (NSDictionary *)receivedParametersDictionaryObject;
    }
    
    // VALIDATION (RETURN)
    if (receivedParametersDictionary == nil)
    {
        NSLog(@"KochavaTrackerPlugin.configure parameter 0 is not an NSDictionary.  iOS native cannot initialize.");
        return;
    }

    // Check for the existence of the hidden unconfigure key.
    if ([receivedParametersDictionary objectForKey:@"INTERNAL_UNCONFIGURE"]) {
        NSLog(@"KochavaTrackerPlugin.configure UnConfigure.");
        [KochavaTrackerPlugin invalidateKochava];
        return;
    }

    // Check for the existence of the hidden reset key.
    if ([receivedParametersDictionary objectForKey:@"INTERNAL_RESET"]) {
        NSLog(@"KochavaTrackerPlugin.configure Reset.");
        [KochavaTrackerPlugin removeKochavaUserDefaults];
        return;
    }
    
    // PARSE SPECIFIC PARAMETERS FROM RECEIVEDPARAMETERSDICTIONARY
    id appGUIDStringObject = receivedParametersDictionary[KVA_PARAM_IOS_APP_GUID_STRING_KEY];
    
    // CONFIGURE TRACKER
    NSMutableDictionary *trackerParametersDictionary = receivedParametersDictionary.mutableCopy;

    // ... kKVAParamAppGUIDStringKey
    if (appGUIDStringObject != nil)
    {
        trackerParametersDictionary[kKVAParamAppGUIDStringKey] = appGUIDStringObject;
        trackerParametersDictionary[KVA_PARAM_IOS_APP_GUID_STRING_KEY] = nil;
    }

    //Retrieve post set items.
    BOOL sleepBool = [[trackerParametersDictionary objectForKey:@"sleepBool"] boolValue];
    trackerParametersDictionary[@"sleepBool"] = nil;

    [KochavaTracker.shared configureWithParametersDictionary:trackerParametersDictionary delegate:self];

    //Check for sleep.
    if(sleepBool) {
        [KochavaTracker.shared setSleepBool:sleepBool];
    }

    //Check if intelligent consent management is on and apply as necessary.
    BOOL intelligentManagementBool = [[trackerParametersDictionary objectForKey:@"consentIntelligentManagement"] boolValue];
    if(intelligentManagementBool) {
        KochavaTracker.shared.consent.didUpdateBlock = ^(KVAConsent * _Nonnull consent)
        {
            NSString *javaScriptString = [NSString stringWithFormat:@"window.consentStatusChangeNotification.notificationCallback('');"];
            if ([self.webView isKindOfClass:[UIWebView class]])
            {
                UIWebView *webView = (UIWebView*)self.webView;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [webView stringByEvaluatingJavaScriptFromString:javaScriptString];
                });
            }
        };
    }
    
}
    
#pragma mark - DELEGATE CALLBACKS
#pragma mark KochavaTrackerDelegate
     
- (void)tracker:(nonnull KochavaTracker *)tracker didRetrieveAttributionDictionary:(nonnull NSDictionary *)attributionDictionary
{
    NSString * attributionBase64 = @"";
    NSString * attributionString = [KochavaTrackerPlugin decodeAttributionDictionary:attributionDictionary];
    NSData *attributionNsData = [attributionString dataUsingEncoding:NSUTF8StringEncoding];
    if(attributionNsData != nil) {
        attributionBase64 = [attributionNsData base64EncodedStringWithOptions:0];
    }
    if(attributionBase64 == nil) {
        attributionBase64 = @"";
    }
    NSString *javaScriptString = [NSString stringWithFormat:@"window.attributionNotification.notificationCallback('%@');",attributionBase64];
    if ([self.webView isKindOfClass:[UIWebView class]])
    {
        UIWebView *webView = (UIWebView*)self.webView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        });
    }
}

#pragma mark - CLASS METHODS

+(id)dataWithHexString:(NSString *)hexString
{
    // Discussion:  This is being employed to take the output of an NSData description (which is a hex string, such as is the case with a push notification token) and turn it back into an NSData.  This was sourced from the web and then optimized.

    // VALIDATION (RETURN)
    // hexString
    // ... must not be nil
    if (hexString == nil)
    {
        return nil;
    }
    
    // hexStringLength
    // ... must be an even number of digits
    NSUInteger hexStringLength = hexString.length;
    if (hexStringLength % 2 > 0)
    {
        NSLog(@"Warning:  func dataWithHexString(_:) - parameter hexString was passed a value which does not have an even number of digits.  hexString = %@", hexString);
        return nil;
    }

    // Must contain only valid HEX characters.
    NSCharacterSet *chars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"] invertedSet];
    BOOL isValid = (NSNotFound == [hexString rangeOfCharacterFromSet:chars].location);
    if(!isValid) {
        NSLog(@"Warning:  func dataWithHexString(_:) - parameter hexString was passed a value which was not valid HEX. hexString = %@", hexString);
        return nil;
    }
    
    // MAIN
    // bytes and bytesPointer
    // ... default to point to some newly allocated memory
    unsigned char *bytes = (unsigned char *)malloc(hexStringLength / 2);
    unsigned char *bytesPointer = bytes;

    // ... fill with long(s) converted from two-digit strings containing base-16 representations of numbers
    for (CFIndex index = 0; index < hexStringLength; index += 2)
    {
        // buffer
        // ... set to the two-digit base 16 number located at index
        char buffer[3];
        buffer[0] = (char)[hexString characterAtIndex:index];
        buffer[1] = (char)[hexString characterAtIndex:index + 1];
        buffer[2] = '\0';

        // longInt and endPointer
        // ... set longInt to buffer converted to a long, and set endPointer to the next character in buffer after the numerical value.
        char *endPointer = NULL;
        
        long int longInt = strtol(buffer, &endPointer, 16);

        // bytesPointer
        // ... update with longInt
        *bytesPointer = (unsigned char)longInt;

        // ... advance to next position
        bytesPointer++;
    }
    
    // return
    return [NSData dataWithBytesNoCopy:bytes length:(hexStringLength / 2) freeWhenDone:YES];
}

@end
