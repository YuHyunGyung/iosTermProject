//
//  SearchFriendViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit

//친구찾기 컨트롤러
class SearchFriendViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchFriendTableView: UITableView!
    var following: [String] = [] //내가 팔로잉 하고 있는 사람들 배열
    var users: [User] = [] //파이어베이스에서 가져온 모든 유저 정보
    var filteredUsers: [User] = [] //검색 필터한 유저들 배열
    
    var usersDbFirebase: UsersDbFirebase?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchFriendTableView.dataSource = self
        searchFriendTableView.delegate = self
    }
    
    
    //신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        let user = User.fromDict(dict: dict!)
        
        if dbaction == .add {
            users.append(user)
        }
        
        if dbaction == .modify {
            if let indexPath = searchFriendTableView.indexPathForSelectedRow {
                users[indexPath.row] = user //선택된 row의 시티정보 수정
            }
        }
        
        if dbaction == .delete {
            for i in 0..<users.count { //삭제 대상 찾음
                if user.id == users[i].id {
                    users.remove(at: i) //삭제
                    break
                }
            }
        }
        //나머지 수정, 삭제 부분은 추가되어야 함
        searchFriendTableView.reloadData() //변경된 사항 TableView에 반영
        
        if let indexPath = searchFriendTableView.indexPathForSelectedRow {
            //만약 선택된 row가 있으면 description 내용을 업데이트
            //descriptionLabel.text = users[indexPath.row].description
        }
    }
}


//tableView - datasource
extension SearchFriendViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //각 섹션에 대하여 몇개의 행을 가질것인가. 섹션이 하나라 한번만 호출됨
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    //각 섹션이 행에 해당하는 UITableViewCell 만들어달라
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendyhg")! as UITableViewCell
        var config = cell.defaultContentConfiguration() //custom한 cell에 데이터 입히기 위함
        
        
        
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        /*
        let meeting = filteredMeetings[indexPath.row]
        
        //cell.accessoryType = .detailDisclosureButton
        cell.textLabel?.text = meeting.title
        cell.detailTextLabel?.text = meeting.date
        cell.textLabel?.textAlignment = .left
        */
        return cell
    }
}
//tableView - delegate
extension SearchFriendViewController: UITableViewDelegate {
    
}

//searchBar - delegate
extension SearchFriendViewController: UISearchBarDelegate {
    
}
