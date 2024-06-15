//
//  AddMeetingFriendTableViewCell.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/15/24.
//

import UIKit


class AddMeetingFriendTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    var addFriendButtonAction: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @objc func addFriendButtonTapped() {
        addFriendButtonAction?()
    }

}
