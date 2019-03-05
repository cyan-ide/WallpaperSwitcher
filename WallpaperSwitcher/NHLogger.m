//
//  NHLogger.m
//  WallpaperSwitcher
//
//  Created by adam on 5/3/19.
//  Copyright © 2019 Adam Westerski. All rights reserved.
//

#import "NHLogger.h"

@implementation NHLogger

void NHLog(NSString* format, ...)
{
#if DEBUG
    static NSDateFormatter* timeStampFormat;
    if (!timeStampFormat) {
        timeStampFormat = [[NSDateFormatter alloc] init];
        [timeStampFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [timeStampFormat setTimeZone:[NSTimeZone systemTimeZone]];
    }
    
    NSString* timestamp = [timeStampFormat stringFromDate:[NSDate date]];
    
    va_list vargs;
    va_start(vargs, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat:format arguments:vargs];
    va_end(vargs);
    
    NSString* message = [NSString stringWithFormat:@"\n[%@] %@", timestamp, formattedMessage];
    
    printf("%s\n", [message UTF8String]);
#endif
}

void NHFileLog(NSString* filePath,NSString* format, ...)
{
#if DEBUG
    static NSDateFormatter* timeStampFormat;
    if (!timeStampFormat) {
        timeStampFormat = [[NSDateFormatter alloc] init];
        [timeStampFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [timeStampFormat setTimeZone:[NSTimeZone systemTimeZone]];
    }
    
    NSString* timestamp = [timeStampFormat stringFromDate:[NSDate date]];
    
    va_list vargs;
    va_start(vargs, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat:format arguments:vargs];
    va_end(vargs);
    
    NSString* message = [NSString stringWithFormat:@"\n[%@] %@", timestamp, formattedMessage];
    
    printf("%s\n", [message UTF8String]);
    
    //NSError *error;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //    [message writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    ////
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        // Add the text at the end of the file.
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:data];
        [fileHandler closeFile];
    } else {
        // Create the file and write text to it.
        [data writeToFile:filePath atomically:YES];
    }
#endif
}

@end
