//
//  HomeViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit

//메인 홈 컨트롤러
class HomeViewController: UIViewController {

    @IBOutlet weak var meetingTableView: UITableView!
    var meetings: [Meeting] = ios_termproject_2071145.load("meetingData.json")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        meetingTableView.dataSource = self
        meetingTableView.delegate = self
    }
}


//datasource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //각 섹션에 대하여 몇개의 행을 가질것인가. 섹션이 하나라 한번만 호출됨
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetings.count
    }
    
    //각 섹션이 행에 해당하는 UITableViewCell 만들어달라
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "yhg")! //let cell = UITableViewCell()
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let meeting = meetings[indexPath.row]
        
        cell.textLabel?.text = meeting.title
        cell.detailTextLabel?.text = "in \(meeting.date)"
        cell.textLabel?.textAlignment = .left
        
        return cell
    }
}

//delegate
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
    
    
    //isEditing 누르면 이 함수가 호출됨(-버튼)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //cities 배열에서 실제로 데이터를 삭제하는 작업을 해줘야함
        if editingStyle == .delete {
            meetings.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    //row를 옮기기
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //cities 배열에서 실제로 데이터를 이동시키는 작업을 해줘야함
        let city = meetings.remove(at: sourceIndexPath.row)
        meetings.insert(city, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    //cell 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
