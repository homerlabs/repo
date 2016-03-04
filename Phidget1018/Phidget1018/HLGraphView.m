//
//  HLGraphView.m
//  HLGrapher
//
//  Created by Matthew Homer on 1/11/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import "HLGraphView.h"
#import "HLCircularBuffer.h"


@interface HLGraphView ()
{
    float scalerY;  //  view height / full scale value

    NSArray *graphData;
    NSMutableArray *colorArray;
    int bufferSize;
}

- (void)drawData:(CGContextRef)graphicContext;

@end


@implementation HLGraphView


@synthesize xScale;


const float HLFullScale = 1000; //  an output of 1000 == +5VDC


- (void)drawData:(CGContextRef)graphicContext
{
    for ( int i=0; i<graphData.count; i++ )
    {
        HLCircularBuffer *channel = graphData[i];
        if ( channel.bufferArray.count )
        {
            NSColor *color = colorArray[i];
            CGContextSetStrokeColorWithColor(graphicContext, [color CGColor]);
            NSNumber *num = channel.bufferArray[0];
            CGContextMoveToPoint(graphicContext, channel.bufferArray.count, num.floatValue*scalerY );

            for ( int i=1; i<channel.bufferArray.count; i++ )
            {
                NSNumber *num = channel.bufferArray[i];
                CGContextAddLineToPoint(graphicContext, channel.bufferArray.count-i, num.intValue*scalerY);
            }
    
            CGContextSetLineWidth(graphicContext, 1.0 );
            CGContextDrawPath(graphicContext, kCGPathStroke);
        }
    }
}


- (void)drawRect:(NSRect)rect
{
    CGContextRef myContext = [NSGraphicsContext currentContext].CGContext;
    CGContextSetStrokeColorWithColor(myContext, [[NSColor blackColor] CGColor]);
    CGContextSetLineWidth(myContext, 2.0 );
    
    CGContextAddRect (myContext, rect);
    CGContextDrawPath(myContext, kCGPathStroke);
    
    [self drawData:myContext];
}


- (void)updateGraphWithData:(NSArray *)data
{
//    NSLog( @"HLGraphView  updateGraph",  );

    graphData = data;
    [self setNeedsDisplay:YES];
}


- (instancetype)initWithFrame:(NSRect)frameRect
{
//    NSLog( @"HLGraphView  initWithFrame" );
    self = [super initWithFrame:frameRect];
    if ( self )
    {
        scalerY = self.frame.size.height / HLFullScale;
        bufferSize = self.frame.size.width;
        
        colorArray = [NSMutableArray array];
        [colorArray addObject:[NSColor blackColor]];
        [colorArray addObject:[NSColor brownColor]];
        [colorArray addObject:[NSColor redColor]];
        [colorArray addObject:[NSColor orangeColor]];
        [colorArray addObject:[NSColor yellowColor]];
        [colorArray addObject:[NSColor greenColor]];
        [colorArray addObject:[NSColor blueColor]];
        [colorArray addObject:[NSColor purpleColor]];
    }
    
    return self;
}


- (void)dealloc
{
    NSLog( @"HLGraphView  dealloc" );
}


@end
