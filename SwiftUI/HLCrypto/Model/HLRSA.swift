//
//  HLRSA.swift
//  RSATool
//
//  Created by Matthew Homer on 10/30/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

//************************************************************************
//        Z(N) = { 1, 2, ... N-1 } but I don't use '1' so it becomes
//        Z(N) = { 2, 3, ... N-1 }
//        N = RSA_P * RSA_Q
//        Gamma = lcm( RSA_P-1, RSA_Q-1 )
//        RSA_KeyPublic * RSA_KeyPrivate is congruant to 1 mod( Gamma )
//        C = M**RSA_KeyPublic  % N
//        M = C**RSA_KeyPrivate % N
//************************************************************************
import Cocoa

public typealias HLPrimeType = Int64

public struct HLRSA {

    let N: HLPrimeType
    let phi: HLPrimeType
    var keyPrivate: HLPrimeType = 0 //  gets set in init()
    var keyPublic: HLPrimeType
    let chunkSizeInt: Int
    let chunkSizeDouble: Double

    let characterSetSize: HLPrimeType   //  used in calculations involving HLPrimetypes
    let characterSet: [Character]
    let paddingChar: Character = "~"
    let paddingNeededThreshold: HLPrimeType
    
    
    //  chunker chops off a chuck of the workingString (mutating the workingString)
    //  while consuming the workingString, if a paddingChar is consumed,
    //  the chunker stops consuming and returns the chunk smaller than it would otherwise
    func chunker(workingString: inout String) -> String   {
        guard workingString.count > 0 else { return "" }
        
        var chunk = String(workingString.removeFirst())
        var chunkInt = stringToInt(chunk)
       
//        print( "chunker-  workingString: \(workingString)" )
        
        while chunkInt < N && workingString.count > 0 {
            var tempChunk = chunk
            let nextChar = workingString.first!  //  take a peek but don't consume yet
            
            if nextChar == paddingChar {
                workingString.removeFirst() //  consume delimiter then return
                break
            }
            tempChunk.append(workingString.first!)  //  take a peek but don't consume yet
            chunkInt = stringToInt(tempChunk)
            
            if chunkInt < N {
                chunk.append(workingString.removeFirst())
            }
        }
        
        return chunk
    }

    func fastExp2Of(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        let arraySize = 100
        var value: [Float80] = Array(repeatElement(0, count: arraySize))
        var weight: [HLPrimeType] = Array(repeatElement(0, count: arraySize))
        var i = 0
        var partialResult = Float80(a)
        value[0] = Float80(a)
        weight[0] = 1
        let bigMod = Float80(mod)
        
        while weight[i] < exp   {
            i += 1
            let temp = partialResult * partialResult
            partialResult = temp.truncatingRemainder(dividingBy: bigMod)
            value[i] = partialResult
            weight[i] = weight[i-1] * 2
  //      print( "i: \(i)   weight[i]: \(weight[i])   partialResult: \(partialResult)" )
       }
       
 //       print( "fastExp2Of: \(a)   exp: \(exp)   mod: \(mod)   i: \(i)" )
       partialResult = 1
       var count = exp
       
        while count > 0  {
            var j = 0
            while weight[j+1] < count   {
                j += 1
            }
            
            let temp = partialResult * value[j]
            partialResult = temp.truncatingRemainder(dividingBy: bigMod)
   //         print( "count: \(count)   j: \(j)" )
            count -= weight[j]
        }

        return HLPrimeType(partialResult)
    }
    
    
    func fastExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {

        var weight: HLPrimeType = 0
        var d: Float80 = 1
        var i: Int = 60
        var bitIndex = Int64(pow(2.0, Double(i)))
        let bigMod = Float80(mod)
        let bigA = Float80(a)

//        print( "fastExpOf: \(a)   exp: \(exp)   mod: \(mod)" )

        while i >= 0 {
        
            weight = weight << 1
            var bigD = d
            bigD *= bigD
            d = bigD.truncatingRemainder(dividingBy: bigMod)
            d = Float80(Int64(d))

            let testB = exp & bitIndex > 0
 //           print( "i: \(i)   bitIndex: \(bitIndex)    weight: \(weight)    testB: \(testB)   d: \(d)   temp: \(temp.debugDescription)" )

           if testB   {
                weight += 1
                let temp = d * bigA
                d = temp.truncatingRemainder(dividingBy: bigMod)
       //         d = Int64(temp2)
       //      print( "i: \(i)   bitIndex: \(bitIndex)    weight: \(weight)   d: \(d)   temp: \(temp.debugDescription)" )
           }
            
 //          print( "i: \(i)   testB: \(testB)    weight: \(weight)   d: \(d)   " )
            bitIndex = bitIndex >> 1
            i -= 1
        }
        
        return Int64(d)
    }

    func slowExpOf(a: HLPrimeType, exp: HLPrimeType, mod: HLPrimeType) -> HLPrimeType   {
        
        let bigMod = Float80(mod)
        let bigA = Float80(a)
        var bigC = bigA

        for _ in 2...exp    {
            bigC *= bigA
            bigC = bigC.truncatingRemainder(dividingBy: bigMod)
        }

       return Int64(bigC)
    }

    func encode( m: HLPrimeType, key: HLPrimeType) -> HLPrimeType {
        let result = fastExpOf(a: m, exp: key, mod: N)
//        let result2 = fastExp2Of(a: m, exp: key, mod: N)
//        let result3 = slowExpOf(a: m, exp: key, mod: N)
  //      assert(result == result2 )
//        print( "encode-  result: \(result)  result2: \(result2)  result3: \(result3)" )
        return result
    }
    
    
    //  for a give char, return it's index in the charSet
    //  add 1 to index to avoid returning zero
    func indexForChar( c: Character) -> Int {
        for index in 0..<Int(characterSetSize) {
            if c == characterSet[index] {
                return index
            }
        }
        
        assert(false, "indexForChar failed to find character")
        return 0    //  returns 0 if not found
    }
    
    
    func stringToInt(_ text: String) -> HLPrimeType {
        var result: HLPrimeType = 0
        
        for char in text    {
            if char == paddingChar { break }
            
            result *= characterSetSize
            let n = HLPrimeType(indexForChar(c: char))
   //         print( "stringToInt-  char: \(char)  result: \(result)    n: \(n)" )
            result += n     //  need to avoid n == 0
       }
        
        return result
    }
    
    //  have to subtract one to make up for the add one in stringToInt()
    func intToString(_ n: HLPrimeType ) -> String {
        var result = ""
        var workingN = n
        var power = characterSetSize
        while power < n {   power *= characterSetSize }
        
        while power > 1 {
            power /= characterSetSize
            let index = Int(workingN / power)
                
//            print( "intToString-  workingN: \(workingN)  power: \(power)    index: \(index)" )
            result.append(characterSet[index])
            workingN %= power
   //         print( "intToString-  result: \(result)" )
        }
        
        return result
    }
    
    
    //  check each character in the input string and replace any invalid character with a default character
    //  use the last character in the characterSet as the default character
    //  all occurances of the characterSet.first will be replaced with characterSet.last
    //  this is a special case where characterSet.first is part of the characterSet but not allowed in the plaintext
    public func validateStringForEncode(_ data: String ) -> String   {
        var inputString = data
        var outputString = ""

        while inputString.count > 0    {
            var char = inputString.removeFirst()
            if !characterSet.contains(char) || char == characterSet.first!   {
                print( "****************    Warning:  Invalid character: '\(char)' in string!" )
                char = characterSet.last!   //  use the last char as the default
            }

            outputString.append(char)
        }
        
        return outputString
    }
        
    //  check each character in the input string and replace any invalid character with a default character
    //  use the last character in the characterSet as the default character
    //  ignore (leave in place) any paddingChars
    public func validateStringForDecode(_ data: String ) -> String   {
        var inputString = data
        var outputString = ""

        while inputString.count > 0    {
            var char = inputString.removeFirst()
            if !characterSet.contains(char) && char != paddingChar   {
                print( "****************    Warning:  Invalid character: '\(char)' in string!" )
                char = characterSet.last!   //  use the last char as the default
            }

            outputString.append(char)
        }
        
        return outputString
    }
        
    public func encodeString(_ input: inout String) -> String  {
        input = validateStringForEncode(input)
        print( "HLRSA-  encodeString:  \(input)" )

        var workingString = input
        var byteStuffedInput = ""
        var dataOut = ""
        
        var plainChunk = chunker(workingString: &workingString)
//           print( "HLRSA1-  encodeFile-  chunk: \(chunk)  workingString: \(workingString)" )
        
        while plainChunk.count > 0 {
            byteStuffedInput.append(plainChunk)
            let plainInt = stringToInt(plainChunk)
            let cipherInt = encode(m: plainInt, key: keyPublic)
            var cipherChunk = intToString(cipherInt)
            
            //  when encoding, must pad chunk for small ints otherwise chunker won't know when to end chunk
            if cipherInt < paddingNeededThreshold {
                cipherChunk.append(paddingChar)
            }
            
            dataOut.append(cipherChunk)
            
            //  don't use cipherInt in case there is a stringToInt() or intToString() problem
            let newCipherInt = stringToInt(cipherChunk)
            let newPlainInt = encode(m: newCipherInt, key: keyPrivate)
            
            //  paddingChar needed in ciphertext by the chunker but should be stripped from deciphertext
            let decodedString = intToString(newPlainInt)
/*            if decodedString.last == paddingChar {
                deCipherString.removeLast()
            }   */
            
            print( "plainChunk: \(plainChunk)    plainInt: \(plainInt)    cipherInt: \(cipherInt)    cipherChunk: \(cipherChunk)    decodedString: \(decodedString)" )
            if plainChunk != decodedString {
                print("******************   Error-  chunk: \(plainChunk) decoded back to \(decodedString)")
            }
    //        assert(chunk == decodedString, "Error-  plainChunk: \(plainChunk) decoded back to \(decodedString)")
            
            plainChunk = chunker(workingString: &workingString)
        }
        
        input = byteStuffedInput
        return dataOut
    }
    
    public func decodeString(_ input: inout String) -> String  {
        input = validateStringForDecode(input)
        print( "HLRSA-  decodeString:  \(input)" )

        var workingString = input
        var dataOut = ""
        
        var cipherChunk = chunker(workingString: &workingString)
//           print( "HLRSA1-  decodeString-  cipherChunk: \(cipherChunk)  workingString: \(workingString)" )

        while cipherChunk.count > 0 {
            let cipherInt = stringToInt(cipherChunk)
            let decipherInt = encode(m: cipherInt, key: keyPrivate)
            let decipherChunk = intToString(decipherInt)
            
            dataOut.append(decipherChunk)
            
            //  don't use decipherInt in case there is a stringToInt() or intToString() problem
            let newDecipherInt = stringToInt(decipherChunk)
            let newCipherInt = encode(m: newDecipherInt, key: keyPublic)
            
            //  paddingChar needed in ciphertext by the chunker but should be stripped from deciphertext
            let decodedString = intToString(newCipherInt)
/*            if decodedString.last == paddingChar {
                deCipherString.removeLast()
            }   */
            
            print( "cipherChunk: \(cipherChunk)    cipherInt: \(cipherInt)    decipherInt: \(decipherInt)    decipherChunk: \(decipherChunk)    decodedString: \(decodedString)" )
            if cipherChunk != decodedString {
                print("******************   Error-  chunk: \(cipherChunk) decoded back to \(decodedString)")
            }
    //        assert(chunk == decodedString, "Error-  chunk: \(chunk) decoded back to \(decodedString)")
            
            cipherChunk = chunker(workingString: &workingString)
        }
        
        return dataOut
    }
    
    public func encodeFile(inputFilepath: String, outputFilepath: String)  {
//        print( "HLRSA-  encode: \(path)" )
        do {
            var dataIn = try String(contentsOfFile: inputFilepath, encoding: .utf8)
            var dataOut = encodeString(&dataIn)
            let dataVerify = decodeString(&dataOut)
            
            if dataIn != dataVerify {
                print("encodeFile Error-  dataIn: \(dataIn) decoded back to \(dataVerify)")
            }
       //     assert(dataIn == dataVerify, "encodeFile Error-  dataIn: \(dataIn) decoded back to \(dataVerify)")

            try dataOut.write(toFile: outputFilepath, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func decodeFile(inputFilepath: String, outputFilepath: String)  {
//        print( "HLRSA-  decodeFile: \(inputFilepath)" )
        do {
            var dataIn = try String(contentsOfFile: inputFilepath, encoding: .utf8)
            var dataOut = decodeString(&dataIn)
            let dataVerify = encodeString(&dataOut)
            
            if dataIn != dataVerify {
                print("decodeFile Error-  dataIn: \(dataIn) decoded back to \(dataVerify)")
            }
       //     assert(dataIn == dataVerify, "encodeFile Error-  dataIn: \(dataIn) decoded back to \(dataVerify)")

            try dataOut.write(toFile: outputFilepath, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //  returns -1 if the calculation fails
    func calculateKey(publicKey: HLPrimeType) -> HLPrimeType  {
        let arraySize = 50
        let bigGamma = Float80(exactly: phi)!
        var s: [Float80] = Array(repeating: 0, count: arraySize)
        var t: [Float80] = Array(repeating: 0, count: arraySize)
        var r: [Float80] = Array(repeating: 0, count: arraySize)
        s[0] = 1
        s[1] = 0
        t[0] = 0
        t[1] = 1
        r[0] = bigGamma
        r[1] = Float80(exactly: publicKey)!
        var i = 1
        
        while r[i].rounded() != 1 && r[i].rounded() != 0    {
            i += 1
            let bigQ = r[i-2] / r[i-1]
            let bigInt = Int64(bigQ)
            let q = Float80(exactly: bigInt)!
            s[i] = s[i-2] - q * s[i-1]
            t[i] = t[i-2] - q * t[i-1]
            r[i] = r[i-2] - q * r[i-1]
  //          print( "i: \(i)    r[i]: \(r[i])" )
        }

        if r[i].rounded() == 1        {
            var privateKey = t[i]
            if privateKey <= 0     {   privateKey += bigGamma       }
            
            let product = Float80(exactly: publicKey)! * Float80(exactly: privateKey)!
            let keyVerify = product.truncatingRemainder(dividingBy: bigGamma)
            assert( keyVerify.rounded() == 1 )
            return Int64(exactly: privateKey)!
        } else {
            return -1
        }
    }

    //  returns -1 if the calculation fails
    func calculateKey2(publicKey: HLPrimeType) -> HLPrimeType  {
        let arraySize = 50
        var s: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        var t: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        var r: [HLPrimeType] = Array(repeating: 0, count: arraySize)
        s[0] = 1
        s[1] = 0
        t[0] = 0
        t[1] = 1
        r[0] = phi
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
            if privateKey <= 0     {   privateKey += phi       }
            
            let product = Float80(exactly: publicKey)! * Float80(exactly: privateKey)!
            let keyVerify = product.truncatingRemainder(dividingBy: Float80(exactly: phi)!)
            assert( keyVerify == 1 )
            return privateKey
        } else {
            return -1
        }
    }
    
    public func makeRandomPlaintextString(numberOfCharacters: Int) -> String {
        var outputString = ""
        for _ in 0..<numberOfCharacters {
            //  never include characterSet[0]
            let randomInt = Int.random(in: 1..<Int(characterSetSize))
            outputString.append(characterSet[randomInt])
        }
        
        return outputString
    }
    
    public func makeRandomPlaintextFile(fileURL: URL, numberOfCharacters: Int)  {
        let data = makeRandomPlaintextString(numberOfCharacters: numberOfCharacters)
        do {
            try data.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    init(p: HLPrimeType, q: HLPrimeType, publicKey: HLPrimeType, characterSet: String) {
    
        self.characterSet = Array(characterSet)
        characterSetSize = Int64(characterSet.count)

        N = p * q
        phi = (p-1) * (q-1)

        chunkSizeDouble = log(Double(N)) / log(Double(characterSetSize))
        chunkSizeInt = Int(chunkSizeDouble)
        
        var temp: HLPrimeType = 1
        for _ in 0..<chunkSizeInt {
            temp *= characterSetSize
        }
        paddingNeededThreshold = temp
        
        keyPublic = publicKey
        keyPrivate = calculateKey(publicKey: publicKey)
        
        print( "HLRSA-  init-  p: \(p)    q: \(q)    N: \(N)    Phi: \(phi)   publicKey: \(publicKey)" )
        print( "HLRSA-  init-  characterSet: \(characterSet)   charSetSize: \(characterSetSize)    chuckSize: \(String.init(format:" %0.2f", arguments: [chunkSizeDouble]))" )
    }
}
