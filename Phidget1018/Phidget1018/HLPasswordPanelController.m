//
//  HLPasswordPanelController.m
//  Phidget1018
//
//  Created by Matthew Homer on 2/21/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

#import "HLPasswordPanelController.h"

@interface HLPasswordPanelController ()
{
    IBOutlet NSSecureTextField *passwordTextField;
}

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end


@implementation HLPasswordPanelController


- (NSString *)password
{
    return passwordTextField.stringValue;
}


- (IBAction)okAction:(id)sender
{
//    NSString *password = passwordTextField.stringValue;
//    NSLog( @"HLPasswordPanelController  okAction: %@", password );
    
    [NSApp stopModal];
    [self.window performClose:self];
}


- (IBAction)cancelAction:(id)sender;
{
//    NSLog( @"HLPasswordPanelController  cancelAction" );
    
    [NSApp abortModal];
    [self.window performClose:self];
}


@end
