//
//  BMenuController.m
//  BUserInterface
//
//  Created by Jesse Grosjean on 8/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BMenuController.h"
#import "BUserInterfaceController.h"


@interface BMenuController (BMenuControllerPrivate)
- (void)addMenuItemForConfigurationElement:(BConfigurationElement *)configurationElement;
- (NSInteger)nextGroupStartIndexFrom:(NSInteger)index;
@end

@implementation BMenuController

- (NSMenu *)menu {
	if (!loaded) {
		loaded = YES;
		
		for (BConfigurationElement *eachMenu in [[BExtensionRegistry sharedInstance] configurationElementsFor:BUserInterfaceMenusExtensionPoint]) {
			if ([[eachMenu name] isEqualToString:@"menu"] && [[[eachMenu attributes] objectForKey:@"id"] isEqualToString:menuExtensionPoint]) {
				NSEnumerator *itemEnumerator = [[eachMenu children] objectEnumerator];
				BConfigurationElement *eachItem;
				
				while (eachItem = [itemEnumerator nextObject]) {
					[self addMenuItemForConfigurationElement:eachItem];
				}
			}
		}
	}
	return menu;
}

- (void)addMenuItem:(NSMenuItem *)menuItem location:(NSString *)location {
	[self menu]; // make sure menu is loaded, then access directly.
	
	if ([menuExtensionPoint isEqualToString:@"com.blocks.BUserInterface.menus.main"] && [menuItem submenu] == nil) {
		BLogError([NSString stringWithFormat:@"trying to add menuItem %@ to top level of main menu, but failed because menuItem doesn't have a submenu.", menuItem]);
	} else {
		if ([menuItem menu] == menu) {
			if (location) {
				BLogInfo([NSString stringWithFormat:@"Repositioning menu item %@", menuItem]);
				[menu removeItem:menuItem];
			} else {
				return;
			}
		}
		
		NSUInteger menuItemInsertIndex = [[menu itemArray] count];
		
		if (location) {
			NSArray *locationComponents = [location componentsSeparatedByString:@":"];
			NSString *locationSpecifier = [locationComponents count] > 0 ? [locationComponents objectAtIndex:0] : nil;
			NSString *relativeToID = [locationComponents count] > 1 ? [locationComponents objectAtIndex:1] : nil;
			NSInteger relativeToIndex = -1;
			BOOL relativeToInvalide = NO;
			
			if (relativeToID) {
				relativeToIndex = [menu indexOfItemWithRepresentedObject:relativeToID];
			}
			
			if ([locationSpecifier isEqualToString:@"after"]) {
				if (relativeToIndex != -1) {
					menuItemInsertIndex = relativeToIndex + 1;
				} else {
					relativeToInvalide = YES;
				}
			} else if ([locationSpecifier isEqualToString:@"before"]) {
				if (relativeToIndex != -1) {
					menuItemInsertIndex = relativeToIndex;
				} else {
					relativeToInvalide = YES;
				}
			} else if ([locationSpecifier isEqualToString:@"group"]) {
				if (relativeToIndex != -1) {
					menuItemInsertIndex = [self nextGroupStartIndexFrom:relativeToIndex + 1];
				} else {
					if ([relativeToID isEqualToString:@"topGroup"]) {
						menuItemInsertIndex = [self nextGroupStartIndexFrom:0];
					} else {
						NSMenuItem *newGroup = [NSMenuItem separatorItem];
						[newGroup setRepresentedObject:relativeToID];
						[menu addItem:newGroup];
						menuItemInsertIndex = [menu indexOfItem:newGroup] + 1;
					}
				}
			} else if ([locationSpecifier isEqualToString:@"remove"]) {
				menuItemInsertIndex = -1;
			} else {
				BLogWarning([NSString stringWithFormat:@"unknown locationSpecifier in menu location %@, will ignore location and add item to end of menu", location]);
			}
			
			if (relativeToInvalide) {
				BLogWarning([NSString stringWithFormat:@"failed to find relativeToID in menu location %@", location]);
			}
		}
		
		if (menuItemInsertIndex != -1) {
			[menu insertItem:menuItem atIndex:menuItemInsertIndex];
		}
	}
}

@end

@implementation BMenuController (BMenuControllerPrivate)

- (void)addMenuItemForConfigurationElement:(BConfigurationElement *)configurationElement {
	NSString *elementName = [configurationElement name];

	if ([elementName isEqualToString:@"menuitem"]) {
		NSString *title = [configurationElement localizedAttributeForKey:@"title"];
		NSString *identifier = [configurationElement attributeForKey:@"id"];
		NSString *location = [configurationElement attributeForKey:@"location"];
		NSString *indentationLevel = [configurationElement attributeForKey:@"indentationLevel"];
		NSString *keyEquivalent = [configurationElement attributeForKey:@"keyEquivalent"];
		NSString *keyEquivalentModifierMask = [configurationElement attributeForKey:@"keyEquivalentModifierMask"];
		NSString *submenuID = [configurationElement attributeForKey:@"submenu"];
		id menuItemInitializer = [configurationElement executableExtensionAttributeForKey:@"menuItemInitializer"];
		NSInteger tag = [configurationElement integerAttributeForKey:@"tag"];
		SEL action = [configurationElement selectorAttributeForKey:@"action"];
		
		id target = [configurationElement executableExtensionAttributeForKey:@"target"];
		NSInteger indexOfItemWithRepresentedObject = identifier == nil ? -1 : [menu indexOfItemWithRepresentedObject:identifier];
		keyEquivalent = keyEquivalent == nil ? @"" : keyEquivalent;
				
		NSMenuItem *menuItem = nil;
		
		if (indexOfItemWithRepresentedObject != -1) {
			menuItem = [menu itemAtIndex:indexOfItemWithRepresentedObject];
		}
		
		if (menuItem == nil) {
			BLogAssert(title != nil, @"title must not be nil for newly inserted menu items.");
			menuItem = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:keyEquivalent];
		}

		if (title != nil) [menuItem setTitle:title];
		if (indentationLevel != nil) {
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[menuItem setIndentationLevel:[[numberFormatter numberFromString:indentationLevel] integerValue]];
			[numberFormatter release];
		}
		if (action != nil) [menuItem setAction:action];
		if (identifier != nil) [menuItem setRepresentedObject:identifier];
		if (tag != 0) [menuItem setTag:tag];
		if ([configurationElement attributeForKey:@"target"]) [menuItem setTarget:target];
		if (keyEquivalent != nil && [keyEquivalent length] > 0) [menuItem setKeyEquivalent:keyEquivalent];
		
		if (keyEquivalentModifierMask != nil) {
			NSUInteger mask = 0;
			
			for (NSString *each in [keyEquivalentModifierMask componentsSeparatedByString:@"|"]) {
				if ([each isEqualToString:@"NSShiftKeyMask"]) {
					mask |= NSShiftKeyMask;
				} else if ([each isEqualToString:@"NSAlternateKeyMask"]) {
					mask |= NSAlternateKeyMask;
				} else if ([each isEqualToString:@"NSCommandKeyMask"]) {
					mask |= NSCommandKeyMask;
				} else if ([each isEqualToString:@"NSControlKeyMask"]) {
					mask |= NSControlKeyMask;
				} else {
					BLogWarning([NSString stringWithFormat:@"Found unknown keyEquivalentModifierMask %@", keyEquivalentModifierMask]);
				}
			}
						
			[menuItem setKeyEquivalentModifierMask:mask];
		}
		
		if (submenuID != nil) {
//			NSMenu *submenu = [[[[BUserInterfaceController sharedInstance] menuControllerForMenuExtensionPoint:submenuID] menu] copy];
			NSMenu *submenu = [[[BUserInterfaceController sharedInstance] menuControllerForMenuExtensionPoint:submenuID] menu];
			if ([[menuItem title] length] > 0) [submenu setTitle:[menuItem title]];
			[menuItem setSubmenu:submenu];
		}
		
		if (menuItemInitializer != nil && [menuItemInitializer respondsToSelector:@selector(initializeMenuItemForInsertionInMenu:)]) {
			[menuItemInitializer initializeMenuItemForInsertionInMenu:menuItem];
		}
		
		[self addMenuItem:menuItem location:location];
	} else if ([elementName isEqualToString:@"separator"]) {
		NSString *location = [configurationElement attributeForKey:@"location"];
		NSString *identifier = [configurationElement attributeForKey:@"group"];
		NSMenuItem *menuItem = [NSMenuItem separatorItem];
		[menuItem setRepresentedObject:identifier];
		[self addMenuItem:menuItem location:location];
	}
}

- (NSInteger)nextGroupStartIndexFrom:(NSInteger)index {
	NSUInteger count = [[menu itemArray] count];
	
	while (index < count) {
		if ([[menu itemAtIndex:index] isSeparatorItem]) {
			return index;
		}
		index++;
	}
	
	return index;
}

@end

NSString *BUserInterfaceMenusExtensionPoint = @"com.blocks.BUserInterface.menus";
