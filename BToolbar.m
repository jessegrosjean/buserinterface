//
//  BToolbar.m
//  BUserInterface
//
//  Created by Jesse Grosjean on 9/8/08.
//  Copyright 2008 Hog Bay Software. All rights reserved.
//

#import "BToolbar.h"


@implementation BToolbar

- (void)setVisible:(BOOL)shown {
	if ([self isVisible] != shown) {
		id delegate = [self delegate];
		
		if (shown) {
			if ([delegate respondsToSelector:@selector(toolbarWillShow:)]) {
				[delegate toolbarWillShow:self];
			}
		} else {
			if ([delegate respondsToSelector:@selector(toolbarWillHide:)]) {
				[delegate toolbarWillHide:self];
			}
		}
		[super setVisible:shown];
	}
}

- (void)runCustomizationPalette:(id)sender {
	id delegate = [self delegate];
	
	if ([delegate respondsToSelector:@selector(toolbarWillRunCustomizationPalette:)]) {
		[delegate toolbarWillRunCustomizationPalette:self];
	}
	
	[super runCustomizationPalette:sender];
}

@end
