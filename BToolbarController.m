//
//  BToolbarController.m
//  BUserInterface
//
//  Created by Jesse Grosjean on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BToolbarController.h"
#import "BToolbar.h"


@interface BToolbarController (BToolbarControllerPrivate)
- (id <BToolbarContributerProtocol>)toolbarContributerFor:(NSString *)itemIdentifier;
@end

@implementation BToolbarController

#pragma mark Init

- (id)initWithToolbarIdentifier:(NSString *)aToolbarIdentifier window:(NSWindow *)aWindow {
	if (self = [super init]) {
		window = aWindow;
		toolbarIdentifier = aToolbarIdentifier;
	}
	return self;
}

#pragma mark Accessors

@synthesize window;

- (NSToolbar *)toolbar {
	if (!toolbar) {
		toolbar = [[BToolbar alloc] initWithIdentifier:toolbarIdentifier];
		allowedItemIdentifiers = [[NSMutableArray alloc] init];
		defaultItemIdentifiers = [[NSMutableArray alloc] init];
		selectableItemIdentifiers = [[NSMutableArray alloc] init];
		itemIdentifiersToContributers = [[NSMutableDictionary alloc] init];
		itemIdentifiersToConfigurationElements = [[NSMutableDictionary alloc] init];
		
		NSDictionary *definedIdentifierLookup = [NSDictionary dictionaryWithObjectsAndKeys:
			NSToolbarSeparatorItemIdentifier, @"NSToolbarSeparatorItemIdentifier",
			NSToolbarSpaceItemIdentifier, @"NSToolbarSpaceItemIdentifier",
			NSToolbarFlexibleSpaceItemIdentifier, @"NSToolbarFlexibleSpaceItemIdentifier",
			NSToolbarShowColorsItemIdentifier, @"NSToolbarShowColorsItemIdentifier",
			NSToolbarShowFontsItemIdentifier, @"NSToolbarShowFontsItemIdentifier",
			NSToolbarCustomizeToolbarItemIdentifier, @"NSToolbarCustomizeToolbarItemIdentifier",
			NSToolbarPrintItemIdentifier, @"NSToolbarPrintItemIdentifier",
			nil];
		
		
		for (BConfigurationElement *eachToolbar in [[BExtensionRegistry sharedInstance] configurationElementsFor:BUserInterfaceToolbarsExtensionPoint]) {
			if ([[eachToolbar name] isEqualToString:@"toolbar"] && [[[eachToolbar attributes] objectForKey:@"id"] isEqualToString:[toolbar identifier]]) {
				NSEnumerator *itemEnumerator = [[eachToolbar children] objectEnumerator];
				BConfigurationElement *eachItem;
				
				while (eachItem = [itemEnumerator nextObject]) {
					NSString *identifier = [eachItem attributeForKey:@"id"];
					
					if ([definedIdentifierLookup objectForKey:identifier]) {
						identifier = [definedIdentifierLookup objectForKey:identifier];
					}
					
					if ([itemIdentifiersToConfigurationElements objectForKey:identifier]) {
						[allowedItemIdentifiers removeObject:identifier];
						[defaultItemIdentifiers removeObject:identifier];
						[selectableItemIdentifiers removeObject:identifier];
						BLogWarning([NSString stringWithFormat:@"toolbar item identifier %@ contributer is being replaced by new configuration element with same identifier %@", identifier, eachItem]);
					}
					
					[itemIdentifiersToConfigurationElements setObject:eachItem forKey:identifier];
					
					[allowedItemIdentifiers addObject:identifier];
					
					if ([eachItem booleanAttributeForKey:@"default"]) {
						[defaultItemIdentifiers addObject:identifier];
					}
					
					if ([eachItem booleanAttributeForKey:@"selectable"]) {
						[selectableItemIdentifiers addObject:identifier];
					}
				}
			}
		}
		
		[toolbar setDelegate:self];
	}
	
	return toolbar;
}

- (BConfigurationElement *)configurationElementFor:(NSString *)itemIdentifier {
	return [itemIdentifiersToConfigurationElements objectForKey:itemIdentifier];
}

#pragma mark Toolbar Delegate

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	BConfigurationElement *configurationElement = [self configurationElementFor:itemIdentifier];
	NSToolbarItem *defaultToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	[defaultToolbarItem setLabel:[configurationElement localizedAttributeForKey:@"label"]];
	[defaultToolbarItem setPaletteLabel:[configurationElement localizedAttributeForKey:@"paletteLabel"]];
	[defaultToolbarItem setToolTip:[configurationElement localizedAttributeForKey:@"toolTip"]];
	[defaultToolbarItem setTag:[configurationElement integerAttributeForKey:@"tag"]];
	[defaultToolbarItem setTarget:[configurationElement executableExtensionAttributeForKey:@"target"]];
	[defaultToolbarItem setAction:[configurationElement selectorAttributeForKey:@"action"]];
	[defaultToolbarItem setImage:[configurationElement imageAttributeForKey:@"image"]];

	id <BToolbarContributerProtocol> toolbarContributer = [self toolbarContributerFor:itemIdentifier];
	if (toolbarContributer) {
		return [toolbarContributer toolbarController:self itemForItemIdentifier:itemIdentifier defaultToolbarItem:defaultToolbarItem willBeInsertedIntoToolbar:flag];
	} else {
		return defaultToolbarItem;
	}
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
	return defaultItemIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
	return allowedItemIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return selectableItemIdentifiers;
}

- (void)toolbarWillAddItem:(NSNotification *)notification {
	NSString *itemIdentifier = [notification valueForKeyPath:@"userInfo.item.itemIdentifier"];
	[[self toolbarContributerFor:itemIdentifier] toolbarController:self willAddItem:notification];
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification {
	NSString *itemIdentifier = [notification valueForKeyPath:@"userInfo.item.itemIdentifier"];
	[[self toolbarContributerFor:itemIdentifier] toolbarController:self didRemoveItem:notification];
}

- (void)toolbarWillShow:(NSToolbar *)aToolbar {
	for (id <BToolbarContributerProtocol> each in [itemIdentifiersToContributers allValues]) {
		if ([each conformsToProtocol:@protocol(BToolbarContributerProtocol)]) {
			[each toolbarController:self willShowToolbar:aToolbar];
		}
	}
}

- (void)toolbarWillHide:(NSToolbar *)aToolbar {
	for (id <BToolbarContributerProtocol> each in [itemIdentifiersToContributers allValues]) {
		if ([each conformsToProtocol:@protocol(BToolbarContributerProtocol)]) {
			[each toolbarController:self willHideToolbar:aToolbar];
		}
	}
}

- (void)toolbarWillRunCustomizationPalette:(NSToolbar *)aToolbar {
	for (id <BToolbarContributerProtocol> each in [itemIdentifiersToContributers allValues]) {
		if ([each conformsToProtocol:@protocol(BToolbarContributerProtocol)]) {
			[each toolbarController:self willRunCustomizationPaletteForToolbar:aToolbar];
		}
	}
}

@end

@implementation BToolbarController (BToolbarControllerPrivate)

- (id <BToolbarContributerProtocol>)toolbarContributerFor:(NSString *)itemIdentifier {
	id contributer = [itemIdentifiersToContributers objectForKey:itemIdentifier];
	
	if (!contributer) {
		BConfigurationElement *configurationElement = [self configurationElementFor:itemIdentifier];
		if ([configurationElement attributeForKey:@"contributer"]) {
			contributer = [configurationElement createExecutableExtensionFromAttribute:@"contributer" conformingToClass:nil conformingToProtocol:@protocol(BToolbarContributerProtocol) respondingToSelectors:nil];
		}
	
		if (!contributer) {
			contributer = [NSNull null];
		}
		
		[itemIdentifiersToContributers setObject:contributer forKey:itemIdentifier];
	}
	
	if (contributer == [NSNull null]) {
		return nil;
	} else {
		return contributer;
	}
}

@end

NSString *BUserInterfaceToolbarsExtensionPoint = @"com.blocks.BUserInterface.toolbars";