// Copyright (c) 2012 Intel Corp
// Copyright (c) 2012 The Chromium Authors
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell co
// pies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in al
// l copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IM
// PLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNES
// S FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WH
// ETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#include "content/nw/src/api/shell/shell.h"
#include "base/values.h"

#import <AppKit/NSApplication.h>
#import <AppKit/NSWorkspace.h>
#import <AppKit/NSSound.h>

#import <Foundation/Foundation.h>

#import <AppKit/NSMenuItem.h>
#import <Foundation/NSArray.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSWorkspace.h>

namespace api {

    //--------------------------------------------------------------------------------
    void Shell::SetBadgeText(const std::string& badgeText) {
        NSString *nsBadgeText = [NSString stringWithUTF8String:badgeText.c_str()];
        
        [[NSApp dockTile] setBadgeLabel:nsBadgeText];
        if ( ([nsBadgeText length] >0) && (![NSApp isActive ])){
            [NSApp requestUserAttention:NSInformationalRequest];
        }
    }
    
    //--------------------------------------------------------------------------------
    void Shell::RequestUserAttention (){
        [NSApp requestUserAttention:NSInformationalRequest];
    }
    
    //--------------------------------------------------------------------------------
    void executeShell(NSString* a_cmdString, NSArray* a_params) {

        try{
            // Set up the process
            NSTask *t = [[[NSTask alloc] init] autorelease];
            [t setLaunchPath:a_cmdString];
            [t setArguments:a_params];
            
            // Set the pipe to the standard output and error to get the results of the command
            NSPipe *p = [[[NSPipe alloc] init] autorelease];
            [t setStandardOutput:p];
            [t setStandardError:p];
            
            // Launch (forks) the process
            [t launch]; // raises an exception if something went wrong
            
            // Prepare to read
            NSFileHandle *readHandle = [p fileHandleForReading];
            NSData *inData = nil;
            NSMutableData *totalData = [[[NSMutableData alloc] init] autorelease];
            
            while ((inData = [readHandle availableData]) &&
                   [inData length]) {
                [totalData appendData:inData];
            }
            
            // Polls the runloop until its finished
            [t waitUntilExit];
            
        }
        catch (NSException *e){
            NSLog(@"Expection occurred in executeShell");
            
        }
    }
    
    //--------------------------------------------------------------------------------
    void Shell::previewItem (const std::string& filePath){
        NSString *nsfilePath = [NSString stringWithUTF8String:filePath.c_str()];
        NSArray *arguments= [NSArray arrayWithObjects: @"-p",nsfilePath,nil];
        executeShell(@"/usr/bin/qlmanage",arguments);
    }
    
    //--------------------------------------------------------------------------------
    void Shell::notify (const std::string& title,const std::string& text,const std::string& icon,const std::string& sound){
        
//        NSUserNotification *userNotification = [NSUserNotification new];
//        userNotification.title = [NSString stringWithUTF8String:title.c_str()];
//        //userNotification.subtitle = subtitle;
//        userNotification.informativeText = [NSString stringWithUTF8String:text.c_str()];
//        //userNotification.userInfo = options;
//        
//        if (sound.length() != 0) {
//            NSString* rsnd= [NSString stringWithUTF8String:filePath.c_str()];
//            userNotification.soundName = [rsnd isEqualToString: @"default"] ? NSUserNotificationDefaultSoundName : rsnd ;
//        }
//        
//        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
//        [center scheduleNotification:userNotification];
    }
    
    
}  // namespace api
