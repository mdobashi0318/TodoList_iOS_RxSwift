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
    
    @IBOutlet weak var completeSwtch: UISwitch!
    
    
    private let ellipsisButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationItem()
        viewModel.find(id)

        viewModel.model.subscribe(onNext: { [weak self] model in
            guard let self else { return }
            self.titleLabel.text = model.title
            self.dateLabel.text = model.deadlineTime
            self.detailLable.text = model.detail
            self.completeSwtch.isOn = CompletionFlag.completion.rawValue == model.completionFlag ? true : false
        })
        .disposed(by: disposeBag)
        
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: UPDATE_DETAIL))
            .subscribe { [weak self] _ in
                guard let self else { return }
                viewModel.find(id)
            }
            .disposed(by: disposeBag)
        
        
        completeSwtch.rx.isOn.changed.subscribe(onNext: { [weak self] isOn in
            guard let self else { return }
            self.viewModel.updateCompleteFlag(flag: isOn)
        })
        .disposed(by: disposeBag)
    }
    
    
    private func initNavigationItem() {
        self.navigationItem.title = "詳細"
        self.navigationItem.rightBarButtonItem = ellipsisButton
        ellipsisButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            
            AlertManager.alertSheetAction(self, message: "Todoをどうしますか?", didTapEditButton: { _ in
                let vc = InputTodoViewController()
                vc.mode = .Edit
                vc.id = self.viewModel.id
                let navi = UINavigationController(rootViewController: vc)
                navi.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navi, animated: true)
            }, didTapDeleteButton: { _ in
                AlertManager.showAlert(self, type: .delete, message: "このTodoを削除しますか?", didTapPositiveButton: { _ in
                    self.viewModel.delete(id: self.viewModel.id, success: {
                        AlertManager.showAlert(self, type: .close, message: "削除しました", didTapPositiveButton: { _ in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }, failure: {
                        AlertManager.showAlert(self, type: .close, message: "削除に失敗しました")
                    })
                  
                })
            })
            
        })
        .disposed(by: disposeBag)
    }
    

}
