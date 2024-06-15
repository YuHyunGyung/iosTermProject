//
//  HomeViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit

//메인 홈 컨트롤러
class HomeViewController: UIViewController {
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate 공유
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var meetingTableView: UITableView!
    
    var filteredMeetings: [Meeting] = [] //검색 필터를 위한 새로운 배열
    var usersMeetingDbFirebase: UsersMeetingDbFirebase? //firebase 전체 모임
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "모임 통장"
        
        searchBar.delegate = self
        meetingTableView.dataSource = self
        meetingTableView.delegate = self
        
        usersMeetingDbFirebase = UsersMeetingDbFirebase(parentNotification: manageMeetingDatabase)
        usersMeetingDbFirebase?.setQuery(from: 1, to: 20000)
    }

    override func viewDidAppear(_ animated: Bool) {
        //화면 다시 나타날때 변경된거 보여줌
        filteredMeetings = appDelegate.meetings
        
        print("HomeViewController didAppear filteredMeetings", filteredMeetings)
        meetingTableView.reloadData()
    }
    
    //모임 추가하기 버튼
    @IBAction func addMeeting(_ sender: UIButton) {
        performSegue(withIdentifier: "GotoDetail", sender: nil)
    }
    
    //모임 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageMeetingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let meeting = Meeting.fromDict(dict: dict)
        
        if dbaction == .add {
            appDelegate.meetings.append(meeting)
            filteredMeetings = appDelegate.meetings
            print("HomeViewController manage add meeting: ", filteredMeetings)
        }
        
        for i in 0..<appDelegate.meetings.count {
            if meeting.meetingId == appDelegate.meetings[i].meetingId { //이미 있으면
                if dbaction == .modify {
                    appDelegate.meetings[i] = meeting
                    filteredMeetings = appDelegate.meetings
                    
                    print("HomeViewController manage modify meeting", filteredMeetings)
                    return
                }
            }
        }
        
    }
}


//tableView - datasource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //각 섹션에 대하여 몇개의 행을 가질것인가. 섹션이 하나라 한번만 호출됨
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMeetings.count
    }
    
    //각 섹션이 행에 해당하는 UITableViewCell 만들어달라
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "yhg")!
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let meeting = filteredMeetings[indexPath.row]
        
        //cell.accessoryType = .detailDisclosureButton
        cell.textLabel?.text = meeting.title
        cell.detailTextLabel?.text = meeting.date
        cell.textLabel?.textAlignment = .left
        
        return cell
    }
}

//tableView - delegate
extension HomeViewController: UITableViewDelegate {
    
    //특정 row를 클릭하면 이 함수가 호출됨
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .detailDisclosureButton
    }
    //i버튼 누르면 전이
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        performSegue(withIdentifier: "GotoDetail", sender: indexPath)
    }
    //다른 cell 선택하면 i 버튼 사라짐
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    //cell 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let meeting = filteredMeetings[indexPath.row]
        if meeting.member.contains(appDelegate.id) {
            return 90
        } else {
            return 0
        }
    }
}

//searchBar - delegate
extension HomeViewController: UISearchBarDelegate {
    //검색 중일때
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMeetings = appDelegate.meetings
        } else {
            let text = searchText.lowercased()
            filteredMeetings = appDelegate.meetings.filter { $0.title.contains(text) }
        }
        meetingTableView.reloadData()
    }
}


//전이
extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let addMeetingDetailViewController = segue.destination as? AddMeetingViewController //전이 하고자 하는 뷰 컨트롤러
        
        addMeetingDetailViewController!.homeViewController = self
        
        
        if let indexPath = sender as? IndexPath {
            addMeetingDetailViewController?.selectedMeeting = indexPath.row
        }
    }
}
