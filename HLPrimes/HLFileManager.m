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
FILE *readTempFile;
NSString *initialPrimeFile = @"1\t2\n2\t3\n3\t5\n4\t7\n5\t11\n6\t13\n";
int kMOD_SIZE = 100000;


-(void)openPrimeForReadWith:(NSString *)path  {
    fclose( primeReadFile );
    primeReadFile = fopen(path.UTF8String, "r");
}

-(void)openFactorForReadWith:(NSString *)path  {
 //   fclose( primeAppendFile );
//    readFile = fopen(path.UTF8String, "r");
}

-(void)openTempForReadWith:(NSString *)path  {
    readTempFile = fopen(path.UTF8String, "r");
}

-(void)closeTempFileForRead
{
    fclose( readTempFile );
}

-(void)cleanup  {
    fclose( primeReadFile );
    fclose( primeAppendFile );
}


-(instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    
//    filePath = path;
    primeReadFile = fopen(path.UTF8String, "r");
    if ( !primeReadFile )
    {
        FILE *tempFile = fopen(path.UTF8String, "w");
        fprintf(tempFile, "%s", initialPrimeFile.UTF8String);
        fclose( tempFile );
        //  try now ...
        primeReadFile = fopen(path.UTF8String, "r");
    }
    
    NSLog( @"HLFileManager-  initWithPath: %@", path );
//    NSString *lastLine = [self lastLineForFile:path];
//    NSLog( @"HLFileManager-  initWithPath-  lastLine: %@", lastLine );
    
    primeAppendFile = fopen(path.UTF8String, "a");
    return self;
}

-(NSString *)lastLineForFile:(NSString *)path
{
    FILE *tempFile = fopen(path.UTF8String, "r");
    int num = 0;
    long prime = 0;
    int items = fscanf(tempFile, "%d\t%ld\n", &num, &prime );
    
    while ( items > 0 )    {
//        NSLog( @"HLFileManager-  getLastLine-  items: %d   num: %d   prime: %ld", items, num, prime );
        items = fscanf(tempFile, "%d\t%ld\n", &num, &prime );
   }
   
   fclose( tempFile );
    return [NSString stringWithFormat:@"%d\t%ld",num, prime];
}

-(void)writeLine:(NSString *)line
{
    int n = line.intValue;
    if ( n % kMOD_SIZE == 0 )
        NSLog( @"writeLine: %@", line );
    
    fputs(line.UTF8String, primeAppendFile);
}

-(NSString *)readLine
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
