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
-(void)cleanup;
-(void)openPrimeForReadWith:(NSString *)path;
-(void)openFactorForReadWith:(NSString *)path;
-(void)openTempForReadWith:(NSString *)path;
-(void)closeTempFileForRead;

@end
