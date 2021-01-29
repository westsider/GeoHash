//
//  DateHelp.swift
//  GeoHash
//
//  Created by Warren Hansen on 1/29/21.
//

import Foundation

class DateHelp {
    static func ISOStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter.string(from: date).appending("Z")
    }
    
    static func dateFromISOString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: string)
    }
    
    static func dateToShort(date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        return formatter1.string(from: date)
    }
    
    class func convertToDateFrom(string: String, debug: Bool)-> Date? {
        let formatter = DateFormatter()
        if ( debug ) { print("\ndate string: \(string)") }
        let dateS = string
        formatter.dateFormat = "dd/MM/yy"
        if let date:Date = formatter.date(from: dateS) {
            if ( debug ) { print("Convertion to Date: \(date)\n") }
            return date
        } else {
            return formatter.date(from: "1900/01/01")
        }
    }
    
    static func convertTimestamp(serverTimestamp: Double) -> String {
        let x = serverTimestamp
        let date = NSDate(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter.string(from: date as Date)
    }
    
    static func convert1970toDate(serverTimestamp: Double) -> Date {
        let x = serverTimestamp
        let date2 = Date(timeIntervalSince1970: x)
        return date2
    }
}
