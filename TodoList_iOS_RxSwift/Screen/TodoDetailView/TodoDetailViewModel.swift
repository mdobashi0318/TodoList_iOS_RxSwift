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
    
    func find(_ id: String) {
        guard let _model = ToDoModel.find(id: id) else { return }
        model.accept(_model)
    }
}
