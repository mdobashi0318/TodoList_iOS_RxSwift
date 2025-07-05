//
//  Array+ex.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2025/06/28.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        //indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        return indices.contains(index) ? self[index] : nil
    }
}
