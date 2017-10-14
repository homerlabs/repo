/*
 *  Primes.h
 *  PrimeClass
 *
 *  Created by Matthew Homer on Fri Aug 29 2003.
 *  Copyright (c) 2003-2009 HomerLabs. All rights reserved.
 *
 */
#include <Carbon/Carbon.h>
using namespace std;

enum outputMode
{
	kNoOutput = 0,
	kPrimes,
	kNumberedPrimes
};


class Primes
{
    public:
    enum err
    {
        kNoErr = 0,
        kMallocErr,
        kOpenFileErr,
        kEOFErr,
        kGeneralErr
    };

    int MakePrimes( const char *filename, UInt32 numOfPrimes, UInt32 modSize, int outputMode );
    
	int FactorPrimes( const char *inFilename, const char *factoredFilename, 
		const char *factoredNiceFilename, UInt32 terminalCount, UInt32 modSize, int outputMode );
    
	int FindNPrime( const char *filename, UInt32 n );
};