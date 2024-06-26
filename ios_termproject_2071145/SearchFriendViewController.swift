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
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

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
        
        //
        searchBar.delegate = self
        searchFriendTableView.dataSource = self
        searchFriendTableView.delegate = self
        
        //
        usersDbFirebaseSet()
        usersFollowingDbFirebaseSet()
        
        print("viewDidLoad reload")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchFriendTableView.reloadData()
        print("viewDidAppear reload")
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
        let user = filteredUsers[indexPath.row]
        if appDelegate.id == user.id {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendyhg") as! SearchFriendTableViewCell //custom한 cell로 캐스팅
        
        ImagePool.image(name: user.imageName, size: CGSize(width: 85, height: 85), completion: {cell.profileImage.image = $0}) //프로필 이미지
        cell.name.text = user.name //유저 닉네임
        
        //팔로우 버튼 눌렀을때
        cell.followingButton.addTarget(self, action: #selector(followButtonTapped(_:)), for: .touchUpInside)
        cell.followingButton.tag = indexPath.row
        
        if following.contains(user.id) {
            cell.followingButton.backgroundColor = .gray
            cell.followingButton.setTitle("팔로잉", for: .normal)
        } else {
            cell.followingButton.backgroundColor = .systemYellow
            cell.followingButton.setTitle("팔로우", for: .normal)
        }
        
        return cell
    }
    
    @objc func followButtonTapped(_ sender: UIButton) {
        guard sender.tag < filteredUsers.count else { return }
        let user = filteredUsers[sender.tag]
        
        let followUser = Following(id: user.id, userId: user.userId) //변경할 내용이 있는 유저 정보
        
        let isFollowing = following.contains(user.id) //팔로우 하고 있는지 확인
        if !isFollowing { //팔로우하지 않은 상태라면
            usersFollowingDbFirebase?.saveChange(key: String(user.id), object: Following.toDict(following: followUser), action: .modify)
        }
        else { //팔로우 한 상태라면
            usersFollowingDbFirebase?.saveChange(key: String(user.id), object: Following.toDict(following: followUser), action: .delete)
        }
        
        
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
                
                // NotificationCenter를 통해 내 정보 컨트롤러에 알림을 보냄
                NotificationCenter.default.post(name: Notification.Name("FollowingUpdated"), object: nil)
                self.searchFriendTableView.reloadData()
            }
        }
    }
}
//tableView - delegate
extension SearchFriendViewController: UITableViewDelegate {
    //특정 row를 클릭하면 이 함수가 호출됨
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    //cell 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let user = filteredUsers[indexPath.row]
        if user.id == appDelegate.id {
            return 0
        } else {
            return 70
        }
    }
}

//searchBar - delegate
extension SearchFriendViewController: UISearchBarDelegate {
    
    //검색중일때
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색어에 따라 사용자 필터링
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            let text = searchText.lowercased()
            filteredUsers = users.filter { $0.name.lowercased().contains(text) }
        }
        
        // 테이블 뷰 업데이트
        searchFriendTableView.reloadData()
    }
}

//
extension SearchFriendViewController {
    //전체유저
    func usersDbFirebaseSet() {
        usersDbFirebase = UsersDbFirebase(parentNotification: manageUsersDatabase)
        usersDbFirebase?.setQuery(from: 1, to: 10000)
    }
    //팔로잉
    func usersFollowingDbFirebaseSet() {
        usersFollowingDbFirebase = UsersFollowingDbFirebase(parentNotification: manageFollowingDatabase)
        usersFollowingDbFirebase?.setQuery(from: 1, to: 10000)
    }
    
    
    //유저 데이터 불러오기
    func manageUsersDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let user = User.fromDict(dict: dict)
        
        if dbaction == .add {
            users.append(user)
            filteredUsers = users
            searchFriendTableView.reloadData()
        }
    }
    
    //팔로잉 데이터 불러오기
    func manageFollowingDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict else { return }
        let follow = Following.fromDict(dict: dict)
        
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
                
                self.searchFriendTableView.reloadData()
            }
        }
        
        if dbaction == .modify {
            following.append(follow.id)
        }
        
        if dbaction == .delete {
            if let index = following.firstIndex(of: follow.id) {
                following.remove(at: index)
            }
        }
    }
}
