//
//  HLRSA.swift
//  RSATool
//
//  Created by Matthew Homer on 10/30/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

//************************************************************************
//        Z(N) = { 1, 2, ... N-1 } but I don't use '1' so it is really
//        Z(N) = { 2, 3, ... N-1 }
//        N = RSA_P * RSA_Q
//        Gamma = lcm( RSA_P-1, RSA_Q-1 )
//        RSA_KeyPublic * RSA_KeyPrivate is congruant to 1 mod( Gamma )
//        C = M**RSA_KeyPublic  % N
//        M = C**RSA_KeyPrivate % N
//************************************************************************
import Cocoa

class HLRSA: NSObject {

    let N: Int64
    let Gamma: Int64
    let charSet: [String] = ["_", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ",", "?", "-", "!", " ",
                             "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                             "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    init(p: Int64, q: Int64) {
    
    N = p * q
    Gamma = (p-1) * (q-1)
    
    super.init()

    print( "HLRSA-  init-  p: \(p)    q: \(q)    N: \(N)    Gamma: \(Gamma)    CharSet size: \(charSet.count)" )
}

    func calculateKey(publicKey: HLPrimeType) -> HLPrimeType  {
        let arraySize = 50
        var s: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        var t: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        var r: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        s[0] = 1
        s[1] = 0
        t[0] = 0
        t[1] = 1
        r[0] = Gamma
        r[1] = publicKey
        var i = 1
        
        while r[1] != 1 && r[i] != 0    {
            i += 1
            let q = r[i-2] / r[i-1]
            s[i] = s[i-2] - q * s[i-1]
            t[i] = t[i-2] - q * t[i-1]
            r[i] = r[i-2] - q * r[i-1]
            print( "i: \(i)    r[i]: \(r[i])" )
        }

        if r[i] == 1        {
            if t[i] > 0     {   return t[i]          }
            else            {   return t[i] + Gamma  }
        }
        
        else                {   return -1            }
    }


    func fastExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        
        var c: HLPrimeType = 0
        var d: HLPrimeType = 1
        var i: Int = 62
        var bitIndex = Int64(pow(2.0, Double(i)))

        print( "fastExpOf: \(a)   exp: \(exp)   mod: \(mod)" )

        while i >= 0 {
        
  //          print( "i: \(i)   bitIndex: \(bitIndex)" )
            c *= 2
            d = (d * d) % mod
            
           let testB = exp & bitIndex > 0
           
           if testB   {
                c += 1
                d = (d * a) % mod
            }
            
      //     print( "i: \(i)   testB: \(testB)    c: \(c)   d: \(d)   " )
            bitIndex = bitIndex >> 1
            i -= 1
        }
        
        return d
    }

    func slowExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        
        var c: HLPrimeType = a
        
        for _ in 2...exp    {
            c *= a
            c %= mod
        }

        return c
    }

    func LCM(lcmA: Int64, lcmB: Int64) -> Int64 {
        print( "lcmA: \(lcmA)   lcmB: \(lcmB)" )
    
        return 0
    }

}
