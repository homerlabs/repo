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

-(NSString *)readTempFileLine;
-(void)writeLine:(NSString *)line;

-(void)openPrimeFileForReadWith:(NSString *)path;
-(NSString *)readPrimeFileLine;
-(void)closePrimeFileForRead;

-(void)openPrimeFileForAppendWith:(NSString *)path;
-(void)closePrimeFileForAppend;

-(void)openFactorFileForAppendWith:(NSString *)path;
-(void)closeFactorFileForAppend;

-(void)openTempFileForReadWith:(NSString *)path;
-(void)closeTempFileForRead;

//-(void)openFactorFileForReadWith:(NSString *)path;
//-(void)closeFactorFileForRead;

@end
