//
//  AppDelegate.m
//  Phidget1018
//
//  Created by Matthew Homer on 1/7/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import "AppDelegate.h"
#import "HLPhidgetWindowController.h"
#import "HLUserPreferences.h"


@interface AppDelegate ()
{
    HLPhidgetWindowController *windowController;
    
    IBOutlet NSMenu *menu;
}


@end


@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
 //   NSLog( @"AppDelegate  applicationDidFinishLaunching" );
    windowController = [[HLPhidgetWindowController alloc] initWithWindowNibName:@"HLPhidgetWindowController"];
    [windowController showWindow:self];

    HLHardwareEnum hardwareSelect = [HLUserPreferences hardwareSelect];
//    NSLog( @"hardwareSelect: %d", hardwareSelect );
    
    //  clear the menu, then select the proper hardware board
    NSMenuItem *menuItem = menu.itemArray[2];   //  sorry about the '2'  MRH
    NSMenu *hardwareMenu = menuItem.submenu;
    for( NSMenuItem *item in hardwareMenu.itemArray )
        item.state = NSOffState;
    
    NSMenuItem *selectedItem = hardwareMenu.itemArray[hardwareSelect];
    selectedItem.state = NSOnState;
}


- (IBAction)hardwareMenuAction:(id)sender
{
    NSMenuItem *menuItem = sender;
    NSMenu *parentMenu = menuItem.menu;
    NSArray *menuArray = parentMenu.itemArray;

    for ( NSMenuItem *item in menuArray )   //  clear checkmark from menu
        item.state = NSOffState;
    
    menuItem.state = NSOnState;
//    NSLog( @"AppDelegate  hardwareMenuAction: %ld", menuItem.tag );

    NSInteger index = [parentMenu indexOfItem:menuItem];
    [HLUserPreferences setHardwareSelect:(HLHardwareEnum)index];
    
    if ( index == HLHardware1018 )
        [windowController selectHardware1018];
    
    else if ( index == HLHardware1073SBC )
        [windowController selectHardware1073SBC];
}


/*- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog( @"AppDelegate  applicationWillTerminate" );
}   */


@end
