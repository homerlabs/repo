/*
 *  Primes.cpp
 *  PrimeClass
 *
 *  Created by Matthew Homer on Fri Aug 29 2003.
 *  Copyright (c) 2003-2009 HomerLabs. All rights reserved.
 *
 */
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <fstream>
#include <iostream>
#include "Primes.h"


/**************************************************************************************
	Method:  MakePrimes	
	Creates a file of numbered primes.	{ "1\t2\n2\t3\n3\t5\n4\t7\n..." }
	If the file already exists, it is replaced by the new one.
	
	The number of primes found is equal to 'numOfPrimes'.
	'mod_size' is used to produce periodic output so that the user can
	determine what portion of the computation remains.
**************************************************************************************/
int Primes::MakePrimes( const char *filename, UInt32 numOfPrimes, UInt32 modSize, int outputMode )
{
	UInt32	i = 0;
	UInt32	primeCandidate = 3;
	ldiv_t		q_r;
	time_t		start_time, stop_time;
	UInt32	largestTestPrime;	//	only need to test for primes up to this value
    
    UInt32	bufSize = (UInt32) sqrt( numOfPrimes );	//	need a better way to determine array size
	if ( bufSize < 4 )	
		bufSize = 4;
    UInt32 	*buf = new UInt32[bufSize];
	if ( buf==NULL || filename==NULL )
	{
		cout << "find_primes1- WARNING:  NULL POINTER ON CALLOC.\n";
		return kMallocErr;
	}	
			
	ofstream out( filename, ios::out | ios::trunc );
	if ( !out )	
	{
		cout << "MakePrimes- ERROR in opening file: " << filename << ".\n";
		return kOpenFileErr;
	}	

	UInt32	primeCount = 1;
	*buf = 3;
	if ( outputMode == kNumberedPrimes )	//	output our first prime (2)
		out << "1\t2\n";
	else if ( outputMode == kPrimes )	
		out << "2\n";
	
    cout << "\nMake Primes\n"; 
    cout << "Output Filename: " << filename << "\t\tMode: " << outputMode << endl;
    cout << "Number of Primes: " << numOfPrimes << "  \tOutput Modulas: " << modSize 
										<< "  \tBuffer Size: " << bufSize << endl;
	cout << "Entering prime generator loop now.\n";
	time(&start_time);

	while ( primeCount < numOfPrimes )					
	{
		bool is_prime = true;
		largestTestPrime = (int) sqrt( primeCandidate );		
		i = 0;
		
		while ( *(buf+i) <= largestTestPrime )	//	check candiate for prime 
		{
			q_r = ldiv( primeCandidate, *(buf+i) );					
			if ( !q_r.rem )	
			{
				is_prime = false;
				break;
			}
			
			i++;
		}	/*	while	*/

		if ( is_prime )						
		{
            if ( primeCount < bufSize )
                *(buf+primeCount) = primeCandidate;
                
			primeCount++;
			
			if ( !fmod( primeCount, modSize ) )	// should we output to console?
				cout << primeCount << "  \t" << primeCandidate << "\n";	
				
			if ( outputMode == kNumberedPrimes ) 
				out << primeCount << "\t" << primeCandidate << endl;
			else if ( outputMode == kPrimes )	
				out << primeCandidate << endl;
		}
			
		primeCandidate += 2;		// next prime candidate
	}	
	
    out.close();
	time(&stop_time);
    cout << "\nLargest Prime in Buffer: " << buf[bufSize-1] << "\n";
	delete [] buf;
	cout.setf( ios::showpoint );
	cout.precision( 3 );
	double loop_time = difftime(stop_time,start_time);
	if ( loop_time < 120 )
		cout << "\nTime in loop: " << loop_time << " seconds.\n";
	else
		cout << "\nTime in loop: " << loop_time/60.0 << " minutes.\n";
	cout << "Make Primes has completed successfully.\n\n";
              
    return kNoErr;
}


/*************************************************************************
	Method:  FactorPrimes	
	'buf' holds the list of primes to test against.
	'terminal_count' is the index of the prime where factoring stops.
*************************************************************************/
int Primes::FactorPrimes( const char *inFilename, const char *factoredFilename, 
	const char *factoredNiceFilename, UInt32 terminalCount, UInt32 modSize, int outputMode )
{
	time_t	start_time, stop_time;
	ldiv_t	quot_rem;
	int		prime = 0;	//	prime and aptionaly count are read from the prime input file
	int		count = 0;	//	prime and aptionaly count are read from the prime input file
	UInt32	last_i, mod_count=0, index=0;
	UInt32 	factor_count, limit;
	
	cout << "\nFactor Primes\n";
	cout << "Source File: " << inFilename << "  \tFactored Prime File: " << factoredFilename;
	cout << "\nFactored Nice Prime File: " << factoredNiceFilename << "\n";
    cout << "Terminal Count: " << terminalCount << "  \tOutput Modulas: " << modSize << "\n";

	ifstream inFile( inFilename );
	if ( !inFile )	
	{
		cout << "FactorPrimes- ERROR in opening file: " << inFilename << ".\n";
		return kOpenFileErr;
	}	
    
	cout << "\nFinding largest prime to factor...   \t";
    while ( !inFile.eof() )
    {
		index++;
		if ( outputMode == kPrimes ) 
			inFile >> prime;
		else if ( outputMode == kNumberedPrimes )
			inFile >> count >> prime;
        
        if ( index >= terminalCount )
            break;
    }
    inFile.close();
    int largestTestPrime = (UInt32) sqrt( prime );		
    cout << "Largest Prime: " << prime << "\n";

	ifstream inFile2( inFilename );
	index = 0;
    while ( !inFile2.eof() )
    {
		index++;
		if ( outputMode == kPrimes ) 
			inFile2 >> prime;
		else if ( outputMode == kNumberedPrimes )
			inFile2 >> count >> prime;
        
        if ( prime >= largestTestPrime )
            break;
    }
    inFile2.close();
	int tableSize = index;
	UInt32	*buf = new UInt32[tableSize];
	if ( !buf )
	{
		cout << "Error in mallac of buf.\n";
		return kMallocErr;
	}
	
 	//	load array with primes
	cout << "\nLoading buffer with primes...   \n";
	ifstream	in_primes( inFilename );
	UInt32 	tableIndex; 
	if ( in_primes )	
	{
		for ( tableIndex=0; tableIndex<tableSize; tableIndex++ )
		{
			if ( outputMode == kPrimes ) 
				in_primes >> prime;
			else if ( outputMode == kNumberedPrimes )
				in_primes >> last_i >> prime;
			buf[tableIndex] = prime;
		}
	
		cout << "Buffer size: " << tableSize << "   \tLargest prime in buffer: " << prime << endl;
		
		if ( in_primes.eof() )
		{
			cout << "EOF ERROR\n";
			in_primes.close();
			return kEOFErr;
		}
		
		in_primes.close();
	}
	else		
        return kOpenFileErr;
        
	//	open output files and start factoring
/*****ofstream	out1( factoredFilename );
	if ( !out1 )
	{
		cout << "error in opening file: " << factoredFilename << ".\n";
		return kOpenFileErr;
	}
*/	
	ofstream out2( factoredNiceFilename );
	if ( !out2 )
	{
		cout << "error in opening file: " << factoredNiceFilename << ".\n";
		return kOpenFileErr;
	}
	
	ifstream in_source_primes( inFilename );
	if ( outputMode == kPrimes ) 
		in_source_primes >> prime;			//	get next prime
	else if ( outputMode == kNumberedPrimes )
		in_source_primes >> count >> prime;	//	get next prime
	index = 1;
	cout << "\nEntering main loop now...\n" ;
	time(&start_time);

	while ( !in_source_primes.eof() && index<=terminalCount )
	{
		if ( ++mod_count == modSize )
		{
			mod_count = 0;
			cout << index << " \t" << prime << endl;
		}
						
/*****	if ( outputMode == kPrimes ) 
			out1 << prime;
		else if ( outputMode == kNumberedPrimes )
			out1  << count << "\t" << prime;
*/		
		int tempInt = prime / 2;	//	same as (p-1)/2
		limit = (int) sqrt( tempInt );		
		
		for ( factor_count=0, tableIndex=0; buf[tableIndex]<=limit; tableIndex++ )	
		{
			quot_rem = ldiv( tempInt, buf[tableIndex] );
			
			while ( !quot_rem.rem )
			{
//*****			out1  << "\t" << buf[tableIndex];
				tempInt = (int)quot_rem.quot;
				quot_rem = ldiv( tempInt, buf[tableIndex] );
				factor_count++;
			}
		}
        
		if ( tempInt > 1 )
		{
//*****		out1 << "\t" << tempInt;
            
			if ( !factor_count )	//	is this a 'nice' prime?
			{
				if ( outputMode == kPrimes ) 
					out2 << prime << endl;
				else if ( outputMode == kNumberedPrimes )
					out2  << count << "\t" << prime << endl;
			}
		}
        
//*****	out1 << endl;
		if ( outputMode == kPrimes ) 
			in_source_primes >> prime;			//	get next prime
		else if ( outputMode == kNumberedPrimes )
			in_source_primes >> count >> prime; //	get next prime
		index++;
	}	//	while (not done)

	in_source_primes.close();	
//*****out1.close();	
	out2.close();	
	time(&stop_time);

	delete [] buf;
	cout.setf( ios::showpoint );
	cout.precision (3);
	double loop_time = difftime( stop_time, start_time );
	if ( loop_time < 120 )
		cout << "\nTime in loop = " << loop_time << " seconds.\n";
	else
		cout << "\nTime in loop = " << loop_time/60.0 << " minutes.\n";
	cout << "Factor Primes has completed successfully.";
    return kNoErr;
}


/*************************************************************************
	Method:  FindNPrime	
	Find the 'n' prime using numbered prime file 'filename'.
*************************************************************************/
int Primes::FindNPrime( const char *filename, UInt32 n )
{
	UInt32 	i = 0, count = 0, prime = 0;

	ifstream inFile( filename );
	if ( !inFile )	
	{
		cout << "FindNPrime- ERROR in opening file: " << filename << ".\n";
		return kOpenFileErr;
	}	
    
    while ( ++i <= n )
        inFile >> count >> prime;
		
    cout << "\nN: " << count << "  \tPrime: " << prime << "\n";

    inFile.close();
    return kNoErr;
}
