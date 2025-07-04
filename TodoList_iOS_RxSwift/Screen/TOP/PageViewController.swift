//
//  PageViewController.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2025/06/22.
//

import Foundation
import UIKit


protocol PageVCDelegate: AnyObject {
    func pageSelected(_ page: CompletionFlag)
}

class PageViewController: UIPageViewController {
    
    private(set) var page: CompletionFlag = .unfinished
    
    weak var pageVCDelegate: PageVCDelegate?
    
    private(set) var pages = [TodoListViewController(page: .unfinished), TodoListViewController(page: .expired), TodoListViewController(page: .completion)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: true)
    }
    
    func setPage(_ page: CompletionFlag) {
        self.page = page
    }
    
}


// MARK: - UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? TodoListViewController,
              let index = pages.firstIndex(of: vc),
            let before = pages[safe: index - 1] else {
            return nil
        }
        return before
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? TodoListViewController,
              let index = pages.firstIndex(of: vc),
              let after = pages[safe: index + 1] else {
            return nil
        }
        return after
    }
    
}


// MARK: - UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let vc = pendingViewControllers.first as? TodoListViewController else {
            return
        }
        page = vc.page
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let vc = previousViewControllers.first as? TodoListViewController else {
            return
        }
        guard completed else {
            page = vc.page
            return
        }
        pageVCDelegate?.pageSelected(page)
    }
    
}

