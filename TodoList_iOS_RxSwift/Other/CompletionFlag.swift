//
//  CompletionFlag.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import Foundation

enum CompletionFlag: String {
    /// 未完
    case unfinished = "0"
    /// 完了
    case completion = "1"
    /// 期限切れ
    case expired = "2"
}
