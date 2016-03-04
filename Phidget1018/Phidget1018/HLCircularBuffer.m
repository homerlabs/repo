//
//  HLCircularBuffer.m
//  HLGrapher
//
//  Created by Matthew Homer on 1/20/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import "HLCircularBuffer.h"

@implementation HLCircularBuffer


@synthesize bufferSize;
@synthesize bufferArray;


- (void)removeAll
{
//    NSLog( @"HLCircularBuffer-  removeAll" );
    [bufferArray removeAllObjects];
}


- (void)addObject:(id)object
{
//    NSLog( @"HLCircularBuffer-  addObject: %@", object );
    
    if ( bufferArray.count == bufferSize )
        [bufferArray removeObjectAtIndex:0];
    
    [bufferArray addObject:object];
}


- (id)initWithSize:(int)size
{
//    NSLog( @"HLCircularBuffer-  initWithSize: %d", size );
    self = [super init];
    if ( self )
    {
        bufferSize = size;
        bufferArray = [NSMutableArray arrayWithCapacity:bufferSize];
    }
    
    return self;
}


/*- (void)dealloc
{
    NSLog( @"HLCircularBuffer-  dealloc" );
}   */


@end
