//
//  BToolbarController.h
//  BUserInterface
//
//  Created by Jesse Grosjean on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Blocks/Blocks.h>

@class BToolbarController;

@protocol BToolbarContributerProtocol <NSObject>

- (NSToolbarItem *)toolbarController:(BToolbarController *)toolbarController itemForItemIdentifier:(NSString *)itemIdentifier defaultToolbarItem:(NSToolbarItem *)defaultItem willBeInsertedIntoToolbar:(BOOL)flag;
- (void)toolbarController:(BToolbarController *)toolbarController willAddItem:(NSNotification *)notification;
- (void)toolbarController:(BToolbarController *)toolbarController didRemoveItem:(NSNotification *)notification;

@end

@interface BToolbarController : NSObject {
	NSWindow *window;
	NSToolbar *toolbar;
	NSString *toolbarIdentifier;
	NSMutableArray *allowedItemIdentifiers;
	NSMutableArray *defaultItemIdentifiers;
	NSMutableArray *selectableItemIdentifiers;
	NSMutableDictionary *itemIdentifiersToContributers;
	NSMutableDictionary *itemIdentifiersToConfigurationElements;
}

#pragma mark Init

- (id)initWithToolbarIdentifier:(NSString *)aToolbarIdentifier window:(NSWindow *)aWindow;

#pragma mark Accessors

@property(readonly) NSWindow *window;
@property(readonly) NSToolbar *toolbar;
- (BConfigurationElement *)configurationElementFor:(NSString *)itemIdentifier;

@end

extern NSString *BUserInterfaceToolbarsExtensionPoint;
