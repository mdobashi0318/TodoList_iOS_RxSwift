//
//  HeaderCell.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2025/07/05.
//

import UIKit

class HeaderCell: UITableViewHeaderFooterView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
}
