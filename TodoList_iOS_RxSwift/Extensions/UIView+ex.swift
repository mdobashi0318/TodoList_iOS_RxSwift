//
//  UIView+ex.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2025/06/29.
//

import UIKit

@IBDesignable
extension UIView {
    
    @IBInspectable
     var cornerRadius: CGFloat {
         get {
             self.cornerRadius
         }
         set {
             layer.cornerRadius = newValue
         }
     }
}
