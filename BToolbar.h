//
//  BToolbar.h
//  BUserInterface
//
//  Created by Jesse Grosjean on 9/8/08.
//  Copyright 2008 Hog Bay Software. All rights reserved.
//

#import "BUserInterface.h"


@interface BToolbar : NSToolbar {

}

@end

@interface NSObject (BUserInterfaceToolbarDelegateAdditions)

- (void)toolbarWillShow:(NSToolbar *)toolbar;
- (void)toolbarWillHide:(NSToolbar *)toolbar;
- (void)toolbarWillRunCustomizationPalette:(NSToolbar *)toolbar;

@end
