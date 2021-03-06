//
//  main.m
//  wswitcherd
//
//  Copyright © 2019 Adam Westerski. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#import "AppSettings.h"
#import "NHLogger.h"

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

NSString *logFileName = @"";
NSString *errorLogFileName = @"";

NSString* contentTypeForImageData(NSData *data) {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
    }
    return nil;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments]; //cmd line arguments
        if ( [arguments count] >=2 && ([arguments containsObject:@"filelog"]))
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *libraryDirectory = [paths objectAtIndex:0];
            errorLogFileName = [libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stderr.log"];
            logFileName = [libraryDirectory stringByAppendingPathComponent:@"Logs/wswitcher/wswitcher.stdout.log"];
        }
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
        
        [defaults setValue:[NSNumber numberWithBool:NO] forKey:kEnabled];
        
        [defaults setValue:[NSNumber numberWithBool:NO] forKey:kDeleteOldWallpapers];
        
        AppSettings *applicationSettings = [[AppSettings alloc] init];
        [applicationSettings setDefaults: defaults];
        
        //read in properties
        NSString *wallpaperSource = [applicationSettings getSettingsStringPropertyForKey: kWallpaperSource];
        NSString *wallpaperSourceCustomURL = [applicationSettings getSettingsStringPropertyForKey: kWallpaperSourceCustomURL];
        NSString *wallpaperSourceCustomSubreddit = [applicationSettings getSettingsStringPropertyForKey: kWallpaperSourceCustomSubreddit];
        
        NSString *downloadsDirectory = [applicationSettings getSettingsStringPropertyForKey: kDownloadsDirectory];
        
        BOOL retryWhenNetworkDown = [applicationSettings getSettingsBoolPropertyForKey: kRetryWhenNetworkDown];
        NSNumber *retryInterval = [applicationSettings getSettingsNumberPropertyForKey: kRetryInterval];
        NSNumber *retryCount = [applicationSettings getSettingsNumberPropertyForKey: kRetryCount];
        
        BOOL deleteOldWallpapers = [applicationSettings getSettingsBoolPropertyForKey: kDeleteOldWallpapers];

        NSString *imageURL;
        NSString *imageFilename;
        BOOL unrecognizedImageType = NO;
        
        if ([wallpaperSource isEqualToString:@"National Geographic"])
         {
             //national geographic
             //download html
             NSError *error = NULL;
             NSString *url_string = [NSString stringWithFormat: @"http://www.nationalgeographic.com/photography/photo-of-the-day/"];
             NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string] options:0 error:&error];
             //redownload if null and settings allow
             int retryCounter = 0;
             while (data == NULL && (retryWhenNetworkDown == TRUE) && retryCounter < [retryCount intValue])
             {
                 error = NULL;
                 data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string] options:0 error:&error];
                 retryCounter++;
                 [NSThread sleepForTimeInterval: [retryInterval intValue]];
             }
             //if exhausted download attempts and still cannot get display error
             if (data == NULL || error != NULL)
             {
                 NHErrFileLog(errorLogFileName,@"Error: could not download National Geo webpage to fetch image URL");
                 return 1;
             }
             
             NSString *pageContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             error = NULL;
             NSString *pattern = @"<meta property=\"og:image\" content=\"(.*)\"/>"; //get string after the last back-slash
             NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
             
             NSTextCheckingResult *match = [regex firstMatchInString:pageContent options:0 range:NSMakeRange(0, [pageContent length])];
             if (match != nil)
                imageURL = [pageContent substringWithRange:[match rangeAtIndex:1]];
             imageFilename = @"nat_geo";
             NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
             imageFilename = [imageFilename stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
             unrecognizedImageType = YES;
         }
        else if ([wallpaperSource isEqualToString:@"Reddit"])
        {
            //reddit
            //download JSON /redownload if needed/
            NSError *error = NULL;
            NSString *subRedditURL = [@"http://www.reddit.com" stringByAppendingString:wallpaperSourceCustomSubreddit];
            subRedditURL = [subRedditURL stringByAppendingString: @"/top.json?limit=10"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:subRedditURL] options:0 error:&error];
            //redownload if null and settings allow
            int retryCounter = 0;
            while (data == NULL && (retryWhenNetworkDown == TRUE) && retryCounter < [retryCount intValue])
            {
                error = NULL;
                data = [NSData dataWithContentsOfURL:[NSURL URLWithString:subRedditURL] options:0 error:&error];
                retryCounter++;
                [NSThread sleepForTimeInterval: [retryInterval intValue]];
            }
            //if exhausted download attempts and still cannot get display error
            if (data == NULL || error != NULL)
            {
                NHErrFileLog(errorLogFileName,@"Error: could not download Reddit JSON with posts list.");
                return 1;
            }
            error = NULL;
            NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (json == NULL || error != NULL)
            {
                NHErrFileLog(errorLogFileName,@"Error parsing Reddit JSON: empty or melformed data.");
                return 1;
            }
            //Parse JSON to extract image URL
            NSDictionary *redditData = [json valueForKey:@"data"];
            NSArray *postsData = [redditData valueForKey:@"children"];
            NSMutableDictionary *postScoring = [[NSMutableDictionary alloc] init];
            for (NSDictionary *post in postsData) {
                NSString *postUrl = [[post valueForKey:@"data"] valueForKey:@"url"];
                NSNumber *score = [[post valueForKey:@"data"] valueForKey:@"ups"]; //add parsing here
                //exclude posts that are not links for images
                if ([postUrl hasSuffix:@".jpg"] || [postUrl hasSuffix:@".png"] || [postUrl hasSuffix:@".gif"])
                    [postScoring setValue:score forKey:postUrl];
            }
            //sort by scoring
            NSArray *orderedKeys = [postScoring keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
                return [obj2 compare:obj1];
            }];
            //take first post with most ratings
            if ([orderedKeys count] > 0)
            {
                //set url
                imageURL = orderedKeys[0];
                //parse url to extract image filename
                NSString *pattern = @"([^\\/]+)$"; //get string after the last back-slash
                error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
            
                NSTextCheckingResult *match = [regex firstMatchInString:imageURL options:0 range:NSMakeRange(0, [imageURL length])];
                if (match != nil)
                    imageFilename = [imageURL substringWithRange:[match rangeAtIndex:1]];
                else {
                    imageFilename = @"subreddit";
                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
                    imageFilename = [imageFilename stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
                    unrecognizedImageType = YES;
                }
            }
            else {
                NHErrFileLog(errorLogFileName,@"Error looking for image data in Subreddit. Couldn't find any URLs linking to images.");
                return 1;
            }
        } else if ([wallpaperSource isEqualToString:@"Other ..."])
        {
            //others
            imageURL = wallpaperSourceCustomURL;
            imageFilename = @"custom_image";
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
            imageFilename = [imageFilename stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
            unrecognizedImageType = YES;
            
        } else
        {
            //default: bing
            //download JSON /redownload if needed/
            NSError *error = NULL;
            NSString *url_string = [NSString stringWithFormat: @"https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string] options:0 error:&error];
            //redownload if null and settings allow
            int retryCounter = 0;
            while (data == NULL && (retryWhenNetworkDown == TRUE) && retryCounter < [retryCount intValue])
            {
                error = NULL;
                data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string] options:0 error:&error];
                retryCounter++;
                [NSThread sleepForTimeInterval: [retryInterval intValue]];
            }
            //if couldnt download display error
            if (data == NULL || error != NULL)
            {
                NHErrFileLog(errorLogFileName,@"Error: could not download Bing JSON with Daily Image URL.");
                return 1;
            }
            error = NULL;
            NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (json == NULL || error != NULL)
            {
                NHErrFileLog(errorLogFileName,@"Error parsing Bing JSON: empty or melformed data.");
                return 1;
            }
            //Parse JSON to extract image URL
            NSDictionary *images = [json valueForKey:@"images"][0];
            imageURL = [images objectForKey:@"url"];
            imageURL = [@"http://www.bing.com" stringByAppendingString:imageURL];
            //parse to extract image filename
            NSString *pattern = @"([^\\/]+)$"; //get string after the last back-slash
            error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
            
            NSTextCheckingResult *match = [regex firstMatchInString:imageURL options:0 range:NSMakeRange(0, [imageURL length])];
            if (match != nil)
                imageFilename = [imageURL substringWithRange:[match rangeAtIndex:1]];
                //check image filename ending, if doesn't match any of the supported just set predefined
                if (![imageFilename hasSuffix:@".jpg"] && ![imageFilename hasSuffix:@".png"] && ![imageFilename hasSuffix:@".gif"])
                {
                    imageFilename = @"bing_daily";
                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
                    imageFilename = [imageFilename stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
                    unrecognizedImageType = YES;
                }
            else
            {
                imageFilename = @"bing_daily";
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
                imageFilename = [imageFilename stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
                unrecognizedImageType = YES;
            }
        }
        
        //download image as indicated in source
        NSURL  *url = [NSURL URLWithString:imageURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        int retryCounter = 0;
        while (urlData == NULL && (retryWhenNetworkDown == TRUE) && retryCounter < [retryCount intValue])
        {
            urlData = [NSData dataWithContentsOfURL:url];
            retryCounter++;
            [NSThread sleepForTimeInterval: [retryInterval intValue]];
        }
        if ( urlData )
        {
            //delete past files (exclude subdirectories, delete only images)
            if (deleteOldWallpapers == YES)
            {
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:downloadsDirectory error:nil];
                for (NSString *filename in fileArray)  {
                    BOOL isDir = NO;
                    NSString * fullPath= [downloadsDirectory stringByAppendingPathComponent:filename];
                    if([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)
                        continue;
                    
                    if ([filename hasSuffix:@".jpg"] || [filename hasSuffix:@".png"] || [filename hasSuffix:@".gif"])
                    {
                        [fileMgr removeItemAtPath:[downloadsDirectory stringByAppendingPathComponent:filename] error:NULL];
                    }
                }
            }
            //write current file (as indicated by file title)
            NSString  *filePath = [downloadsDirectory stringByAppendingString:@"/"];
            filePath = [filePath stringByAppendingString:imageFilename];
            //check if downloads directory exists , if not create it
            if ([[NSFileManager defaultManager] fileExistsAtPath:downloadsDirectory] == NO)
            {
                NSError *error;
                NSMutableDictionary *permissions = [[NSMutableDictionary alloc] init];
                [permissions setObject:[NSNumber numberWithInt:484] forKey:NSFilePosixPermissions]; /*484 is Decimal for the 744 octal*/
                [permissions setObject:NSUserName() forKey:NSFileOwnerAccountName];
                [[NSFileManager defaultManager] createDirectoryAtPath:downloadsDirectory withIntermediateDirectories:YES attributes:permissions error:&error];
                if (error) {
                    NHErrFileLog(errorLogFileName,@"Error when attempting to create (non-existant) downloads directory: %@", downloadsDirectory);
                    return 1;
                }
            }
            //recognize file type if couldn't figure it out from the URL
            if (unrecognizedImageType == YES) {
                NSString *imageType = contentTypeForImageData(urlData);
                filePath = [filePath stringByAppendingString:@"."];
                filePath = [filePath stringByAppendingString:imageType];
            }
            BOOL result = [urlData writeToFile:filePath atomically:YES];
            if (result == YES)
            {
                //change wallpaper
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
                NSError *error = NULL;
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], NSWorkspaceDesktopImageAllowClippingKey, [NSNumber numberWithInteger:NSImageScaleProportionallyUpOrDown], NSWorkspaceDesktopImageScalingKey, nil];
                [[NSWorkspace sharedWorkspace] setDesktopImageURL:fileURL forScreen:[[NSScreen screens] lastObject]  options:options error:&error];
                //[[NSWorkspace sharedWorkspace] setDesktopImageURL:fileURL forScreen:[[NSScreen screens] lastObject]  options:nil error:&error];
                if (error != NULL)
                {
                    NHErrFileLog(errorLogFileName,@"Error setting wallpaper (%@) to %@",wallpaperSource,filePath);
                    return 1;
                } else
                    NHFileLog(logFileName,@"Downloaded and updated wallpaper (%@): %@",wallpaperSource,filePath);
            } else
            {
                NHErrFileLog(errorLogFileName,@"Error writing image file to hard disk, directory does not exist or lacking write permission.");
                return 1;
            }
        }
    }
    return 0;
}
