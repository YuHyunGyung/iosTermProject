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

    var usersMeetingDbFirebase: UsersMeetingDbFirebase?
    
    @IBOutlet weak var account: UITextField!
    var accountInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MeetingAccountchargeViewController \n selectedMeeting : ", selectedMeeting!)
        
        usersMeetingDbFirebase = UsersMeetingDbFirebase(parentNotification: manageMeetingDatabase)
        usersMeetingDbFirebase?.setQuery(from: 1, to: 20000)
    }
    
    //충전하기 button
    @IBAction func chargeButton(_ sender: UIButton) {
        
        //입력한 충전 금액이 있으면
        if let accountText = account.text, let accountValue = Int(accountText) {
            accountInt += accountValue
        }
        
        
        var id = appDelegate.meetings[selectedMeeting!].id
        var meetingId = appDelegate.meetings[selectedMeeting!].meetingId
        var name = appDelegate.meetings[selectedMeeting!].name
        var title = appDelegate.meetings[selectedMeeting!].title
        var date = appDelegate.meetings[selectedMeeting!].date
        var memo = appDelegate.meetings[selectedMeeting!].memo
        var member = appDelegate.meetings[selectedMeeting!].member
        var account = appDelegate.meetings[selectedMeeting!].account + accountInt
    
        /*
        //선택한 모임이 있으면 = 신규가 아니면 수정
        if let selectedMeeting = selectedMeeting {
        }
        */
        
        let meeting = Meeting(id: id, meetingId: meetingId, name: name, title: title, date: date, memo: memo, member: member, account: account)
        usersMeetingDbFirebase?.saveChange(key: String(meetingId), object: Meeting.toDict(meeting: meeting), action: .modify)
        
        accountViewController.meetingAccountCollectionView.reloadData()
        
        selectedMeeting = nil
        self.account.text = nil
        //self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MeetingAccountChargeViewController {
    //모임 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageMeetingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let meeting = Meeting.fromDict(dict: dict)
        
        
        if dbaction == .add {
            //appDelegate.meetings.append(meeting)
            print("MeetingAccountChargeViewController manage add meeting : ", appDelegate.meetings)
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
