//
//  TodoModel.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import Foundation
import RealmSwift
import RxSwift

final class TodoModel {
    
    /// プライマリキー
    var id: String = ""
    
    /// Todoの期限
    var deadlineTime: String = ""
    
    /// Todoのタイトル
    var title: String = ""
    
    /// Todoの詳細
    var detail: String = ""
    
    /// Todoの完了フラグ
    /// - 0: 未完
    /// - 1: 完了
    var completionFlag: String = ""
    
    /// 作成日時
    var created_at: String = ""
    
    /// 更新日時
    var updated_at: String = ""
    
    // MARK: Todo取得
    
    /// 全件取得
    /// - Returns: 取得したTodoを全件返す
    static func allFindTodo() -> Observable<[TodoModel]> {
        Observable.create { observable in
            guard let realm = RealmTodoModel.realm else {
                observable.onError(TodoModelError(message: "エラーが発生しました"))
                return Disposables.create()
            }
            var model = [TodoModel]()
            
            realm.objects(RealmTodoModel.self).forEach {
                model.append(TodoModel.map($0))
            }
            
            model.sort {
                $0.deadlineTime < $1.deadlineTime
            }
            observable.onNext(model)
            observable.onCompleted()
            return Disposables.create()
        }
    }
    
    /// １件取得
    /// - Parameters:
    ///   - id: プライマリキー
    /// - Returns: 取得したTodoの最初の1件を返す
    static func find(id: String) -> TodoModel? {
        guard let realm = RealmTodoModel.realm,
              let model = realm.object(ofType: RealmTodoModel.self, forPrimaryKey: id) else {
            return nil
        }
        return TodoModel.map(model)
    }
    
    // MARK: Todo追加
    
    /// Todoを追加する
    /// - Parameters:
    ///   - addValue: 登録するTodoのTodo
    ///   - result: Todoの登録時の成功すればVoid、またはエラーを返す
    static func add(_ Todo:TodoModel)  throws {
        
        guard let realm = RealmTodoModel.realm else {
            throw TodoModelError(message: "追加エラー")
        }
        
        let now = DateFormatter.stringFromDate(date: Date(), type: .secnd)
        
        let TodoModel: TodoModel = TodoModel()
        TodoModel.id = UUID().uuidString
        TodoModel.title = Todo.title
        TodoModel.deadlineTime = Todo.deadlineTime
        TodoModel.detail = Todo.detail
        TodoModel.completionFlag = CompletionFlag.unfinished.rawValue
        TodoModel.created_at = now
        TodoModel.updated_at = now
        
        let model = RealmTodoModel.map(TodoModel)
        
        do {
            try realm.write() {
                realm.add(model)
            }
            NotificationManager().addNotification(toDoModel: TodoModel) { _ in
                /// 何もしない
            }
            
            
        }
        catch {
            throw TodoModelError(message: "追加エラー")
        }
        
    }
    
    
    // MARK: Todo更新
    
    /// Todoの更新
    /// - Parameters:
    ///   - updateTodo: 更新するTodo
    ///   - result: Todoの更新時のエラー
    ///   - result: Todoの登録時の成功すればVoid、またはエラーを返す
    static func update(_ updateTodo: TodoModel) throws {
        guard let realm = RealmTodoModel.realm,
              let rModel = RealmTodoModel.find(id: updateTodo.id) else {
            throw TodoModelError(message: "更新エラー")
        }
        
        do {
            try realm.write() {
                rModel.title = updateTodo.title
                rModel.deadlineTime = updateTodo.deadlineTime
                rModel.detail = updateTodo.detail
                rModel.completionFlag = updateTodo.completionFlag
                rModel.updated_at = DateFormatter.stringFromDate(date: Date(), type: .secnd)
            }
            
            if updateTodo.completionFlag == CompletionFlag.completion.rawValue {
                NotificationManager().removeNotification([rModel.id])
            } else {
                NotificationManager().addNotification(toDoModel: updateTodo) { _ in
                    /// 何もしない
                }
            }
            
            
        }
        catch {
            throw TodoModelError(message: "更新エラー")
        }
        
    }
    
    
    /// 完了フラグの更新
    /// - Parameters:
    ///   - updateTodo: 更新するTodo
    ///   - flag: 変更する値
    static func updateCompletionFlag(id: String, flag: CompletionFlag) {
        guard let realm = RealmTodoModel.realm,
              let model: TodoModel = TodoModel.find(id: id)else {
            return
        }
        
        try? realm.write() {
            model.completionFlag = flag.rawValue
        }
        if model.completionFlag == CompletionFlag.completion.rawValue {
            NotificationManager().removeNotification([model.id])
        } else {
            NotificationManager().addNotification(toDoModel: model) { _ in
                /// 何もしない
            }
        }
        
        
        
    }
    
    // MARK: Todo削除
    
    /// Todoの削除
    /// - Parameters:
    ///   - deleteTodo: 削除するTodo
    ///   - result: Todoの登録時の成功すればVoid、またはエラーを返す
    static func delete(id: String) throws {
        guard let realm = RealmTodoModel.realm,
        let model = find(id: id) else {
            throw TodoModelError(message: "削除エラー")
        }
        
        let reamlModel = RealmTodoModel.map(model)
        do {
            try realm.write() {
                realm.delete(reamlModel)
            }
            NotificationManager().removeNotification([id])
            
        }
        catch {
            throw TodoModelError(message: "削除エラー")
        }
    }
    
    
    /// 全件削除
    static func deleteAll() throws {
        guard let realm = RealmTodoModel.realm else {
            return
        }
        do {
            try realm.write {
                realm.deleteAll()
            }
            NotificationManager().allRemoveNotification()
            
        } catch {
            throw TodoModelError(message: "削除エラー")
        }
    }
    
    
    static func map(_ realmModel: RealmTodoModel) -> TodoModel {
        let model = TodoModel()
        model.id = realmModel.id
        model.deadlineTime = realmModel.deadlineTime
        model.title = realmModel.title
        model.detail = realmModel.detail
        model.completionFlag = realmModel.completionFlag
        model.created_at = realmModel.created_at
        model.updated_at = realmModel.updated_at
        return model
    }
}





final class RealmTodoModel: Object {
    
    static let realm: Realm? = {
        var configuration: Realm.Configuration
        configuration = Realm.Configuration()
        configuration.schemaVersion = UInt64(1)
        return try? Realm(configuration: configuration)
    }()
    
    
    @Persisted(primaryKey: true) var id: String = ""
    
    /// Todoの期限
    @Persisted var deadlineTime: String = ""
    
    /// Todoのタイトル
    @Persisted var title: String = ""
    
    /// Todoの詳細
    @Persisted var detail: String = ""
    
    /// Todoの完了フラグ
    /// - 0: 未完
    /// - 1: 完了
    @Persisted var completionFlag: String = ""
    
    /// 作成日時
    @Persisted var created_at: String = ""
    
    /// 更新日時
    @Persisted var updated_at: String = ""
    
    /// １件取得
    /// - Parameters:
    ///   - id: プライマリキー
    /// - Returns: 取得したTodoの最初の1件を返す
    static func find(id: String) -> RealmTodoModel? {
        guard let realm = RealmTodoModel.realm,
              let model = realm.object(ofType: RealmTodoModel.self, forPrimaryKey: id) else {
            return nil
        }
        return model
    }
    
    
    static func map(_ model: TodoModel) -> RealmTodoModel {
        let realmModel = RealmTodoModel()
        realmModel.id = model.id
        realmModel.deadlineTime = model.deadlineTime
        realmModel.title = model.title
        realmModel.detail = model.detail
        realmModel.completionFlag = model.completionFlag
        realmModel.created_at = model.created_at
        realmModel.updated_at = model.updated_at
        return realmModel
    }
        
}
