//
//  HLPhidgetInterfaceKitController.h
//  Phidget1018
//
//  Created by Matthew Homer on 1/7/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "HLPhidget1018.h"
#import "HLPhidget1018Delegate.h"


@interface HLPhidgetInterfaceKitController : NSObject


@property HLPhidget1018 *phidget1018;

- (id)initFor1018:(id)delegate;
- (id)initFor1073SBC:(id)delegate;
- (void)disconnect;

- (void)updateOutput:(int)index withValue:(BOOL)value;

- (int)adjustSampleRate:(int)milliSec;
- (void)adjustSensitivity:(int)value;

- (void)setRatioMetricMode:(BOOL)value;


@end
