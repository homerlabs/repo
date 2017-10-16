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
-(NSString *)lastLineForFile:(NSString *)path;

-(NSString *)readLine;
-(void)writeLine:(NSString *)line;

-(void)openPrimeFileForReadWith:(NSString *)path;
-(void)closePrimeFileForRead;

-(void)openPrimeFileForAppendWith:(NSString *)path;
-(void)closePrimeFileForAppend;

-(void)openTempFileForReadWith:(NSString *)path;
-(void)closeTempFileForRead;

-(void)openFactorFileForReadWith:(NSString *)path;

@end
