//
//  HLFileManager.h
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLFileManager : NSObject

-(void)createPrimeFileWith:(NSString *)path;
//-(NSString *)lastLineForFile:(NSString *)path;
-(NSString *)readLineFromFile:(FILE *)file;

-(int)openPrimesFileForReadWith:(NSString *)path;
-(NSString *)readPrimesFileLine;
-(void)closePrimesFileForRead;

-(void)openPrimesFileForAppendWith:(NSString *)path;
-(void)appendPrimesLine:(NSString *)line;
-(void)closePrimesFileForAppend;

-(int)openNicePrimesFileForWriteWith:(NSString *)path;
-(void)writeNicePrimesFile:(NSString *)line;;
-(void)closeNicePrimesFileForWrite;

-(void)setModSize:(int)size;
+(instancetype)sharedInstance;

@end
