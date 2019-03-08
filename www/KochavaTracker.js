
/*
 * File Name  : KochavaTracker.js
 * Author     : Kochava
 * Description : This file initiates calls to the native library from the plugin
 */

//Internal function that sends a command to the native layer.
function cordovaExecCommand(command) {
    var args = Array.prototype.slice.call(arguments, 1);
    cordova.exec(function callback(data) { },
        function errorHandler(err) { },
        'KochavaTrackerPlugin',
        command,
        args
    );
}

//Internal function that sends a command to the native layer and includes a callback.
function cordovaExecCommandCallback(command, callback) {
    var args = Array.prototype.slice.call(arguments, 2);
    cordova.exec(callback,
        function errorHandler(err) { },
        'KochavaTrackerPlugin',
        command,
        args
    );
}

//Keep track of the event listener references.
var kochavaTrackerAttributionEventListener = null;
var kochavaTrackerConsentStatusChangeEventListener = null;

//KochavaTracker SDK Entrypoint.
var KochavaTracker = {

    // Config Parameters
    PARAM_ANDROID_APP_GUID_STRING_KEY: "androidAppGUIDString",
    PARAM_IOS_APP_GUID_STRING_KEY: "iOSAppGUIDString",
    PARAM_PARTNER_NAME_STRING_KEY: "partnerName",
    PARAM_APP_LIMIT_AD_TRACKING_BOOL_KEY: "limitAdTracking",
    PARAM_IDENTITY_LINK_MAP_OBJECT_KEY: "identityLink",
    PARAM_IDENTITY_LINK_DICTIONARY_KEY: "identityLink", //Deprecated key
    PARAM_LOG_LEVEL_ENUM_KEY: "logLevelEnum",
    PARAM_RETRIEVE_ATTRIBUTION_BOOL_KEY: "retrieveAttribution",
    PARAM_INTELLIGENT_CONSENT_MANAGEMENT_BOOL_KEY: "consentIntelligentManagement",
    PARAM_MANUAL_MANAGED_CONSENT_REQUIREMENTS_BOOL_KEY: "consentManualManagedRequirements",
    PARAM_SLEEP_BOOL_KEY: "sleepBool",

    // Log level values
    LOG_LEVEL_ENUM_NONE_VALUE: "none",
    LOG_LEVEL_ENUM_ERROR_VALUE: "error",
    LOG_LEVEL_ENUM_WARN_VALUE: "warn",
    LOG_LEVEL_ENUM_INFO_VALUE: "info",
    LOG_LEVEL_ENUM_DEBUG_VALUE: "debug",
    LOG_LEVEL_ENUM_TRACE_VALUE: "trace",

    // Consent Status Key Strings
    CONSENT_STATUS_DESCRIPTION_STRING_KEY: "description",
    CONSENT_STATUS_REQUIRED_BOOL_KEY: "required",
    CONSENT_STATUS_GRANTED_BOOL_KEY: "granted",
    CONSENT_STATUS_SHOULD_PROMPT_BOOL_KEY: "should_prompt",
    CONSENT_STATUS_RESPONSE_TIME_LONG_KEY: "response_time",
    CONSENT_STATUS_PARTNERS_KEY: "partners",
    CONSENT_STATUS_PARTNER_NAME_STRING_KEY: "name",
    CONSENT_STATUS_REQUIREMENTS_KNOWN_BOOL_KEY: "requirements_known",

    // Standard Event Types
    // For standard parameters and expected usage see: https://support.kochava.com/reference-information/post-install-event-examples/
    EVENT_TYPE_ACHIEVEMENT_STRING_KEY: "Achievement",
    EVENT_TYPE_ADD_TO_CART_STRING_KEY: "Add to Cart",
    EVENT_TYPE_ADD_TO_WISH_LIST_STRING_KEY: "Add to Wish List",
    EVENT_TYPE_CHECKOUT_START_STRING_KEY: "Checkout Start",
    EVENT_TYPE_LEVEL_COMPLETE_STRING_KEY: "Level Complete",
    EVENT_TYPE_PURCHASE_STRING_KEY: "Purchase",
    EVENT_TYPE_RATING_STRING_KEY: "Rating",
    EVENT_TYPE_REGISTRATION_COMPLETE_STRING_KEY: "Registration Complete",
    EVENT_TYPE_SEARCH_STRING_KEY: "Search",
    EVENT_TYPE_TUTORIAL_COMPLETE_STRING_KEY: "Tutorial Complete",
    EVENT_TYPE_VIEW_STRING_KEY: "View",
    EVENT_TYPE_AD_VIEW_STRING_KEY: "Ad View",
    EVENT_TYPE_PUSH_RECEIVED_STRING_KEY: "Push Received",
    EVENT_TYPE_PUSH_OPENED_STRING_KEY: "Push Opened",
    EVENT_TYPE_CONSENT_GRANTED_STRING_KEY: "Consent Granted",
    EVENT_TYPE_DEEP_LINK_STRING_KEY: "_Deeplink",
    EVENT_TYPE_AD_CLICK_STRING_KEY: "Ad Click",
    EVENT_TYPE_START_TRIAL_STRING_KEY: "Start Trial",
    EVENT_TYPE_SUBSCRIBE_STRING_KEY: "Subscribe",

    // Notification Events
    // Deprectated, use setAttributionListener and setConsentStatusChangeListener
    ATTRIBUTION_EVENT_TYPE: "attribution-notification",
    CONSENT_STATUS_CHANGE_EVENT_TYPE: "consent-status-change-notification",

    // Sets a listener for the Attribution callback event. Setting to null will remove an existing listener.
    setAttributionListener: function (functionString) {
        // If we already have a listener remove it before we add the new one.
        if(kochavaTrackerAttributionEventListener != null) {
            document.removeEventListener(KochavaTracker.ATTRIBUTION_EVENT_TYPE, kochavaTrackerAttributionEventListener);
            kochavaTrackerAttributionEventListener = null;
        }
        // Only add the listener if its not null. This allows clearing of the listener.
        if(functionString != null) {
            kochavaTrackerAttributionEventListener = functionString;
            document.addEventListener(KochavaTracker.ATTRIBUTION_EVENT_TYPE, kochavaTrackerAttributionEventListener);
        }
    },

    // Sets a listener for the Consent Status Change callback event. Setting to null will remove an existing listener.
    setConsentStatusChangeListener: function (functionString) {
        // If we already have a listener remove it before we add the new one.
        if(kochavaTrackerConsentStatusChangeEventListener != null) {
            document.removeEventListener(KochavaTracker.CONSENT_STATUS_CHANGE_EVENT_TYPE, kochavaTrackerConsentStatusChangeEventListener);
            kochavaTrackerConsentStatusChangeEventListener = null;
        }
        // Only add the listener if its not null. This allows clearing of the listener.
        if(functionString != null) {
            kochavaTrackerConsentStatusChangeEventListener = functionString;
            document.addEventListener(KochavaTracker.CONSENT_STATUS_CHANGE_EVENT_TYPE, kochavaTrackerConsentStatusChangeEventListener);
        }
    },

    // Send an event with a string: sendEventString(String, String)
    sendEventString: function (nameString, infoString) {
        cordovaExecCommand('sendEventString', nameString, infoString);
    },

    // Send an event with a MapObject: sendEventMapObject(String, MapObject)
    sendEventMapObject: function (nameString, infoMapObject) {
        cordovaExecCommand('sendEventMapObject', nameString, infoMapObject);
    },

    // Send an event with a MapObject and Apple Store receipt (iOS Only): sendEventAppleAppStoreReceipt(String, MapObject, String)
    sendEventAppleAppStoreReceipt: function (nameString, infoMapObject, appStoreReceiptBase64EncodedString) {
        cordovaExecCommand('sendEventAppleAppStoreReceipt', nameString, infoMapObject, appStoreReceiptBase64EncodedString);
    },

    // Send an event with a MapObject and Google Play receipt (Android Only): sendEventGooglePlayReceipt(String, MapObject, String, String)
    sendEventGooglePlayReceipt: function (nameString, infoMapObject, receiptData, receiptDataSignature) {
        cordovaExecCommand('sendEventGooglePlayReceipt', nameString, infoMapObject, receiptData, receiptDataSignature);
    },

    // Send an event with a deeplink: sendDeepLink(String, String)
    sendDeepLink: function (openURLString, sourceApplicationString) {
        cordovaExecCommand('sendDeepLink', openURLString, sourceApplicationString);
    },

    // Sets App Limit Ad Tracking: setAppLimitAdTracking(boolean)
    setAppLimitAdTracking: function (appLimitAdTrackingBool) {
        cordovaExecCommand('setAppLimitAdTracking', appLimitAdTrackingBool);
    },

    // Deprecated, see setIdentityLink.
    sendIdentityLink: function (mapObject) {
        cordovaExecCommand('setIdentityLink', mapObject);
    },

    // Sets an Identity Link Map Object: setIdentityLink(MapObject)
    setIdentityLink: function (mapObject) {
        cordovaExecCommand('setIdentityLink', mapObject);
    },

    // Retrieves attribution via a callback: getAttribution(FunctionString)
    getAttribution: function (functionString) {
        cordovaExecCommandCallback('getAttribution', functionString);
    },

    // Retrieves the device id via a callback: getDeviceId(FunctionString)
    getDeviceId: function (functionString) {
        cordovaExecCommandCallback('getDeviceId', functionString);
    },

    // Retrieves the SDK version via a callback: getVersion(FunctionString)
    getVersion: function (functionString) {
        cordovaExecCommandCallback('getVersion', functionString);
    },

    // Adds a new Push Token: addPushToken(String)
    addPushToken: function (tokenString) {
        cordovaExecCommand('addPushToken', tokenString);
    },

    // Removes an existing Push Token: removePushToken(String)
    removePushToken: function (tokenString) {
        cordovaExecCommand('removePushToken', tokenString);
    },

    // Sets the sleep state: setSleep(boolean)
    setSleep: function (sleepBool) {
        cordovaExecCommand('setSleep', sleepBool);
    },

    // Retrieves the sleep state via a callback: getSleep(FunctionBool)
    getSleep: function (functionBool) {
        cordovaExecCommandCallback('getSleep', functionBool);
    },

    // Sets consent to granted or declined: setConsentGranted(boolean)
    setConsentGranted: function (grantedBool) {
        cordovaExecCommand('setConsentGranted', grantedBool);
    },

    // Sets consent to required or not: setConsentRequired(boolean)
    setConsentRequired: function (requiredBool) {
        cordovaExecCommand('setConsentRequired', requiredBool);
    },

    // Sets consent as having been prompted for: setConsentPrompted()
    setConsentPrompted: function () {
        cordovaExecCommand('setConsentPrompted');
    },

    // Retrieves the consent status via a callback: getConsentStatus(FunctionString)
    // String contents is serialized Json.
    getConsentStatus: function (functionString) {
        cordovaExecCommandCallback('getConsentStatus', functionString);
    },

    // Configures and starts the SDK: configure(MapObject)
    configure: function (optionsMapObject) {
        optionsMapObject["versionExtension"] = "Cordova 2.3.0";
        optionsMapObject["wrapperBuildDateString"] = "2018-12-05T21:18:00Z";
        cordovaExecCommand('configure', optionsMapObject);
    }

};

module.exports = KochavaTracker;
