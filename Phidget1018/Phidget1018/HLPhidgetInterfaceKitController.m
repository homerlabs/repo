//
//  HLPhidgetInterfaceKitController.m
//  Phidget1018
//
//  Created by Matthew Homer on 1/7/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HLPhidgetInterfaceKitController.h"
#import "HLPhidget1018.h"
#import "HLPasswordPanelController.h"


@interface HLPhidgetInterfaceKitController ()
{
    HLPhidget1018 *phidget1018;
    id<HLPhidget1018Delegate>   __weak phidgetDelegate;
    CPhidgetInterfaceKitHandle ifkit;
    
    BOOL isSampleMode;
}

- (id)init:(id)delegate;
- (void)phidgetAdded:(id)nothing;
- (void)phidgetRemoved:(id)nothing;
- (void)ErrorEvent:(NSArray *)errorEventData;

//- (void)OutputChange:(NSArray *)outputChangeData;
- (void)InputChange:(NSArray *)inputChangeData;
- (void)SensorChange:(NSArray *)sensorChangeData;

@end


@implementation HLPhidgetInterfaceKitController

@synthesize phidget1018;

//Event callback functions for C, which in turn call a method on the GUI object in it's thread context
int gotAttach(CPhidgetHandle phid, void *context);
int gotDetach(CPhidgetHandle phid, void *context);
int gotError(CPhidgetHandle phid, void *context, int errcode, const char *error);
int gotInputChange(CPhidgetInterfaceKitHandle phid, void *context, int ind, int val);
int gotSensorChange(CPhidgetInterfaceKitHandle phid, void *context, int ind, int val);
//int gotOutputChange(CPhidgetInterfaceKitHandle phid, void *context, int ind, int val);


//Event callback functions for C, which in turn call a method on the GUI object in it's thread context
int gotAttach(CPhidgetHandle phid, void *context) {
	[(__bridge id)context performSelectorOnMainThread:@selector(phidgetAdded:)
								  withObject:nil
							   waitUntilDone:NO];
	return 0;
}
int gotDetach(CPhidgetHandle phid, void *context) {
	[(__bridge id)context performSelectorOnMainThread:@selector(phidgetRemoved:)
								  withObject:nil
							   waitUntilDone:NO];
	return 0;
}
int gotError(CPhidgetHandle phid, void *context, int errcode, const char *error) {
	[(__bridge id)context performSelectorOnMainThread:@selector(ErrorEvent:)
            withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:errcode], [NSString stringWithUTF8String:error], nil]
            waitUntilDone:NO];
	return 0;
}
int gotInputChange(CPhidgetInterfaceKitHandle phid, void *context, int ind, int val) {
	[(__bridge id)context performSelectorOnMainThread:@selector(InputChange:)
            withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:ind], [NSNumber numberWithInt:val], nil]
            waitUntilDone:NO];
	return 0;
}
int gotSensorChange(CPhidgetInterfaceKitHandle phid, void *context, int ind, int val) {
	[(__bridge id)context performSelectorOnMainThread:@selector(SensorChange:)
            withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:ind], [NSNumber numberWithInt:val], nil]
            waitUntilDone:NO];
	return 0;
}
/*int gotOutputChange(CPhidgetInterfaceKitHandle phid, void *context, int ind, int val) {
	[(__bridge id)context performSelectorOnMainThread:@selector(OutputChange:)
            withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:ind], [NSNumber numberWithInt:val], nil]
            waitUntilDone:NO];
	return 0;
}   */


- (void)updateOutput:(int)index withValue:(BOOL)value
{
//    NSLog( @"HLPhidgetInterfaceKitController  updateOutput- index:%d  value:%d", index, value );
	CPhidgetInterfaceKit_setOutputState( ifkit, index, value );
}

/*- (void)OutputChange:(NSArray *)outputChangeData
{
    NSLog( @"HLPhidgetInterfaceKitController  OutputChange- index:%@  value:%@", outputChangeData[0], outputChangeData[1] );
    
    NSNumber *index = outputChangeData[0];
    phidget1018.outputsArray[index.intValue] = [outputChangeData objectAtIndex:1];
}   */


- (void)InputChange:(NSArray *)inputChangeData
{
//    NSLog( @"HLPhidgetInterfaceKitController  InputChange- index:%@  value:%@", inputChangeData[0], inputChangeData[1] );
    if ( inputChangeData.count != 2 )
        NSLog( @"HLPhidgetInterfaceKitController  InputChange- count:%ld", inputChangeData.count );
    assert( !(inputChangeData.count-2) && "Multiple changes not handled!" );
    
    NSNumber *index = inputChangeData[0];
    NSNumber *value = inputChangeData[1];
    phidget1018.inputsArray[index.intValue] = value;
    [phidgetDelegate updateInput:index.intValue withValue:value.boolValue];
}


- (void)SensorChange:(NSArray *)sensorChangeData
{
//    NSLog( @"HLPhidgetInterfaceKitController  SensorChange- index:%@  value:%@", sensorChangeData[0], sensorChangeData[1] );
    assert( !(sensorChangeData.count-2) && "Multiple changes not handled!" );

    NSNumber *index = sensorChangeData[0];
    NSNumber *value = sensorChangeData[1];
    
    [phidgetDelegate updateSensor:index.intValue withValue:value.intValue];
}


- (void)setRatioMetricMode:(BOOL)value
{
//   NSLog( @"HLPhidgetInterfaceKitController  setRatioMetricMode: %d", milliSec );

    int result = CPhidgetInterfaceKit_setRatiometric( ifkit, value );
        if ( result )
        {
            NSLog( @"HLPhidgetInterfaceKitController  setRatioMetricMode error: %d", result );
            assert( 0 && "CPhidgetInterfaceKit_setRatiometric failed." );
        }
}


- (int)adjustSampleRate:(int)milliSec
{
//   NSLog( @"HLPhidgetInterfaceKitController  adjustRate: %d", milliSec );
    
    int adjustedRate = (milliSec/8)*8;
    if ( adjustedRate < 16 )    adjustedRate = 16;
    if ( adjustedRate > 1000 )  adjustedRate = 1000;
    
    for( int i=0; i<phidget1018.numSensors; i++ )
    {
        int result = CPhidgetInterfaceKit_setDataRate( ifkit, i, adjustedRate );
        if ( result )
        {
            NSLog( @"HLPhidgetInterfaceKitController  adjustRate error: %d", result );
    //        assert( 0 && "CPhidgetInterfaceKit_setDataRate failed." );
        }
    }
    
    return adjustedRate;
}


- (void)adjustSensitivity:(int)value
{
//   NSLog( @"HLPhidgetInterfaceKitController  adjustSensitivity: %d", value );
    
    if ( value )
        isSampleMode = NO;
    else
        isSampleMode = YES;
    
    for( int i=0; i<phidget1018.numSensors; i++ )
    {
        int result = CPhidgetInterfaceKit_setSensorChangeTrigger( ifkit, i, value );
        if ( result )
        {
            NSLog( @"HLPhidgetInterfaceKitController  adjustSensitivity error: %d", result );
            assert( 0 && "CPhidgetInterfaceKit_setSensorChangeTrigger failed." );
        }
    }
}


- (id)initFor1018:(id)delegate
{
//    NSLog( @"HLPhidgetInterfaceKitController  initFor1018" );
    
    self = [self init:delegate];
    if ( self )
    {
        int serial = -1;
        int result = CPhidget_open( (CPhidgetHandle)ifkit, serial );
        if ( result )
        {
            NSLog( @"initFor1018-  CPhidget_open failed with: %d", result );
            assert( 0 );
        }
    }
    
    return self;
}


- (id)initFor1073SBC:(id)delegate
{
//    NSLog( @"HLPhidgetInterfaceKitController  initFor1073SBC" );
    
    self = [self init:delegate];
    if ( self )
    {
        int serial = -1;
//        NSString *password = @"admin";
        
        HLPasswordPanelController *passwordWindowController = [[HLPasswordPanelController alloc] initWithWindowNibName:@"HLPasswordPanelController"];
        
        NSInteger modalResult = [NSApp runModalForWindow:passwordWindowController.window];
//        NSLog( @"initFor1018-  modalResult: %ld", modalResult );
        
        if ( modalResult == NSModalResponseStop )
        {
            int result = CPhidget_openRemote((CPhidgetHandle)ifkit, serial, NULL, [[passwordWindowController password] UTF8String]);
            if ( result )
            {
                NSLog( @"initFor1018-  CPhidget_openRemote failed with: %d", result );
                assert( 0 );
            }
        }
        
        else    //  no password given
            self = nil;
    }
    
    return self;
}


- (id)init:(id)delegate
{
//    NSLog( @"HLPhidgetInterfaceKitController  init: %@", delegate );
    
    self = [super init];
    if ( self )
    {
        //CPhidget_enableLogging(PHIDGET_LOG_INFO, NULL);
        
        ifkit = nil;    //  do not remove
        CPhidgetInterfaceKit_create(&ifkit);
        
        CPhidget_set_OnAttach_Handler((CPhidgetHandle)ifkit, gotAttach, (__bridge void *)(self));
        CPhidget_set_OnDetach_Handler((CPhidgetHandle)ifkit, gotDetach, (__bridge void *)(self));
        CPhidget_set_OnError_Handler((CPhidgetHandle)ifkit, gotError, (__bridge void *)(self));
        CPhidgetInterfaceKit_set_OnInputChange_Handler(ifkit, gotInputChange, (__bridge void *)(self));
        CPhidgetInterfaceKit_set_OnSensorChange_Handler(ifkit, gotSensorChange, (__bridge void *)(self));
//        CPhidgetInterfaceKit_set_OnOutputChange_Handler(ifkit, gotOutputChange, (__bridge void *)(self));

        phidgetDelegate = delegate;
    }

    return self;
}


- (void)disconnect
{
//    NSLog( @"HLPhidgetInterfaceKitController  disconnect" );

	if( ifkit )
	{
		//Stop all events before closing
		CPhidget_set_OnAttach_Handler((CPhidgetHandle)ifkit, NULL, NULL);
		CPhidget_set_OnDetach_Handler((CPhidgetHandle)ifkit, NULL, NULL);
		CPhidget_set_OnError_Handler((CPhidgetHandle)ifkit, NULL, NULL);
		CPhidgetInterfaceKit_set_OnInputChange_Handler(ifkit, NULL, NULL);
		CPhidgetInterfaceKit_set_OnSensorChange_Handler(ifkit, NULL, NULL);
//		CPhidgetInterfaceKit_set_OnOutputChange_Handler(ifkit, NULL, NULL);
		
		CPhidget_close((CPhidgetHandle)ifkit);
		CPhidget_delete((CPhidgetHandle)ifkit);
		ifkit = NULL;
	}
    
    [self phidgetRemoved:self];
}


/*- (void)dealloc
{
    NSLog( @"HLPhidgetInterfaceKitController  dealloc" );
}   */


- (void)phidgetAdded:(id)nothing
{
//    NSLog( @"HLPhidgetInterfaceKitController  phidgetAdded" );

    phidget1018 = [[HLPhidget1018 alloc] initWithHandle:ifkit];
    NSLog( @"Phidget Added:   %@  \tSerial Number: %@  \tVersion: %@",
        phidget1018.name, phidget1018.serialNumber, phidget1018.version );
        
    
    for( int i=0; i<phidget1018.numOutputs; i++ )
    {
        int value = -1;
        int result = CPhidgetInterfaceKit_getOutputState( ifkit, i, &value );
        assert( !result );
        phidget1018.outputsArray[i] = [NSNumber numberWithBool:value];
    }
//    NSLog( @"outputsArray: %@", phidget1018.outputsArray );
    
    [phidgetDelegate deviceAttached];
}

- (void)phidgetRemoved:(id)nothing
{
//    NSLog( @"HLPhidgetInterfaceKitController  phidgetRemoved" );
    
    NSLog( @"Phidget Removed: %@  \tSerial Number: %@", phidget1018.name, phidget1018.serialNumber );
    phidget1018 = nil;
    [phidgetDelegate deviceDetached];
}


int errorCounter = 0;
- (void)ErrorEvent:(NSArray *)errorEventData
{
    NSLog( @"HLPhidgetInterfaceKitController  ErrorEvent: %@", errorEventData );
	int errorCode = [[errorEventData objectAtIndex:0] intValue];
//	NSString *errorString = [errorEventData objectAtIndex:1];
	
	switch(errorCode)
	{
		case EEPHIDGET_BADPASSWORD:
			CPhidget_close((CPhidgetHandle)ifkit);
//			[NSApp runModalForWindow:passwordPanel];
			break;
		case EEPHIDGET_BADVERSION:
			CPhidget_close((CPhidgetHandle)ifkit);
//			NSRunAlertPanel(@"Version mismatch", [NSString stringWithFormat:@"%@\nApplication will now close.", errorString], nil, nil, nil);
			[NSApp terminate:self];
			break;
		case EEPHIDGET_PACKETLOST:
			break; //ignore this error
		default:
			errorCounter++;
			
/*			NSAttributedString *string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",errorString]];
			
			[[errorEventLog textStorage] beginEditing];
			[[errorEventLog textStorage] appendAttributedString:string];
			[[errorEventLog textStorage] endEditing];
			
			[errorEventLogCounter setIntValue:errorCounter];
			if(![errorEventLogWindow isVisible])
				[errorEventLogWindow setIsVisible:YES];
			break;  */
	}
}


@end
