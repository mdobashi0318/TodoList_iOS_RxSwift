//
//  NSNotification_Name+ex.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2024/02/25.
//

import Foundation

extension NSNotification.Name {    
    static let update_detail = Notification.Name(rawValue: "updateDetail")
    static let tap_notification = Notification.Name(rawValue: "tapNotificationBanner")
}
