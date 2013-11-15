//
//  PRHAppDelegate.m
//  Hotkeys
//
//  Created by Peter Hosey on 2013-11-15.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#import "PRHAppDelegate.h"

#import "PRHHotkeysWindowController.h"

@implementation PRHAppDelegate
{
	PRHHotkeysWindowController *_wc;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	_wc = [PRHHotkeysWindowController new];
	[_wc showWindow:nil];
}
- (void)applicationWillTerminate:(NSNotification *)notification {
	[_wc close];
	_wc = nil;
}

@end
