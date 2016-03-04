//
//  HLUserPreferences.h
//  Sudoku Solver
//
//  Created by Matthew Homer on 12/7/14.
//  Copyright (c) 2014 Homer Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const HLPreferencesChangedNotification;

extern NSString *const HLPlotterHardwareSelectKey;

enum HLHardwareEnum
{
    HLHardware1018,
    HLHardware1073SBC,
} typedef HLHardwareEnum;


@interface HLUserPreferences : NSObject

+ (HLHardwareEnum)hardwareSelect;
+ (void)setHardwareSelect:(HLHardwareEnum)select;

@end
