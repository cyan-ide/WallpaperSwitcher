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

static NSString *kSaveLogs = @"SaveLogs";
static NSString *kDeleteOldWallpapers = @"DeleteOldWallpapers";

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

BOOL saveLogs;
BOOL deleteOldWallpapers;

AppSettings *applicationSettings;


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
        [launchAgentFileContents writeToFile:launchAgentsFileDirectoryPath atomically:YES];
    }
    
    //wswitcherd path, log directories
    //2. modify startup interval bast on the app settings
    NHFileLog(@"/Users/adam/wswitcher.log",@"currentDownloadInterval: %@",currentDownloadInterval);
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
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"6" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"18" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"every day"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"6" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"twice a week"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"6" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [interval setValue:@"2" forKey:@"Weekday"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"6" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [interval setValue:@"6" forKey:@"Weekday"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"weekly"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@"6" forKey:@"Hour"];
        [interval setValue:@"0" forKey:@"Minute"];
        [interval setValue:@"2" forKey:@"Weekday"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    //2.1 modify log settings
    if (saveLogs == YES) {
        [launchAgentFileContents setValue:[libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stderr.log"] forKey:@"StandardErrorPath"];
        [launchAgentFileContents setValue:[libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stdout.log"] forKey:@"StandardOutPath"];
    }
    else
    {
        [launchAgentFileContents setValue:NULL forKey:@"StandardErrorPath"];
        [launchAgentFileContents setValue:NULL forKey:@"StandardOutPath"];
    }
    //write all changes to plist file
    [launchAgentFileContents writeToFile:launchAgentsFileDirectoryPath atomically:YES];
    
    //3. update file permissions / ownershop for Launch Agent plist (744 / user ownership)
    NSMutableDictionary *permissions = [[NSMutableDictionary alloc] init];
    [permissions setObject:[NSNumber numberWithInt:484] forKey:NSFilePosixPermissions]; /*484 is Decimal for the 744 octal*/
    [permissions setObject:NSUserName() forKey:NSFileOwnerAccountName];
    //NSFileGroupOwnerAccountName
    NSError *error1;
    [fileManager setAttributes:permissions ofItemAtPath:launchAgentsFileDirectoryPath error:&error1];
    if (saveLogs == YES) {
        NSString *logDir = [libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher"];
        BOOL isDir = NO;
        if([fileManager fileExistsAtPath:logDir isDirectory:&isDir] && isDir)
            [fileManager setAttributes:permissions ofItemAtPath:logDir error:&error1];
        else
            [fileManager createDirectoryAtPath:logDir withIntermediateDirectories:NO attributes:permissions error:&error1];
    }
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
    
    [defaults setValue:[NSNumber numberWithBool:NO] forKey:kSaveLogs];
    [defaults setValue:[NSNumber numberWithBool:NO] forKey:kDeleteOldWallpapers];
    
    [defaults setValue:[NSNumber numberWithBool:NO] forKey:kEnabled];
    
    NHLog(@"test: %@",@"zzz");
    applicationSettings = [[AppSettings alloc] init];
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
    
    saveLogs = [applicationSettings getSettingsBoolPropertyForKey:kSaveLogs];
    deleteOldWallpapers = [applicationSettings getSettingsBoolPropertyForKey:kDeleteOldWallpapers];
    
    //refresh UI to reflect current settings
    [_downloadIWallpaperIntervalButton selectItemWithTitle: currentDownloadInterval];
    [_downloadSourceButton selectItemWithTitle: currentWallpaperSource];
    if ([currentWallpaperSource isEqualToString:@"Reddit"])
    {
        [_CustomURLInputField setStringValue: currentWallpaperSourceCustomSubreddit];
        [_CustomURLInputField setEditable:YES];
    }
    else if ([currentWallpaperSource isEqualToString:@"Other ..."])
    {
        [_CustomURLInputField setStringValue: currentWallpaperSourceCustomURL];
        [_CustomURLInputField setEditable:YES];
    }
    else
    {
        [_CustomURLInputField setStringValue: @""];
        [_CustomURLInputField setEditable:NO];
    }
    
    [_downloadsDirectoryInpytField setStringValue: currentDownloadsDirectory];
    
    if (currentRetryWhenNetworkDown == YES)
        [_retryCheckboxButton setState:NSControlStateValueOn];
    else
        [_retryCheckboxButton setState:NSControlStateValueOff];
    
    [_retryTimesInputBox setStringValue: [currentRetryCount stringValue]];
    [_retrySecondsInputField setStringValue: [currentRetryInterval stringValue]];
    
    if (saveLogs == YES)
        [_writeLogsCheckboxButton setState:NSControlStateValueOn];
    else
        [_writeLogsCheckboxButton setState:NSControlStateValueOff];
    
    if (deleteOldWallpapers == YES)
        [_deleteDirCheckboxButton setState:NSControlStateValueOn];
    else
        [_deleteDirCheckboxButton setState:NSControlStateValueOff];
}

- (IBAction)enableButtonPressAction:(id)sender {
}

/*
 NHFileLog(@"/Users/adam/wswitcher.log",@"download interval change !");
 NHFileLog(@"/Users/adam/wswitcher.log",@"download interval change to: %@",[_downloadIWallpaperIntervalButton titleOfSelectedItem]);
 } */

- (IBAction)downloadSourceChange:(id)sender {
    NSString *uiValue = [_downloadSourceButton titleOfSelectedItem];
    if ( ~[uiValue isEqualToString:currentWallpaperSource] ){
        currentWallpaperSource = uiValue;
        [applicationSettings setSettingsStringProperty:currentWallpaperSource forKey:kWallpaperSource];
        
        if ([currentWallpaperSource isEqualToString:@"Reddit"])
        {
            [_CustomURLInputField setStringValue: currentWallpaperSourceCustomSubreddit];
            [_CustomURLInputField setEditable:YES];
        }
        else if ([currentWallpaperSource isEqualToString:@"Other ..."])
        {
            [_CustomURLInputField setStringValue: currentWallpaperSourceCustomURL];
            [_CustomURLInputField setEditable:YES];
        }
        else
        {
            [_CustomURLInputField setStringValue: @""];
            [_CustomURLInputField setEditable:NO];
        }
    }
}

- (IBAction)downloadWallpaperIntervalChange:(id)sender {
    NSString *uiValue = [_downloadIWallpaperIntervalButton titleOfSelectedItem];
    if ( ~[uiValue isEqualToString:currentDownloadInterval] ){
        currentDownloadInterval = uiValue;
        [applicationSettings setSettingsStringProperty:currentDownloadInterval forKey:kDownloadInterval];
        [self modifyLaunchAgentPlist];
    }
}

- (IBAction)retryCheckboxButtonActionPress:(id)sender {
    BOOL uiState = NO;
    if ([_retryCheckboxButton state] == NSControlStateValueOn)
        uiState = YES;
    
    if (uiState != currentRetryWhenNetworkDown)
    {
        currentRetryWhenNetworkDown = uiState;
        [applicationSettings setSettingsBoolProperty:uiState forKey:kRetryWhenNetworkDown];
    }
}

- (IBAction)deleteDirPressAction:(id)sender {
    BOOL uiState = NO;
    if ([_deleteDirCheckboxButton state] == NSControlStateValueOn)
        uiState = YES;
    
    if (uiState != deleteOldWallpapers)
    {
        deleteOldWallpapers = uiState;
        [applicationSettings setSettingsBoolProperty:uiState forKey:kDeleteOldWallpapers];
    }
}

- (IBAction)writeLogsButtonPressAction:(id)sender {
    BOOL uiState = NO;
    if ([_writeLogsCheckboxButton state] == NSControlStateValueOn)
        uiState = YES;

    if (uiState != saveLogs)
    {
        saveLogs = uiState;
        [applicationSettings setSettingsBoolProperty:uiState forKey:kSaveLogs];
        [self modifyLaunchAgentPlist];
    }
}

- (IBAction)selectDownloadsDirButtonPressAction:(id)sender {
    NSOpenPanel *op = [NSOpenPanel openPanel];
    op.canChooseFiles = NO;
    op.canChooseDirectories = YES;
    [op runModal];
    //currentDownloadsDirectory = [[op.URLs firstObject] absoluteString];
    NSString *uiValue = [[op.URLs firstObject] path];
    if ( ~[uiValue isEqualToString:currentDownloadsDirectory] ){
        currentDownloadsDirectory = uiValue;
        [_downloadsDirectoryInpytField setStringValue: currentDownloadsDirectory];
        [applicationSettings setSettingsStringProperty:currentDownloadsDirectory forKey:kDownloadsDirectory];
    }
}

- (IBAction)viewDownloadDirButtonPress:(id)sender {
    //NSURL *folderURL = [fileURL URLByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] openFile:currentDownloadsDirectory];
}

- (IBAction)updateButtonPressAction:(id)sender {
    [self modifyLaunchAgentPlist];
}

- (IBAction)retryTimesTextFieldChange:(id)sender {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *uiValue = [formatter numberFromString: [_retryTimesInputBox stringValue]];
    
    if (uiValue != NULL && uiValue != currentRetryCount)
    {
        currentRetryCount = uiValue;
        [applicationSettings setSettingsNumericProperty:uiValue forKey:kRetryCount];
    }
}

- (IBAction)retryIntervalTextFieldChange:(id)sender {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *uiValue = [formatter numberFromString: [_retrySecondsInputField stringValue]];
    
    if (uiValue != NULL && uiValue != currentRetryInterval)
    {
        currentRetryInterval = uiValue;
        [applicationSettings setSettingsNumericProperty:uiValue forKey:kRetryInterval];
    }
}

- (IBAction)customURLTextFieldChange:(id)sender {
    NSString *uiValue = [_CustomURLInputField stringValue];
    if ( [currentWallpaperSource isEqualToString:@"Reddit"] && ~[uiValue isEqualToString:currentWallpaperSourceCustomSubreddit] )
    {
        currentWallpaperSourceCustomSubreddit = uiValue;
        [applicationSettings setSettingsStringProperty:currentWallpaperSourceCustomSubreddit forKey: kWallpaperSourceCustomSubreddit];
    }
    else if ([currentWallpaperSource isEqualToString:@"Other ..."] && ~[uiValue isEqualToString:currentWallpaperSourceCustomURL])
    {
        currentWallpaperSourceCustomURL = uiValue;
        [applicationSettings setSettingsStringProperty:currentWallpaperSourceCustomURL forKey: kWallpaperSourceCustomURL];
    }
}

- (IBAction)downloadsDirectoryTextFieldChange:(id)sender {
    NSString *uiValue = [_downloadsDirectoryInpytField stringValue];
    if ( ~[uiValue isEqualToString:currentDownloadsDirectory] ){
        currentDownloadsDirectory = uiValue;
        [applicationSettings setSettingsStringProperty:currentDownloadsDirectory forKey:kDownloadsDirectory];
    }
}

@end
