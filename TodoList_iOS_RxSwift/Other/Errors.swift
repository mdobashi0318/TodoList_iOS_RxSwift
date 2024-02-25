//
//  Errors.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import Foundation

// MARK: TodoModelError

struct TodoModelError: Error {
    var message: String = ""
    var errorType: ErrorType = .Other
    
    init(message: String) {
        self.message = message
    }
    
    init(errorType: ErrorType) {
        self.errorType = errorType
    }
    
    enum ErrorType: CaseIterable {
        case DB
        case Other
    }
}
