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
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var mode: Mode = .Add
    
    var id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id {
            viewModel.find(id: id)
            viewModel.model.asDriver()
                .drive(onNext: { model in
                })
                .disposed(by: disposeBag)
        }
        
        initNavigationItem()
        initTableView()
        
    }
    
    private func initTableView() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        
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
    
    
    
    private func add() {
        viewModel.add()
            .subscribe(onCompleted: {
                AlertManager.showAlert(self, type: .close, message: "Todoを登録しました", didTapPositiveButton: { _ in
                    self.dismiss(animated: true)
                })
            }, onError: { error in
                guard let error = error as? TodoModelError else {
                    AlertManager.showAlert(self, type: .close, message: "Todoを登録に失敗しました。")
                    return
                }
                switch error.errorType {
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
            .disposed(by: disposeBag)
        

    }
    
    
    private func update() {
        viewModel.update()
            .subscribe(onCompleted: {
                AlertManager.showAlert(self, type: .close, message: "Todoを更新しました", didTapPositiveButton: { _ in
                    NotificationCenter.default.post(name: Notification.Name(UPDATE_DETAIL), object: nil)
                    self.dismiss(animated: true)
                })
            }, onError: { error in
                guard let error = error as? TodoModelError else {
                    AlertManager.showAlert(self, type: .close, message: "Todoを更新に失敗しました。")
                    return
                }
                switch error.errorType {
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
            .disposed(by: disposeBag)
    }
}



extension InputTodoViewController:  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        TableRow.allCases.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case TableRow.title.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as? TextFieldCell else {
                return UITableViewCell()
            }
            
            viewModel.title
                .bind(to: cell.textField.rx.text)
                .disposed(by: disposeBag)
            
            cell.textField.rx.text
                .orEmpty
                .bind(to: viewModel.title)
                .disposed(by: disposeBag)
            return cell
            
        case TableRow.dateTime.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as? DatePickerCell else {
                return UITableViewCell()
            }
            cell.datePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())
            
            viewModel.date
                .bind(to: cell.datePicker.rx.date)
                .disposed(by: disposeBag)
            
            cell.datePicker.rx.date
                .bind(to: viewModel.date)
                .disposed(by: disposeBag)
            return cell
            
        case TableRow.detail.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell") as? TextViewCell else {
                return UITableViewCell()
            }
            
            viewModel.details
                .bind(to: cell.textView.rx.text)
                .disposed(by: disposeBag)
            
            cell.textView.rx.text
                .orEmpty
                .subscribe(onNext: { [weak self] text in
                    guard let self else { return }
                    self.viewModel.details.accept(text)
                    tableView.beginUpdates()
                    cell.textView.sizeToFit()
                    cell.height.constant = cell.textView.bounds.height
                    tableView.endUpdates()
                })
                .disposed(by: disposeBag)
            return cell
        case TableRow.complete.rawValue:
            break
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return switch section {
        case TableRow.title.rawValue:
            "タイトル"
        case TableRow.dateTime.rawValue:
            "期限"
        case TableRow.detail.rawValue:
            "詳細"
        case TableRow.complete.rawValue:
            nil
        default:
            nil
        }
    }
    
}



enum TableRow: Int, CaseIterable {
    case title, dateTime, detail, complete
}
