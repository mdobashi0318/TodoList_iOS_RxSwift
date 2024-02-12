//
//  TextFieldCell.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2024/02/12.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
