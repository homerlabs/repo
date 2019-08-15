//
//  HLFileManager.m
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import "HLFileManager.h"
#import <stdio.h>

static HLFileManager *sharedInstance = nil;

@implementation HLFileManager

FILE *primesReadFile, *primesAppendFile;
FILE *nicePrimesWriteFile;
FILE *readTempFile;
int modSize = 1000000;
int modCounter = 0;


-(void)createPrimeFileWith:(NSString *)path {
        primesAppendFile = fopen(path.UTF8String, "w");    //  create new file
        
        if ( primesAppendFile != nil )
        {
            [self appendPrimesLine: @"1\t2\n"];
            [self appendPrimesLine: @"2\t3\n"];
            [self closePrimesFileForAppend];
        }
}

//************************************************      primes file read        ****************
-(int)openPrimesFileForReadWith:(NSString *)path  {
    primesReadFile = fopen(path.UTF8String, "r");
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


//************************************************      primes file append      ****************
-(void)openPrimesFileForAppendWith:(NSString *)path  {
     primesAppendFile = fopen(path.UTF8String, "a");
}
-(void)closePrimesFileForAppend
{
    fclose( primesAppendFile );
}

-(void)appendPrimesLine:(NSString *)line
{
    int n = line.intValue;
    if ( n % modSize == 0 )
    {
        //        let density = Float80(self.lastP) / Float80(self.lastN)
        NSArray<NSString *> *array = [line componentsSeparatedByString:@"\t"];
        NSString *lastNStr = array[0];
        NSString *lastPStr = [NSString stringWithFormat:@"%@", array[1]];
        
        UInt64 lastN = lastNStr.intValue;
        UInt64 lastP = lastPStr.intValue;
        NSLog( @"** new prime-  lastN: %llu    lastP: %llu    density: %0.3f", lastN, lastP, lastN/(lastP*1.0) );
    }
    
    fputs(line.UTF8String, primesAppendFile);
}
//************************************************      primes file append      ****************


//************************************************      nice primes file write  ****************
-(int)openNicePrimesFileForWriteWith:(NSString *)path
{
    nicePrimesWriteFile = fopen(path.UTF8String, "w");
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

/*-(NSString *)lastLineForFile:(NSString *)path
{
    readTempFile = fopen(path.UTF8String, "r");
    
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
}   */

-(char *)trimLineEnding:(char *)line
{
    unsigned long len = strlen(line);
    line[len-1] = '\0';       //  need to remove '\n'
   return line;
}

-(void)setModSize:(int)size
{
    modSize = size;
}

+ (instancetype)sharedInstance
{
    if (!sharedInstance)
        sharedInstance = [[HLFileManager alloc] init];
    return sharedInstance;
}

@end
