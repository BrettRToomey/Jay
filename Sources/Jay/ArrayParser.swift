//
//  ArrayParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ArrayParser: JsonParser {
    
    static func parse<R: Reader>(with r: Unmanaged<R>) throws -> JSON {
        
        let reader = r.takeUnretainedValue()
        
        try self.prepareForReading(with: r)
        
        //detect opening bracket
        guard reader.curr() == Const.BeginArray else {
            throw JayError.unexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //move along, now start looking for values
        try self.prepareForReading(with: r)
        
        //check curr value for closing bracket, to handle empty array
        if reader.curr() == Const.EndArray {
            //empty array
            try reader.next()
            return .array([])
        }
        
        //now start scanning for values
        var values = [JSON]()
        repeat {
            
            //scan for value
            let val = try ValueParser.parse(with: r)
            values.append(val)
            
            //scan for either a comma, in which case there must be another
            //value OR for a closing bracket
            try self.prepareForReading(with: r)
            switch reader.curr() {
            case Const.EndArray: try reader.next(); return .array(values)
            case Const.ValueSeparator: try reader.next(); break //comma, so another value must come. let the loop repeat.
            default: throw JayError.unexpectedCharacter(reader)
            }
        } while true
    }
}

