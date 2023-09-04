//
//  InputTodoViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/10.
//

import UIKit
import RxSwift
import RxCocoa


enum Mode: CaseIterable {
    case Add
    case Edit
}


class InputTodoViewController: UIViewController {
    
    private let viewModel = InputTodoViewModel()
    
    private let disposeBag = DisposeBag()
    
    private let addButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
    
    private let closeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var detailTextView: UITextView!
    
    
    var mode: Mode = .Add
    
    var id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id {
            viewModel.find(id: id)
        }
        
        initNavigationItem()
        initTextEvent()
        
    }
    
    
    
    private func initNavigationItem() {
        navigationItem.title = mode == .Add ? "Todo作成" : "Todo更新"
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = closeButton
        
        addButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            
            if mode == .Add {
                add()
            } else {
                update()
            }
     
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
        
        
        datePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        datePicker.rx.date.changed.subscribe(onNext: { date in
            self.viewModel.date.accept(date)
        })
        .disposed(by: disposeBag)
        
        
        detailTextView.rx.text.subscribe(onNext: { text in
            self.viewModel.details.accept(text ?? "")
            
        })
        .disposed(by: disposeBag)
        
        
        
        viewModel.model.bind(to: { model in
            titleTextField.text = model.value.title
            datePicker.date = Format.dateFromString(string: model.value.deadlineTime) ?? Date()
            detailTextView.text = model.value.detail
            
            self.viewModel.title.accept(model.value.title)
            self.viewModel.date.accept(Format.dateFromString(string: model.value.deadlineTime) ?? Date())
            self.viewModel.details.accept(model.value.detail)
        })
    }
    
    
    
    private func add() {
        viewModel.add(success: {
            AlertManager.showAlert(self, type: .close, message: "Todoを登録しました", didTapPositiveButton: { _ in
                self.dismiss(animated: true)
            })
        }, failure: { type in
            switch type {
            case .DB:
                AlertManager.showAlert(self, type: .close, message: "Todoを登録に失敗しました。")
            case .Other:
                if self.viewModel.title.value.isEmpty {
                    AlertManager.showAlert(self, type: .close, message: "タイトルを入力してください")
                } else {
                    AlertManager.showAlert(self, type: .close, message: "詳細を入力してください")
                }
            }
        })
    }
    
    
    private func update() {
        viewModel.update(success: {
            AlertManager.showAlert(self, type: .close, message: "Todoを更新しました", didTapPositiveButton: { _ in
                NotificationCenter.default.post(name: Notification.Name(UPDATE_DETAIL), object: nil)
                self.dismiss(animated: true)
            })
        }, failure: { type in
            switch type {
            case .DB:
                AlertManager.showAlert(self, type: .close, message: "Todoを更新に失敗しました。")
            case .Other:
                if self.viewModel.title.value.isEmpty {
                    AlertManager.showAlert(self, type: .close, message: "タイトルを入力してください")
                } else {
                    AlertManager.showAlert(self, type: .close, message: "詳細を入力してください")
                }
            }
        })
    }
}
