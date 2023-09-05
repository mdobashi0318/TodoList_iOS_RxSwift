//
//  TodoListViewModel.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import Foundation
import RxSwift
import RxCocoa


struct TodoListViewModel {
    
    let model = BehaviorRelay<[ToDoModel]>(value: [])
    
    var page: CompletionFlag = .unfinished
    
    func findList() {
        let _model = ToDoModel.allFindTodo()
        switch page {
        case .unfinished:
            model.accept(_model.filter({ $0.completionFlag == CompletionFlag.unfinished.rawValue }))
        case .expired:
            model.accept(_model.filter({ $0.completionFlag == CompletionFlag.unfinished.rawValue &&  Format.dateFromString(string: $0.deadlineTime) ?? Date() < Format.dateFormat() }))
        case .completion:
            model.accept(_model.filter({ $0.completionFlag == CompletionFlag.completion.rawValue }))
        }
        
        
    }
    
    func deleteAll(success: @escaping () -> Void, failure: @escaping () -> Void)  {
        
        do {
            try ToDoModel.deleteAll()
            model.accept([])
            success()
        } catch {
            failure()
        }
        
        
    }
    
}
