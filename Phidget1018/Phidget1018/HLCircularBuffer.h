//
//  HLCircularBuffer.h
//  HLGrapher
//
//  Created by Matthew Homer on 1/20/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLCircularBuffer : NSObject
{
    int bufferSize;
    NSMutableArray *bufferArray;
}


@property (nonatomic) int bufferSize;
@property (nonatomic) NSMutableArray *bufferArray;


- (id)initWithSize:(int)size;
- (void)addObject:(id)object;
- (void)removeAll;

@end
