# WallpaperSwitcher
Daily wallpaper switching tool for MacOS, integrates into System Preferences.

Allows to automatically switch wallpaper at selected interval, to an image coming from Web source: 
- Bing Daily Image
- National Geographic Photo of the Day
- Reddit post
- custom URL

Tested on MacOS Mojave (10.14) and MacOS Sierra (10.12).

Overview
-----------

App consists of two main parts:
- preference pane that integrates into MacOS System Preferences and allows to configure all sorts of options (wallpaper source, how often switch etc.)
- command-line tool that downloads the image (saves it into hard disk, and asks OS to switch it)

The command-line tool is included into the Pref pane bundle and installs together with it. During runtime it is periodaically invoked by MacOS native scheduler - launchd (the setup is done via Preference Pane).

Installation
-----------
To install simply open / double click the Preference Pane and add it to your System Preferences. Afterwards go to Wallpaper Switcher preferences and press "Enable".

Usage / Options
-----------

Available options are:
- **Download New Wallpaper (interval).** Choose how often the wallpaper should be switched: every 6 hours, every 12 hours, every day, twice a week, weekly
- **Wallpaper source.** Select where the wallpaper should be downloaded from: Bing, National Geographic, selected Reddit board, custom URL
- **Custom URL / Custom Subreddit.** Input custom URL if source is "Other ..." or subreddit name in format /r/<name> 
- **Retry download if network down.** If internet connection is unavailable or source website is down, Wallpaper Switcher can re-attempt downloading the image several times.
-- **retry x times.** Set how many times re-download should be attempted.
-- **every x seconds.** Set how long should Wallpaper Switcher wait before attempting to download image if connection was down.
- **Downloads directory.** Set a custom directory to which all wallpapers should be downloaded.
- **Delete past image files in downloads directory.** If selected, prior to downloading new image, all previous images in the downloads directory will be deleted 
(should be used with care as Wallpaper Switcher will delete all image files in the specified directory).
- **Write Logs.** Write output and any error messages to ~/Library/Logs/wswitcherd/
- **Update Wallpaper now.** Forces app to update wallpaper regardless of any scheduler settings.
- **Enable / Disable.** Starts scheduler with whatever options selected.

If Wallpaper Switcher is enabled all changes in options should be instant and automaticly applied (no need to restart anything). 
E.g. if enabled and changing source, you should see the wallpaper downloading / changing instant.

