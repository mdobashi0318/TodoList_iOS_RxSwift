//
//  ViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/07.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = TodoListViewModel()
    
    private let disposeBag = DisposeBag()
    
    private let addButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
    
    private let deleteButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationItem()
        initTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.findAll()
    }
    
    
    private func initNavigationItem() {
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = deleteButton
        
        addButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            
            let navi = UINavigationController(rootViewController: InputTodoViewController())
            navi.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navi, animated: true)
        })
        .disposed(by: disposeBag)
        
        
        
        deleteButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            
            AlertManager.showAlert(self, type: .confirm, message: "Todoを全件削除しますか?", didTapPositiveButton: { _ in
                self.viewModel.deleteAll(success: {
                    AlertManager.showAlert(self, type: .close, message: "全件削除しました", didTapPositiveButton: { _ in
                        self.tableView.reloadData()
                    })
                }, failure: {
                    AlertManager.showAlert(self, type: .close, message: "削除に失敗しました")
                })
            })
            
        })
        .disposed(by: disposeBag)
    }
    
    private func initTableView() {
        
        // セルをセット
        tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        viewModel.model.bind(to: tableView.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) { row, todo, cell in
            cell.titleLabel.text = todo.title
            cell.completeLabel.text = todo.completionFlag == "1" ? "完了" : "未完了"
            cell.dateLabel.text = todo.deadlineTime
        }
        .disposed(by: disposeBag)
        
        // セルタップ
        tableView.rx.modelSelected(ToDoModel.self).subscribe(onNext: { [weak self] model in
            let vc = TodoDetailViewController()
            vc.id = model.id
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        .disposed(by: disposeBag)
        
        
        // 選択状態のハイライト解除
           tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
               self?.tableView.deselectRow(at: indexPath, animated: true)
           })
           .disposed(by: disposeBag)
    }
    
    
    
    
    
    
}



