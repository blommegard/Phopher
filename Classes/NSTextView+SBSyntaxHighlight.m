//
//  NSTextView+SBSyntaxHighlight.m
//  Phöpher
//
//  Created by Simon Blommegård on 2010-12-20.
//  Copyright 2010 Simon Blommegård. All rights reserved.
//

#import <ParseKit/ParseKit.h>

#import "NSTextView+SBSyntaxHighlight.h"

@implementation NSTextView (SBSyntaxHighlight)

- (void)highlightString {
	NSArray *selectedRanges = [self selectedRanges];
	
	PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:[self string]];
	
	//Initial tokenizer conf..
	[tokenizer.wordState setWordChars:YES from:'$' to:'$'];
	[tokenizer setTokenizerState:tokenizer.wordState from:'$' to:'$'];
	[tokenizer.wordState setWordChars:NO from:'\'' to:'\''];
	[tokenizer.commentState setReportsCommentTokens:YES];

	//Sets..
	NSSet *flowSet = [NSSet setWithObjects:@"for", @"while", @"if", @"else", @"elseif", @"foreach", @"do", @"return", @"case", @"break", @"switch", nil];
	NSSet *constantsSet = [NSSet setWithObjects:@"true", @"false", @"null", nil];
	
	//Create the output string..
	NSMutableAttributedString *outString = [[NSMutableAttributedString alloc] initWithString:[self string]];
	[outString addAttribute:NSFontAttributeName value:[self font] range:NSMakeRange(0, [outString length])];
	
	PKToken *eof = [PKToken EOFToken];
	PKToken *tok = nil;
	
	while ((tok = [tokenizer nextToken]) != eof) {
		NSLog(@"%@", [tok debugDescription]);
		// Quotes..
		if ([tok isQuotedString])
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange([tok offset], [[tok stringValue] length])];
		// Numbers
		if ([tok isNumber])
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange([tok offset], [[tok stringValue] length])];		
		// Variables
		if ([tok isWord] && [[tok stringValue] hasPrefix:@"$"])
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor greenColor] range:NSMakeRange([tok offset], [[tok stringValue] length])];
		// Stuffs
		if([tok isWord] && [flowSet containsObject:[[tok stringValue] lowercaseString]])
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor brownColor] range:NSMakeRange([tok offset], [[tok stringValue] length])];
		// Constants
		if([tok isWord] && [constantsSet containsObject:[[tok stringValue] lowercaseString]])
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor yellowColor] range:NSMakeRange([tok offset], [[tok stringValue] length])];
		// Symbols
		if([tok isSymbol])
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor orangeColor] range:NSMakeRange([tok offset], [[tok stringValue] length])];
		// Comment
		if([tok isComment]) {
//			NSFont *font = [[NSFontManager sharedFontManager]  convertFont:[self font] toHaveTrait:NSItalicFontMask];
//			[outString addAttribute:NSFontAttributeName value:font range:NSMakeRange([tok offset], [[tok stringValue] length])];
			
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor greenColor] range:NSMakeRange([tok offset], [[tok stringValue] length])];
		}

	}
	
	[[self textStorage] setAttributedString:outString];
	[self setSelectedRanges:selectedRanges];
}

@end
