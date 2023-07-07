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

    
    // TODO: 作成画面作るまでのTodo作成に使う
    func add() {
        let model = ToDoModel()
        model.title = "テスト1"
        model.detail = "テスト1 詳細"
        model.deadlineTime = Format().stringFromDate(date: Date())
        model.createTime = Format().stringFromDate(date: Date(), addSec: true)
        try? ToDoModel.add(model)
    }
    
    
    
}
