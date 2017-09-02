//
//  Logger.swift
//  YouWeTestChat
//
//  Created by Anton Makarov on 01.09.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation

class Logger {
    static func debug(msg: AnyObject, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        let fname = (fileName as NSString).lastPathComponent
        print("\(fname):\(funcName):\(line)", msg)
    }
    
    
    static func error(msg: AnyObject, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        debug(msg: "ERROR: \(msg)!!" as AnyObject, line: line, fileName: fileName, funcName: funcName)
    }
    
    
    static func mark(line: Int = #line, fileName: String = #file, funcName: String = #function) {
        debug(msg: "called" as AnyObject, line: line, fileName: fileName, funcName: funcName)
    }
}
