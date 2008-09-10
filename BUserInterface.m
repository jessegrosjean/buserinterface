//
//  BUserInterface.m
//  BUserInterface
//
//  Created by Jesse Grosjean on 7/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BUserInterface.h"


@implementation NSApplication (BUserInterfaceAdditions)

+ (void)load {
    if (self == [NSApplication class]) {
		[NSApplication replaceMethod:@selector(sendEvent:) withMethod:@selector(BUserInterface_sendEvent:)];
    }
}

static SEL doubleTapShiftKeyAction = NULL;
static SEL doubleTapControlKeyAction = NULL;
static SEL doubleTapAlternateKeyAction = NULL;
static SEL doubleTapCommandKeyAction = NULL;

+ (SEL)doubleTapShiftKeyAction {
	return doubleTapShiftKeyAction;
}

+ (void)setDoubleTapShiftKeyAction:(SEL)action {
	doubleTapShiftKeyAction = action;
}

+ (SEL)doubleTapControlKeyAction {
	return doubleTapControlKeyAction;
}

+ (void)setDoubleTapControlKeyAction:(SEL)action {
	doubleTapControlKeyAction = action;
}

+ (SEL)doubleTapAlternateKeyAction {
	return doubleTapAlternateKeyAction;
}

+ (void)setDoubleTapAlternateKeyAction:(SEL)action {
	doubleTapAlternateKeyAction = action;
}

+ (SEL)doubleTapCommandKeyAction {
	return doubleTapCommandKeyAction;
}

+ (void)setDoubleTapCommandKeyAction:(SEL)action {
	doubleTapCommandKeyAction = action;
}

// states:
// 0 - looking for first down
// 1 - looking for first up.
// 2 - looking for second down.
// 3 - looking for second up.

static NSTimeInterval startTimeStamp;
static NSInteger shiftKeyState;
static NSInteger controlKeyState;
static NSInteger alternateKeyState;
static NSInteger commandKeyState;
static BOOL lastShiftKeyDown;
static BOOL lastControlKeyDown;
static BOOL lastAlternateKeyDown;
static BOOL lastCommandKeyDown;

- (void)BUserInterface_sendEvent:(NSEvent *)anEvent {
	if ([anEvent type] == NSFlagsChanged) {
		NSUInteger modifierFlags = [anEvent modifierFlags];
		NSTimeInterval newTimestamp = [anEvent timestamp];

		if (shiftKeyState == 0 && controlKeyState == 0 && alternateKeyState == 0 && commandKeyState == 0) {
			startTimeStamp = newTimestamp;
		} else if (newTimestamp - startTimeStamp > 0.5) {
			shiftKeyState = 0;
			controlKeyState = 0;
			alternateKeyState = 0;
			commandKeyState = 0;
			startTimeStamp = newTimestamp;
		}

		BOOL shiftKeyDown = ((modifierFlags & NSAlphaShiftKeyMask) != 0 || (modifierFlags & NSShiftKeyMask));
		BOOL controlKeyDown = (modifierFlags & NSControlKeyMask) != 0;
		BOOL alternateKeyDown = (modifierFlags & NSAlternateKeyMask) != 0;
		BOOL commandKeyDown = (modifierFlags & NSCommandKeyMask) != 0;
		
		if (doubleTapShiftKeyAction != nil && lastShiftKeyDown != shiftKeyDown) {
			if (shiftKeyDown && shiftKeyState == 0) {
				shiftKeyState++;
			} else if (!shiftKeyDown && shiftKeyState == 1) {
				shiftKeyState++;
			} else if (shiftKeyDown && shiftKeyState == 2) {
				shiftKeyState++;
			} else if (!shiftKeyDown && shiftKeyState == 3) {
				[self sendAction:doubleTapShiftKeyAction to:nil from:nil];
				shiftKeyState = 0;
			}
			lastShiftKeyDown = shiftKeyDown;
		}

		if (doubleTapControlKeyAction != nil && lastControlKeyDown != controlKeyDown) {
			if (controlKeyDown && shiftKeyState == 0) {
				controlKeyState++;
			} else if (!controlKeyDown && controlKeyState == 1) {
				controlKeyState++;
			} else if (controlKeyDown && controlKeyState == 2) {
				controlKeyState++;
			} else if (!controlKeyDown && controlKeyState == 3) {
				[self sendAction:doubleTapControlKeyAction to:nil from:nil];
				controlKeyState = 0;
			}
			controlKeyDown = lastControlKeyDown;
		}
		    
		if (doubleTapAlternateKeyAction != nil && lastAlternateKeyDown != alternateKeyDown) {
			if (alternateKeyDown && shiftKeyState == 0) {
				alternateKeyState++;
			} else if (!alternateKeyDown && alternateKeyState == 1) {
				alternateKeyState++;
			} else if (alternateKeyDown && alternateKeyState == 2) {
				alternateKeyState++;
			} else if (!alternateKeyDown && alternateKeyState == 3) {
				[self sendAction:doubleTapAlternateKeyAction to:nil from:nil];
				alternateKeyState = 0;
			}
			lastAlternateKeyDown = alternateKeyDown;
		}
		
		if (doubleTapCommandKeyAction != nil && lastCommandKeyDown != commandKeyDown) {
			if (commandKeyDown && shiftKeyState == 0) {
				commandKeyState++;
			} else if (!commandKeyDown && commandKeyState == 1) {
				commandKeyState++;
			} else if (commandKeyDown && commandKeyState == 2) {
				commandKeyState++;
			} else if (!commandKeyDown && commandKeyState == 3) {
				[self sendAction:doubleTapCommandKeyAction to:nil from:nil];
				commandKeyState = 0;
			}
			lastCommandKeyDown = commandKeyDown;
		}		
	}	
	
	[self BUserInterface_sendEvent:anEvent];
}

@end

@implementation NSImage (BUserInterfaceAdditions)

- (CIImage *)toCIImage {
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
    return [[CIImage alloc] initWithBitmapImageRep:bitmap];
}

- (NSImage *)toNSImage:(CIImage *)ciImage {
	CGRect extent = [ciImage extent];
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(extent.size.width, extent.size.height)];
    [image addRepresentation:[NSCIImageRep imageRepWithCIImage:ciImage]];
    return image;
}

- (NSImage *)coreImageTintedImageWithColor:(NSColor *)inTint {
	NSSize theSize = [self size];
	NSImage *theNewImage = [[NSImage alloc] initWithSize:theSize];  
	
	[theNewImage lockFocus];
	
	CGRect cg = CGRectMake(0, 0, theSize.width, theSize.height);
	CIContext* context = [[NSGraphicsContext currentContext] CIContext];
	
	if (context != nil) {
        CIImage *image = [self toCIImage];
		CIColor *color = [[CIColor alloc] initWithColor:inTint];
		CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust" keysAndValues:@"inputImage", image, @"inputColor", color, nil];
		[context drawImage:[filter valueForKey: @"outputImage"] atPoint:cg.origin fromRect:cg];
	}
	
	[theNewImage unlockFocus];
	
	return theNewImage;
}

- (NSImage *)tintedImageWithColor:(NSColor *)inTint {
	return [self tintedImageWithColor:inTint operation:NSCompositeSourceAtop];
}

- (NSImage *)tintedImageWithColor:(NSColor *)inTint operation:(NSCompositingOperation)inOperation {
	NSSize theSize = [self size];
	NSImage *theNewImage = [[NSImage alloc] initWithSize:theSize];  
	
	[theNewImage lockFocus];
	
	[self compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];  
	[inTint set]; 
	NSRectFillUsingOperation(NSMakeRect(0, 0, theSize.width, theSize.height), inOperation); 
	
	[theNewImage unlockFocus];
	
	return theNewImage;
}

@end

@implementation NSMenu (BUserInterfaceAdditions)

- (NSArray *)allItems:(BOOL)includeSubmenus {
	NSMutableArray *allItems = [NSMutableArray arrayWithCapacity:[self numberOfItems]];
	for (NSMenuItem *each in [self itemArray]) {
		[allItems addObject:each];
		if (includeSubmenus) {
			NSMenu *submenu = [each submenu];
			if (submenu) {
				[allItems addObjectsFromArray:[submenu allItems:YES]];
			}
		}
	}
	return allItems;
	
}

- (NSMenuItem *)itemWithRepresentedObject:(id)representedObject {
	for (NSMenuItem *each in [self itemArray]) {
		if ([[each representedObject] isEqual:representedObject]) {
			return each;
		}
	}
	return nil;
}

@end