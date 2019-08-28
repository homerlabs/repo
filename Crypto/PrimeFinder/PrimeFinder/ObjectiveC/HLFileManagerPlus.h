//
//  HLFileManagerPlus.h
//  PrimeFinder
//
//  Created by Matthew Homer on 8/27/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

#import "HLFileManager.h"

@interface HLFileManagerPlus : HLFileManager

-(int)createPrimesFilesForAppendWith:(NSString *)basePath numberOfFiles:(int)count;
-(void)closePrimesFileForAppend;

-(void)appendLine:(NSString *)line fileId: (int)fileId;

@end
