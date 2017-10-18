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

-(int)openPrimesFileForReadWith:(NSString *)path;
-(NSString *)readPrimesFileLine;
-(void)closePrimesFileForRead;

-(void)openPrimesFileForAppendWith:(NSString *)path;
-(void)appendPrimesLine:(NSString *)line;
-(void)closePrimesFileForAppend;

-(int)openFactoredFileForReadWith:(NSString *)path;
-(NSString *)readFactoredFileLine;
-(void)closeFactoredFileForRead;

-(int)openFactoredFileForAppendWith:(NSString *)path;
-(void)appendFactoredLine:(NSString *)line;
-(void)closeFactoredFileForAppend;

-(int)openNicePrimesFileForWriteWith:(NSString *)path;
-(void)writeNicePrimesFile:(NSString *)line;;
-(void)closeNicePrimesFileForWrite;

-(void)openTempFileForReadWith:(NSString *)path;
-(NSString *)readTempFileLine;
-(void)closeTempFileForRead;

@end
