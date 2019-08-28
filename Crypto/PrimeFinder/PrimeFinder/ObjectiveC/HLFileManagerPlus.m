//
//  HLFileManagerPlus.m
//  Prime Finder
//
//  Created by Matthew Homer on 8/27/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "HLFileManagerPlus.h"

@implementation HLFileManagerPlus : HLFileManager

FILE *primesReadFILE0, *primesAppendFILE0;
FILE *primesReadFILE1, *primesAppendFILE1;
FILE *primesReadFILE2, *primesAppendFILE2;
FILE *primesReadFILE3, *primesAppendFILE3;
FILE *primesReadFILE4, *primesAppendFILE4;


//************************************************      primes file append2      ****************
-(int)createPrimesFilesForAppendWith:(NSString *)basePath numberOfFiles:(int)count {
    for (int i=0; i<count; i++) {
        NSString *path = [NSString stringWithFormat:@"%@_%i", basePath, i];

        if (i == 0) {
            primesAppendFILE0 = fopen(path.UTF8String, "w");    //  create new file
            if ( primesAppendFILE0 != nil )
            {
      //          [self appendPrimesLine: @"1\t2\n"];
      //          [self appendPrimesLine: @"2\t3\n"];
            }
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

-(void)closePrimesFileForAppend2
{
    fclose( primesAppendFILE0 );
    fclose( primesAppendFILE1 );
    fclose( primesAppendFILE2 );
}
//************************************************      primes file append2      ****************


@end
