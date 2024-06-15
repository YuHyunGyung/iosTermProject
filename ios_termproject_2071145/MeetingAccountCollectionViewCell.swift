//
//  MeetingAccountCollectionViewCell.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/15/24.
//

import UIKit

class MeetingAccountCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var chargeButton: UIButton!
    
    var chargeButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //charge button action
        chargeButton.addTarget(self, action: #selector(chargeButtonTapped), for: .touchUpInside)
    }
    
    @objc func chargeButtonTapped() {
        chargeButtonAction?()
    }
}
