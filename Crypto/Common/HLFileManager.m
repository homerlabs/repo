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
FILE *factoredReadFile, *factoredAppendFile;
FILE *nicePrimesWriteFile;
FILE *readTempFile;
NSString *initialFactorFile = @"5\t2\n7\t3\n11\t5\n13\t2\t3\n";
int modSize = 1;
int modCounter = 0;

NSString *fileExtension = @"txt";


-(int)createPrimeFileIfNeeded:(NSURL *)primeURL {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",primeURL.path , fileExtension];
    FILE *primeFile = fopen(pathWithExtension.UTF8String, "r");
    
    //  if open failed, create new file
    if ( !primeFile )
    {
        NSURL *url = [NSBundle.mainBundle URLForResource:@"HLPrimes" withExtension:@"txt"];
        FILE *primeSourceFile = fopen(url.path.UTF8String, "r");
        FILE *primeFile = fopen(pathWithExtension.UTF8String, "w");
        int prime = 0, index = 1;
        int result = fscanf(primeSourceFile, "%d\n", &prime );
        
        while ( result == 1 )   {
            NSString* output = [NSString stringWithFormat: @"%d\t%d\n", index++, prime];
            fputs(output.UTF8String, primeFile);
            
            result = fscanf(primeSourceFile, "%d\n", &prime );
        }

        fclose(primeSourceFile);
        fclose(primeFile);
    }

    return 0;
}

//************************************************      primes file read        ****************
-(int)openPrimesFileForReadWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    primesReadFile = fopen(pathWithExtension.UTF8String, "r");
    return (primesReadFile == nil); //  return 0 for no error
}
-(void)closePrimesFileForRead
{
    fclose( primesReadFile );
}

-(NSString *)readPrimesFileLine
{
    return [self readLineFromFile:primesReadFile];
}
//************************************************      primes file read        ****************


//************************************************      factored file read      ****************
-(int)openFactoredFileForReadWith:(NSString *)path
{
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    factoredReadFile = fopen(pathWithExtension.UTF8String, "r");

    if ( !factoredReadFile )
        return -1;  //    error
    else
        return 0;   //  no error
}
-(void)closeFactoredFileForRead
{
    fclose( factoredReadFile );
}

-(char *)trimLineEnding:(char *)line
{
    unsigned long len = strlen(line);
    line[len-1] = '\0';       //  need to remove '\n'
   return line;
}

-(NSString *)readFactoredFileLine
{
    return [self readLineFromFile:factoredReadFile];
}
//************************************************      factored file read      ****************

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
    if ( n % modSize == 0 )
        NSLog( @"** new prime: %@", line );
    
    fputs(line.UTF8String, primesAppendFile);
}
//************************************************      primes file append      ****************


//************************************************      factored file append    ****************
-(int)openFactoredFileForAppendWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    //  make sure file already exists
    factoredAppendFile = fopen(pathWithExtension.UTF8String, "r");
    if ( !factoredAppendFile )
    {
        FILE *tempFile = factoredAppendFile = fopen(pathWithExtension.UTF8String, "w");
        if ( !tempFile ) {  //  can't use this path!
            return -1;  //    error
        }
        fprintf(factoredAppendFile, "%s", initialFactorFile.UTF8String);
    }
    fclose( factoredAppendFile );
    
    factoredAppendFile = fopen(pathWithExtension.UTF8String, "a");
    assert( factoredAppendFile );
    modCounter = 0;
    return 0;   //  no error
}
-(void)closeFactoredFileForAppend
{
    fclose( factoredAppendFile );
}

-(void)appendFactoredLine:(NSString *)line
{
//    int n = line.intValue;
//    if ( n % kMOD_SIZE == 0 )
    
    fprintf(factoredAppendFile, "%s\n", line.UTF8String);
    if ( modCounter++ % modSize == 0 )
        NSLog( @"  ** prime factored: %@", line );
}
//************************************************      factored file append    ****************


//************************************************      nice primes file write  ****************
-(int)openNicePrimesFileForWriteWith:(NSString *)path
{
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    nicePrimesWriteFile = fopen(pathWithExtension.UTF8String, "w");
    assert( nicePrimesWriteFile );
    modCounter = 0;
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
    if ( modCounter++ % modSize == 0 )
        NSLog( @"  ** nice prime: %@", line );
}
//************************************************      nice primes file write  ****************


//************************************************      temp file read          ****************
-(void)openTempFileForReadWith:(NSString *)path  {
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    readTempFile = fopen(pathWithExtension.UTF8String, "r");
}
-(void)closeTempFileForRead
{
    fclose( readTempFile );
}

-(NSString *)readLineFromFile:(FILE *)file
{
    int lineSize = 1000;
    char lineBuf[lineSize];
    char *result = fgets(lineBuf, lineSize, file);
    if ( result )
        return [NSString stringWithUTF8String:[self trimLineEnding: result]];
    else
        return nil;
}
//************************************************      temp file read          ****************

-(NSString *)lastLineForFile:(NSString *)path
{
    NSString *pathWithExtension = [NSString stringWithFormat:@"%@.%@",path , fileExtension];
    readTempFile = fopen(pathWithExtension.UTF8String, "r");
    
    if ( readTempFile )  {
        NSString *temp = @"";
        NSString *previous;

        do  {
            previous = temp;
            temp = [self readLineFromFile:readTempFile];
        } while (temp);
        
        fclose( readTempFile );
        return previous;
    }
    
    else
        return nil;
}

-(void)setModSize:(int)size
{
    modSize = size;
}

-(instancetype)init:(int)modulasSize
{
    self = [super init];
    modSize = modulasSize;
    return self;
}

@end
