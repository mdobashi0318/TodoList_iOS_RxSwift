//
//  AlertManager.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/10.
//

import Foundation
import UIKit

struct AlertManager {

    enum AlertType: CaseIterable {
        case delete, close, confirm
    }

    /// アラートを表示する
    /// - Parameters:
    ///   - vc: ViewController
    ///   - type: 出すアラートのタイプを設定する
    static func showAlert(_ vc: UIViewController, type: AlertType, title: String? = nil, message: String, didTapPositiveButton: ((UIAlertAction) -> Void)? = nil, didTapNegativeButton: ((UIAlertAction) -> Void)? = nil) {

        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

        switch type {
        case .delete:
            controller.addAction(UIAlertAction(title: "削除",
                                               style: .destructive,
                                               handler: didTapPositiveButton)
            )

            controller.addAction(UIAlertAction(title: "キャンセル",
                                               style: .cancel,
                                               handler: didTapNegativeButton)
            )
        case .close:
            controller.addAction(UIAlertAction(title: "閉じる",
                                               style: .cancel,
                                               handler: didTapPositiveButton))
        case .confirm:
            controller.addAction(UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: didTapPositiveButton)
            )

            controller.addAction(UIAlertAction(title: "キャンセル",
                                               style: .cancel,
                                               handler: didTapNegativeButton)
            )
        }

        vc.present(controller, animated: true, completion: nil)
    }

    /// アラートシートを作成する
    /// - Parameters:
    ///   - viewController: 表示するViewController
    ///   - title: タイトル
    ///   - message: メッセージ
    ///   - didTapEditButton: 編集ボタンタップ時の動作
    ///   - didTapDeleteButton: 削除ボタンタップ時の動作
    ///   - didTapCancelButton: キャンセルボタンタップ時の動作
    static func alertSheetAction(_ viewController: UIViewController, title: String? = nil, message: String, didTapEditButton: @escaping (UIAlertAction) -> Void, didTapDeleteButton: @escaping (UIAlertAction) -> Void, didTapCancelButton: ((UIAlertAction) -> Void)? = nil) {

        let alertSheet = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .actionSheet
        )
        alertSheet.addAction(UIAlertAction(title: "編集",
                                           style: .default,
                                           handler: didTapEditButton
        ))

        alertSheet.addAction(UIAlertAction(title: "削除",
                                           style: .destructive,
                                           handler: didTapDeleteButton
        ))

        alertSheet.addAction(UIAlertAction(title: "キャンセル",
                                           style: .cancel,
                                           handler: didTapCancelButton
        ))

        viewController.present(alertSheet, animated: true, completion: nil)
    }

}
