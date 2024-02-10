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
    
    let model = BehaviorRelay(value: TodoModel())
    
    let title = BehaviorRelay(value: "")
    let date = BehaviorRelay(value: Date())
    let details = BehaviorRelay(value: "")
    
    func find(id: String) {
        guard let _model = TodoModel.find(id: id) else {
            return
        }
        model.accept(_model)
    }
    
    
    func add(success: @escaping () -> Void, failure: @escaping (ErrorType) -> Void)  {
        if title.value.isEmpty || details.value.isEmpty {
            failure(.Other)
            return
        }
        
        let now = DateFormatter.stringFromDate(date: Date(), type: .secnd)
        let model = TodoModel()
        model.title = title.value
        model.detail = details.value
        model.deadlineTime = DateFormatter.stringFromDate(date: date.value, type: .dateTime)
        model.created_at = now
        model.updated_at = now
        
        do {
            try TodoModel.add(model)
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
        
        let model = TodoModel()
        model.id = self.model.value.id
        model.title = title.value
        model.detail = details.value
        model.deadlineTime = DateFormatter.stringFromDate(date: date.value, type: .dateTime)
        model.updated_at = DateFormatter.stringFromDate(date: Date(), type: .secnd)
        
        do {
            try TodoModel.update(model)
            success()
        } catch {
            failure(.DB)
        }
    }
    
    
}
