//
//  InputTodoViewModel.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/10.
//


import Foundation
import RxSwift
import RxCocoa



enum ErrorType: CaseIterable {
    case DB
    case Other
}

struct InputTodoViewModel {
    
    let model = BehaviorRelay(value: ToDoModel())
    
    let title = BehaviorRelay(value: "")
    let date = BehaviorRelay(value: Date())
    let details = BehaviorRelay(value: "")
    
    func find(id: String) {
        guard let _model = ToDoModel.find(id: id) else {
            return
        }
        model.accept(_model)
    }
    
    
    func add(success: @escaping () -> Void, failure: @escaping (ErrorType) -> Void)  {
        if title.value.isEmpty || details.value.isEmpty {
            failure(.Other)
            return
        }
        
        let model = ToDoModel()
        model.title = title.value
        model.detail = details.value
        model.deadlineTime = Format.stringFromDate(date: date.value)
        model.createTime = Format.stringFromDate(date: Date(), addSec: true)
        
        do {
            try ToDoModel.add(model)
            success()
        } catch {
            failure(.DB)
        }
    }
    
    
    func update(success: @escaping () -> Void, failure: @escaping (ErrorType) -> Void)  {
        if title.value.isEmpty || details.value.isEmpty {
            failure(.Other)
            return
        }
        
        let model = ToDoModel()
        model.id = self.model.value.id
        model.title = title.value
        model.detail = details.value
        model.deadlineTime = Format.stringFromDate(date: date.value)
        
        do {
            try ToDoModel.update(model)
            success()
        } catch {
            failure(.DB)
        }
    }
    
    
}
