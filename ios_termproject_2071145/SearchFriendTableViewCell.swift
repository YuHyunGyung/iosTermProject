//
//  SearchFriendTableViewCell.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit

class SearchFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    
    @IBAction func followingButton(_ sender: UIButton) {
        
    }
    
    /*
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = UIImage(named: "default_profile") // 기본 이미지로 초기화
    }
    */
}
