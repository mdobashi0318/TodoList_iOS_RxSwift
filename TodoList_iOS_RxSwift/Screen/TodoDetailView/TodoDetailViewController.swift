//
//  TodoDetailViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/11.
//

import UIKit
import RxSwift
import RxCocoa

class TodoDetailViewController: UIViewController {
    
    private let viewModel = TodoDetailViewModel()
    
    var id = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var detailLable: UILabel!
    
    private let disposeBag = DisposeBag()
    
    private let ellipsisButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationItem()
        viewModel.find(id)

        viewModel.model.bind(to: { model in
            titleLabel.text = model.value.title
            dateLabel.text = model.value.deadlineTime
            detailLable.text = model.value.detail
            
        })
        
    }
    
    
    private func initNavigationItem() {
        self.navigationItem.title = "詳細"
        self.navigationItem.rightBarButtonItem = ellipsisButton
        ellipsisButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            
            AlertManager.alertSheetAction(self, message: "Todoをどうしますか?", didTapEditButton: { _ in
                let navi = UINavigationController(rootViewController: InputTodoViewController())
                navi.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navi, animated: true)
            }, didTapDeleteButton: { _ in
                AlertManager.showAlert(self, type: .delete, message: "このTodoを削除しますか?", didTapPositiveButton: { _ in
                    // TODO: 削除処理
                    AlertManager.showAlert(self, type: .close, message: "削除しました", didTapPositiveButton: { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                })
            })
            
        })
        .disposed(by: disposeBag)
    }

}
