//
//  AppDelegate.m
//  SublHandler
//
//  Created by Gabriel Rinaldi on 7/10/13.
//  Copyright (c) 2013 Gabriel Rinaldi. All rights reserved.
//

#import "NSURL+L0URLParsing.h"
#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setMenu:[self menu]];
	[statusItem setImage:[NSImage imageNamed:@"StatusBarIcon"]];
	[statusItem setHighlightMode:YES];
    [self setStatusItem:statusItem];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kDefaultsPathKey : kDefaultPath }];
}

/**
 * Handles URLs with format subl://open/?url=file:///path/to/file&line=11&column=2
 * Both line and col are optional.
 */
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    
    if ([[url host] isEqualToString:@"open"]) {
        NSDictionary *params = [url dictionaryByDecodingQueryString];
        NSString *fileURI = [params objectForKey:@"url"];
        
        if (fileURI) {
            NSString *fileName = [fileURI componentsSeparatedByString:@"://"][1];
            NSString *line = [params objectForKey:@"line"];
            NSString *column = [params objectForKey:@"column"];
            
            NSTask *task = [NSTask new];
            [task setLaunchPath:[self sublimePath]];
            NSString *filePath = [NSString stringWithFormat:@"%@:%ld:%ld", fileName, line ? [line integerValue] : 1, [column integerValue]];
            [task setArguments:@[ filePath ]];
            [task launch];
            
            NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
            NSString *appPath = [sharedWorkspace fullPathForApplication:@"Sublime Text 3"];
            NSFileManager *fileManager = [NSFileManager new];
            if (![fileManager isReadableFileAtPath:appPath]) {
                appPath = [sharedWorkspace fullPathForApplication:@"Sublime Text 2"];
            } else if (![fileManager isReadableFileAtPath:appPath]) {
                appPath = [sharedWorkspace fullPathForApplication:@"Sublime Text"];
            }
            
            NSString *identifier = [[NSBundle bundleWithPath:appPath] bundleIdentifier];
            NSArray *selectedApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:identifier];
            NSRunningApplication *runningApp = (NSRunningApplication *)[selectedApps objectAtIndex:0];
            [runningApp activateWithOptions:NSApplicationActivateAllWindows];
        }
    }
}

- (void)showPreferencesWindow:(id)sender {
    [[self textField] setStringValue:[self sublimePath]];
    [NSApp activateIgnoringOtherApps:YES];
    [[self preferencesWindow] makeKeyAndOrderFront:nil];
}

- (void)applyChange:(NSButton *)button {
    NSString *path = [[self textField] stringValue];
    if (path) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:path forKey:kDefaultsPathKey];
    }
    
    [[self preferencesWindow] orderOut:nil];
}

- (void)restoreDefaultPath:(NSButton *)button {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:kDefaultPath forKey:kDefaultsPathKey];

    [[self textField] setStringValue:kDefaultPath];
}

- (NSString *)sublimePath {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsPathKey];
}

@end
