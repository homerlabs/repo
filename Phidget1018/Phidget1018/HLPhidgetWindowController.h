//
//  HLPhidgetWindowController.h
//  Phidget1018
//
//  Created by Matthew Homer on 1/7/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HLPhidget1018Delegate.h"

enum 
{
    kHLModeSample,
    kHLModeEvent
} typedef ModeEnums;


@interface HLPhidgetWindowController : NSWindowController <NSWindowDelegate, HLPhidget1018Delegate>


- (void)updateInput:(int)inputIndex withValue:(BOOL)value;
- (void)updateSensor:(int)inputIndex withValue:(int)value;
- (void)deviceAttached;
- (void)deviceDetached;

- (void)selectHardware1018;
- (void)selectHardware1073SBC;
- (void)windowWillClose:(NSNotification *)notification;


@end
