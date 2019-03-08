//
//  WallpaperSwitcher.h
//  WallpaperSwitcher
//
//  Created by adam on 5/3/19.
//  Copyright © 2019 Adam Westerski. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <AppSettings.h>
#import <NHLogger.h>

@interface WallpaperSwitcher : NSPreferencePane

- (void)mainViewDidLoad;
- (void)modifyLaunchAgentPlist;

@property (weak) IBOutlet NSPopUpButton *downloadIWallpaperIntervalButton;
@property (weak) IBOutlet NSPopUpButton *downloadSourceButton;
@property (weak) IBOutlet NSButton *retryCheckboxButton;
@property (weak) IBOutlet NSTextField *retryTimesInputBox;
@property (weak) IBOutlet NSTextField *retrySecondsInputField;
@property (weak) IBOutlet NSTextField *CustomURLInputField;
@property (weak) IBOutlet NSTextField *downloadsDirectoryInpytField;
@property (weak) IBOutlet NSButton *deleteDirCheckboxButton;
@property (weak) IBOutlet NSButton *writeLogsCheckboxButton;
@property (weak) IBOutlet NSButton *enableButton;
@property (weak) IBOutlet NSTextField *customURLLabel;



- (IBAction)enableButtonPressAction:(id)sender;
- (IBAction)downloadSourceChange:(id)sender;
- (IBAction)downloadWallpaperIntervalChange:(id)sender;

- (IBAction)retryCheckboxButtonActionPress:(id)sender;
- (IBAction)deleteDirPressAction:(id)sender;
- (IBAction)writeLogsButtonPressAction:(id)sender;
- (IBAction)selectDownloadsDirButtonPressAction:(id)sender;
- (IBAction)viewDownloadDirButtonPress:(id)sender;


- (IBAction)updateButtonPressAction:(id)sender;

- (IBAction)retryTimesTextFieldChange:(id)sender;
- (IBAction)retryIntervalTextFieldChange:(id)sender;
- (IBAction)customURLTextFieldChange:(id)sender;
- (IBAction)downloadsDirectoryTextFieldChange:(id)sender;


@end
