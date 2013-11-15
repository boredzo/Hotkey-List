//
//  PRHHotkeysWindowController.m
//  Hotkeys
//
//  Created by Peter Hosey on 2013-11-15.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#import "PRHHotkeysWindowController.h"

#include <Carbon/Carbon.h>
#import "SRCommon.h"

@interface PRHHotkeysWindowController () <NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation PRHHotkeysWindowController
{
	NSArray *_hotkeys;
}

- (instancetype) initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
		CFArrayRef hotkeys = NULL;
		OSStatus err = CopySymbolicHotKeys(&hotkeys);
		if (err == noErr) {
			_hotkeys = (__bridge_transfer NSArray *)hotkeys;
		}
    }
    return self;
}

- (instancetype) init {
	return [self initWithWindowNibName:NSStringFromClass([self class])];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return _hotkeys.count <= NSIntegerMax ? _hotkeys.count : NSIntegerMax;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
	NSDictionary *hotkey = _hotkeys[row];
	if ([column.identifier isEqualToString:@"enabled"]) {
		NSNumber *enabledNum = hotkey[(__bridge NSString *)kHISymbolicHotKeyEnabled];
		return @(enabledNum.boolValue ? NSOnState : NSOffState);
	} else if ([column.identifier isEqualToString:@"keyCombo"]) {
		NSNumber *keyCodeNum = hotkey[(__bridge NSString *)kHISymbolicHotKeyCode];
		NSNumber *keyModifiersNum = hotkey[(__bridge NSString *)kHISymbolicHotKeyModifiers];
		return SRStringForCarbonModifierFlagsAndKeyCode(keyModifiersNum.unsignedIntegerValue, keyCodeNum.unsignedIntegerValue);
	}

	return nil;
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
	NSArray *sortDescriptors = tableView.sortDescriptors;
	NSArray *hotkeys = _hotkeys;
	for (NSSortDescriptor *desc in [sortDescriptors reverseObjectEnumerator]) {
		if ([desc.key isEqualToString:@"string"]) {
			hotkeys = [hotkeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSDictionary *dict1 = obj1, *dict2 = obj2;

				NSNumber *keyCode1Num = dict1[(__bridge NSString *)kHISymbolicHotKeyCode];
				NSNumber *keyModifiers1Num = dict1[(__bridge NSString *)kHISymbolicHotKeyModifiers];
				NSString *string1 = SRStringForCarbonModifierFlagsAndKeyCode(keyModifiers1Num.unsignedIntegerValue, keyCode1Num.unsignedIntegerValue);

				NSNumber *keyCode2Num = dict2[(__bridge NSString *)kHISymbolicHotKeyCode];
				NSNumber *keyModifiers2Num = dict2[(__bridge NSString *)kHISymbolicHotKeyModifiers];
				NSString *string2 = SRStringForCarbonModifierFlagsAndKeyCode(keyModifiers2Num.unsignedIntegerValue, keyCode2Num.unsignedIntegerValue);

				return [string1 compare:string2];
			}];
		} else {
			hotkeys = [hotkeys sortedArrayUsingDescriptors:@[desc]];
		}
	}
	_hotkeys = hotkeys;
	[tableView reloadData];
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
	NSUInteger numToCopy = rowIndexes.count;
	if (numToCopy == 0)
		return NO;

	NSArray *hotkeysToCopy = [_hotkeys objectsAtIndexes:rowIndexes];
	NSMutableArray *hotkeyStrings = [NSMutableArray arrayWithCapacity:numToCopy];
	for (NSDictionary *hotkey in hotkeysToCopy) {
		NSNumber *keyCodeNum = hotkey[(__bridge NSString *)kHISymbolicHotKeyCode];
		NSNumber *keyModifiersNum = hotkey[(__bridge NSString *)kHISymbolicHotKeyModifiers];
		NSString *string = SRStringForCarbonModifierFlagsAndKeyCode(keyModifiersNum.unsignedIntegerValue, keyCodeNum.unsignedIntegerValue);
		[hotkeyStrings addObject:string];
	}

	[pboard clearContents];
	return [pboard writeObjects:hotkeyStrings];
}

- (IBAction) copy:(id)sender {
	if (![self tableView:self.tableView writeRowsWithIndexes:self.tableView.selectedRowIndexes toPasteboard:[NSPasteboard generalPasteboard]])
		NSBeep();
}

@end
