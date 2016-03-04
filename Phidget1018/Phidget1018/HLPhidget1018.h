//
//  HLPhidget1018.h
//  Phidget1018
//
//  Created by Matthew Homer on 1/8/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Phidget21/phidget21.h>


@interface HLPhidget1018 : NSObject
{
    NSString *serialNumber, *version, *name;
    int numInputs, numOutputs, numSensors;
    
    NSMutableArray *inputsArray, *outputsArray, *sensorArray;
}

- (id)initWithHandle:(CPhidgetInterfaceKitHandle)handle;

@property NSString *serialNumber, *version, *name;
@property int numInputs, numOutputs, numSensors;
@property NSMutableArray *inputsArray, *outputsArray, *sensorArray;

@end
