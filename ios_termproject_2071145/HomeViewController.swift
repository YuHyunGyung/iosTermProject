//
//  HomeViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit

//메인 홈 컨트롤러
class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var meetingTableView: UITableView!
    var meetings: [Meeting] = ios_termproject_2071145.load("meetingData.json")
    var filteredMeetings: [Meeting] = [] //검색 필터를 위한 새로운 배열
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredMeetings = meetings
        
        searchBar.delegate = self
        meetingTableView.dataSource = self
        meetingTableView.delegate = self
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
        //performSegue(withIdentifier: "GotoDetail", sender: indexPath)
    }
    //다른 cell 선택하면 i 버튼 사라짐
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    //cell 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

//searchBar - delegate
extension HomeViewController: UISearchBarDelegate {
    //검색 중일때
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMeetings = meetings
        } else {
            let text = searchText.lowercased()
            filteredMeetings = meetings.filter { $0.title.contains(text) }
        }
        meetingTableView.reloadData()
    }
}
