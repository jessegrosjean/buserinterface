//
//  BUserInterfaceController.m
//  BUserInterface
//
//  Created by Jesse Grosjean on 8/24/07.
//  Copyright 2007 Blocks. All rights reserved.
//

#import "BUserInterfaceController.h"
#import "BMenuController.h"
#import "BToolbarController.h"


@interface BMenuController (BUserInterfaceControllerPrivate)
- (id)initWithMenu:(NSMenu *)aMenu extensionPoint:(NSString *)aMenuExtensionPoint;
@end

@implementation BUserInterfaceController

#pragma mark Class Methods

+ (id)sharedInstance {
    static id sharedInstance = nil;
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

#pragma mark Init

- (void)disassembleMenu:(NSMenu *)menu {
	while ([[menu itemArray] count] > 0) {
		NSMenuItem *each = [menu itemAtIndex:0];
		NSMenu *submenu = [each submenu];
		[self disassembleMenu:submenu];
		[each setSubmenu:nil];
		[menu removeItemAtIndex:0];
	}
}

- (id)init {
	if (self = [super init]) {
		menuExtensionPointsToMenuControllers = [[NSMutableDictionary alloc] init];
			
		if ([NSBundle loadNibNamed:@"SpecialMenuTemplates" owner:self]) {
			[self disassembleMenu:mainMenu];
		} else {
			BLogWarning(@"Failed to load SpecialMenuTemplates nib");
		}
	}
	return self;
}

#pragma mark Menu Controllers

- (BMenuController *)menuControllerForMenuExtensionPoint:(NSString *)menuExtensionPoint {
	BMenuController *menuController = [menuExtensionPointsToMenuControllers objectForKey:menuExtensionPoint];

	if (!menuController) {
		NSMenu *menu = nil;
		
		if ([menuExtensionPoint isEqualToString:@"com.blocks.BUserInterface.menus.main"]) {
			menu = mainMenu;
		} else if ([menuExtensionPoint isEqualToString:@"com.blocks.BUserInterface.menus.main.application"]) {
			menu = applicationMenu;
		} else if ([menuExtensionPoint isEqualToString:@"com.blocks.BUserInterface.menus.main.application.service"]) {
			menu = servicesMenu;
		} else if ([menuExtensionPoint isEqualToString:@"com.blocks.BUserInterface.menus.main.file.openRecent"]) {
			menu = openRecentMenu;
		} else if ([menuExtensionPoint isEqualToString:@"com.blocks.BUserInterface.menus.main.format.font"]) {
			menu = fontMenu;
		} else if ([menuExtensionPoint isEqualToString:@"com.blocks.BUserInterface.menus.main.window"]) {
			menu = windowMenu;
		} else {
			menu = [[NSMenu alloc] init];
		}
		
		menuController = [[BMenuController alloc] initWithMenu:menu extensionPoint:menuExtensionPoint];
		[menuExtensionPointsToMenuControllers setObject:menuController forKey:menuExtensionPoint];
	}
	
	return menuController;
}

#pragma mark Lifecycle Callback

- (void)applicationWillFinishLaunching {
	if ([[[NSApp mainMenu] itemArray] count] > 0) {
		BLogWarning(@"Blocks based applications should declare menus in plugin.xml files, not nibs. The main menu is about to be replaced with the a new menu constructed from the contents of the com.blocks.BUserInterface.menus extension point.");
	}
	
	[[NSApplication sharedApplication] setMainMenu:[[self menuControllerForMenuExtensionPoint:@"com.blocks.BUserInterface.menus.main"] menu]];
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *currentVersionString = [infoDictionary objectForKey:@"CFBundleVersion"];

	if (![[userDefaults objectForKey:@"UILastCFBundleVersion"] isEqualToString:currentVersionString]) {
		[userDefaults setObject:currentVersionString forKey:@"UILastCFBundleVersion"];
		[userDefaults removeObjectForKey:@"UISuppressVersionWarning"];
	}

	NSString *shortVersionString = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
	BOOL isDevelopmentVersion = [shortVersionString rangeOfString:@"Development"].location != NSNotFound;
	BOOL isBetaVersion = [shortVersionString rangeOfString:@"Beta"].location != NSNotFound;
	
	if (isDevelopmentVersion || isBetaVersion) {
		if (![userDefaults boolForKey:@"UISuppressVersionWarning"]) {
			NSString *proccessName = [[NSProcessInfo processInfo] processName];
			NSString *alertMessageText = [NSString stringWithFormat:@"%@ %@ (%@)", proccessName, shortVersionString, currentVersionString];
			NSString *alertInformativeText = nil;
			
			if (isDevelopmentVersion) {
				alertInformativeText = [NSString stringWithFormat:BLocalizedString(@"This version of %@ is still in development and is not meant to be used for real work. If you would like to provide feedback and help direct future development of %@ please join the discussion in the %@ user forum.", nil), proccessName, proccessName, proccessName, nil];
			} else {
				alertInformativeText = [NSString stringWithFormat:BLocalizedString(@"This version of %@ is in beta and it may not be stable enough for real work. Please help stabilize it by reporting any problems that you see in the %@ user forum.", nil), proccessName, proccessName, nil];
			}
			
			NSAlert *versionAlert = [NSAlert alertWithMessageText:alertMessageText defaultButton:BLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:alertInformativeText];
			
			[versionAlert setShowsSuppressionButton:YES];
			[versionAlert runModal];
			
			if ([[versionAlert suppressionButton] state] == NSOnState) {
				[userDefaults setBool:YES forKey:@"UISuppressVersionWarning"];
			}
		}
	}
}

@end

@implementation BMenuController (BUserInterfaceControllerPrivate)

- (id)initWithMenu:(NSMenu *)aMenu extensionPoint:(NSString *)aMenuExtensionPoint {
	if (self = [super init]) {
		menu = aMenu;
		menuExtensionPoint = aMenuExtensionPoint;
	}
	return self;
}

@end