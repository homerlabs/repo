//
//  HLUserPreferences.m
//  Sudoku Solver
//
//  Created by Matthew Homer on 12/7/14.
//  Copyright (c) 2014 Homer Labs. All rights reserved.
//

#import "HLUserPreferences.h"

NSString *const HLPreferencesChangedNotification = @"HLPreferencesChangedNotification";
NSString *const HLPlotterHardwareSelectKey = @"HLPlotterHardwareSelectKey";


@implementation HLUserPreferences


+ (void)setHardwareSelect:(HLHardwareEnum)select;
{
//    NSLog( @"HLUserPreferences  setHardwareSelect: %d", select );
    [[NSUserDefaults standardUserDefaults] setInteger:select forKey:HLPlotterHardwareSelectKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (HLHardwareEnum)hardwareSelect
{
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:HLPlotterHardwareSelectKey];
//    NSLog( @"HLUserPreferences-  hardwareSelect: %ld", value );
    return (HLHardwareEnum)value;
}


@end
