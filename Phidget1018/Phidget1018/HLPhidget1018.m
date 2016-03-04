//
//  HLPhidget1018.m
//  Phidget1018
//
//  Created by Matthew Homer on 1/8/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import "HLPhidget1018.h"


@interface HLPhidget1018 ()
{
    CPhidgetInterfaceKitHandle ifkit;
}

@end


@implementation HLPhidget1018


@synthesize serialNumber, version, name;
@synthesize numInputs, numOutputs, numSensors;
@synthesize inputsArray, outputsArray, sensorArray;


- (id)initWithHandle:(CPhidgetInterfaceKitHandle)handle
{
//    NSLog( @"HLPhidget1018  init" );
    self = [super init];
    if ( self )
    {
        assert( handle && "Serious ERROR:  handle is NULL!" );
        ifkit = handle;

        int tempInt = 0;
        CPhidget_getSerialNumber((CPhidgetHandle)ifkit, &tempInt);
        serialNumber = [NSString stringWithFormat:@"%d", tempInt];
        
        CPhidget_getDeviceVersion((CPhidgetHandle)ifkit, &tempInt);
        version = [NSString stringWithFormat:@"%d", tempInt];
        
        const char *tempChars;
        CPhidget_getDeviceName((CPhidgetHandle)ifkit, &tempChars);
        name = [NSString stringWithUTF8String:tempChars];
        
        CPhidget_DeviceID devid;
        CPhidget_getDeviceID((CPhidgetHandle)ifkit, &devid);
        CPhidgetInterfaceKit_getSensorCount(ifkit, &numSensors);
        CPhidgetInterfaceKit_getInputCount(ifkit, &numInputs);
        CPhidgetInterfaceKit_getOutputCount(ifkit, &numOutputs);
    
        inputsArray = [NSMutableArray array];
        outputsArray = [NSMutableArray array];
        sensorArray = [NSMutableArray array];
        
        for( int i=0; i<numInputs; i++ )
        {
            [inputsArray addObject:@0];
            [outputsArray addObject:@0];
            [sensorArray addObject:@0];
        }
    }
    
    return self;
}


/*- (void)dealloc
{
    NSLog( @"HLPhidget1018  dealloc" );
}   */


@end
