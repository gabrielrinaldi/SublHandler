//
//  AppDelegate.h
//  SublHandler
//
//  Created by Gabriel Rinaldi on 7/10/13.
//  Copyright (c) 2013 Gabriel Rinaldi. All rights reserved.
//

#pragma mark AppDelegate

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *menu;
@property (unsafe_unretained) IBOutlet NSWindow *preferencesWindow;
@property (weak) IBOutlet NSTextField *textField;

- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)applyChange:(id)sender;
- (IBAction)restoreDefaultPath:(id)sender;

@end
