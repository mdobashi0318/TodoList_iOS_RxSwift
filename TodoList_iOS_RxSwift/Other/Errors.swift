//
//  Errors.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import Foundation

// MARK: TodoModelError

struct TodoModelError: Error {
    var isError: Bool = false
    var message: String = ""
    
    init(isError: Bool) {
        self.isError = isError
    }
    
    init(message: String) {
        self.message = message
    }
}


// MARK: DeleteError

struct DeleteError: Error {
    var model: ToDoModel
    var message: String
}
