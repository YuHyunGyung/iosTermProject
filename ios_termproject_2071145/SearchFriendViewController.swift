//
//  SearchFriendViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

//친구찾기 컨트롤러
class SearchFriendViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchFriendTableView: UITableView!
    
    //var id: String?
    var stringId: String?
    
    var following: [Int] = [] //내가 팔로잉 하고 있는 사람들 배열
    
    var users: [User] = [] //파이어베이스에서 가져온 모든 유저 정보
    var filteredUsers: [User] = [] //검색 필터한 유저들 배열
    
    var usersDbFirebase: UsersDbFirebase? //전체유저
    var usersFollowingDbFirebase: UsersFollowingDbFirebase? //팔로잉한 유저
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("Recived stringId : ", stringId ?? "no data received")
        
        //Firestore에서 모든 유저 데이터 가져오기
        Firestore.firestore().collection("Users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.users.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let user = User.fromDict(dict: data)
                    self.users.append(user)
                }
                self.filteredUsers = self.users
                self.searchFriendTableView.reloadData()
            }
        }
        //팔로잉 데이터 불러오기
        Firestore.firestore().collection("Users").document(stringId!).collection("Following").getDocuments { (querySnapshot, error) in
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
            print("viewDidload following: ", self.following)
        }
        
        
        usersDbFirebase = UsersDbFirebase(parentNotification: manageUsersDatabase)
        usersDbFirebase?.setQuery(from: 1, to: 10000)
        
        usersFollowingDbFirebase = UsersFollowingDbFirebase(parentNotification: manageFollowingDatabase)
        usersFollowingDbFirebase?.setQuery(from: 1, to: 10000)
        
        usersFollowingDbFirebase?.id = self.stringId
        print("SearchFriendViewController id : ", self.stringId, ", ", usersFollowingDbFirebase?.id)
        
        searchBar.delegate = self
        searchFriendTableView.dataSource = self
        searchFriendTableView.delegate = self
    }
    
    
    //유저 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageUsersDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let user = User.fromDict(dict: dict)
        
        if dbaction == .add {
            users.append(user)
            return
        }
    }
    
    //팔로잉 신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageFollowingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let follow = Following.fromDict(dict: dict)
        
        if dbaction == .add {
            following.append(follow.id)
            print("1. dict : ", dict, "2. follow : ", follow)
            print("following data : ", following)
            return
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendyhg") as! SearchFriendTableViewCell //custom한 cell로 캐스팅
        /*
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        */
        
        let user = filteredUsers[indexPath.row]
        
        cell.profileImage.image = UIImage(named: user.imageName) //유저 이미지
        cell.name.text = user.name //유저 닉네임
        
        if following.contains(user.id) { //유저 팔로잉, 팔로우 구분 버튼
            cell.followingButton.setTitle("팔로잉", for: .normal)
        } else {
            cell.followingButton.setTitle("팔로우", for: .normal)
        }
        
        return cell
    }
}
//tableView - delegate
extension SearchFriendViewController: UITableViewDelegate {
    //특정 row를 클릭하면 이 함수가 호출됨
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = filteredUsers[indexPath.row] //팔로우, 팔로잉 버튼 클릭된 유저
        let followUser = Following(id: selectedUser.id, userId: selectedUser.userId) //변경할 내용이 있는 유저 정보
        let isFollowing = following.contains(selectedUser.id) //팔로우 하고 있는지 확인
        
        if !isFollowing { //팔로우하지 않은 상태라면
            following.append(selectedUser.id)
            usersFollowingDbFirebase?.saveChange(key: String(selectedUser.id), object: Following.toDict(following: followUser), action: .add)
        }
        else { //팔로우 안한 상태라면
            following.remove(at: indexPath.row)
            usersFollowingDbFirebase?.saveChange(key: String(selectedUser.id), object: Following.toDict(following: followUser), action: .delete)
        }
    }
    
    //cell 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

//searchBar - delegate
extension SearchFriendViewController: UISearchBarDelegate {
    
    //검색 중일때
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            let text = searchText.lowercased()
            filteredUsers = users.filter { $0.name.contains(text) }
        }
        searchFriendTableView.reloadData()
    }
}
