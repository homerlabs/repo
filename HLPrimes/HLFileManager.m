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

FILE *primeReadFile, *primeAppendFile;
FILE *factorAppendFile;
FILE *readTempFile;
NSString *initialPrimeFile = @"1\t2\n2\t3\n3\t5\n4\t7\n5\t11\n6\t13\n";
NSString *initialFactorFile = @"5\t2\n7\t3\n11\t5\n13\t2\t3\n";
int kMOD_SIZE = 100000;

NSString *fileExtension = @"txt";


-(int)openPrimeFileForReadWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    primeReadFile = fopen(pathWithExtension.UTF8String, "r");
    
    //  if open failed, create and open new file
    if ( !primeReadFile )
    {
        FILE *tempFile = fopen(pathWithExtension.UTF8String, "w");
        if ( !tempFile ) {  //  can't use this path!
            return -1;  //    error
        }
        
        fprintf(tempFile, "%s", initialPrimeFile.UTF8String);
        fclose( tempFile );
        //  try now ...
        primeReadFile = fopen(pathWithExtension.UTF8String, "r");
    }
    
    return 0;   //  no error
}
-(void)closePrimeFileForRead
{
    fclose( primeReadFile );
}

-(void)openPrimeFileForAppendWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
     primeAppendFile = fopen(pathWithExtension.UTF8String, "a");
}
-(void)closePrimeFileForAppend
{
    fclose( primeAppendFile );
}

-(int)openFactorFileForAppendWith:(NSString *)path  {
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
-(void)closeFactorFileForAppend
{
    fclose( factorAppendFile );
}

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

-(void)appendPrimeLine:(NSString *)line
{
    int n = line.intValue;
    if ( n % kMOD_SIZE == 0 )
        NSLog( @"** new prime: %@", line );
    
    fputs(line.UTF8String, primeAppendFile);
}

-(void)appendFactorLine:(NSString *)line
{
//    int n = line.intValue;
//    if ( n % kMOD_SIZE == 0 )
    
    fprintf(factorAppendFile, "%s\n", line.UTF8String);
    NSLog( @"  ** prime factored: %@", line );
}

-(NSString *)readPrimeFileLine
{
    int lineSize = 1000;
    char lineBuf[lineSize];
    char *result = fgets(lineBuf, lineSize, primeReadFile);
    if ( result )
    {
        unsigned long len = strlen(result);
        result[len-1] = '\0';       //  need to remove '\n'
       return [NSString stringWithUTF8String:result];
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
