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

FILE *primesReadFILE, *primesAppendFILE;
FILE *nicePrimesWriteFILE;
FILE *readTempFile;
int modSize = 1000000;
int modCounter = 0;


//************************************************      primes file read        ****************
-(int)openPrimesFileForReadWith:(NSString *)path  {
    primesReadFILE = fopen(path.UTF8String, "r");
    return (primesReadFILE == nil); //  return 0 for no error
}

-(void)closePrimesFileForRead
{
    fclose( primesReadFILE );
}

-(NSString *)readPrimesFileLine
{
    return [self readLineFromFile:primesReadFILE];
}
//************************************************      primes file read        ****************


//************************************************      primes file append      ****************
-(int)createPrimesFileForAppendWith:(NSString *)path {
        primesAppendFILE = fopen(path.UTF8String, "w");    //  create new file
    
        if ( primesAppendFILE != nil )
        {
            [self appendPrimesLine: @"1\t2\n"];
            [self appendPrimesLine: @"2\t3\n"];
        }
    return (primesAppendFILE == nil); //  return 0 for no error
}

-(void)closePrimesFileForAppend
{
    fclose( primesAppendFILE );
}

-(void)appendPrimesLine:(NSString *)line
{
    if (line.length < 1 )
    {
//        NSLog( @"HLFileManager-  appendPrimesLine-  empty line ignored" );
//        assert( 0 );
        return;
    }
    
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
    
    fputs(line.UTF8String, primesAppendFILE);
}
//************************************************      primes file append      ****************


//************************************************      nice primes file write  ****************
-(int)createNicePrimesFileForAppendWith:(NSString *)path
{
    nicePrimesWriteFILE = fopen(path.UTF8String, "w");
    assert( nicePrimesWriteFILE );
    modCounter = 0;
    return 0;   //  no error
}
-(void)closeNicePrimesFileForAppend
{
    fclose( nicePrimesWriteFILE );
}

-(void)writeNicePrimesFile:(NSString *)line
{
//    int n = line.intValue;
//    if ( n % kMOD_SIZE == 0 )
    
    fprintf(nicePrimesWriteFILE, "%s\n", line.UTF8String);
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

/*-(void)openPrimesFileForAppendWith:(NSString *)path  {
     primesAppendFILE = fopen(path.UTF8String, "a");
}   */

@end
