//
//  NullParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct NullParser: JsonParser {
    
    func parse(with reader: Reader) throws -> JSON {
        
        try self.prepareForReading(with: reader)
        
        //try to read the "null" literal, throw if anything goes wrong
        try reader.stopAtFirstDifference(ByteReader(content: Const.Null))
        return .null
    }
}
