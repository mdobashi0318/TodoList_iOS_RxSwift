//
//  ToDoModel.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import Foundation
import RealmSwift


final class ToDoModel: Object {
    
    private static var realm: Realm? {
        var configuration: Realm.Configuration
        configuration = Realm.Configuration()
        configuration.schemaVersion = UInt64(1)
        return try? Realm(configuration: configuration)
    }
    
    
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
    
    /// Todoの作成日時
    @Persisted var createTime: String = ""
    
    // MARK: Todo取得
    
    /// 全件取得
    /// - Returns: 取得したTodoを全件返す
    static func allFindTodo() -> [ToDoModel] {
        guard let realm else {
            return []
        }
        var model = [ToDoModel]()
        
        realm.objects(ToDoModel.self).forEach {
            model.append($0)
        }
        
        model.sort {
            $0.deadlineTime < $1.deadlineTime
        }
        
        return model
    }
    
    /// １件取得
    /// - Parameters:
    ///   - todoId: TodoId
    ///   - createTime: Todoの作成時間
    /// - Returns: 取得したTodoの最初の1件を返す
    static func find(id: String) -> ToDoModel? {
        guard let realm else {
            return nil
        }
        return (realm.objects(ToDoModel.self).filter("id == '\(String(describing: id))'").first)
    }
    
    // MARK: Todo追加
    
    /// ToDoを追加する
    /// - Parameters:
    ///   - addValue: 登録するTodoのTodo
    ///   - result: Todoの登録時の成功すればVoid、またはエラーを返す
    static func add(_ todo:ToDoModel)  throws {
        
        guard let realm else {
            throw TodoModelError(message: "追加エラー")
        }
        
        let toDoModel: ToDoModel = ToDoModel()
        toDoModel.id = UUID().uuidString
        toDoModel.title = todo.title
        toDoModel.deadlineTime = todo.deadlineTime
        toDoModel.detail = todo.detail
        toDoModel.completionFlag = CompletionFlag.unfinished.rawValue
        toDoModel.createTime = Format().stringFromDate(date: Date(), addSec: true)
        
        do {
            try realm.write() {
                realm.add(toDoModel)
            }
            NotificationManager().addNotification(toDoModel: toDoModel) { _ in
                /// 何もしない
            }
            
            
        }
        catch {
            throw TodoModelError(message: "追加エラー")
        }
        
    }
    
    
    // MARK: Todo更新
    
    /// ToDoの更新
    /// - Parameters:
    ///   - updateTodo: 更新するTodo
    ///   - result: Todoの更新時のエラー
    ///   - result: Todoの登録時の成功すればVoid、またはエラーを返す
    static func update(_ updateTodo: ToDoModel) throws {
        guard let realm,
              let toDoModel: ToDoModel = ToDoModel.find(id: updateTodo.id) else {
            throw TodoModelError(message: "更新エラー")
        }
        
        do {
            try realm.write() {
                toDoModel.title = updateTodo.title
                toDoModel.deadlineTime = updateTodo.deadlineTime
                toDoModel.detail = updateTodo.detail
                toDoModel.completionFlag = updateTodo.completionFlag
            }
            
            if updateTodo.completionFlag == CompletionFlag.completion.rawValue {
                NotificationManager().removeNotification([toDoModel.id])
            } else {
                NotificationManager().addNotification(toDoModel: toDoModel) { _ in
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
    static func updateCompletionFlag(updateTodo: ToDoModel, flag: CompletionFlag) {
        guard let realm else {
            return
        }
        guard let toDoModel: ToDoModel = ToDoModel.find(id: updateTodo.id) else { return }
        try? realm.write() {
            toDoModel.completionFlag = flag.rawValue
        }
        if updateTodo.completionFlag == CompletionFlag.completion.rawValue {
            NotificationManager().removeNotification([toDoModel.id])
        } else {
            NotificationManager().addNotification(toDoModel: toDoModel) { _ in
                /// 何もしない
            }
        }
        
        
        
    }
    
    // MARK: Todo削除
    
    /// ToDoの削除
    /// - Parameters:
    ///   - deleteTodo: 削除するTodo
    ///   - result: Todoの登録時の成功すればVoid、またはエラーを返す
    static func delete(deleteTodo: ToDoModel) throws {
        guard let realm else {
            throw TodoModelError(message: "削除エラー")
        }
        
        NotificationManager().removeNotification([deleteTodo.id])
        
        
        do {
            try realm.write() {
                realm.delete(deleteTodo)
            }
            
            
        }
        catch {
            throw TodoModelError(message: "削除エラー")
        }
    }
    
    
    /// 全件削除
    static func allDelete()  {
        guard let realm else {
            return
        }
        try? realm.write {
            realm.deleteAll()
        }
        
        
    
        
        
        NotificationManager().allRemoveNotification()
        
    }
    
}
