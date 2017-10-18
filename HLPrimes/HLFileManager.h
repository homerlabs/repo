//
//  HLFileManager.h
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLFileManager : NSObject

-(NSString *)lastLineForFile:(NSString *)path;

-(int)openPrimeFileForReadWith:(NSString *)path;
-(NSString *)readPrimeFileLine;
-(void)closePrimeFileForRead;

-(void)openPrimeFileForAppendWith:(NSString *)path;
-(void)appendPrimeLine:(NSString *)line;
-(void)closePrimeFileForAppend;

-(int)openFactorFileForAppendWith:(NSString *)path;
-(void)appendFactorLine:(NSString *)line;
-(void)closeFactorFileForAppend;

-(void)openTempFileForReadWith:(NSString *)path;
-(NSString *)readTempFileLine;
-(void)closeTempFileForRead;

@end
