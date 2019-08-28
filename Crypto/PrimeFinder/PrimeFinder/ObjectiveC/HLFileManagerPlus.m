//
//  HLFileManagerPlus.m
//  Prime Finder
//
//  Created by Matthew Homer on 8/27/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "HLFileManager.h"
#import "HLFileManagerPlus.h"

@implementation HLFileManagerPlus : HLFileManager

FILE *primesAppendFILE0, *primesAppendFILE1, *primesAppendFILE2, *primesAppendFILE3, *primesAppendFILE4;


-(void)appendLine:(NSString *)line fileId: (int)fileId {
    if (line.length < 1) {
        NSLog( @"Serious Error  appendLine is empty  fieldId: %i", fileId );
    }
    if (fileId == 0)
        fputs(line.UTF8String, primesAppendFILE0);
    else if (fileId == 1)
        fputs(line.UTF8String, primesAppendFILE1);
    else if (fileId == 2)
        fputs(line.UTF8String, primesAppendFILE2);
    else {
        NSLog( @"Serious Error  fieldId out of range-  fieldId: %i", fileId );
        assert( false );
    }
}


-(int)createPrimesFilesForAppendWith:(NSString *)basePath numberOfFiles:(int)count {
    NSLog( @"HLFileManagerPlus-  createPrimesFilesForAppendWith: %@", basePath );
    for (int i=0; i<count; i++) {
        NSString *path = [NSString stringWithFormat:@"%@_%i.txt", basePath, i];

        if (i == 0) {
            primesAppendFILE0 = fopen(path.UTF8String, "w");    //  create new file
            [self appendLine: @"2\n3\n" fileId: 0];
        }
        else if (i == 1) {
            primesAppendFILE1 = fopen(path.UTF8String, "w");    //  create new file
        }
        else if (i == 2) {
            primesAppendFILE2 = fopen(path.UTF8String, "w");    //  create new file
        }
    }
    
    return 0;
}

-(void)closePrimesFileForAppend
{
    NSLog( @"HLFileManagerPlus-  closePrimesFileForAppend" );
    fclose( primesAppendFILE0 );
    fclose( primesAppendFILE1 );
    fclose( primesAppendFILE2 );
}

@end
