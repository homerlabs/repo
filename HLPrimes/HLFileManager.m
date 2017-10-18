//
//  HLFileManager.m
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import "HLFileManager.h"
#import <stdio.h>

@implementation HLFileManager

FILE *primesReadFile, *primesAppendFile;
FILE *factorAppendFile;
FILE *nicePrimesWriteFile;
FILE *readTempFile;
NSString *initialPrimeFile = @"1\t2\n2\t3\n3\t5\n4\t7\n5\t11\n6\t13\n";
NSString *initialFactorFile = @"5\t2\n7\t3\n11\t5\n13\t2\t3\n";
int kMOD_SIZE = 100000;

NSString *fileExtension = @"txt";

//************************************************      primes file read        ****************
-(int)openPrimesFileForReadWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    primesReadFile = fopen(pathWithExtension.UTF8String, "r");
    
    //  if open failed, create and open new file
    if ( !primesReadFile )
    {
        FILE *tempFile = fopen(pathWithExtension.UTF8String, "w");
        if ( !tempFile ) {  //  can't use this path!
            return -1;  //    error
        }
        
        fprintf(tempFile, "%s", initialPrimeFile.UTF8String);
        fclose( tempFile );
        //  try now ...
        primesReadFile = fopen(pathWithExtension.UTF8String, "r");
    }
    
    return 0;   //  no error
}
-(void)closePrimesFileForRead
{
    fclose( primesReadFile );
}

-(NSString *)readPrimesFileLine
{
    int lineSize = 1000;
    char lineBuf[lineSize];
    char *result = fgets(lineBuf, lineSize, primesReadFile);
    if ( result )
    {
        unsigned long len = strlen(result);
        result[len-1] = '\0';       //  need to remove '\n'
       return [NSString stringWithUTF8String:result];
    }
    else
        return nil;
}
//************************************************      primes file read        ****************


//************************************************      primes file append      ****************
-(void)openPrimesFileForAppendWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
     primesAppendFile = fopen(pathWithExtension.UTF8String, "a");
}
-(void)closePrimesFileForAppend
{
    fclose( primesAppendFile );
}

-(void)appendPrimesLine:(NSString *)line
{
    int n = line.intValue;
    if ( n % kMOD_SIZE == 0 )
        NSLog( @"** new prime: %@", line );
    
    fputs(line.UTF8String, primesAppendFile);
}
//************************************************      primes file append      ****************


//************************************************      factored file append    ****************
-(int)openFactoredFileForAppendWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    //  make sure file already exists
    factorAppendFile = fopen(pathWithExtension.UTF8String, "r");
    if ( !factorAppendFile )
    {
        FILE *tempFile = factorAppendFile = fopen(pathWithExtension.UTF8String, "w");
        if ( !tempFile ) {  //  can't use this path!
            return -1;  //    error
        }
        fprintf(factorAppendFile, "%s", initialFactorFile.UTF8String);
    }
    fclose( factorAppendFile );
    
    factorAppendFile = fopen(pathWithExtension.UTF8String, "a");
    assert( factorAppendFile );
    return 0;   //  no error
}
-(void)closeFactoredFileForAppend
{
    fclose( factorAppendFile );
}

-(void)appendFactoredLine:(NSString *)line
{
//    int n = line.intValue;
//    if ( n % kMOD_SIZE == 0 )
    
    fprintf(factorAppendFile, "%s\n", line.UTF8String);
    NSLog( @"  ** prime factored: %@", line );
}
//************************************************      factored file append    ****************


//************************************************      nice primes file write  ****************
-(int)openNicePrimesFileForWriteWith:(NSString *)path
{
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    //  make sure file already exists
    nicePrimesWriteFile = fopen(pathWithExtension.UTF8String, "w");
    assert( nicePrimesWriteFile );
    return 0;   //  no error
}
-(void)closeNicePrimesFileForWrite
{
    fclose( nicePrimesWriteFile );
}

-(void)writeNicePrimesFile:(NSString *)line
{
//    int n = line.intValue;
//    if ( n % kMOD_SIZE == 0 )
    
    fprintf(nicePrimesWriteFile, "%s\n", line.UTF8String);
    NSLog( @"  ** nice prime: %@", line );
}
//************************************************      nice primes file write  ****************


/*-(void)openFactorFileForReadWith:(NSString *)path  {
    factorReadFile = fopen(pathWithExtension.UTF8String, "r");
    
    //  if open failed, create and open new file
    if ( !factorReadFile )
    {
        FILE *tempFile = fopen(pathWithExtension.UTF8String, "w");
        fprintf(tempFile, "%s", initialFactorFile.UTF8String);
        fclose( tempFile );
        //  try now ...
        factorReadFile = fopen(pathWithExtension.UTF8String, "r");
    }
}
-(void)closeFactorFileForRead
{
    fclose( factorReadFile );
}   */

-(void)openTempFileForReadWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    readTempFile = fopen(pathWithExtension.UTF8String, "r");
}
-(void)closeTempFileForRead
{
    fclose( readTempFile );
}

-(NSString *)lastLineForFile:(NSString *)path
{
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    readTempFile = fopen(pathWithExtension.UTF8String, "r");
    
    if ( readTempFile )  {
        NSString *temp = @"";
        NSString *previous;

        do  {
            previous = temp;
            temp = [self readTempFileLine];
        } while (temp);
        
        fclose( readTempFile );
        return previous;
    }
    
    else
        return nil;
}

-(NSString *)readTempFileLine
{
    int lineSize = 1000;
    char lineBuf[lineSize];
    char *result = fgets(lineBuf, lineSize, readTempFile);
    if ( result )
    {
        unsigned long len = strlen(result);
        result[len-1] = '\0';       //  need to remove '\n'
       return [NSString stringWithUTF8String:result];
    }
    else
        return nil;
}

@end
