//
//  BMenuController.h
//  BUserInterface
//
//  Created by Jesse Grosjean on 8/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Blocks/Blocks.h>

@interface NSObject (BMenuControllerAdditions)
- (void)initializeMenuItemForInsertionInMenu:(NSMenuItem *)menuItem;
@end

@interface BMenuController : NSObject {
	BOOL loaded;
	NSMenu *menu;
	NSString *menuExtensionPoint;
}

@property(readonly) NSMenu *menu;
- (void)addMenuItem:(NSMenuItem *)menuItem location:(NSString *)location;
   
@end

extern NSString *BUserInterfaceMenusExtensionPoint;