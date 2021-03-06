//
//  WallpaperSwitcher.m
//  WallpaperSwitcher
//
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

NSString *logFileName = @"";
NSString *errorLogFileName = @"";


- (void) modifyLaunchAgentPlist {
    //1. check if launch agent file is present, if not copy

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = NULL;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    //permissions used for writing / creating files
    NSMutableDictionary *permissions = [[NSMutableDictionary alloc] init];
    [permissions setObject:[NSNumber numberWithInt:484] forKey:NSFilePosixPermissions]; /*484 is Decimal for the 744 octal*/
    [permissions setObject:NSUserName() forKey:NSFileOwnerAccountName];
    //paths to src / dest files and directories
    NSString *launchAgentsFileDirectoryPath = [libraryDirectory stringByAppendingPathComponent:@"LaunchAgents/com.wswitcher.agent.plist"];
    NSString *launchAgentsDirectoryPath = [libraryDirectory stringByAppendingPathComponent:@"LaunchAgents"];
    NSString *launchAgentsBundleFilePath = [[self bundle] pathForResource:@"com.wswitcher.agent" ofType:@"plist"];
    if ([fileManager fileExistsAtPath:launchAgentsFileDirectoryPath] == NO)
    {
        //check if directory exists before coping
        if ([fileManager fileExistsAtPath:launchAgentsDirectoryPath] == NO)
            [fileManager createDirectoryAtPath:launchAgentsDirectoryPath withIntermediateDirectories:YES attributes:permissions error:&error];
        /*
        if (error) {
            NHErrFileLog(errorLogFileName,@"Error on copying launch agent config file: %@\nfrom path: %@\ntoPath: %@", error, launchAgentsBundleFilePath, launchAgentsFileDirectoryPath);
        } */
        //copy file from bundle to launch agents directory
        error = NULL;
        [fileManager copyItemAtPath:launchAgentsBundleFilePath toPath:launchAgentsFileDirectoryPath error:&error];
        /*
        if (error) {
            NHErrFileLog(errorLogFileName,@"Error on copying launch agent config file: %@\nfrom path: %@\ntoPath: %@", error, launchAgentsBundleFilePath, launchAgentsFileDirectoryPath);
        } */
        //1.1. update launch agent fields from defaults to system specific
        NSMutableDictionary* launchAgentFileContents = [NSMutableDictionary dictionaryWithContentsOfFile:launchAgentsFileDirectoryPath];
        NSString *wswitcherdFilePath = [[[self bundle] sharedSupportPath] stringByAppendingPathComponent:@"wswitcherd"];
        [launchAgentFileContents setValue:wswitcherdFilePath forKey:@"Program"];
        [launchAgentFileContents writeToFile:launchAgentsFileDirectoryPath atomically:YES];
    }
    
    //wswitcherd path, log directories
    //2. modify startup interval bast on the app settings
    NSMutableDictionary* launchAgentFileContents = [NSMutableDictionary dictionaryWithContentsOfFile:launchAgentsFileDirectoryPath];
    if ([currentDownloadInterval isEqualToString:@"every 6 hours"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@3 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@9 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@15 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@21 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"every 12 hours"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@6 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@18 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"every day"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@6 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"twice a week"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@6 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [interval setValue:@2 forKey:@"Weekday"];
        [calendarInterval addObject:interval];
        
        interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@6 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [interval setValue:@6 forKey:@"Weekday"];
        [calendarInterval addObject:interval];
        
        [launchAgentFileContents setValue:calendarInterval forKey:@"StartCalendarInterval"];
    }
    else if ([currentDownloadInterval isEqualToString:@"weekly"]) {
        NSMutableArray *calendarInterval=[[NSMutableArray alloc] init];
        NSMutableDictionary *interval=[[NSMutableDictionary alloc] init];
        [interval setValue:@6 forKey:@"Hour"];
        [interval setValue:@0 forKey:@"Minute"];
        [interval setValue:@2 forKey:@"Weekday"];
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
    //NSFileGroupOwnerAccountName
    NSError *error1 = NULL;
    [fileManager setAttributes:permissions ofItemAtPath:launchAgentsFileDirectoryPath error:&error1];
    if (saveLogs == YES) {
        NSString *logDir = [libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher"];
        BOOL isDir = NO;
        error1 = NULL;
        if([fileManager fileExistsAtPath:logDir isDirectory:&isDir] && isDir)
            [fileManager setAttributes:permissions ofItemAtPath:logDir error:&error1];
        else
            [fileManager createDirectoryAtPath:logDir withIntermediateDirectories:NO attributes:permissions error:&error1];
    }
}

- (void) modifyLaunchAgentPlistAndReloadService {
    [self modifyLaunchAgentPlist];
    //run launchctl task to reload wswitcher demon and update its settings
    if (currentEnabled == YES)
    {
        //check if laumnch agent file exists , if not copy it (it will be required for either enable or disable action)
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        
        NSString *launchAgentsFilePath = [libraryDirectory stringByAppendingPathComponent:@"LaunchAgents/com.wswitcher.agent.plist"];
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/launchctl"];
        [task setArguments:@[ @"unload", launchAgentsFilePath ]];
        [task launch];
        
        task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/launchctl"];
        [task setArguments:@[ @"load", launchAgentsFilePath ]];
        [task launch];
    }
}

- (void)mainViewDidLoad
{
    //get path for default downloads directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    NSString *picturesDirectory = [paths objectAtIndex:0];
    NSString *wallpaperDefaultDirectory = [picturesDirectory stringByAppendingPathComponent:@"WallpaperSwitcher"];
    //init default settings
    NSMutableDictionary *defaults=[[NSMutableDictionary alloc] init];
    [defaults setValue:@"Bing Daily Image" forKey:kWallpaperSource];
    [defaults setValue:@"every 6 hours" forKey:kDownloadInterval];
    [defaults setValue:@"" forKey:kWallpaperSourceCustomURL];
    [defaults setValue:@"/r/wallpapers" forKey:kWallpaperSourceCustomSubreddit];
    
    [defaults setValue:wallpaperDefaultDirectory forKey:kDownloadsDirectory];
    
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:kRetryWhenNetworkDown];
    [defaults setValue:[NSNumber numberWithInt:30] forKey:kRetryInterval];
    [defaults setValue:[NSNumber numberWithInt:10] forKey:kRetryCount];
    
    [defaults setValue:[NSNumber numberWithBool:NO] forKey:kSaveLogs];
    [defaults setValue:[NSNumber numberWithBool:NO] forKey:kDeleteOldWallpapers];
    
    [defaults setValue:[NSNumber numberWithBool:NO] forKey:kEnabled];
    
    applicationSettings = [[AppSettings alloc] init];
    [applicationSettings setDefaults: defaults];
    
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
        [_CustomURLInputField setEnabled:YES];
        [_customURLLabel setStringValue:@"Custom Subreddit"];
    }
    else if ([currentWallpaperSource isEqualToString:@"Other ..."])
    {
        [_CustomURLInputField setStringValue: currentWallpaperSourceCustomURL];
        [_CustomURLInputField setEnabled:YES];
        [_customURLLabel setStringValue:@"Custom URL"];
    }
    else
    {
        [_CustomURLInputField setStringValue: @""];
        [_CustomURLInputField setEnabled:NO];
        [_customURLLabel setStringValue:@"Custom URL"];
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
    
    if (currentEnabled == YES)
        [_enableButton setTitle:@"Disable"];
    else
        [_enableButton setTitle:@"Enable"];
    
    //set log file paths
    if ( saveLogs == YES)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        errorLogFileName = [libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stderr.log"];
        logFileName = [libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stdout.log"];
    }
}

- (IBAction)enableButtonPressAction:(id)sender {
    //check if laumnch agent file exists , if not copy it (it will be required for either enable or disable action)
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    NSString *launchAgentsFilePath = [libraryDirectory stringByAppendingPathComponent:@"LaunchAgents/com.wswitcher.agent.plist"];
    if ([fileManager fileExistsAtPath:launchAgentsFilePath] == NO)
        [self modifyLaunchAgentPlist];
    //run launchctl task to load wswitcher demon
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/launchctl"];
    if (currentEnabled == NO)
    {
        currentEnabled = YES;
        [applicationSettings setSettingsBoolProperty:currentEnabled forKey:kEnabled];
        [_enableButton setTitle:@"Disable"];
        //unload just in case it was loaded before
        [task setArguments:@[ @"unload", launchAgentsFilePath ]];
        [task launch];
        //load again
        task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/launchctl"];
        [task setArguments:@[ @"load", launchAgentsFilePath ]];
        [task launch];
    } else
    {
        currentEnabled = NO;
        [applicationSettings setSettingsBoolProperty:currentEnabled forKey:kEnabled];
        [_enableButton setTitle:@"Enable"];
        //disable service
        [task setArguments:@[ @"unload", launchAgentsFilePath ]];
        [task launch];
    }
}

/*
 NHFileLog(@"/Users/adam/wswitcher.log",@"download interval change !");
 NHFileLog(@"/Users/adam/wswitcher.log",@"download interval change to: %@",[_downloadIWallpaperIntervalButton titleOfSelectedItem]);
 } */

- (IBAction)downloadSourceChange:(id)sender {
    NSString *uiValue = [_downloadSourceButton titleOfSelectedItem];
    if ( ![uiValue isEqualToString:currentWallpaperSource] ){
        currentWallpaperSource = uiValue;
        [applicationSettings setSettingsStringProperty:currentWallpaperSource forKey:kWallpaperSource];
        
        if ([currentWallpaperSource isEqualToString:@"Reddit"])
        {
            [_CustomURLInputField setStringValue: currentWallpaperSourceCustomSubreddit];
            [_CustomURLInputField setEnabled:YES];
            [_customURLLabel setStringValue:@"Custom Subreddit"];
        }
        else if ([currentWallpaperSource isEqualToString:@"Other ..."])
        {
            [_CustomURLInputField setStringValue: currentWallpaperSourceCustomURL];
            [_CustomURLInputField setEnabled:YES];
            [_customURLLabel setStringValue:@"Custom URL"];
        }
        else
        {
            [_CustomURLInputField setStringValue: @""];
            [_CustomURLInputField setEnabled:NO];
            [_customURLLabel setStringValue:@"Custom URL"];
        }
        
        //invoke update wallpaper after source change (if wallpaper switcher is enabled)
        if (currentEnabled == YES)
        {
            NSString *wswitcherdFilePath = [[[self bundle] sharedSupportPath] stringByAppendingPathComponent:@"wswitcherd"];
            
            NSTask *task = [[NSTask alloc] init];
            [task setArguments:@[ @"filelog" ]];
            [task setLaunchPath:wswitcherdFilePath];
            [task launch];
        }
    }
}

- (IBAction)downloadWallpaperIntervalChange:(id)sender {
    NSString *uiValue = [_downloadIWallpaperIntervalButton titleOfSelectedItem];
    if ( ![uiValue isEqualToString:currentDownloadInterval] ){
        currentDownloadInterval = uiValue;
        [applicationSettings setSettingsStringProperty:currentDownloadInterval forKey:kDownloadInterval];
        [self modifyLaunchAgentPlistAndReloadService];
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
        //display warning dialog if delete files is enabled
        BOOL userSecurityCheck = YES;
        if (uiState == YES) //if state is being changed to delete, double check with user
        {
            //check if directory exists
            BOOL isDir = NO;
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            if([fileMgr fileExistsAtPath:currentDownloadsDirectory isDirectory:&isDir])
            {
                NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:currentDownloadsDirectory error:nil];
                if ([fileArray count] > 0) //if non empty, ask user if he's sure
                {
                    userSecurityCheck = NO;
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Directory not empty"];
                    [alert setInformativeText:@"Your downloads directopry may contains files that will be deleted when cleaning up before wallpaper download! Are you sure?"];
                    [alert addButtonWithTitle:@"Cancel"];
                    [alert setIcon: [NSImage imageNamed:NSImageNameCaution] ];
                    [alert addButtonWithTitle:@"Ok"];
                    if ([alert runModal] == NSAlertSecondButtonReturn) //user pressed ok
                        userSecurityCheck = YES;
                }
            }
        }
        
        if (userSecurityCheck == YES)
        {
            deleteOldWallpapers = uiState;
            [applicationSettings setSettingsBoolProperty:uiState forKey:kDeleteOldWallpapers];
        } else
        { //if didnt pass security check disable delete
            [_deleteDirCheckboxButton setState:NSControlStateValueOff];
            deleteOldWallpapers = NO;
        }
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
        [self modifyLaunchAgentPlistAndReloadService];
    }
}

- (IBAction)selectDownloadsDirButtonPressAction:(id)sender {
    NSOpenPanel *op = [NSOpenPanel openPanel];
    op.canChooseFiles = NO;
    op.canChooseDirectories = YES;
    [op runModal];
    //currentDownloadsDirectory = [[op.URLs firstObject] absoluteString];
    NSString *uiValue = [[op.URLs firstObject] path];
    if ( ![uiValue isEqualToString:currentDownloadsDirectory] ){
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
    NSString *wswitcherdFilePath = [[[self bundle] sharedSupportPath] stringByAppendingPathComponent:@"wswitcherd"];
    
    NSTask *task = [[NSTask alloc] init];
    [task setArguments:@[ @"filelog" ]];
    [task setLaunchPath:wswitcherdFilePath];
    [task launch];
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
    BOOL urlValueChanged = NO;
    NSString *uiValue = [_CustomURLInputField stringValue];
    if ( [currentWallpaperSource isEqualToString:@"Reddit"] && ![uiValue isEqualToString:currentWallpaperSourceCustomSubreddit] )
    {
        currentWallpaperSourceCustomSubreddit = uiValue;
        [applicationSettings setSettingsStringProperty:currentWallpaperSourceCustomSubreddit forKey: kWallpaperSourceCustomSubreddit];
        urlValueChanged = YES;
    }
    else if ([currentWallpaperSource isEqualToString:@"Other ..."] && ![uiValue isEqualToString:currentWallpaperSourceCustomURL])
    {
        currentWallpaperSourceCustomURL = uiValue;
        [applicationSettings setSettingsStringProperty:currentWallpaperSourceCustomURL forKey: kWallpaperSourceCustomURL];
        urlValueChanged = YES;
    }
    
    if (urlValueChanged && currentEnabled == YES) {
        //invoke update wallpaper after source change (if wallpaper switcher is enabled)
        NSString *wswitcherdFilePath = [[[self bundle] sharedSupportPath] stringByAppendingPathComponent:@"wswitcherd"];
        
        NSTask *task = [[NSTask alloc] init];
        [task setArguments:@[ @"filelog" ]];
        [task setLaunchPath:wswitcherdFilePath];
        [task launch];
    }
}

- (IBAction)downloadsDirectoryTextFieldChange:(id)sender {
    NSString *uiValue = [_downloadsDirectoryInpytField stringValue];
    if ( ![uiValue isEqualToString:currentDownloadsDirectory] ){
        //display warning dialog if delete files is enabled
        BOOL userSecurityCheck = YES;
        if (deleteOldWallpapers == YES)
        {
            //check if directory exists
            BOOL isDir = NO;
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            if([fileMgr fileExistsAtPath:uiValue isDirectory:&isDir])
            {
                NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:uiValue error:nil];
                if ([fileArray count] > 0) //if non empty, ask user if he's sure
                {
                    userSecurityCheck = NO;
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Directory not empty"];
                    [alert setInformativeText:@"Your downloads directopry may contains files that will be deleted when cleaning up before wallpaper download! Are you sure?"];
                    [alert addButtonWithTitle:@"Cancel"];
                    [alert setIcon: [NSImage imageNamed:NSImageNameCaution] ];
                    [alert addButtonWithTitle:@"Ok"];
                    if ([alert runModal] == NSAlertSecondButtonReturn) //user pressed ok
                        userSecurityCheck = YES;
                }
            }
        }
        
        if (userSecurityCheck == YES)
        {
            currentDownloadsDirectory = uiValue;
            [applicationSettings setSettingsStringProperty:currentDownloadsDirectory forKey:kDownloadsDirectory];
            //invoke update wallpaper after source change (if wallpaper switcher is enabled)
            if (currentEnabled == YES)
            {
                NSString *wswitcherdFilePath = [[[self bundle] sharedSupportPath] stringByAppendingPathComponent:@"wswitcherd"];
             
                NSTask *task = [[NSTask alloc] init];
                [task setArguments:@[ @"filelog" ]];
                [task setLaunchPath:wswitcherdFilePath];
                [task launch];
            }
        } else
            [_downloadsDirectoryInpytField setStringValue: currentDownloadsDirectory];
    }
}

@end
