//
//  InputTodoViewModel.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/10.
//


import Foundation
import RxSwift
import RxCocoa

struct InputTodoViewModel {
    
    let model = BehaviorRelay(value: TodoModel())
    
    let title = BehaviorRelay(value: "")
    let date = BehaviorRelay(value: Date())
    let details = BehaviorRelay(value: "")
    
    private let isValidation = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    init() {
        validation()
    }
    
    private func validation() {
        Observable
            .combineLatest(title, details)
            .map({ title, details -> Bool in
                !title.isEmpty && !details.isEmpty
            })
            .bind(to: isValidation)
            .disposed(by: disposeBag)
    }
    
    
    func find(id: String) -> Completable {
        return Completable.create { completable in
            guard let _model = TodoModel.find(id: id) else {
                completable(.error(TodoModelError(message: "Todoが見つかりませんでした。")))
                return Disposables.create()
            }
            model.accept(_model)
            title.accept(model.value.title)
            date.accept(DateFormatter.dateFromString(string: model.value.deadlineTime, type: .dateTime) ?? Date())
            details.accept(model.value.detail)
            
            return Disposables.create()
        }

    }
    
    
    func add() -> Completable {
        return Completable.create { completable in
            
            if !isValidation.value {
                completable(.error(TodoModelError(errorType: .Other)))
                return Disposables.create()
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
                completable(.completed)
            } catch {
                completable(.error(TodoModelError(errorType: .DB)))
            }
            return Disposables.create()
        }
    }
    
    
    func update() -> Completable {
        return Completable.create { completable in
            if !isValidation.value {
                completable(.error(TodoModelError(errorType: .Other)))
                return Disposables.create()
            }
            
            model.value.title = title.value
            model.value.detail = details.value
            model.value.deadlineTime = DateFormatter.stringFromDate(date: date.value, type: .dateTime)
            model.value.updated_at = DateFormatter.stringFromDate(date: Date(), type: .secnd)
            
            do {
                try TodoModel.update(model.value)
                completable(.completed)
            } catch {
                completable(.error(TodoModelError(errorType: .DB)))
            }
            return Disposables.create()
        }
    }
    
}
