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

NSString *currentWallpaperSource;
NSString *currentDownloadInterval;
NSString *currentWallpaperSourceCustomURL;
NSString *currentWallpaperSourceCustomSubreddit;

NSString *currentDownloadsDirectory;

BOOL currentRetryWhenNetworkDown;
NSNumber *currentRetryInterval;
NSNumber *currentRetryCount;

BOOL currentEnabled;


- (void) modifyLaunchAgentPlist {
    
    //1. check if launch agent file is present, if not copy

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    NSString *launchAgentsFileDirectoryPath = [libraryDirectory stringByAppendingPathComponent:@"LaunchAgents/com.wswitcher.agent.plist"];
    NSString *launchAgentsBundleFilePath = [[self bundle] pathForResource:@"com.wswitcher.agent" ofType:@"plist"];
    NHFileLog(@"/Users/adam/wswitcher.log",@"modify Plist!");
    NHFileLog(@"/Users/adam/wswitcher.log",@"dest path: %@",launchAgentsFileDirectoryPath);
    NHFileLog(@"/Users/adam/wswitcher.log",@"src path: %@",launchAgentsBundleFilePath);
    if ([fileManager fileExistsAtPath:launchAgentsFileDirectoryPath] == NO)
    {
        [fileManager copyItemAtPath:launchAgentsBundleFilePath toPath:launchAgentsFileDirectoryPath error:&error];
        if (error) {
            NSLog(@"Error on copying launch agent config file: %@\nfrom path: %@\ntoPath: %@", error, launchAgentsBundleFilePath, launchAgentsFileDirectoryPath);
        }
        //1.1. update launch agent fields from defaults to system specific
        NSMutableDictionary* launchAgentFileContents = [NSMutableDictionary dictionaryWithContentsOfFile:launchAgentsFileDirectoryPath];
        NSString *launchAgentsBundleFilePath = [[[self bundle] sharedSupportPath] stringByAppendingPathComponent:@"wswitcherd"];
        [launchAgentFileContents setValue:launchAgentsBundleFilePath forKey:@"Program"];
        [launchAgentFileContents setValue:[libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stderr.log"] forKey:@"StandardErrorPath"];
        [launchAgentFileContents setValue:[libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stdout.log"] forKey:@"StandardOutPath"];
    }
    
    //wswitcherd path, log directories
    //2. modify startup interval bast on the app settings
    NSMutableDictionary* launchAgentFileContents = [NSMutableDictionary dictionaryWithContentsOfFile:launchAgentsFileDirectoryPath];
    if ([currentDownloadInterval isEqualToString:@"every 6 hours"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"3" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"9" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"15" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"21" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"every 12 hours"]) {
    }
    else if ([currentDownloadInterval isEqualToString:@"every day"]) {
    }
    else if ([currentDownloadInterval isEqualToString:@"twice a week"]) {
    }
    else if ([currentDownloadInterval isEqualToString:@"weekly"]) {
    }
    
    
    
    
    
    //3. update file permissions / ownershop for Launch Agent plist (744 / user ownership)
}

- (void)mainViewDidLoad
{
    //init default settings
    NSMutableDictionary *defaults=[[NSMutableDictionary alloc] init];
    [defaults setValue:@"Bing Daily Image" forKey:kWallpaperSource];
    [defaults setValue:@"every 6 hours" forKey:kDownloadInterval];
    [defaults setValue:@"" forKey:kWallpaperSourceCustomURL];
    [defaults setValue:@"/r/wallpapers" forKey:kWallpaperSourceCustomSubreddit];
    
    //TODO: set to /Users/<curr user>/Pictures/WallpaperSwitcher/
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
    //set current values
    currentWallpaperSource = [applicationSettings getSettingsStringPropertyForKey:kWallpaperSource];
    currentDownloadInterval = [applicationSettings getSettingsStringPropertyForKey:kDownloadInterval];
    currentWallpaperSourceCustomURL = [applicationSettings getSettingsStringPropertyForKey:kWallpaperSourceCustomURL];
    currentWallpaperSourceCustomSubreddit = [applicationSettings getSettingsStringPropertyForKey:kWallpaperSourceCustomSubreddit];
    
    currentDownloadsDirectory = [applicationSettings getSettingsStringPropertyForKey:kDownloadsDirectory];
    
    currentRetryWhenNetworkDown = [applicationSettings getSettingsBoolPropertyForKey:kRetryWhenNetworkDown];
    currentRetryInterval = [applicationSettings getSettingsNumberPropertyForKey:kRetryInterval];
    currentRetryCount = [applicationSettings getSettingsNumberPropertyForKey:kRetryCount];
    
    currentEnabled = [applicationSettings getSettingsBoolPropertyForKey:kEnabled];
    
}

- (IBAction)enableButtonPressAction:(id)sender {
}

- (IBAction)downloadIWallpaperIntervalChange:(id)sender {
}

- (IBAction)downloadSourceChange:(id)sender {
}

- (IBAction)retryDownloadCheckChange:(id)sender {
}

- (IBAction)retryCheckboxButtonActionPress:(id)sender {
}

- (IBAction)deleteDirPressAction:(id)sender {
}

- (IBAction)writeLogsButtonPressAction:(id)sender {
}

- (IBAction)selectDownloadsDirButtonPressAction:(id)sender {
}

- (IBAction)viewDownloadDirButtonPress:(id)sender {
}

- (IBAction)updateButtonPressAction:(id)sender {
    [self modifyLaunchAgentPlist];
}

@end
