//
//  PageViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/09/04.
//

import UIKit
import RxCocoa
import RxSwift

class MainViewController: UIViewController {
        
    private let disposeBag = DisposeBag()
    
    private let addButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
    
    private let deleteButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: nil, action: nil)
    
    private let pageVC = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    // MARK: Button
    
    @IBOutlet weak var unfinishedButton: UIButton! {
        didSet {
            unfinishedButton.backgroundColor = selectButtonColor
        }
    }
    
    @IBOutlet weak var completionButton: UIButton! {
        didSet {
            completionButton.backgroundColor = deSelectButtonColor
        }
    }
    
    @IBOutlet weak var expiredButton: UIButton! {
        didSet {
            expiredButton.backgroundColor = deSelectButtonColor
        }
    }
    
    @IBOutlet private weak var indicatorViewXConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var pageView: UIView!
    
    @IBOutlet private weak var indicatorView: UIView!
    
    private let selectButtonColor: UIColor = .systemBackground
    
    private let deSelectButtonColor: UIColor = .systemGray5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationItem()
        addChildVC()
        receiveTapNotification()
        pageVC.pageVCDelegate = self
        indicatorViewXConstraint.constant = -(UIScreen.main.bounds.width / 3)
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
                guard let currentVC = self.pageVC.viewControllers?.first as? TodoListViewController else {
                    return
                }
                currentVC.viewModel
                    .deleteAll()
                    .subscribe(onCompleted: {
                        AlertManager.showAlert(self, type: .close, message: "全件削除しました", didTapPositiveButton: { _ in
                            currentVC.tableView.reloadData()
                        })
                    }, onError: { _ in
                        AlertManager.showAlert(self, type: .close, message: "削除に失敗しました")
                    })
                    .disposed(by: self.disposeBag)
            })
        })
        .disposed(by: disposeBag)
    }
    
    private func receiveTapNotification() {
        NotificationCenter.default.rx
            .notification(.tap_notification)
            .subscribe { [weak self] notification in
                guard let self else { return }
                let vc = TodoDetailViewController()
                guard let id = notification.element?.object as? String else {
                    AlertManager.showAlert(self, type: .close, message: "Todoが見つかりませんでした。")
                    return
                }
                vc.id = id
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    
    private func addChildVC() {
        self.addChild(pageVC)
        self.pageView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        
    }
    
    
    @IBAction private func unfinishedButtonTapped(_ sender: UIButton) {
        unfinishedButton.backgroundColor = selectButtonColor
        expiredButton.backgroundColor = deSelectButtonColor
        completionButton.backgroundColor = deSelectButtonColor
        if pageVC.page != .unfinished {
            pageVC.setViewControllers([pageVC.pages[0]], direction: .reverse, animated: true)
            pageVC.setPage(.unfinished)
            moveIndicator(.unfinished)
        }
    }
    
    @IBAction func expiredButtonTapped(_ sender: UIButton) {
        unfinishedButton.backgroundColor = deSelectButtonColor
        expiredButton.backgroundColor = selectButtonColor
        completionButton.backgroundColor = deSelectButtonColor
        switch pageVC.page {
        case .unfinished:
            pageVC.setViewControllers([pageVC.pages[1]], direction: .forward, animated: true)
            pageVC.setPage(.expired)
            moveIndicator(.expired)
        case .completion:
            pageVC.setViewControllers([pageVC.pages[1]], direction: .reverse, animated: true)
            pageVC.setPage(.expired)
            moveIndicator(.expired)
        default:
            break
        }
        
    }
    
    @IBAction func completionButtonTapped(_ sender: UIButton) {
        unfinishedButton.backgroundColor = deSelectButtonColor
        expiredButton.backgroundColor = deSelectButtonColor
        completionButton.backgroundColor = selectButtonColor
        if pageVC.page != .completion {
            pageVC.setViewControllers([pageVC.pages[2]], direction: .forward, animated: true)
            pageVC.setPage(.completion)
            moveIndicator(.completion)
        }
    }
    
    @MainActor
    private func moveIndicator(_ page: CompletionFlag) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self else { return }
            switch page {
            case .unfinished:
                self.indicatorViewXConstraint.constant = -(UIScreen.main.bounds.width / 3)
            case .completion:
                self.indicatorViewXConstraint.constant = (UIScreen.main.bounds.width / 3)
            case .expired:
                self.indicatorViewXConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        })
    }

}


// MARK: - PageVCDelegate

extension MainViewController: @preconcurrency PageVCDelegate {
    
    func pageSelected(_ page: CompletionFlag) {
        switch pageVC.page {
        case .unfinished:
            unfinishedButton.backgroundColor = selectButtonColor
            expiredButton.backgroundColor = deSelectButtonColor
            completionButton.backgroundColor = deSelectButtonColor
        case .expired:
            unfinishedButton.backgroundColor = deSelectButtonColor
            expiredButton.backgroundColor = selectButtonColor
            completionButton.backgroundColor = deSelectButtonColor
        case .completion:
            unfinishedButton.backgroundColor = deSelectButtonColor
            expiredButton.backgroundColor = deSelectButtonColor
            completionButton.backgroundColor = selectButtonColor
        }
        moveIndicator(page)
    }
    
    
}
