//
//  AddMeetingViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/14/24.
//

import UIKit

//신규 모임 추가 하는 컨트롤러
class AddMeetingViewController: UIViewController {

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
    @IBOutlet weak var memberTableView: UITableView!
    
    var homeViewController: HomeViewController!
    var selectedMeeting: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //date text field 기본 값 설정
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        var current_date_string = formatter.string(from: Date())
        dateTextField.text = current_date_string

        //pickerview의 done 을 나타내줄 툴바
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
        
        //date pickerview 초기화
        datePickerView.dataSource = self
        datePickerView.delegate = self
        
        //선택된 도시 화면 초기화
        if let selectedMeeting = selectedMeeting {
            initMeeting(meeting: homeViewController.appDelegate.meetings[selectedMeeting])
        }
        
    }
    
    //date pickerview done button
    @objc func DoneButton(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //선택된 도시 화면 초기화
    func initMeeting(meeting: Meeting) {
        
        titleTextField.text = meeting.title
        dateTextField.text = meeting.date
        memoTextView.text = meeting.memo
        
        var memberString = ""
        for i in 0..<meeting.member.count-1 {
            memberString += String(meeting.member[i])+","
        }
        memberString += String(meeting.member[meeting.member.count-1])
        print("memberString : ", memberString)
    }
    
    //모임 저장하기
    @IBAction func savingButton(_ sender: UIButton) {
        guard let title = titleTextField.text, let memo = memoTextView.text, title.isEmpty == false || memo.isEmpty == false else { return }
        
        var date = dateTextField.text
        //멤버 코드 추가하기
        
        var id = homeViewController.appDelegate.meetings.count
        var meetingId = homeViewController.appDelegate.meetings.count //새로운 모임 primary key 부여
        var name = "" //homeViewController.meetings.count
        var member: Array<Int> = Array()//모임 멤버 배열
        var account: String = "0" //계좌 잔액
        
        if let selectedMeeting = selectedMeeting { //신규 삽입이 아니면 수정
            id = homeViewController.appDelegate.meetings[selectedMeeting].id
            meetingId = homeViewController.appDelegate.meetings[selectedMeeting].meetingId
            name = homeViewController.appDelegate.meetings[selectedMeeting].name
            member = homeViewController.appDelegate.meetings[selectedMeeting].member
            account = homeViewController.appDelegate.meetings[selectedMeeting].account
        }
        
        
        let meeting = Meeting(id: id, meetingId: meetingId, name: name, title: title, date: date ?? "", memo: memo, member: member, account: account)
        print("AddMeetingViewController Meeting : ", meeting)
        
        if let selectedMeeting = selectedMeeting { //신규 삽입 아니면 수정
            homeViewController.appDelegate.meetings[selectedMeeting] = meeting
        } else {
            homeViewController.appDelegate.meetings.append(meeting)
        }
        
        
        selectedMeeting = nil
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
}


//pickerview - datasource, delegate
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
