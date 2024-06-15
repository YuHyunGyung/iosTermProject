//
//  MeetingAccountChargeViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/15/24.
//

import UIKit

//모임 계좌에 충전하는 컨트롤러
class MeetingAccountChargeViewController: UIViewController {
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate 공유

    var accountViewController: AccountViewController!
    var selectedMeeting: Int?

    var users: [User] = []
    var usersDbFirebase: UsersDbFirebase?
    var usersMeetingDbFirebase: UsersMeetingDbFirebase?
    
    @IBOutlet weak var account: UITextField!
    var meetingAccountInt = 0
    var myAccountInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MeetingAccountchargeViewController \n selectedMeeting : ", selectedMeeting!)
        
        usersDbFirebaseSet()
        usersMeetingDbFirebaseSet()
    }
    
    //충전하기 button
    @IBAction func chargeButton(_ sender: UIButton) {
        //user
        var user: User = User(id: -1, userId: "", password: "", name: "", imageName: "", account: -1)
        for i in 0..<users.count {
            if appDelegate.id == users[i].id {
                user = users[i]
            }
        }
        
        //입력한 충전 금액이 있으면
        if let accountText = account.text, let accountValue = Int(accountText) {
            if user.account-accountValue < 0 {
                showToast(message: "잔액이 부족합니다.")
                return
            }
            else {
                meetingAccountInt += accountValue
                user.account -= accountValue //myAccountInt -= accountValue
            }
        }
        
        
        
        //meeting
        var id = appDelegate.meetings[selectedMeeting!].id
        var meetingId = appDelegate.meetings[selectedMeeting!].meetingId
        var name = appDelegate.meetings[selectedMeeting!].name
        var title = appDelegate.meetings[selectedMeeting!].title
        var date = appDelegate.meetings[selectedMeeting!].date
        var memo = appDelegate.meetings[selectedMeeting!].memo
        var member = appDelegate.meetings[selectedMeeting!].member
        var account = appDelegate.meetings[selectedMeeting!].account + meetingAccountInt
    
        /*
        //선택한 모임이 있으면 = 신규가 아니면 수정
        if let selectedMeeting = selectedMeeting {
        }
        */
        
        let meeting = Meeting(id: id, meetingId: meetingId, name: name, title: title, date: date, memo: memo, member: member, account: account)
        usersMeetingDbFirebase?.saveChange(key: String(meetingId), object: Meeting.toDict(meeting: meeting), action: .modify)
        usersDbFirebase?.saveChange(key: String(user.id), object: User.toDict(user: user), action: .modify)
        
        accountViewController.meetingAccountCollectionView.reloadData()
        
        selectedMeeting = nil
        self.account.text = nil
        //self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}

//manage
extension MeetingAccountChargeViewController {
    //전체유저
    func usersDbFirebaseSet() {
        usersDbFirebase = UsersDbFirebase(parentNotification: manageUsersDatabase)
        usersDbFirebase?.setQuery(from: 1, to: 10000)
    }
    
    func usersMeetingDbFirebaseSet() {
        usersMeetingDbFirebase = UsersMeetingDbFirebase(parentNotification: manageMeetingDatabase)
        usersMeetingDbFirebase?.setQuery(from: 1, to: 20000)
    }
    
    //유저 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageUsersDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let user = User.fromDict(dict: dict)
        
        if dbaction == .add {
            users.append(user)
            print("MyProfileViewController manage add users : ", users)
        }
        
        for i in 0..<users.count {
            if appDelegate.id == users[i].id {
                if dbaction == .modify {
                    users[i] = user
                    print("MyProfileViewController manage modify users : ", users)
                }
            }
        }
    }
    
    //모임 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageMeetingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let meeting = Meeting.fromDict(dict: dict)
        
        
        if dbaction == .add {
            
        }
        
        if dbaction == .delete {
            
        }
        
        for i in 0..<appDelegate.meetings.count {
            if meeting.meetingId == appDelegate.meetings[i].meetingId {
                if dbaction == .modify {
                    appDelegate.meetings[i] = meeting
                    print("MeetingAccountChargeViewController manage modify meeting : ", appDelegate.meetings)
                }
            }
        }
    }
}


//toast
extension MeetingAccountChargeViewController {
    
    //toast - 회원 계정이 이미 있는 경우 toast 메세지 함수
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel() //UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        let maxSize = CGSize(width: self.view.frame.size.width - 40, height: CGFloat.greatestFiniteMagnitude)
        let expectedSize = toastLabel.sizeThatFits(maxSize)
        
        toastLabel.frame = CGRect(x: (self.view.frame.size.width - expectedSize.width - 20) / 2,
                                  y: self.view.frame.size.height - 100,
                                  width: expectedSize.width + 20,
                                  height: expectedSize.height + 10)
    
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
