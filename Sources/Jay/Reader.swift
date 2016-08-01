//
//  Reader.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

public protocol Reader: class {
    
    // Returns the currently pointed-at char
    func curr() -> UInt8

    // Moves cursor to the next char
    func next() throws
    
    // Returns `true` if all characters have been read 
    func isDone() -> Bool
    
    // Finish parsing when valid JSON object has been parsed?
    // Return true: for streaming parsers that never end, so that we don't
    //              hang on waiting for more data even though a valid JSON
    //              object has been parsed.
    // Return false: for parsers that already have all data in memory, stricter
    //               mode that ensures that no invalid trailing bytes have been
    //               sent after the valid JSON object.
    func finishParsingWhenValid() -> Bool
}

extension Reader {
    
    func readNext(_ next: Int) throws -> [JChar] {
        try self.ensureNotDone()
        var buff = [JChar]()
        while buff.count < next {
            buff.append(self.curr())
            try self.nextAndCheckNotDone()
        }
        return buff
    }
    
    func ensureNotDone() throws {
        if self.isDone() {
            throw JayError.unexpectedEnd(self)
        }
    }
    
    func nextAndCheckNotDone() throws {
        try self.next()
        try self.ensureNotDone()
    }
    
    // Consumes all contiguous whitespace and returns # of consumed chars
    @discardableResult
    func consumeWhitespace() throws -> Int {
        var counter = 0
        while !self.isDone() {
            let char = self.curr()
            if Const.Whitespace.contains(char) {
                //consume
                counter += 1
                try self.next()
            } else {
                //non-whitespace, return
                break
            }
        }
        return counter
    }
    
    // Iterates both readers and checks that characters match until
    // a) expectedReader runs out of characters -> great! all match
    // b) self runs out of characters -> bad, no match!
    // c) we encounter a difference -> bad, no match!
    func stopAtFirstDifference(_ other: ByteReader) throws {
        
        while true {
            
            if other.isDone() {
                //a) all matched, return
                return
            }
            
            if self.isDone() {
                //b) no match
                throw JayError.mismatch(self, other)
            }

            let charSelf = self.curr()
            let charOther = other.curr()
            guard charSelf == charOther else {
                //c) no match
                throw JayError.mismatch(self, other)
            }
            
            try self.next()
            try other.next()
        }
    }
}


