//
//  MyProfileViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit
import FirebaseFirestore

//내정보 컨트롤러
class MyProfileViewController: UIViewController {
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    var usersDbFirebase: UsersDbFirebase?
    var users: [User] = []
    
    var usersFollowingDbFirebase: UsersFollowingDbFirebase?
    var following: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("MyProfileViewController viewDidLoad")
        
        usersDbFirebaseSet()
        usersFollowingDbFirebaseSet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("MyProfileViewController viewDidAppear")
        initMyProfile()
    }
    
    //프로필 데이터 초기화 설정
    func initMyProfile() {
        for i in 0..<users.count {
            if appDelegate.id == users[i].id {
                let user = users[i]
                print("MyProfileViewController initMyProfile user : ", user)
                
                userNameLabel.text = user.name //유저 닉네임
                profileImageView.image = UIImage(named: user.imageName) //프로필 이미지
                followingLabel.text = String(following.count) //팔로잉 수
                accountLabel.text = String(user.account) //계좌 잔액
                return
            }
        }
        
    }
    
    //충전버튼
    @IBAction func chargeButton(_ sender: UIButton) {
        performSegue(withIdentifier: "GotoCharge", sender: nil)
    }
}

//firestore
extension MyProfileViewController {
    //전체유저
    func usersDbFirebaseSet() {
        usersDbFirebase = UsersDbFirebase(parentNotification: manageUsersDatabase)
        usersDbFirebase?.setQuery(from: 1, to: 10000)
    }
    //팔로잉
    func usersFollowingDbFirebaseSet() {
        usersFollowingDbFirebase = UsersFollowingDbFirebase(parentNotification: manageFollowingDatabase)
        usersFollowingDbFirebase?.setQuery(from: 1, to: 10000)
    }
    
    //유저 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageUsersDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let user = User.fromDict(dict: dict)
        
        
        if dbaction == .add {
            users.append(user)
            print("MyProfileViewController manage users : ", users)
        }
        
        if dbaction == .modify {
            
        }
    }
        
        
    //팔로잉 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageFollowingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let follow = Following.fromDict(dict: dict)
        
        if dbaction == .add {
            Firestore.firestore().collection("Users").document(String(appDelegate.id)).collection("Following").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting following documents: \(error)")
                } else {
                    self.following.removeAll() // 기존 팔로잉 데이터를 지우기
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let follow = Following.fromDict(dict: data)
                        self.following.append(follow.id)
                    }
                }
                print("MyProfileViewController manage following: ", self.following)
            }
        }
    }
}


//전이
extension MyProfileViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let accountChargeViewController = segue.destination as? AccountChargeViewController
        
        accountChargeViewController!.myprofileViewController = self
    }
}
