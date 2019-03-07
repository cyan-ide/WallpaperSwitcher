//
//  main.m
//  wswitcherd
//
//  Created by adam on 5/3/19.
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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
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
        
        AppSettings *applicationSettings = [[AppSettings alloc] init];
        [applicationSettings setDefaults: defaults];
        
        //read in properties
        NSString *wallpaperSource = [applicationSettings getSettingsStringPropertyForKey: kWallpaperSource];
        NSString *downloadInterval = [applicationSettings getSettingsStringPropertyForKey: kDownloadInterval];
        NSString *wallpaperSourceCustomURL = [applicationSettings getSettingsStringPropertyForKey: kWallpaperSourceCustomURL];
        NSString *wallpaperSourceCustomSubreddit = [applicationSettings getSettingsStringPropertyForKey: kWallpaperSourceCustomSubreddit];
        
        NSString *downloadsDirectory = [applicationSettings getSettingsStringPropertyForKey: kDownloadsDirectory];
        
        BOOL retryWhenNetworkDown = [applicationSettings getSettingsBoolPropertyForKey: kRetryWhenNetworkDown];
        NSNumber *retryInterval = [applicationSettings getSettingsNumberPropertyForKey: kRetryInterval];
        NSNumber *retryCount = [applicationSettings getSettingsNumberPropertyForKey: kRetryCount];
        /*
        NHLog(@"wallpaperSource: %@",wallpaperSource);
        NHLog(@"downloadInterval: %@",downloadInterval);
        NHLog(@"wallpaperSourceCustomURL: %@",wallpaperSourceCustomURL);
        NHLog(@"wallpaperSourceCustomSubreddit: %@",wallpaperSourceCustomSubreddit);
        NHLog(@"downloadsDirectory: %@",downloadsDirectory);
        
        NHLog(@"retryWhenNetworkDown: %d",retryWhenNetworkDown);
        NHLog(@"retryInterval: %d",[retryInterval integerValue]);
        NHLog(@"retryCount: %d",[retryCount integerValue]);
        */
        NSString *imageURL;
        NSString *imageFilename;
        
        //wallpaperSource = @"Reddit";
        //wallpaperSourceCustomSubreddit = @"/r/wallpapers";
        //wallpaperSourceCustomURL = @"https://i.redd.it/kydhs421glk21.jpg";
        if ([wallpaperSource isEqualToString:@"National Geographic"])
         {
             //national geographic
             //download html
             NSError *error;
             NSString *url_string = [NSString stringWithFormat: @"http://www.nationalgeographic.com/photography/photo-of-the-day/"];
             //NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
             NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string] options:0 error:&error];
             //redownload here ? if null ?
             if (data == NULL || error != NULL)
             {
                 NSLog(@"Error: could not download National Geo webpage to fetch image URL");
                 return 1;
             }
             
             NSString *pageContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
            
             NSString *pattern = @"<meta property=\"og:image\" content=\"(.*)\"/>"; //get string after the last back-slash
             NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
             
             NSTextCheckingResult *match = [regex firstMatchInString:pageContent options:0 range:NSMakeRange(0, [pageContent length])];
             if (match != nil)
                imageURL = [pageContent substringWithRange:[match rangeAtIndex:1]];
             imageFilename = @"nat_geo.jpg";
         }
        else if ([wallpaperSource isEqualToString:@"Reddit"])
        {
            //reddit
            //download JSON /redownload if needed/
            NSError *error;
            NSString *subRedditURL = [@"http://www.reddit.com" stringByAppendingString:wallpaperSourceCustomSubreddit];
            subRedditURL = [subRedditURL stringByAppendingString: @"/top.json?limit=10"];
            //NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:subRedditURL] options:0 error:&error];
            //redownload here ? if null ?
            if (data == NULL || error != NULL)
            {
                NSLog(@"Error: could not download Reddit JSON with posts list.");
                return 1;
            }
            NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (json == NULL || error != NULL)
            {
                NSLog(@"Error parsing Reddit JSON: empty or melformed data.");
                return 1;
            }
            //NSLog(@"json: %@", json);
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
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
            
                NSTextCheckingResult *match = [regex firstMatchInString:imageURL options:0 range:NSMakeRange(0, [imageURL length])];
                if (match != nil)
                    imageFilename = [imageURL substringWithRange:[match rangeAtIndex:1]];
                else
                    imageFilename = @"subreddit.png";
            }
            else {
                NSLog(@"Error looking for image data in Subreddit. Couldn't find any URLs linking to images.");
                return 1;
            }
        } else if ([wallpaperSource isEqualToString:@"Other ..."])
        {
            //others
            imageURL = wallpaperSourceCustomURL;
            imageFilename = @"custom_image.jpg";
            
        } else
        {
            //default: bing
            //download JSON /redownload if needed/
            NSError *error;
            NSString *url_string = [NSString stringWithFormat: @"https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"];
            //NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string] options:0 error:&error];
            //redownload here ? if null ?
            if (data == NULL || error != NULL)
            {
                NSLog(@"Error: could not download Bing JSON with Daily Image URL.");
                return 1;
            }
            NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (json == NULL || error != NULL)
            {
                NSLog(@"Error parsing Bing JSON: empty or melformed data.");
                return 1;
            }
            //NSLog(@"json: %@", json);
            //Parse JSON to extract image URL
            NSDictionary *images = [json valueForKey:@"images"][0];
            imageURL = [images objectForKey:@"url"];
            imageURL = [@"http://www.bing.com" stringByAppendingString:imageURL];
            //imageURL = [json valueForKey:@"url"];
            
            //parse to extract image filename
            NSString *pattern = @"([^\\/]+)$"; //get string after the last back-slash
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
            
            NSTextCheckingResult *match = [regex firstMatchInString:imageURL options:0 range:NSMakeRange(0, [imageURL length])];
            if (match != nil)
                imageFilename = [imageURL substringWithRange:[match rangeAtIndex:1]];
            else
                imageFilename = @"bing_daily.png";
        }
        
        //download image as indicated in source
        //NHLog(@"imageURL: %@",imageURL);
        NSURL  *url = [NSURL URLWithString:imageURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        int retryCounter = 0;
        while (urlData == NULL && (retryWhenNetworkDown == TRUE) && retryCounter < [retryCount intValue])
        {
            urlData = [NSData dataWithContentsOfURL:url];
            retryCounter++;
            [NSThread sleepForTimeInterval: [retryInterval intValue]];
        }
        //NHLog(@"done with attempts: %d",retryCounter);
        //   NHLog(@"error downloading image!");
        //while ()
        if ( urlData )
        {
            //delete past files (exclude subdirectories, delete only images)
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
            //write current file (as indicated by file title)
            NSString  *filePath = [downloadsDirectory stringByAppendingString:@"/"];
            filePath = [filePath stringByAppendingString:imageFilename];
            //NHLog(@"filepath: %@",filePath);
            [urlData writeToFile:filePath atomically:YES];
            //change wallpaper
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
            NSError *error;
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:nil, NSWorkspaceDesktopImageFillColorKey, [NSNumber numberWithBool:NO], NSWorkspaceDesktopImageAllowClippingKey, [NSNumber numberWithInteger:NSImageScaleProportionallyUpOrDown], NSWorkspaceDesktopImageScalingKey, nil];
            [[NSWorkspace sharedWorkspace] setDesktopImageURL:fileURL forScreen:[[NSScreen screens] lastObject]  options:options error:&error];
        }
    }
    return 0;
}
