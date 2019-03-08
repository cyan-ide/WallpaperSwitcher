//
//  NHLogger.h
//  WallpaperSwitcher
//
//  Created by adam on 5/3/19.
//  Copyright © 2019 Adam Westerski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHLogger : NSObject

void NHLog(NSString* format, ...);
void NHFileLog(NSString* filePath,NSString* format, ...);
void NHErrFileLog(NSString* filePath,NSString* format, ...);

@end

NS_ASSUME_NONNULL_END
