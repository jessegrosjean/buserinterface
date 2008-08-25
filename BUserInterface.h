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
#import "BMenuController.h"
#import "BToolbarController.h"

@interface NSImage (BUserInterfaceAdditions)

- (NSImage *)coreImageTintedImageWithColor:(NSColor *)inTint;
- (NSImage *)tintedImageWithColor:(NSColor *)inTint;
- (NSImage *)tintedImageWithColor:(NSColor *)inTint operation:(NSCompositingOperation)inOperation;

@end

@interface NSMenu (BUserInterfaceAdditions)

- (NSMenuItem *)itemWithRepresentedObject:(id)representedObject;

@end