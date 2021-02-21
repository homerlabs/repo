//
//  HLFileManager.swift
//  Prime Finder
//
//  Created by Matthew Homer on 2/8/21.
//  Copyright © 2021 Matthew Homer. All rights reserved.
//

import Foundation
import Cocoa

class HLFileManager {
    static let shared = HLFileManager()
    let defaultFileManager = FileManager.default
    var urlWritting: URL?
    var urlReading: URL?
    private var readBuffer: String = ""
    var buffer: UnsafeMutablePointer<UInt8>!    //  gets allocated on file open
    let bufferSize = 4096

    var inStream: InputStream?
    var outStream: OutputStream?

    func getLastLine(_ url: URL?) -> String {
        var nextLine = ""
        var lastLine = ""
        urlReading = url
        let success = openFileForRead(url: urlReading)
        guard success else { return "" }
        
        nextLine = getNextLine()

        while !nextLine.isEmpty {
            lastLine = nextLine
            nextLine = getNextLine()
        }
        
        closeFileForReading()
        return lastLine
    }
    
    //  scans readBuffer for '\n' delimited line and if found
    //  removes it from the head of readBuffer
    //  returns line if found or ""
    private func readLineFromBuffer() -> String {
        var returnString = ""
        
        if let index = readBuffer.firstIndex(of: "\n") {
            returnString = String(readBuffer[...index])
            readBuffer = String(readBuffer.dropFirst(returnString.count))
        }

        return returnString
    }
 
    // reads bufferSize data from iStream
    //  returns converted String or ""
    private func readIntoBuffer() -> String {
        var returnString = ""
        let readCount = inStream!.read(buffer, maxLength: bufferSize)
        if readCount == -1 {
            print("Serious ERROR:  streamError: \(String(describing: inStream!.streamError)).\n")
        }
        else {
            let data = Data(bytes: buffer, count: readCount)
            if let str = String(data: data, encoding: .utf8) {
                returnString = str
            }
        }
        
        return returnString
    }
    
    func getNextLine() -> String {
        var nextLine = readLineFromBuffer()
        
        //  check to see if we need to read more data from the inputstream
        if nextLine.isEmpty {
            readBuffer.append(readIntoBuffer())
            nextLine = readLineFromBuffer()
        }
        
        return nextLine
    }
    
    //  returns true for success
    func openFileForRead(url: URL?) -> Bool {
        urlReading = nil
        
        if url != nil && defaultFileManager.fileExists(atPath: url!.path) {
            urlReading = url
        }
        else {
            urlReading = getURLForReading(url: url)
        }
        
        //************************************************************
        //  if we get a URL, set iStream and create buffer
        if urlReading != nil {
            setBookmarkForURL(urlReading, key: HLPrime.HLPrimesURLKey)
            inStream = InputStream(url: urlReading!)
            inStream?.open()
            buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            return inStream != nil
        }
        else {
            return false
        }
    }
    
    //  creates empty 'SomeFile.txt' file
    //  returns true on success
    func createTextFile(url: URL?) -> Bool {
        guard url != nil else { return false }
        
        urlWritting = url
        return defaultFileManager.createFile(atPath: urlWritting!.path, contents: nil, attributes: nil)
    }
    
    //  appends string to URL urlWritting
    //  returns true on success
    @discardableResult func appendStringToFile(_ data: String) -> Bool {
        guard urlWritting != nil else { return false }
        
        if let outputStream = OutputStream(toFileAtPath: urlWritting!.path, append: true) {
            outputStream.open()
            let writeCount = outputStream.write(data, maxLength: data.count)
            outputStream.close()
            return writeCount == data.count ? true : false
        }
        else {
            return false
        }
    }
    
    func closeFileForReading() {
        inStream?.close()
        buffer.deallocate()
    }
    
    func closeFileForWritting() {
        outStream?.close()
    }
    
    //  returns true if url found on the file system
    func isFileFound(url: URL?) -> Bool {
        guard url != nil else { return false }
        return defaultFileManager.fileExists(atPath: url!.path)
    }

    //  keep private as this is a singleton class
    private init() {}
}

extension HLFileManager {
    //  TODO check for presence of file before try
    func setBookmarkForURL(_ url: URL?, key: String) {
        do  {
            let data = try url?.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                    includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey:key)
        }   catch   {
            print("****************************     HLWarning:  Unable to create security bookmark for key: \(key)   Error: \(error)!")
        }
    }

    func getBookmark(_ key: String) -> URL?   {
        var url: URL?
        
        if let data = UserDefaults.standard.data(forKey: key)  {
            do  {
                var isStale = false
                    url = try URL(resolvingBookmarkData: data, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    let success = url!.startAccessingSecurityScopedResource()

                    if !success {
                        print("startAccessingSecurityScopedResource-  success: \(success)")
                    }
                } catch {
                    print("HLWarning:  Unable to optain security bookmark for key: \(key)!")
                }
        }
        return url
    }
    
    func getURLForReading(url: URL?) -> URL? {
        var url: URL?
        let openPanel = NSOpenPanel();
        openPanel.canCreateDirectories = true;
        openPanel.allowedFileTypes = ["txt"];
        openPanel.showsTagField = false;
        openPanel.message = "Set Primes file path";
        
        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK) {
            url = openPanel.url
        }
    
        return url
    }

    func getURLForWritting(title: String, message: String, filename: String) -> URL? {
        var url: URL?
    
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.title = title
        savePanel.nameFieldStringValue = filename
        savePanel.message = message
        savePanel.allowedFileTypes = ["txt"]
        
        let response = savePanel.runModal()
        
        if response == NSApplication.ModalResponse.OK {
            url = savePanel.url
        }
        else {
            print("NSSavePanel operation was canceled.")
        }
        
        print("url: \(String(describing: url))")
        return url
    }

}
