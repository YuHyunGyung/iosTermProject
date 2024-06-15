//
//  AccountChargeViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/15/24.
//

import UIKit

//myprofile 내 계좌 잔액 충전하는 컨트롤러
class AccountChargeViewController: UIViewController {
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate 공유
    
    var myprofileViewController: MyProfileViewController!
    
    //var usersDbFirebase: UsersDbFirebase?
    //var users: [User] = []
    
    @IBOutlet weak var account: UITextField!
    var accountInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //usersDbFirebaseSet()
    }
    
    //충전하기 button
    @IBAction func chargeButton(_ sender: UIButton) {
        //입력한 충전 금액이 있으면
        if let accountText = account.text, let accountValue = Int(accountText) {
            accountInt += accountValue
        }
        
        for i in 0..<myprofileViewController.users.count {
            if appDelegate.id == myprofileViewController.users[i].id {
                print("come")
                
                let usr = myprofileViewController.users[i]
                accountInt += usr.account
                
                
                let user = User(id: usr.id, userId: usr.userId, password: usr.password, name: usr.name, imageName: usr.imageName, account: accountInt)
                myprofileViewController.usersDbFirebase?.saveChange(key: String(usr.id), object: User.toDict(user: user), action: .modify)
                
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
        
    }
}

/*
//firestore
extension AccountChargeViewController {
    //전체유저
    func usersDbFirebaseSet() {
        usersDbFirebase = UsersDbFirebase(parentNotification: manageUsersDatabase)
        usersDbFirebase?.setQuery(from: 1, to: 10000)
    }
    
    //유저 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageUsersDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let user = User.fromDict(dict: dict)
        
        
        if dbaction == .add {
            users.append(user)
            print("AccountChargeViewController manage users : ", users)
        }
        
        if dbaction == .modify {
            
        }
    }
}
*/
