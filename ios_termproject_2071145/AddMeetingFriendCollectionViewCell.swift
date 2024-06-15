//
//  AddMeetingFriendCollectionViewCell.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/14/24.
//

import UIKit

class AddMeetingFriendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var deleteButton : UIButton!
    
    var deleteButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    
        //이미지 뷰를 뷰에서 10만큼 떨어지게
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        //이름라벨을 이미지뷰 밑에 배치
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLable)
        NSLayoutConstraint.activate([
            nameLable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            nameLable.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    
    
        //버튼을 이미지 뷰의 오른쪽 상단에 배치
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        //deleteButton을 최상단으로 가져오기
        contentView.bringSubviewToFront(deleteButton)
        
        //deleteButton action
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc func deleteButtonTapped() {
        deleteButtonAction?()
    }
    
}

