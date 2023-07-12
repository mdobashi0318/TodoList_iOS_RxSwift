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


    func findAll() {
        model.accept(ToDoModel.allFindTodo()) 
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
