//
//  TodoDetailViewModel.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/11.
//

import Foundation
import RxSwift
import RxCocoa

struct TodoDetailViewModel {
    
    var model =  BehaviorRelay<TodoModel>(value: TodoModel())
    
    
    var id: String {
        get {
            return model.value.id
        }
    }
    
    func find(_ id: String) -> Completable {
        return Completable.create { completable in
            guard let _model = TodoModel.find(id: id) else {
                completable(.error(TodoModelError(message: "Todoが見つかりませんでした")))
                return Disposables.create()
            }
            model.accept(_model)
            completable(.completed)
               
            return Disposables.create()
        }
        
    }
    
    
    func updateCompleteFlag(flag: Bool) {
        TodoModel.updateCompletionFlag(id: id, flag: flag ? CompletionFlag.completion : CompletionFlag.unfinished)
    }
    
    func delete(id: String, success: @escaping () -> Void, failure: @escaping () -> Void)  {
        do {
            try TodoModel.delete(id: id)
            success()
        } catch {
            failure()
        }
    }
}
