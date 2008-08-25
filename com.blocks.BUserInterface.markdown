The BUserInterface plugin is mainly concerned with creating `NSMenu` instances in a flexible way that allows other plugins to insert their own menu items. There are two ways that you can use this plugin.

1. You can extend an existem menu by adding your own items by using the extension point `com.blocks.BUserInterface.menus`.
2. You can use `BMenuController` to create your own `NSMenu` instances in such a way that other plugins can add their own items.

## Examples:

This example shows how to use `BMenuController` to create a new popup menu that allows other plugins to contribute their own menu items. See the `com.blocks.BUserInterface.menus` extension point documentation for an example configuration that will extend from that point.

    BUserInterfaceController *userInterfaceController = [BUserInterfaceController sharedInstance];
    BMenuController *menuController = [userInterfaceController menuControllerForMenuExtensionPoint:@"com.blocks.pluginExample"];
	[NSMenu popUpContextMenu:menuController.menu withEvent:anEvent forView:aView];