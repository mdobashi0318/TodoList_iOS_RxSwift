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
    
    var model =  BehaviorRelay<ToDoModel>(value: ToDoModel())
    
    
    var id: String {
        get {
            return model.value.id
        }
    }
    
    func find(_ id: String) {
        guard let _model = ToDoModel.find(id: id) else { return }
        model.accept(_model)
    }
    
    
    func updateCompleteFlag(flag: Bool) {
        ToDoModel.updateCompletionFlag(id: id, flag: flag ? CompletionFlag.completion : CompletionFlag.unfinished)
    }
    
    func delete(id: String, success: @escaping () -> Void, failure: @escaping () -> Void)  {
        do {
            try ToDoModel.delete(id: id)
            success()
        } catch {
            failure()
        }
    }
}
