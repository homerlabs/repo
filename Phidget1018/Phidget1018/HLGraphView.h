//
//  HLGraphView.h
//  HLGrapher
//
//  Created by Matthew Homer on 1/11/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HLGraphView : NSView
{
    int xScale;
}


@property int xScale;

- (void)updateGraphWithData:(NSArray *)data;

@end
