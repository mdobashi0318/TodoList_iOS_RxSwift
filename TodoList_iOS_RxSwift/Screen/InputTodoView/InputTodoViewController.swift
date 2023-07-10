//
//  InputTodoViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/10.
//

import UIKit
import RxSwift
import RxCocoa

class InputTodoViewController: UIViewController {
    
    private let viewModel = InputTodoViewModel()
    
    private let disposeBag = DisposeBag()
    
    private let addButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
    
    private let closeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    

    @IBOutlet weak var detailTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationItem()
        initTextEvent()
        

    }

    
    
    private func initNavigationItem() {
        navigationItem.title = "Todo作成"
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = closeButton
        
        addButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            
            viewModel.add(success: {
                AlertManager.showAlert(self, type: .close, message: "Todoを登録しました", didTapPositiveButton: { _ in
                    self.dismiss(animated: true)
                })
            }, failure: {
                AlertManager.showAlert(self, type: .close, message: "Todoを登録に失敗しました。")
            })
        })
        .disposed(by: disposeBag)
        
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            self.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
    }
    
    
    private func initTextEvent() {
        titleTextField.rx.text.subscribe(onNext: { text in
            self.viewModel.title.accept(text ?? "")
        })
        .disposed(by: disposeBag)
        
        
        datePicker.rx.date.changed.subscribe(onNext: { date in
            print("date: \(date)")
            self.viewModel.date.accept(date)
        })
        .disposed(by: disposeBag)
        
        
        detailTextView.rx.text.subscribe(onNext: { text in
            self.viewModel.details.accept(text ?? "")
            
        })
        .disposed(by: disposeBag)
    }

}
