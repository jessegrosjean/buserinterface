//
//  BUserInterface.h
//  BUserInterface
//
//  Created by Jesse Grosjean on 7/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Blocks/Blocks.h>
#import <QuartzCore/QuartzCore.h>
#import "BUserInterfaceController.h"
#import "BToolbarController.h"

@interface NSApplication (BUserInterfaceAdditions)

+ (NSUInteger)applicationLaunchCount;
+ (SEL)doubleTapShiftKeyAction;
+ (void)setDoubleTapShiftKeyAction:(SEL)action;
+ (SEL)doubleTapControlKeyAction;
+ (void)setDoubleTapControlKeyAction:(SEL)action;
+ (SEL)doubleTapAlternateKeyAction;
+ (void)setDoubleTapAlternateKeyAction:(SEL)action;
+ (SEL)doubleTapCommandKeyAction;
+ (void)setDoubleTapCommandKeyAction:(SEL)action;
+ (void)skipNextActiviation;

@end

@interface NSImage (BUserInterfaceAdditions)

- (NSImage *)coreImageTintedImageWithColor:(NSColor *)inTint;
- (NSImage *)tintedImageWithColor:(NSColor *)inTint;
- (NSImage *)tintedImageWithColor:(NSColor *)inTint operation:(NSCompositingOperation)inOperation;

@end

@interface NSMenu (BUserInterfaceAdditions)

+ (NSAttributedString *)mainMenuKeyEquivalentsReport;

- (NSArray *)allItems:(BOOL)includeSubmenus;
- (NSMenuItem *)itemWithRepresentedObject:(id)representedObject;

@end

@interface BFontNameToDisplayNameTransformer : NSValueTransformer {
}
@end

@interface BTextFieldFontChooser : NSTextField {
	NSString *fontDefaultsKey;
}

@property(retain) NSString *fontDefaultsKey;
@property(readonly) NSFont *selectedFont;

- (IBAction)chooseFont:(id)sender;

@end