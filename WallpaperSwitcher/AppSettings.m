//
//  AppSettings.m
//  WallpaperSwitcher
//
//  Created by adam on 5/3/19.
//  Copyright © 2019 Adam Westerski. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings
{
    NSMutableDictionary *_appDefaults;
}

- (void) setDefaults: (NSMutableDictionary *) appDefaults
{
    _appDefaults = appDefaults;
}

- (void) setSettingsNumericProperty: (NSNumber *) property forKey: (NSString *) key
{
    CFPropertyListRef value = (__bridge CFNumberRef)property;
    CFStringRef cfKey = (__bridge CFStringRef)key;
    
    CFPreferencesSetValue(cfKey, value, CFSTR("com.wswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

- (void) setSettingsBoolProperty: (BOOL) property forKey: (NSString *) key
{
    CFPropertyListRef value; //= (__bridge CFBooleanRef)property;
    CFStringRef cfKey = (__bridge CFStringRef)key;
    if (property == YES)
        value=kCFBooleanTrue;
    else
        value = kCFBooleanFalse;
    //kCFBooleanTrue    kCFBooleanFal
    CFPreferencesSetValue(cfKey, value, CFSTR("com.wswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

- (void) setSettingsStringProperty: (NSString *) property forKey: (NSString *) key
{
    CFPropertyListRef value = (__bridge CFStringRef)property;
    CFStringRef cfKey = (__bridge CFStringRef)key;
 
    CFPreferencesSetValue(cfKey, value, CFSTR("com.wswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

- (NSString *) getSettingsStringPropertyForKey: (NSString *) key
{
    CFPropertyListRef value;
    CFStringRef cfKey = (__bridge CFStringRef)key;
    value = CFPreferencesCopyValue( cfKey, CFSTR("com.wswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value == NULL) {
        return( [_appDefaults valueForKey:key] );
    }
    NSString *stringValue = (__bridge NSString *)value;
    return(stringValue);

}

- (BOOL) getSettingsBoolPropertyForKey: (NSString *) key
{
    CFPropertyListRef value;
    CFStringRef cfKey = (__bridge CFStringRef)key;
    value = CFPreferencesCopyValue( cfKey, CFSTR("com.wswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    value = NULL;
    if (value == NULL) {
        return( [[_appDefaults valueForKey:key] boolValue] );
    }
    NSNumber *numberValue = (__bridge NSNumber *)value;
    return([numberValue boolValue]);
}

- (NSNumber *) getSettingsNumberPropertyForKey: (NSString *) key
{
    CFPropertyListRef value;
    CFStringRef cfKey = (__bridge CFStringRef)key;
    value = CFPreferencesCopyValue( cfKey, CFSTR("com.wswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value == NULL) {
        return( [_appDefaults valueForKey:key] );
    }
    NSNumber *numberValue = (__bridge NSNumber *)value;
    return(numberValue);
}

//    NSInteger *result;
//
//    const char* const appID = [[[NSBundle bundleForClass:[self class]] bundleIdentifier] cStringUsingEncoding:NSASCIIStringEncoding]; // Get the bundle identifier -> com.yourcompany.whatever
//    CFStringRef bundleID = CFStringCreateWithCString(kCFAllocatorDefault, appID, kCFStringEncodingASCII);
//    BOOL b = false;
//    const NSInteger i = CFPreferencesGetAppIntegerValue(CFSTR("intKey"), bundleID, &b);
//    NSLog(@"%d", i);
//    CFRelease(bundleID);
//    //return(@"");
//
//    CFStringRef start_page_url;
//
//    //start_page_url = CFPreferencesCopyValue( CFSTR(“start_page_url”), kCFPreferencesCurrentApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
//
//    //return(result);

//- (void) test
//{
//    const char* const appID = [[[NSBundle bundleForClass:[self class]] bundleIdentifier] cStringUsingEncoding:NSASCIIStringEncoding]; // Get the bundle identifier -> com.yourcompany.whatever
//    CFStringRef bundleID = CFStringCreateWithCString(kCFAllocatorDefault, appID, kCFStringEncodingASCII); // Need a CFString
//    CFStringRef s = (CFStringRef)CFPreferencesCopyAppValue(CFSTR("stringKey"), bundleID);
//    if (!s)
//        CFPreferencesSetAppValue(CFSTR("stringKey"), CFSTR("stringValue"), bundleID);
//    else
//        CFRelease(s);
//    CFNumberRef n = (CFNumberRef)CFPreferencesCopyAppValue(CFSTR("intKey"), bundleID);
//    if (!n)
//    {
//        const int val = 123;
//        n = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &val); // Need an number object
//        CFPreferencesSetAppValue(CFSTR("intKey"), n, bundleID);
//    }
//    CFRelease(n);
//    CFPreferencesAppSynchronize(bundleID);
//    CFRelease(bundleID);
//}


@end
