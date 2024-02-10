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
    
    let model = BehaviorRelay<[TodoModel]>(value: [])
    
    var page: CompletionFlag = .unfinished
    
    private let disposeBag = DisposeBag()
    
    func findList() -> Completable {
        Completable.create { completable in
            TodoModel.allFindTodo()
                .subscribe(onNext: { response in
                    model.accept(response)
                    /*
                    switch page {
                    case .unfinished:
                        model.accept(response.filter({ $0.completionFlag == CompletionFlag.unfinished.rawValue }))
                    case .expired:
                        model.accept(response.filter({ $0.completionFlag == CompletionFlag.unfinished.rawValue && DateFormatter.dateFromString(string: $0.deadlineTime, type: .secnd) ?? Date() < DateFormatter.dateFormatNow(type: .secnd) }))
                    case .completion:
                        model.accept(response.filter({ $0.completionFlag == CompletionFlag.completion.rawValue }))
                    }
                    */
                })
                .disposed(by: disposeBag)
            completable(.completed)
            return Disposables.create()
        }
 
    }
    
    
    func deleteAll() -> Completable {
        Completable.create { completable in
            do {
                try TodoModel.deleteAll()
                model.accept([])
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
}
