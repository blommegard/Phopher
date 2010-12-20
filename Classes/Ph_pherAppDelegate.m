//
//  Ph_pherAppDelegate.m
//  Phöpher
//
//  Created by Simon Blommegård on 2009-12-07.
//  Copyright 2009 Simon Blommegård. All rights reserved.
//

#import "Ph_pherAppDelegate.h"
#import "NoodleLineNumberView.h"
#import "NSTextView+SBSyntaxHighlight.h"

@interface Ph_pherAppDelegate ()

@property(retain) NSURL *includeFileURL;
@property BOOL enableIncludeFile;

@end


@implementation Ph_pherAppDelegate

@synthesize window, includeFileURL, enableIncludeFile;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[inputTextContainer setFont:[NSFont fontWithName:@"Menlo" size:13]];
	[inputTextContainer setTextColor:[NSColor blackColor]];
	[outputTextContainer setFont:[NSFont fontWithName:@"Menlo" size:13]];
	[outputTextContainer setTextColor:[NSColor blackColor]];
	
	[NSApp setServicesProvider:self];
}

- (void)awakeFromNib {
	lineNumberView = [[NoodleLineNumberView alloc] initWithScrollView:scrollView];
	[scrollView setVerticalRulerView:lineNumberView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    [scrollView setRulersVisible:YES];
	[window makeFirstResponder:scrollView];
}

#pragma mark -

- (NSString *)executeCode: (NSString *)code {
	NSTask *task = [[NSTask alloc] init];
	NSPipe *inputPipe = [NSPipe pipe];
	NSPipe *outputPipe = [NSPipe pipe];
	
	[task setStandardInput:inputPipe];
	[task setStandardOutput:outputPipe];
	[task setLaunchPath:@"/usr/bin/php"];
	
	[task launch];
	
	NSString *include = [NSString stringWithContentsOfURL:includeFileURL encoding:NSUTF8StringEncoding error:nil];
	NSString *input = [NSString stringWithFormat:@"<?php %@ ?>", code];

	// include a file?
	if([includeFileCheckBox state] == NSOnState && !service) {
		// before...or after the the input?
		if ([includeFileSecmentedControl isSelectedForSegment:0]) {
			[[inputPipe fileHandleForWriting] writeData:[include dataUsingEncoding:NSUTF8StringEncoding]];
			[[inputPipe fileHandleForWriting] writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];
		} else {
			[[inputPipe fileHandleForWriting] writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];	
			[[inputPipe fileHandleForWriting] writeData:[include dataUsingEncoding:NSUTF8StringEncoding]];
		}
	} else {
		[[inputPipe fileHandleForWriting] writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[[inputPipe fileHandleForWriting] closeFile];
	
	NSData *output = [[outputPipe fileHandleForReading] readDataToEndOfFile];
	
	return [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
}

- (void) runServiceCode:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
	service = TRUE;
	NSString *pboardString = [pboard stringForType:NSStringPboardType];
	NSString *newString = [self executeCode:pboardString];
	
	[window	orderOut:self];
	[bezelTextView setString:newString];
	[bezelTextView setFont:[NSFont fontWithName:@"Menlo" size:12]];
	[bezelTextView setTextColor:[NSColor whiteColor]];
	[bezelWindow makeKeyAndOrderFront:nil];
}

#pragma mark -

-(IBAction) runCode: (id) sender {
	service = FALSE;
	[outputTextContainer setString:[self executeCode: [inputTextContainer string]]];
}

-(IBAction) copyToClipboard: (id) sender {
	if ([[outputTextContainer string] length] != 0) {
		NSPasteboard *pboard = [NSPasteboard generalPasteboard];
		[pboard clearContents];
		[pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
		[pboard setString:[outputTextContainer string] forType:NSPasteboardTypeString];
	}
}

-(IBAction) HUDcopyToClipboard: (id) sender {
	if ([[bezelTextView string] length] != 0) {
		NSPasteboard *pboard = [NSPasteboard generalPasteboard];
		[pboard clearContents];
		[pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
		[pboard setString:[bezelTextView string] forType:NSPasteboardTypeString];
		[bezelWindow orderOut:self];
	}
}

-(IBAction) includeFileCheckBoxClicked: (id) sender {
	// we click the checkbox and there's no file selected
	if([includeFileCheckBox state] && !includeFileURL) {
		NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
		[openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
			self.includeFileURL = [openPanel URL];
			if (result == NSFileHandlingPanelCancelButton)
				self.enableIncludeFile = NO;
		}];
	}
}

#pragma mark -

- (void)textDidChange:(NSNotification *)aNotification {	
	[inputTextContainer highlightString];
}

#pragma mark -

- (void)pathControl:(NSPathControl *)pathControl willDisplayOpenPanel:(NSOpenPanel *)openPanel {
	// dialogsettings
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setResolvesAliases:YES];
	[openPanel setTitle:@"Choose a PHP file to include"];
	[openPanel setPrompt:@"Choose"];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	[window makeKeyAndOrderFront:nil];
	[inputTextContainer selectAll:nil];
	[window makeFirstResponder:inputTextContainer];
	return YES;
}
@end
