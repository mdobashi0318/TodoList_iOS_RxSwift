//
//  NotificationManager.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import Foundation
import UserNotifications

struct NotificationManager: Sendable {
    
    /// 通知を全件削除する
    let allRemoveNotification = { @Sendable in
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("ToDoの通知を全件削除しました")
    }
    
    
    /// 指定した通知を削除する
    let removeNotification = { @Sendable (identifiers: [String]) -> Void in
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)
        print("ToDoの通知を\(identifiers.count)件削除しました")
    }
    
    

    /// 通知を設定する
    /// - Parameters:
    ///   - toDoModel: ToDoModels
    ///   - isRequestResponse: 通知の登録に成功したかを返す
    func addNotification(toDoModel: TodoModel, isRequestResponse: @escaping(Bool) -> ()) {
        
        let content:UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = toDoModel.title
        content.body = toDoModel.detail
        content.sound = UNNotificationSound.default
        
        //通知する日付を設定
        guard let date:Date = DateFormatter.dateFromString(string: toDoModel.deadlineTime, type: .dateTime) else {
            print("期限の登録に失敗しました")
            isRequestResponse(false)
            
            return
        }
        
        let calendar = Calendar.current
        let dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute] , from: date)
        let trigger:UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request:UNNotificationRequest = UNNotificationRequest.init(identifier: toDoModel.id, content: content, trigger: trigger)
        let center:UNUserNotificationCenter = UNUserNotificationCenter.current()
        
        center.add(request) { (error) in
            print("request: \(request)")
            
            if error != nil {
                print("通知の登録に失敗しました: \(error!)")
                isRequestResponse(false)
                
            } else {
                print("通知の登録をしました")
                isRequestResponse(true)
                
            }
        }
    }
    
    
    
    /// 通知の設定が許可されているかを取得する
    func getNotificationStatus() async -> Bool {
        return await getNotificationSettings()
    }
    
    
    private func getNotificationSettings() async -> Bool {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings{ (settings) in
                switch settings.authorizationStatus {
                case .authorized:
                    continuation.resume(returning: true)
                default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
