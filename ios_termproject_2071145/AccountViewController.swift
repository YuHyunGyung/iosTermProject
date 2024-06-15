//
//  AccountViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit


//내가 해당하는 모임 통장의 잔액 확인하는 컨트롤러
class AccountViewController: UIViewController {
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate 공유
    
    
    
    @IBOutlet weak var meetingAccountCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        meetingAccountCollectionView.dataSource = self
        meetingAccountCollectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        meetingAccountCollectionView.reloadData()
    }
}


//collectionView - datasource
extension AccountViewController: UICollectionViewDataSource {
    
    //몇개의 아이템이 있는지
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.meetings.count
    }
    
    //셀에 들어갈 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "meetingAccountyhg", for: indexPath) as! MeetingAccountCollectionViewCell
       
        
        let meeting = appDelegate.meetings[indexPath.item]
        
        cell.title.text = meeting.title
        cell.account.text = String(meeting.account)
        
        //charge button action
        cell.chargeButtonAction = { [weak self] in
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            self?.chargeAccount(at: indexPath)
        }
        
        return cell
    }
    
    //모임 계좌에 잔액 충전
    func chargeAccount(at indexPath: IndexPath) {
        /*
        if indexPath.item < appDelegate.meetings.count {
            let meeting = appDelegate.meetings[indexPath.item]
        }
        */
        
        performSegue(withIdentifier: "GotoMeetingCharge", sender: indexPath)
    }
}

//collectionView - delegate, flow
extension AccountViewController: UICollectionViewDelegate {
    //아이템 선택할때 동작
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//전이
extension AccountViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let meetingAccountChargeViewController = segue.destination as? MeetingAccountChargeViewController
        
        meetingAccountChargeViewController!.accountViewController = self
        
        if let indexPath = sender as? IndexPath {
            meetingAccountChargeViewController?.selectedMeeting = indexPath.row
        }
    }
}
