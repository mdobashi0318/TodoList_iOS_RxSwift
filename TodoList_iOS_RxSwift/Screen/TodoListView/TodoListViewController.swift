//
//  TodoListViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/09/05.
//

import UIKit
import RxCocoa
import RxSwift


class TodoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = TodoListViewModel()
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var noTodoView: UIView!
        
    convenience init(page: CompletionFlag) {
        self.init()
        self.viewModel.page.accept(page)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.findList()
            .subscribe { [weak self] model in
                guard let self else { return }
                if self.viewModel.model.value.isEmpty {
                    self.noTodoView.isHidden = false
                    self.tableView.isScrollEnabled = false
                } else {
                    self.noTodoView.isHidden = true
                    self.tableView.isScrollEnabled = true
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    
    private func initTableView() {
        // セルをセット
        tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        viewModel.model.bind(to: tableView.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) { row, todo, cell in
            cell.titleLabel.text = todo.title
            cell.completeLabel.text = todo.completionFlag == CompletionFlag.completion.rawValue ? "完了" : "未完了"
            cell.dateLabel.text = todo.deadlineTime
        }
        .disposed(by: disposeBag)
        
        // セルタップ
        tableView.rx.modelSelected(TodoModel.self).subscribe(onNext: { [weak self] model in
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
