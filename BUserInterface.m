//
//  BUserInterface.m
//  BUserInterface
//
//  Created by Jesse Grosjean on 7/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BUserInterface.h"


static BOOL inCompleteMethod = NO;

@implementation NSTextView (BUserInterfaceMethodReplacements)

+ (void)load {
    if (self == [NSTextView class]) {
		[NSTextView replaceMethod:@selector(complete:) withMethod:@selector(BUserInterface_complete:)];
    }
}

- (void)BUserInterface_complete:(id)sender {
	inCompleteMethod = YES;
	[self BUserInterface_complete:sender];
	inCompleteMethod = NO;
}

@end

@implementation NSApplication (BUserInterfaceAdditions)

+ (void)load {
    if (self == [NSApplication class]) {
		[NSApplication replaceMethod:@selector(sendEvent:) withMethod:@selector(BUserInterface_sendEvent:)];
		[NSApplication replaceMethod:@selector(nextEventMatchingMask:untilDate:inMode:dequeue:) withMethod:@selector(BUserInterface_nextEventMatchingMask:untilDate:inMode:dequeue:)];
		[NSApplication replaceMethod:@selector(activateIgnoringOtherApps:) withMethod:@selector(BUserInterface_activateIgnoringOtherApps:)];
    }
}

+ (NSUInteger)applicationLaunchCount {
	return [[[NSUserDefaults standardUserDefaults] objectForKey:@"UIApplicationLaunchCount"] integerValue];
}

static SEL doubleTapShiftKeyAction = NULL;
static SEL doubleTapControlKeyAction = NULL;
static SEL doubleTapAlternateKeyAction = NULL;
static SEL doubleTapCommandKeyAction = NULL;
static BOOL skipNextActiviation = NO;

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

+ (void)skipNextActiviation {
	// Hack because in Leopard services always active the application.
	skipNextActiviation = YES;
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

- (NSEvent *)BUserInterface_nextEventMatchingMask:(NSUInteger)mask untilDate:(NSDate *)expiration inMode:(NSString *)mode dequeue:(BOOL)deqFlag {
	if (inCompleteMethod) {
		mask &= ~NSAppKitDefinedMask;
	}
	return [self BUserInterface_nextEventMatchingMask:mask untilDate:expiration inMode:mode dequeue:deqFlag];
}

- (void)BUserInterface_activateIgnoringOtherApps:(BOOL)flag {
	if (skipNextActiviation) {
		flag = NO;
		skipNextActiviation = NO;
	}	
	[self BUserInterface_activateIgnoringOtherApps:flag];
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

+ (NSString *)keyEquivalentModifierMaskDescription:(NSUInteger)keyEquivalentModifierMask {
	NSMutableArray *modifiers = [NSMutableArray array];
	if (NSCommandKeyMask & keyEquivalentModifierMask) [modifiers addObject:@"Command"];
	if (NSAlternateKeyMask & keyEquivalentModifierMask) [modifiers addObject:@"Option"];
	if (NSControlKeyMask & keyEquivalentModifierMask) [modifiers addObject:@"Control"];
	if (NSShiftKeyMask & keyEquivalentModifierMask) [modifiers addObject:@"Shift"];
	return [modifiers componentsJoinedByString:@"-"];
}

+ (NSAttributedString *)mainMenuKeyEquivalentsReport {
	NSMenu *mainMenu = [NSApp mainMenu];
	NSArray *allMenuItems = [mainMenu allItems:YES];
	NSMutableDictionary *existingKeyEquivalents = [NSMutableDictionary dictionary];
	NSMutableDictionary *validKeyEquivalentsToStringRepresentations = [NSMutableDictionary dictionaryWithObjectsAndKeys:
																	   @"Space",@" ", 
																	   @"ParagraphSeparator", [NSString stringWithFormat:@"%C", NSParagraphSeparatorCharacter], 
																	   @"LineSeparator", [NSString stringWithFormat:@"%C", NSLineSeparatorCharacter],
																	   @"Tab", [NSString stringWithFormat:@"%C", NSTabCharacter], 
																	   @"FormFeed",[NSString stringWithFormat:@"%C", NSFormFeedCharacter], 
																	   @"Newline",[NSString stringWithFormat:@"%C", NSNewlineCharacter],  
																	   @"CarriageReturn",[NSString stringWithFormat:@"%C", NSCarriageReturnCharacter],  
																	   @"Enter",[NSString stringWithFormat:@"%C", NSEnterCharacter],  
																	   @"Backspace",[NSString stringWithFormat:@"%C", NSBackspaceCharacter],  
																	   @"Delete",[NSString stringWithFormat:@"%C", NSDeleteCharacter], 
																	   @"UpArrow",[NSString stringWithFormat:@"%C", NSUpArrowFunctionKey], 
																	   @"DownArrow",[NSString stringWithFormat:@"%C", NSDownArrowFunctionKey], 
																	   @"LeftArrow",[NSString stringWithFormat:@"%C", NSLeftArrowFunctionKey], 
																	   @"RightArrow",[NSString stringWithFormat:@"%C", NSRightArrowFunctionKey], 
																	   @"Insert",[NSString stringWithFormat:@"%C", NSInsertFunctionKey], 
																	   @"Home",[NSString stringWithFormat:@"%C", NSHomeFunctionKey], 
																	   @"PageUp",[NSString stringWithFormat:@"%C", NSPageUpFunctionKey], 
																	   @"PageDown",[NSString stringWithFormat:@"%C", NSPageDownFunctionKey], 
																	   nil];
	
	for (NSString *each in [@"` ~ 1 ! 2 @ 3 # 4 $ 5 % 6 ^ 7 & 8 * 9 ( 0 ) - _ = + q w e r t y u i o p [ { ] } \\ | a s d f g h j k l ; : ' \" z x c v b n m , < . > / ?" componentsSeparatedByString:@" "]) {
		[validKeyEquivalentsToStringRepresentations setObject:[each uppercaseString] forKey:each];
	}

	for (NSMenuItem *eachMenuItem in allMenuItems) {
		NSString *keyEquivalent = [eachMenuItem keyEquivalent];

		if ([keyEquivalent length] > 0) {								
			NSUInteger keyEquivalentModifierMask = [eachMenuItem keyEquivalentModifierMask];
			
			if (![keyEquivalent isEqualToString:[keyEquivalent lowercaseString]]) {
				keyEquivalent = [keyEquivalent lowercaseString];
				keyEquivalentModifierMask |= NSShiftKeyMask;
			}

			keyEquivalent = [validKeyEquivalentsToStringRepresentations objectForKey:keyEquivalent];
			
			if (keyEquivalent) {
				keyEquivalent = [[self keyEquivalentModifierMaskDescription:keyEquivalentModifierMask] stringByAppendingFormat:@"-%@", keyEquivalent];				
				[existingKeyEquivalents setObject:eachMenuItem forKey:keyEquivalent];
			} else {
				NSLog(@"ERROR Didn't find mapping for %@", [eachMenuItem description]);
			}
		}
	}

	NSArray *modifierCombinations = [NSArray arrayWithObjects:
									 [NSNumber numberWithUnsignedInteger:NSCommandKeyMask],
									 [NSNumber numberWithUnsignedInteger:NSCommandKeyMask | NSShiftKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSCommandKeyMask | NSShiftKeyMask | NSAlternateKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSCommandKeyMask | NSShiftKeyMask | NSAlternateKeyMask | NSControlKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSCommandKeyMask | NSAlternateKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSCommandKeyMask | NSControlKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSAlternateKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSAlternateKeyMask | NSShiftKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSAlternateKeyMask | NSShiftKeyMask | NSControlKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSControlKeyMask],
//									 [NSNumber numberWithUnsignedInteger:NSControlKeyMask | NSShiftKeyMask],
									 nil];
	
	NSMutableAttributedString *results = [[NSMutableAttributedString alloc] init];
	NSMutableParagraphStyle *paragrpahStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];

	[paragrpahStyle setTabStops:[NSArray arrayWithObject:[[NSTextTab alloc] initWithType:NSLeftTabStopType location:300]]];
	
	for (NSString *eachCharacter in [[validKeyEquivalentsToStringRepresentations allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
		eachCharacter = [validKeyEquivalentsToStringRepresentations objectForKey:eachCharacter];
		
		for (NSNumber *eachModifiers in modifierCombinations) {
			NSString *keyEquivalent = [[self keyEquivalentModifierMaskDescription:[eachModifiers unsignedIntegerValue]] stringByAppendingFormat:@"-%@", eachCharacter];				
			NSMenuItem *menuItemForKeyEquivalent = [existingKeyEquivalents objectForKey:keyEquivalent];
			NSColor *color;
			
			if (menuItemForKeyEquivalent) {
				[results appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t%@\n", keyEquivalent, [menuItemForKeyEquivalent title]]]];
				color = [NSColor blackColor];
			} else {
				[results appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", keyEquivalent]]];
				color = [NSColor lightGrayColor];
			}
			
			NSRange range = [[results string] paragraphRangeForRange:NSMakeRange([[results string] length] - 1, 1)];
			[results addAttribute:NSForegroundColorAttributeName value:color range:range];
			[results addAttribute:NSParagraphStyleAttributeName value:paragrpahStyle range:range];
		}
	}
			
	return results;
}

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

@implementation BFontNameToDisplayNameTransformer

+ (void)initialize {
	[NSValueTransformer setValueTransformer:[[BFontNameToDisplayNameTransformer alloc] init] forName:@"BFontNameToDisplayNameTransformer"];
}

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)aValue {
    NSFont *font = [NSFont fontWithName:aValue size:12];
	return [font displayName];
}

@end

@implementation BTextFieldFontChooser

- (void)commonInit {
	[self setEditable:NO];
	[self setFocusRingType:NSFocusRingTypeNone];
}

- (id)init {
	if (self = [super init]) {
		[self commonInit];
	}
	return self;
}

- (void)awakeFromNib {
	[self commonInit];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	return YES;
}

- (BOOL)resignFirstResponder {
	return YES;
}

@synthesize fontDefaultsKey;

- (NSString *)fontDefaultsKeyObservablePath {
	return [NSString stringWithFormat:@"values.%@", fontDefaultsKey];
}

- (void)updateTextField {
	NSFont *font = [self selectedFont];
	if (font) {
		[self setStringValue:[NSString stringWithFormat:@"%@ %.1f pt.", [font displayName], [font pointSize]]];
	} else {
		[self setStringValue:@""];
	}
}

- (void)setFontDefaultsKey:(NSString *)newKey {
	NSUserDefaultsController *sharedUserDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	
	if (fontDefaultsKey) {
		[sharedUserDefaultsController removeObserver:self forKeyPath:[self fontDefaultsKeyObservablePath]];
	}
	
	fontDefaultsKey = newKey;
	
	if (fontDefaultsKey) {
		[sharedUserDefaultsController addObserver:self forKeyPath:[self fontDefaultsKeyObservablePath] options:0 context:NULL];
	}
	
	[self updateTextField];
}

- (NSFont *)selectedFont {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:self.fontDefaultsKey];
	if (data) {
		return [NSUnarchiver unarchiveObjectWithData:data];
	}
	return nil;
}

- (void)changeFont:(id)sender {
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *selectedFont = [fontManager selectedFont];
	if (selectedFont == nil) selectedFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
	selectedFont = [fontManager convertFont:selectedFont];
	[[NSUserDefaults standardUserDefaults] setValue:[NSArchiver archivedDataWithRootObject:selectedFont] forKey:self.fontDefaultsKey];
}

- (IBAction)chooseFont:(id)sender {
	NSData *fontData = [[NSUserDefaults standardUserDefaults] objectForKey:self.fontDefaultsKey];
	NSFont *font = fontData ? [NSUnarchiver unarchiveObjectWithData:fontData] : nil;
	if (font) [[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
    [[self window] makeFirstResponder:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[self fontDefaultsKeyObservablePath]]) {
		[self updateTextField];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end