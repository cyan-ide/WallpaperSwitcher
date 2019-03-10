//
//  AppSettings.m
//  WallpaperSwitcher
//
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

@end
