//
//  PageViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/09/04.
//

import UIKit
import RxCocoa
import RxSwift

class PageViewController: UIPageViewController {
    
    var currentVC = TodoListViewController(page: .unfinished)
    
    private let disposeBag = DisposeBag()
    
    private let addButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
    
    private let deleteButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: nil, action: nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationItem()
        dataSource = self
        view.backgroundColor = currentVC.view.backgroundColor
        setViewControllers([currentVC], direction: .forward, animated: true)
    }
    
    
    private func initNavigationItem() {
        navigationItem.title = "TodoList"
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
                self.currentVC.viewModel
                    .deleteAll()
                    .subscribe(onCompleted: {
                        AlertManager.showAlert(self, type: .close, message: "全件削除しました", didTapPositiveButton: { _ in
                            self.currentVC.tableView.reloadData()
                        })
                    }, onError: { _ in
                        AlertManager.showAlert(self, type: .close, message: "削除に失敗しました")
                    })
                    .disposed(by: self.disposeBag)
                
            })
        })
        .disposed(by: disposeBag)
    }

}



extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? TodoListViewController else {
            return nil
        }

        switch vc.viewModel.page.value {
        case .expired:
            currentVC = TodoListViewController(page: .unfinished)
        case .completion:
            currentVC = TodoListViewController(page: .expired)
        default:
            return nil
        }
        return currentVC
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? TodoListViewController else {
            return nil
        }

        switch vc.viewModel.page.value {
        case .unfinished:
            currentVC = TodoListViewController(page: .expired)
        case .expired:
            currentVC = TodoListViewController(page: .completion)
        default:
            return nil
        }
        return currentVC
    }
    
    
    
}
