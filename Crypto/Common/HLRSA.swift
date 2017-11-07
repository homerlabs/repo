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

typealias HLPrimeType = Int64

class HLRSA: NSObject {

    let N: HLPrimeType
    let Gamma: HLPrimeType
    var keyPrivate: HLPrimeType = 0
    var keyPublic: HLPrimeType = 0
    let chuckSize: Int
    let charSetSize: HLPrimeType
    let charSet: [Character] = ["_", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ",", "?", "-", "!", " ",
                             "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                             "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    func encode( m: HLPrimeType, key: HLPrimeType) -> HLPrimeType {
        let result = fastExpOf(a: m, exp: key, mod: N)
//        let result = slowExpOf(a: m, exp: key, mod: N)
//        assert(result == result2 )
        return result
    }
    
    
    func stringToInt(text: String) -> HLPrimeType {
        var result: HLPrimeType = 0
        
        for char in text    {
            result *= charSetSize
            let n = Int64(indexForChar(c: char))
     //       print( "stringToInt-  char: \(char)  result: \(result)    n: \(n)" )
            result += n
       }
        
        return result
    }
    
    func intToString( n: HLPrimeType) -> String {
        var result = ""
        var workingN = n
        var power = charSetSize
        while power < n {   power *= charSetSize}
        
        while power > 1 {
            power /= charSetSize
            if workingN >= power {
                let index = Int(workingN / power)
                
 //               print( "intToString-  workingN: \(workingN)  power: \(power)" )
                result.append(charSet[index])
           }
            workingN %= power
 //           print( "intToString-  result: \(result)" )
        }
        
        return result
    }
    
    
    func encodeFile(plaintextURL: URL)  {
//        print( "HLRSA-  encode: \(plaintextURL.path)" )
        do {
            var data = try String(contentsOfFile: plaintextURL.path, encoding: .utf8)
            print( "HLRSA-  encode-  text: \(data)" )
            
            while data.count > 0 {
                var chunk = ""

                for _ in 0..<chuckSize  {
                    if data.count > 0   {
                        let singleChar = data.removeFirst()
                        chunk.append(singleChar)
                     }
                }
                
                let plaintextInt = stringToInt(text: chunk)
                let cypher = encode(m: plaintextInt, key: keyPublic)
                let cypherString = intToString(n: cypher)
                
                let deCypherInt = encode(m: cypher, key: keyPrivate)
                let deCypherString = intToString(n: deCypherInt)
                print( "chunk: \(chunk)    plaintextInt: \(plaintextInt)    cypher: \(cypher)    cypherString: \(cypherString)    deCypher: \(deCypherString)" )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func indexForChar( c: Character) -> Int {
        var index = Int(charSetSize - 1)
        while index >= 0  {
            let d = charSet[index]
            if c == d   {
                break
            }
            
            index -= 1
        }
        
        return index
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
        
        while r[i] != 1 && r[i] != 0    {
            i += 1
            let q = r[i-2] / r[i-1]
            s[i] = s[i-2] - q * s[i-1]
            t[i] = t[i-2] - q * t[i-1]
            r[i] = r[i-2] - q * r[i-1]
  //          print( "i: \(i)    r[i]: \(r[i])" )
        }

        if r[i] == 1        {
            var privateKey = t[i]
            if privateKey <= 0     {   privateKey += Gamma       }
            let keyVerify = (publicKey * privateKey) % Gamma
            assert( keyVerify == 1 )
            return privateKey
        }
        
        else                {   return -1            }
    }


    func fastExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        
        var c: HLPrimeType = 0
        var d: HLPrimeType = 1
        var i: Int = 62
        var bitIndex = Int64(pow(2.0, Double(i)))

 //       print( "fastExpOf: \(a)   exp: \(exp)   mod: \(mod)" )

        while i >= 0 {
        
  //          print( "i: \(i)   bitIndex: \(bitIndex)" )
            c *= 2
            let doubleD = Double(d)
            let temp = doubleD * doubleD
            let temp2 = temp.truncatingRemainder(dividingBy: Double(mod))
  //          print( "temp2a: \(temp2)" )
   //         d = (d * d) % mod
            d = Int64(temp2)

           let testB = exp & bitIndex > 0
           
           if testB   {
                c += 1
 //               d = (d * a) % mod
                let temp = Double(d) * Double(a)
                let temp2 = temp.truncatingRemainder(dividingBy: Double(mod))
      //          print( "temp2b: \(temp2)" )
                d = Int64(temp2)
            }
            
      //     print( "i: \(i)   testB: \(testB)    c: \(c)   d: \(d)   " )
            bitIndex = bitIndex >> 1
            i -= 1
        }
        
        return d
    }

    func slowExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        
    //    var c: HLPrimeType = a
        let doubleA = Double(a)
        var doubleC = Double(a)

        for _ in 2...exp    {
        //    c *= a
        //    c %= mod
            
            doubleC *= doubleA
            doubleC = doubleC.truncatingRemainder(dividingBy: Double(mod))
        }

        return Int64(doubleC)
    }

    init(p: Int64, q: Int64) {
        N = p * q
        Gamma = (p-1) * (q-1)
        charSetSize = Int64(charSet.count)
        let x = log(Double(N)) / log(Double(charSetSize))
    //    print( "HLRSA-  init-  x: \(x)" )
        chuckSize = Int(x)
        
        print( "HLRSA-  init-  p: \(p)    q: \(q)    N: \(N)    Gamma: \(Gamma)    charSetSize: \(charSetSize)    chuckSize: \(chuckSize)" )
        super.init()
    }
}
