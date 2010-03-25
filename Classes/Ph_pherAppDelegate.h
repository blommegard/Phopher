//
//  Ph_pherAppDelegate.h
//  Phöpher
//
//  Created by Simon Blommegård on 2009-12-07.
//  Copyright 2009 Simon Blommegård. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NoodleLineNumberView;

@interface Ph_pherAppDelegate : NSObject <NSApplicationDelegate, NSPathControlDelegate> {
    NSWindow *window;
	
	IBOutlet NSTextView *inputTextContainer;
	IBOutlet NSTextView *outputTextContainer;
	IBOutlet NSScrollView *scrollView;
	NoodleLineNumberView *lineNumberView;
	
	IBOutlet NSWindow *bezelWindow;
	IBOutlet NSTextView *bezelTextView;
	
	IBOutlet NSButton *includeFileCheckBox;
	IBOutlet NSSegmentedControl *includeFileSecmentedControl;
	
	BOOL service;
	NSURL *includeFileURL;
	BOOL enableIncludeFile;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction) runCode: (id) sender;
-(IBAction) copyToClipboard: (id) sender;
-(IBAction) HUDcopyToClipboard: (id) sender;

-(IBAction) includeFileCheckBoxClicked: (id) sender;
@end
