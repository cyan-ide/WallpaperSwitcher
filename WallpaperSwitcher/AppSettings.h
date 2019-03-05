//
//  AppSettings.h
//  WallpaperSwitcher
//
//  Created by adam on 5/3/19.
//  Copyright © 2019 Adam Westerski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppSettings : NSObject

- (void) setDefaults: (NSMutableDictionary *) appDefaults;

- (NSString *) getSettingsStringPropertyForKey: (NSString *) key;
- (NSNumber *) getSettingsNumberPropertyForKey: (NSString *) key;
- (BOOL) getSettingsBoolPropertyForKey: (NSString *) key;

- (void) setSettingsStringProperty: (NSString *) property forKey: (NSString *) key;
- (void) setSettingsBoolProperty: (BOOL) property forKey: (NSString *) key;
- (void) setSettingsNumericProperty: (NSNumber *) property forKey: (NSString *) key;

@end

NS_ASSUME_NONNULL_END
