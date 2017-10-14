//
//  HLFileManager.h
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLFileManager : NSObject

-(instancetype)initWithPath:(NSString *)path;
-(NSString *)readLine;
-(void)writeLine:(NSString *)line;
-(NSString *)getLastLine;

@end
