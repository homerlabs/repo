#  HLCrypto  also known as RSATool

Apple forbade the use of the name 'RSATool' for this app which was too bad as that is excatly what this app is.  The user selects primes P and Q, the Character Set to Encode/Decode, and the Private Key from which the Public Key is calculated.

To Encode, select plaintext file and provide name/path for ciphertext file.  Once the Encode is completed, a Decode operation is performed comparing that result with the original plaintext message.  This verifies the correctness of the Encode.

To Decode, provide ciphertext path is not already present and provide deciphertext name/path.  Once the Decode is completed, a Encode is performed comparing the result with the original ciphertext.  This verifies the correctness of the Decode.

TODO:
    update Help files
    add more/better unit tests
    test everything and get ready to ship
    add Firebase?
