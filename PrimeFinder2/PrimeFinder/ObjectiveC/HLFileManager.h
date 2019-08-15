//
//  HLFileManager.h
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLFileManager : NSObject

-(BOOL)createPrimeFileIfNeededWith:(NSString *)path;
-(NSString *)lastLineForFile:(NSString *)path;
-(NSString *)readLineFromFile:(FILE *)file;

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
-(void)closeTempFileForRead;

-(void)setModSize:(int)size;
-(instancetype)init;
+(instancetype)sharedManager;

@end
