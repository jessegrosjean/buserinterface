//
//  BUserInterfaceController.h
//  BUserInterface
//
//  Created by Jesse Grosjean on 8/24/07.
//  Copyright 2007 Blocks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Blocks/Blocks.h>


@class BMenuController;
@class BToolbarController;

@interface BUserInterfaceController : NSObject {
	IBOutlet NSMenu *mainMenu;
	IBOutlet NSMenu *applicationMenu;
	IBOutlet NSMenu *windowMenu;
	IBOutlet NSMenu *servicesMenu;
	IBOutlet NSMenu *openRecentMenu;
	IBOutlet NSMenu *fontMenu;
	
	NSMutableDictionary *menuExtensionPointsToMenuControllers;
}

#pragma mark Class Methods

+ (id)sharedInstance;

#pragma mark Controllers

- (BMenuController *)menuControllerForMenuExtensionPoint:(NSString *)menuExtensionPoint;

@end