Use this extension point to add menu items to an existing menus that define an extension point. The `com.blocks.BUserInterface.menus` extension point has three configuration elements, `menu`, `menuitem`, and `separator`.

- `menu` The `menu` configuration element is used to assign a unique id to a `NSMenu` this is being built. It has a single `id` attribute that should either refere to a new menu that you are declaring, or to another menu declared elsewhere that you wish to extend. The `menu` element can contain both `menuitem` and `separator` elements.
- `menuitem` The `menuitem` configuration element is used to add `NSMenuItems` to a menu. This element has a number of attributes:
	- `title` The title that will be used for the `NSMenuItem`
	- `id` Unique id that others can use to refere to the menu item (for example when declaring insert postion you can insert relative to an already defined menu item that you refere to by id.
	- `action` The selector action that will be sent to the menu item's target.
	- `target` The object that will be the menu's target.
	- `keyEquivalent` The menu items key equivalent.
	- `keyEquivalentModifierMask` The modify mask for the keyEquivalent, for example `NSCommandKeyMask|NSAlternateKeyMask`.
	- `location` The location that this menu item should be inserted, relative to an existing `group` or menu item `id` that also exists in the menu that's being extended. For example `group:preferencesGroup` means to insert in the group `preferencesGroup` wich is defined by a `separator` element. Or `after:about` means to insert the menu item after the menu item with the id `about`.
	- `submenu` id of the menu that should be used as a submenu of the menu item.
- `separator` Used to insert a separator and declar a group id. This element can have the attributes:
	- `group` id of the group being defined.
	- `location` Same as location attributed used in `menuitem` element.

## Examples

This example shows how the BPreferencesController adds a separator group and a preferences menu item to the `com.blocks.BUserInterface.menus.main.application` menu that's defined in BUserInterface's Plugin.xml:

    <extension point="com.blocks.BUserInterface.menus" processOrder="1" >
        <menu id="com.blocks.BUserInterface.menus.main.application">
            <separator group="preferencesGroup" location="after:about"/>
            <menuitem title="%Preferences..." id="preferences" action="showWindow:" keyEquivalent="," target="BPreferencesController sharedInstance" location="group:preferencesGroup" />
        </menu>
    </extension>

This example shows how to add a menu item that has a submenu, and how to add another item to that submenu:

    <extension point="com.blocks.BUserInterface.menus">
        <menu id="com.blocks.BUserInterface.menus.main">
            <menuitem title="%ExampleMenuItem" id="exampleMenuItem" submenu="com.blocks.BUserInterface.menus.main.example" />
        </menu>

        <menu id="com.blocks.BUserInterface.menus.main.example">
            <menuitem title="%OtherExampleMenuItem" id="otherExampleMenuItem" action="otherExampleItemAction:"/>
        </menu>
    </extension>