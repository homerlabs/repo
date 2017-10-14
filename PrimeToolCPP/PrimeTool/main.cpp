#include <iostream>
#include "Primes.h"

char defaultPrimeFilename[] = "/zPrimes";
char defaultFactoredPrimeFilename[] = "/zFactoredPrimes";
char defaultFactoredNicePrimeFilename[] = "/zNiceFactoredPrimes";

int main ( int argc, const char *argv[] ) 
{
	int		numberOfPrimes = 1000000;
	int		outputMode = kPrimes;
	const char	*primeFilename				= defaultPrimeFilename;
	const char	*factoredPrimeFilename		= defaultFactoredPrimeFilename;
	const char	*factoredNicePrimeFilename	= defaultFactoredNicePrimeFilename;
	
	if ( argc > 6 )
	{
		cout << "\nERROR:  Too many command line arguments.  Must be 5 or less.\n"; 
		return 1;
	}
	
	if ( argc > 5 )
		factoredNicePrimeFilename = argv[5]; 
		
	if ( argc > 4 )
		factoredPrimeFilename = argv[4]; 
		
	if ( argc > 3 )
		primeFilename = argv[3]; 
		
	if ( argc > 2 )
		outputMode = atoi(argv[2]); 
		
	else if ( argc > 1 )
	{
		long tempLong = atol(argv[1]); 
		if ( tempLong )
		numberOfPrimes = (int)tempLong; 
	}
	
	int modSize = numberOfPrimes/10;
    Primes myPrimes;
    
    myPrimes.MakePrimes( primeFilename, numberOfPrimes, modSize, outputMode );
    
    myPrimes.FactorPrimes( primeFilename, factoredPrimeFilename, 
			factoredNicePrimeFilename, numberOfPrimes, modSize, outputMode );
    
//    myPrimes.FindNPrime( primeFilename, modSize );

    return 0;
}
