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
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.add()
        viewModel.findAll()
        tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        viewModel.model.bind(to: tableView.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) { row, todo, cell in
            cell.textLabel?.text = todo.title
        }
        .disposed(by: disposeBag)
    }


}



