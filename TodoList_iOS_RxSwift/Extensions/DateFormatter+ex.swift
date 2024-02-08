//
//  DateFormatter+ex.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2024/02/09.
//

import Foundation


extension DateFormatter {
    
    /// FormatをFormatType別にフォーマットを返す
    private static func _dateFormatter(type: FormatType) -> DateFormatter {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = switch type {
        case .secnd: "yyyy/MM/dd HH:mm:ss"
        case .date:  "yyyy/MM/dd"
        case .dateTime: "yyyy/MM/dd HH:mm"
        default: "yyyy/MM/dd HH:mm"
        }
        
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter
    }
    
    
    /// Stringのフォーマットを設定Dateを返す
    static func dateFromString(string: String, type: FormatType) -> Date? {
        let formatter: DateFormatter = _dateFormatter(type: type)
        return formatter.date(from: string)
    }
    
    
    /// Dateのフォーマットを設定しStringを返す
    static func stringFromDate(date: Date, type: FormatType) -> String {
        let formatter = _dateFormatter(type: type)
        let s_Date:String = formatter.string(from: date)
        
        return s_Date
    }
    
    
    /// 現在時間をフォーマット設定して返す
    static func dateFormatNow(type: FormatType) -> Date {
        let formatter = DateFormatter._dateFormatter(type: type)
        let s_Date:String = formatter.string(from: Date())
        
        return formatter.date(from: s_Date) ?? Date()
    }
    
    enum FormatType {
        case secnd
        case date
        case dateTime
        case None
    }
}
