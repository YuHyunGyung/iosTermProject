//
//  AddMeetingViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/14/24.
//

import UIKit
import FirebaseFirestore

//모임 저장하는 컨트롤러
class AddMeetingViewController: UIViewController {
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate 공유
    
    let days = [
    ["2024","2025","2026","2027","2028","2029","2030"], //연도
    ["1","2","3","4","5","6","7","8","9","10","11","12"], //월
    ["1","2","3","4","5","6","7","8","9","10", //일
     "11","12","13","14","15","16","17","18","19","20",
    "21","22","23","24","25","26","27","28","29","30",
    "31"]
    ]
    
    var year: String?
    var month: String?
    var day: String?
    
    let datePickerView = UIPickerView()
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBOutlet weak var memberCollectionView: UICollectionView! //추가한 멤버 보여주는 collectionView - 수평스크롤
    @IBOutlet weak var memberAddTableView: UITableView! //추가할 멤버 보여주는 tableView
    
    var homeViewController: HomeViewController!
    var selectedMeeting: Int?
    
    
    var users: [User] = [] //파이어베이스에서 가져온 모든 유저 정보
    //var filteredUsers: [User] = []
    
    var following: [Int] = [] //내가 팔로잉하고 있는 사람들 배열
    var filteredFollowing: [Int] = []
    var meetingsMembers: [Int] = [] //변경되기 전 멤버를 유지하기 위한 배열
    
    var followingUsers: [User] = [] //팔로잉한 유저들 정보
    var members: [User] = [] //모임의 멤버들 정보
    //var membersInt: [Int] = [] //새로운 모임일 경우 멤버 저장할 배열
    
    var usersDbFirebase: UsersDbFirebase? //전체유저
    var usersFollowingDbFirebase: UsersFollowingDbFirebase? //팔로잉한 유저
    var usersMeetingDbFirebase: UsersMeetingDbFirebase? //전체 모임
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //date text field 기본 값 설정
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        let current_date_string = formatter.string(from: Date())
        dateTextField.text = current_date_string

        //memoTextView 테두리 설정
        memoTextView.layer.borderColor = UIColor.lightGray.cgColor
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.cornerRadius = 5
        
        //pickerview의 done을 나타내줄 툴바
        let toolBar = UIToolbar()
        let BarButton = UIBarButtonItem()
        
        //텍스트필드에 피커뷰를 할당하는 부분
        dateTextField.inputView = datePickerView
        
        //툴바 배경
        toolBar.frame = CGRect(x: 0, y: 0, width: 0, height: 40)
        toolBar.backgroundColor = .darkGray
        self.dateTextField.inputAccessoryView = toolBar
        
        //툴바에 버튼 추가
        BarButton.title = "Done"
        BarButton.target = self
        BarButton.action = #selector(DoneButton(_:))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, BarButton], animated: true)
        
        
        //선택된 화면 초기화
        if let selectedMeeting = selectedMeeting {
            initMeeting(meeting: homeViewController.appDelegate.meetings[selectedMeeting])
        }
        
        //
        usersDbFirebase = UsersDbFirebase(parentNotification: manageUsersDatabase)
        usersDbFirebase?.setQuery(from: 1, to: 10000)
        
        usersFollowingDbFirebase = UsersFollowingDbFirebase(parentNotification: manageFollowingDatabase)
        usersFollowingDbFirebase?.setQuery(from: 1, to: 10000)
        
        usersMeetingDbFirebase = UsersMeetingDbFirebase(parentNotification: manageMeetingDatabase)
        usersMeetingDbFirebase?.setQuery(from: 1, to: 20000)
        
        
        //date pickerView 초기화
        datePickerView.dataSource = self
        datePickerView.delegate = self
        
        //멤버 추가할 tableView 초기화
        memberAddTableView.dataSource = self
        memberAddTableView.delegate = self
        
        //추가된 멤버 collectionView 초기화
        memberCollectionView.dataSource = self
        memberCollectionView.delegate = self
        
        
        //팔로우한 유저 가져오기
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
            print("viewDidLoad following : ", self.following)
            self.memberAddTableView.reloadData()
        }
        
        
        
        Firestore.firestore().collection("Users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting users documents: \(error)")
            } else {
                self.users.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let user = User.fromDict(dict: data)
                    self.users.append(user)
                }
            }
            print("viewDidLoad users : ", self.users)
            self.memberCollectionView.reloadData()
        }
    }
    
    //date pickerview done button
    @objc func DoneButton(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //선택된 화면 초기화
    func initMeeting(meeting: Meeting) {
        
        titleTextField.text = meeting.title
        dateTextField.text = meeting.date
        memoTextView.text = meeting.memo
        
        var memberString = ""
        if meeting.member.count != 0 {
            for i in 0..<meeting.member.count-1 {
                memberString += String(meeting.member[i])+","
            }
            
            memberString += String(meeting.member[meeting.member.count-1])
            print("memberString : ", memberString)
        }
        
        if selectedMeeting != nil {
            meetingsMembers = meeting.member
        }
        
    }
    
    //모임 저장하기 버튼
    @IBAction func savingButton(_ sender: UIButton) {
        guard let title = titleTextField.text, let memo = memoTextView.text, title.isEmpty == false || memo.isEmpty == false else { print("모임 저장하기 실패"); return }
        
        //멤버 코드 추가하기
        let date = dateTextField.text
        var id = appDelegate.id //새로운 모임의 주최자인 유저 primary key 부여
        var meetingId = appDelegate.meetings.count + 20001 //새로운 모임 primary key 부여
        var name = appDelegate.name //새로운 모임의 주최자인 유저 닉네임
        
        
        var member = meetingsMembers
        if !member.contains(appDelegate.id) {
            member.append(appDelegate.id)
        }
        //var member: [Int] = []
        var account: Int = 0 //계좌 잔액
        
        if let selectedMeeting = selectedMeeting { //신규 삽입이 아니면 수정
            id = appDelegate.meetings[selectedMeeting].id
            meetingId = appDelegate.meetings[selectedMeeting].meetingId
            name = appDelegate.meetings[selectedMeeting].name
            //member = appDelegate.meetings[selectedMeeting].member
            account = appDelegate.meetings[selectedMeeting].account
        } 
        /*
        else {
            member = membersInt
        }
        */
        
        
        let meeting = Meeting(id: id, meetingId: meetingId, name: name, title: title, date: date ?? "", memo: memo, member: member, account: account)
        print("AddMeetingViewController save Meeting : ", meeting)
        
        if let selectedMeeting = selectedMeeting { //신규 삽입 아니면 수정
            //homeViewController.appDelegate.meetings[selectedMeeting] = meeting
            usersMeetingDbFirebase?.saveChange(key: String(meetingId), object: Meeting.toDict(meeting: meeting), action: .modify)
        } else { //신규 삽입
            //homeViewController.appDelegate.meetings.append(meeting)
            usersMeetingDbFirebase?.saveChange(key: String(meetingId), object: Meeting.toDict(meeting: meeting), action: .add)
        }
        
        
        selectedMeeting = nil
        self.navigationController?.popToRootViewController(animated: true) //self.navigationController?.popViewController(animated: true)
    }
}



//firestore 연결
extension AddMeetingViewController {
    
    //유저 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageUsersDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let user = User.fromDict(dict: dict)
        
        /*
        if dbaction == .add {
            users.append(user)
            filteredUsers = users
            print("AddMeetingViewController users : ", users)
            return
        }
         */
    }
    
    //팔로잉 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageFollowingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        
        guard let dict = dict else { return }
        let follow = Following.fromDict(dict: dict)
        
        /*
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
                print("manage AddMeetingViewController following :", self.following)
            }
            return
        }
        */
    }
    
    //모임 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageMeetingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let meeting = Meeting.fromDict(dict: dict)
        
        
        if dbaction == .add {
            //appDelegate.meetings.append(meeting)
            print("AddMeetingViewController manage add meeting : ", appDelegate.meetings)
        }
        
        if dbaction == .delete {
            
        }
        
        for i in 0..<appDelegate.meetings.count {
            if meeting.meetingId == appDelegate.meetings[i].meetingId {
                if dbaction == .modify {
                    appDelegate.meetings[i] = meeting
                    print("AddMeetingViewController manage modify meeting : ", appDelegate.meetings)
                }
            }
        }
    }
}


//collectionView - datasource
extension AddMeetingViewController: UICollectionViewDataSource {
    
    //몇개의 아이템이 있는지
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meetingsMembers.count
    }
    
    
    //셀에 들어갈 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //선택한 모임이면
        if selectedMeeting != nil {
            if meetingsMembers.count != 0 { //멤버가 있으면
                self.members.removeAll() //먼저 멤버 배열 중복이 있을 수도 있으니 다 지우고
                
                print("member : ", meetingsMembers, "users count : ", users.count)
                for i in 0..<meetingsMembers.count {
                    print("i : ", i)
                    for j in 0..<users.count {
                        print("j : ", j)
                        print("AddMeetingFriend meeting member : ", meetingsMembers)
                        print("AddMeetingFriend users j : ", j, "users[j] : ", users[j])
                        if meetingsMembers[i] == users[j].id {
                            print("collect!")
                            members.append(users[j]) //users정보에 appDelegate.meetings.member에 있는 멤버 정보와 같으면 멤버 배열에 넣어두기
                        }
                    }
                }
            }
        }
        
        //선택한 모임이 없으면
        else {
            self.members.removeAll()
            
            for i in 0..<meetingsMembers.count { //membersInt.count {
                for j in 0..<users.count {
                    if meetingsMembers[i] == users[j].id {
                        members.append(users[j])
                    }
                }
            }
        }
        
        
        print("indexPath row : ", indexPath.row, "members count : ", members.count)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addMeetingFriendyhg", for: indexPath) as! AddMeetingFriendCollectionViewCell
        
        
        if indexPath.row < members.count {
            let user = members[indexPath.row] //여기 넣어야 오류 안남
            
            ImagePool.image(name: user.imageName, size: CGSize(width: 85, height: 85)) { [weak self] image in
                cell.imageView.image = image
            }
            cell.nameLable.text = user.name
            print("user info : ", user)
        } else {
            print("Index out of range for members array")
        }
        
        
        cell.deleteButtonAction = { [weak self] in
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            self?.deleteMember(at: indexPath)
        }
        
        return cell
    }
    
    //멤버 삭제하는 버튼에 쓰일 함수 정의
    func deleteMember(at indexPath: IndexPath) {
        //guard let selectedMeeting = selectedMeeting else { return }
        
        
        //meetingsMembers 배열의 유효한 인덱스 범위 내에서 삭제 작업 수행
        if indexPath.item < meetingsMembers.count {
            meetingsMembers.remove(at: indexPath.item)
            memberCollectionView.deleteItems(at: [indexPath])
            
            memberCollectionView.reloadData()
            memberAddTableView.reloadData()
        } else {
            print("Index out of range for meetingsMembers array")
        }
    }
    
}


//collectionView - delegate, flowlayout
extension AddMeetingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //아이템 선택하면 호출됨
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if appDelegate.id == meetingsMembers[indexPath.item] {
            return CGSizeZero
        }
        
        return CGSize(width: 85, height: 85)
    }
}


//tableView - datasource
extension AddMeetingViewController: UITableViewDataSource {
    
    //각 섹션에 대하여 몇개의 행 가질지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("following count : ", following.count)
        return following.count
    }
    
    //각 섹션의 행에 해당하는 cell 만들기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if following.count != 0 { //followingUsers에 팔로잉한 유저 정보 넣기
            self.followingUsers.removeAll()
            
            for i in 0..<following.count {
                for j in 0..<users.count {
                    if following[i] == users[j].id {
                        followingUsers.append(users[j])
                    }
                }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addMeetingFriendTableViewCellyhg") as! AddMeetingFriendTableViewCell
        
        let user = followingUsers[indexPath.row]
        
        ImagePool.image(name: user.imageName, size: CGSize(width: 85, height: 85)) { [weak self] image in
            cell.profileImageView.image = image
        }
        cell.userNameLabel.text = user.name
        
        //멤버 추가 버튼 눌렀을 경우
        cell.addFriendButton.addTarget(self, action: #selector(addFriendButtonTapped(_:)), for: .touchUpInside)
        cell.addFriendButton.tag = indexPath.row
        
        //추가했으면 버튼 안보이게 하기
        if let selectedMeeting = selectedMeeting, selectedMeeting < appDelegate.meetings.count {
            if meetingsMembers.contains(followingUsers[indexPath.row].id) {
                cell.addFriendButton.isHidden = true
            } else {
                cell.addFriendButton.isHidden = false
            }
        }
        else if selectedMeeting == nil {
            if meetingsMembers.contains(followingUsers[indexPath.row].id) {
                cell.addFriendButton.isHidden = true
            } else {
                cell.addFriendButton.isHidden = false
            }
        }
        
        
        return cell
    }
    @objc func addFriendButtonTapped(_ sender: UIButton) {
        print("addFriendButtonTapped sender.tag : ", sender.tag, "\n followingUsers : ", followingUsers)
        
        guard sender.tag < followingUsers.count else { return }
        let user = followingUsers[sender.tag]
        print("addFriendButtonTapped user : ", user)
        
        print("selectedMeeting : ", selectedMeeting)
        
        if let selectedMeeting = selectedMeeting, selectedMeeting < appDelegate.meetings.count {
            meetingsMembers.append(user.id)
        }
        else if selectedMeeting == nil {
            meetingsMembers.append(user.id)
        }
        
        memberCollectionView.reloadData()
        memberAddTableView.reloadData()
    }
}

//tableView - delegate
extension AddMeetingViewController: UITableViewDelegate {
    //특정 row 클릭시 호출
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //cell 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


//pickerView - datasource, delegate
extension AddMeetingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //days 배열의 구성요소의 수를 반환하는 메서드 -> picker뷰의 행의 수를 결정
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return days.count
    }
    
    //days 배열의 구성요소의 열의 수를 반환하는 메서드 -> 각 행의 열의 수를 결정
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days[component].count
    }
    
    //days 배열의 값들을 반환하는 메서드 -> 각각의 값을 결정
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        return days[component][row]
        
    }
    
    //주어진 component에서 선택된 열을 매개변수로 갖음
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        //component에 따라 연, 월, 일의 값을 변경
        switch component {
        case 0:
            year = days[0][row]
        case 1:
            month = days[1][row]
        case 2:
            day = days[2][row]
        default:
            print("Error!!")
        }
        
        //바뀐 값을 텍스트필드의 값으로 할당
        if let year = year, let month = month, let day = day {
            let dateString = year + "년 " + month + "월 " + day + "일"
            dateTextField.text = dateString
        }
    }
}
