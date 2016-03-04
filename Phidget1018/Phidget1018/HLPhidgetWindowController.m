//
//  HLPhidgetWindowController.m
//  Phidget1018
//
//  Created by Matthew Homer on 1/7/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import "HLPhidgetWindowController.h"
#import "HLPhidgetInterfaceKitController.h"
#import "HLGraphView.h"
#import "HLCircularBuffer.h"
#import "HLUserPreferences.h"


@interface HLPhidgetWindowController ()
{
    HLPhidgetInterfaceKitController *interfaceKitController;
    NSMutableArray *channelArray;
    BOOL shouldLog, shouldPlot, ratioMetricMode;
    ModeEnums analogMode;
    
    int logFileDescriptor;
    NSURL *tempFileURL;
    NSDate *startTime;
    BOOL loggingDidStart;
    NSString *windowTitle;
    
    IBOutlet NSBox *digitalBox;
    IBOutlet NSBox *analogBox;
    
    IBOutlet NSMatrix *digitalInputMatrix;
    IBOutlet NSMatrix *digitalOutputMatrix;
    IBOutlet NSMatrix *analogInputMatrix;
    IBOutlet NSMatrix *analogVoltageMatrix;
    
    IBOutlet NSMatrix *channelSelectMatrix;
    IBOutlet HLGraphView *graphView;
    
    IBOutlet NSTextField *lableTextField;
    IBOutlet NSTextField *valueTextField;
    IBOutlet NSSegmentedControl *modeControl;
    IBOutlet NSButton *logButton;
    IBOutlet NSButton *resetButton;
}

@property (nonatomic) BOOL shouldLog, shouldPlot, ratioMetricMode;

- (IBAction)ratioMetricModeAction:(id)sender;
- (IBAction)logDataAction:(id)sender;
- (IBAction)plotDataAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)channelSelectDidChange:(id)sender;
- (void)switchMode:(ModeEnums)mode;

- (IBAction)textFieldDidChange:(id)sender;
- (IBAction)OutputDidChange:(id)sender;
- (IBAction)AnalogModeDidChange:(id)sender;

@end


@implementation HLPhidgetWindowController


NSString *const HL_LOGGER_FILE_EXTENSION = @"txt";
NSString *const filename = @"LogData.txt";
NSString *const phidgetFrameworkPath = @"/Library/Frameworks/Phidget21.framework";

const float voltageScaler = 5/1000.0;

@synthesize shouldLog, shouldPlot, ratioMetricMode;


- (IBAction)logDataAction:(id)sender
{
    NSButton *button = sender;
//    NSLog( @"HLPhidgetWindowController  logDataAction: %ld", button.state );
    
    if ( button.state )
    {
        shouldLog = YES;
        
        NSArray *array = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
        tempFileURL = [NSURL URLWithString:filename relativeToURL:array[0]];
        logFileDescriptor = creat( tempFileURL.path.UTF8String, 0700 );
        
        startTime = [NSDate date];
        NSString *outputString = [NSString stringWithFormat:@"StartTime:%@\n", startTime.description];
        NSInteger len = outputString.length;
        
        NSInteger bytesWritten = write( logFileDescriptor, outputString.UTF8String, len );
        if ( bytesWritten != len )
        {
            NSLog( @"ERROR:  bytesWritten != len:  %ld : %ld", bytesWritten, len );
            assert( 0 );
        }
    }
    else
    {
        shouldLog = NO;
        
        if ( !shouldPlot )
            logButton.enabled = NO;
        
        close( logFileDescriptor );
        
        if ( loggingDidStart )
        {
            loggingDidStart = NO;
            NSSavePanel *savePanel = [NSSavePanel savePanel];
            [savePanel setNameFieldStringValue:filename];
            savePanel.allowedFileTypes = @[HL_LOGGER_FILE_EXTENSION];
            
            [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
            {
                if ( result == NSFileHandlingPanelOKButton )
                {
                    NSURL *toURL = [savePanel URL];
                    assert( tempFileURL );

                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtURL:toURL error:&error];

                    BOOL isOK = [[NSFileManager defaultManager] moveItemAtURL:tempFileURL toURL:toURL error:&error];
                    if ( !isOK )
                    {
                        NSLog( @"NSFileManager moveItem failed: %@", error );
                    }
                }
            }]; 
        }
    }
}


- (IBAction)ratioMetricModeAction:(id)sender
{
    NSButton *button = sender;
//    NSLog( @"HLPhidgetWindowController  ratioMetricModeAction: %ld", button.state );
    [interfaceKitController setRatioMetricMode:button.state];
}


- (IBAction)plotDataAction:(id)sender
{
    NSButton *button = sender;
//    NSLog( @"HLPhidgetWindowController  plotDataAction: %ld", button.state );
    
    if ( button.state )
    {
        shouldPlot = YES;
        logButton.enabled = YES;
        resetButton.enabled = YES;

        if ( analogMode == kHLModeSample )
            graphView.xScale = valueTextField.intValue;
        else
            graphView.xScale = 0;
    }
    else
    {
        shouldPlot = NO;
 //       logButton.enabled = NO;

        if ( !loggingDidStart )
            resetButton.enabled = NO;
    }
}


- (void)selectHardware1018
{
//    NSLog( @"HLPhidgetWindowController  selectHardware1018" );
    
    [interfaceKitController disconnect];
    [self deviceDetached];
    interfaceKitController = [[HLPhidgetInterfaceKitController alloc] initFor1018:self];
}


- (void)selectHardware1073SBC
{
//    NSLog( @"HLPhidgetWindowController  selectHardware1073SBC" );
    
    [interfaceKitController disconnect];
    [self deviceDetached];
    interfaceKitController = [[HLPhidgetInterfaceKitController alloc] initFor1073SBC:self];
}


- (void)switchMode:(ModeEnums)mode
{
//    NSLog( @"HLPhidgetWindowController  switchMode: %d", mode );
    
    analogMode = mode;
    
    if ( mode == kHLModeSample )
    {
        lableTextField.stringValue = @"Rate (mSec):";
        
        [interfaceKitController adjustSensitivity:0];
        
        int rate = [interfaceKitController adjustSampleRate:valueTextField.intValue];
        [valueTextField setIntValue:rate];
    }
    else
    {
        lableTextField.stringValue = @" Sensitivity: ";
        analogMode = kHLModeEvent;
        [interfaceKitController adjustSensitivity:valueTextField.intValue];
    }
}


- (void)deviceAttached
{
//    NSLog( @"HLPhidgetWindowController  deviceAttached" );

    self.window.title= [NSString stringWithFormat:@"%@ : %@", interfaceKitController.phidget1018.name, interfaceKitController.phidget1018.serialNumber];
    digitalBox.hidden = NO;
    analogBox.hidden = NO;
    
    int numChannels = interfaceKitController.phidget1018.numSensors;
    int bufferSize = graphView.frame.size.width;
    
    channelArray = [NSMutableArray arrayWithCapacity:numChannels];
    for ( int i=0; i<numChannels; i++ )
    {
        HLCircularBuffer *circularBuffer = [[HLCircularBuffer alloc] initWithSize:bufferSize];
        [channelArray addObject:circularBuffer];
        
        NSNumber *num = interfaceKitController.phidget1018.outputsArray[i];
        [digitalOutputMatrix setState:num.boolValue atRow:i column:0];
    }
    
    [self switchMode:kHLModeSample];
}


- (void)deviceDetached
{
//    NSLog( @"HLPhidgetWindowController  deviceDetached" );
    self.window.title= windowTitle;
    digitalBox.hidden = YES;
    analogBox.hidden = YES;
}


- (IBAction)resetAction:(id)sender
{
    for ( HLCircularBuffer *buffer in channelArray )
        [buffer removeAll];

    [graphView updateGraphWithData:channelArray];
}


- (IBAction)channelSelectDidChange:(id)sender
{
    NSMatrix *matrix = sender;
    NSButtonCell *cell = matrix.selectedCell;
//    NSLog( @"HLPhidgetWindowController  channelSelectDidChange: %@", matrix );
    
    //  handle channel being turned off
    if ( !cell.state )
    {
        HLCircularBuffer *channel = channelArray[matrix.selectedRow];
        [channel removeAll];
    }
}


- (IBAction)textFieldDidChange:(id)sender
{
//    NSLog( @"HLPhidgetWindowController  textFieldDidChange: %ld", textfield.integerValue );
    
    if ( analogMode == kHLModeSample )
    {
        [interfaceKitController adjustSensitivity:0];   //  is this required??
        
        int rate = [interfaceKitController adjustSampleRate:valueTextField.intValue];
        [valueTextField setIntValue:rate];
    }
    else
        [interfaceKitController adjustSensitivity:valueTextField.intValue];
}


- (IBAction)AnalogModeDidChange:(id)sender
{
//    NSLog( @"HLPhidgetWindowController  AnalogModeDidChange: %ld", modeControl.selectedSegment );
    [self switchMode:(ModeEnums)modeControl.selectedSegment];
}


- (IBAction)OutputDidChange:(id)sender
{
    int index = (int)[sender selectedTag];
    [interfaceKitController updateOutput:index withValue:[[sender cellWithTag:index] state]];
}


- (void)updateInput:(int)inputIndex withValue:(BOOL)value
{
//    NSLog( @"HLPhidgetWindowController  updateInput-  Index:%d  \tvalue:%d", inputIndex, value );
    [digitalInputMatrix setState:value atRow:inputIndex column:0];
}


- (void)updateSensor:(int)inputIndex withValue:(int)value
{
//    NSLog( @"HLPhidgetWindowController  updateSensor-  Index:%d  \tvalue:%d", inputIndex, value );

    [[analogInputMatrix cellAtRow:inputIndex column:0] setIntegerValue:value];
    
    NSString *voltage = [NSString stringWithFormat:@"%0.2f", value*voltageScaler];
    [[analogVoltageMatrix cellAtRow:inputIndex column:0] setStringValue:voltage];
    
    //  send to grapher/logger if channel selected
    NSButtonCell *cell = [channelSelectMatrix cellAtRow:inputIndex column:0];
    if ( cell.state && shouldPlot )
    {
//    NSLog( @"value: %d", value );
        if ( shouldLog )
        {
            loggingDidStart = YES;
            NSString *outputString = [NSString stringWithFormat:@"%0.3f, %d, %d\n", -startTime.timeIntervalSinceNow, inputIndex, value];
            NSInteger len = outputString.length;
            
            NSInteger bytesWritten = write( logFileDescriptor, outputString.UTF8String, len );
            if ( bytesWritten != len )
            {
                NSLog( @"ERROR:  bytesWritten != len:  %ld : %ld", bytesWritten, len );
                assert( 0 );
            }
        }
    
        HLCircularBuffer *channel = channelArray[inputIndex];
        [channel addObject:[NSNumber numberWithInt:value]];
        
        [graphView updateGraphWithData:channelArray];
    }
}


- (void)windowWillClose:(NSNotification *)notification
{
//    NSLog( @"HLPhidgetWindowController  windowWillClose: %@", notification );
    [interfaceKitController disconnect];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
 //   NSLog( @"HLPhidgetWindowController  windowDidLoad" );

    BOOL frameworkPresent = [[NSFileManager defaultManager] fileExistsAtPath:phidgetFrameworkPath];
    if ( frameworkPresent )
    {
        windowTitle = self.window.title;
        
        HLHardwareEnum hardwareSelect = [HLUserPreferences hardwareSelect];
        
        if ( hardwareSelect == HLHardware1018 )
            interfaceKitController = [[HLPhidgetInterfaceKitController alloc] initFor1018:self];
        
        else if ( hardwareSelect == HLHardware1073SBC )
            interfaceKitController = [[HLPhidgetInterfaceKitController alloc] initFor1073SBC:self];
        
        else
            assert( 0 && "HardwareSelectIndex has unexpected value!" );
    }
    else    //  no drivers installed
    {
        NSAlert *panel = [[NSAlert alloc] init];
        panel.alertStyle = NSCriticalAlertStyle;
 
        [panel addButtonWithTitle:@"Quit"];
        [panel addButtonWithTitle:@"Go to Phidget Website"];
        
        panel.messageText = @"Yikes!  Phidget21.framework NOT installed!";
        panel.informativeText =
@"You need the following 2 things to use this app:\n\tHardware-  PhidgetInterfaceKit 8/8/8\n\tSoftware-   Phidget Drivers";
        
        NSModalResponse response = [panel runModal];
        
        if ( response == NSAlertSecondButtonReturn )
        {
            NSURL *url = [NSURL URLWithString:@"http://www.phidgets.com/docs/OS_-_OS_X#Quick_Downloads"];
            [[NSWorkspace sharedWorkspace] openURL:url];
        }
        
        exit( 1 );
    }
}


-(void) dealloc
{
    NSLog( @"HLPhidgetWindowController  dealloc" );
}


@end
