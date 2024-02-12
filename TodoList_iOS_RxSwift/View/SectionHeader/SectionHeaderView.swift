//
//  SectionHeaderView.swift
//  TodoList_iOS_RxSwift
//
//  Created by 土橋正晴 on 2024/02/12.
//

import UIKit

class SectionHeaderView: UIView {

    @IBOutlet weak var label: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
         super.init(frame: frame)

        loadNib()
     }

     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         
     }
    

    private func loadNib() {
        let view = Bundle.main.loadNibNamed("SectionHeaderView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

}
