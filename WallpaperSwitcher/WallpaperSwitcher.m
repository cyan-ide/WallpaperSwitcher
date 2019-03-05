//
//  WallpaperSwitcher.m
//  WallpaperSwitcher
//
//  Created by adam on 5/3/19.
//  Copyright © 2019 Adam Westerski. All rights reserved.
//

#import "WallpaperSwitcher.h"

static NSString *kWallpaperSource = @"WallpaperSource";
static NSString *kDownloadInterval = @"DownloadInterval";
static NSString *kWallpaperSourceCustomURL = @"WallpaperSourceCustomURL";
static NSString *kWallpaperSourceCustomSubreddit = @"WallpaperSourceCustomSubreddit";

static NSString *kDownloadsDirectory = @"DownloadsDirectory";

static NSString *kRetryWhenNetworkDown = @"RetryWhenNetworkDown";
static NSString *kRetryInterval = @"RetryInterval";
static NSString *kRetryCount = @"RetryCount";

static NSString *kEnabled = @"Enabled";

@implementation WallpaperSwitcher

- (void)mainViewDidLoad
{
    //init default settings
    NSMutableDictionary *defaults=[[NSMutableDictionary alloc] init];
    [defaults setValue:@"Bing Daily Image" forKey:kWallpaperSource];
    [defaults setValue:@"every 6 hours" forKey:kDownloadInterval];
    [defaults setValue:@"" forKey:kWallpaperSourceCustomURL];
    [defaults setValue:@"/r/wallpapers" forKey:kWallpaperSourceCustomSubreddit];
    
    [defaults setValue:@"/Users/adam/Pictures/wallpapers" forKey:kDownloadsDirectory];
    
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:kRetryWhenNetworkDown];
    [defaults setValue:[NSNumber numberWithInt:30] forKey:kRetryInterval];
    [defaults setValue:[NSNumber numberWithInt:10] forKey:kRetryCount];
    
    [defaults setValue:[NSNumber numberWithBool:NO] forKey:kEnabled];
    
    NHLog(@"test: %@",@"zzz");
    AppSettings *applicationSettings = [[AppSettings alloc] init];
    [applicationSettings setDefaults: defaults];
//    NSString * dupa = [applicationSettings getSettingsStringPropertyForKey:@"ddd"];
//    NSString * dupa2 = [applicationSettings getSettingsStringPropertyForKey:kWallpaperSource];
//    NSNumber *dupa3 = [applicationSettings getSettingsNumberPropertyForKey:kRetryInterval];
//    NSNumber *dupa4 = [applicationSettings getSettingsNumberPropertyForKey:@"costam"];
//    BOOL dupa5 = [applicationSettings getSettingsBoolPropertyForKey:@"costam"];
//    BOOL dupa6 = [applicationSettings getSettingsBoolPropertyForKey:kRetryWhenNetworkDown];
//
//    NHFileLog(@"/Users/adam/wswitcher.log",@"test2: %@",@"zzz");
//    NHFileLog(@"/Users/adam/wswitcher.log",@"costam: %@",dupa);
//    NHFileLog(@"/Users/adam/wswitcher.log",@"costam2: %@",dupa2);
//    if (dupa3 !=NULL)
//        NHFileLog(@"/Users/adam/wswitcher.log",@"costam23: %d",[dupa3 integerValue]);
//
//    NHFileLog(@"/Users/adam/wswitcher.log",@"costam5: %d",dupa5);
//    NHFileLog(@"/Users/adam/wswitcher.log",@"costam6: %d",dupa6);
//    //settings tests
//    [applicationSettings setSettingsStringProperty:NULL forKey:@"costamPropName"];
//    [applicationSettings setSettingsStringProperty:NULL forKey:@"jezyNaWiezy"];
//    [applicationSettings setSettingsStringProperty:NULL forKey:@"whatsTheNymber"];
//    //[applicationSettings setSettingsBoolProperty:YES forKey:@"jezyNaWiezy"];
//    //[applicationSettings setSettingsNumericProperty:[NSNumber numberWithInteger:666] forKey:@"whatsTheNymber"];
//    //setSettingsStringProperty
    
    //AppQuitGracefullyKey;
    
}

@end
