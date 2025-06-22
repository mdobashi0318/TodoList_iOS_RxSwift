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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        setViewControllers([TodoListViewController(page: .unfinished)], direction: .forward, animated: true)
        
    }
    
    func setPage(_ page: CompletionFlag) {
        self.page = page
    }
    
}


// MARK: - UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch page {
        case .expired:
            page = .unfinished
            pageVCDelegate?.pageSelected(page)
            return TodoListViewController(page: page)
        case .completion:
            page = .expired
            pageVCDelegate?.pageSelected(page)
            return TodoListViewController(page: page)
        default:
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch page {
        case .unfinished:
            page = .expired
            pageVCDelegate?.pageSelected(page)
            return TodoListViewController(page: page)
        case .expired:
            page = .completion
            pageVCDelegate?.pageSelected(page)
            return TodoListViewController(page: page)
        default:
            return nil
        }
    }
    
}
