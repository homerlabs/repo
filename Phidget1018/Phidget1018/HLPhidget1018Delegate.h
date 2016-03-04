//
//  HLPhidget1018Delegate.h
//  Phidget1018
//
//  Created by Matthew Homer on 1/8/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

@protocol HLPhidget1018Delegate <NSObject>

- (void)updateInput:(int)inputIndex withValue:(BOOL)value;
- (void)updateSensor:(int)inputIndex withValue:(int)value;
- (void)deviceAttached;
- (void)deviceDetached;

@end
