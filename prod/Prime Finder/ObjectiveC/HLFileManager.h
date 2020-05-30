//
//  HLFileManager.h
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLFileManager: NSObject

-(int)createPrimesFileForAppendWith:(NSString *)path;
-(void)closePrimesFileForAppend;
-(void)appendPrimesLine:(NSString *)line;


-(BOOL)openPrimesFileForReadWith:(NSString *)path;
-(void)closePrimesFileForRead;
-(NSString *)readPrimesFileLine;


-(int)createNicePrimesFileForAppendWith:(NSString *)path;
-(void)closeNicePrimesFileForAppend;
-(void)writeNicePrimesFile:(NSString *)line;


-(NSString *)readLineFromFile:(FILE *)file;


-(void)setModSize:(int)size;
+(instancetype)sharedInstance;

@end
