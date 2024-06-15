//
//  LoginViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

//로그인 컨트롤러
class LoginViewController: UIViewController {
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate 공유
    
    var isShowKeyboard = false

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var signupViewController: SignupViewController? //회원가입 showToast 함수 이용하기 위해 참조
    var users: [User] = [] //파이어베이스에서 가져온 모든 유저 정보
    //var id: Int? //로그인한 유저 아이디 찾기 위함
    var stringId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //키보드 제스쳐
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
    }
    
    //로그인 button
    @IBAction func loginUser(_ sender: UIButton) {

        let userId = userIdTextField.text!
        let password = passwordTextField.text!
                
                
        
        // Firestore에서 유저 데이터 가져오기
        Firestore.firestore().collection("Users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.users.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let user = User.fromDict(dict: data)
                    self.users.append(user)
                    
                    
                    for i in 0..<self.users.count {
                        if(userId == self.users[i].userId && password == self.users[i].password) {
                            self.appDelegate.id = self.users[i].id
                            self.appDelegate.userId = self.users[i].userId
                            self.appDelegate.name = self.users[i].name
                            //self.appDelegate.account = self.users[i].account
                            
                            print("LoginViewController id : ", self.appDelegate.id, " userId : ", self.appDelegate.userId, " name : ", self.appDelegate.name, "\n")
                            return 
                        }
                    }
                }
            }
        }
        
        
        
        
        Auth.auth().signIn(withEmail: userId+"@hansung.ac.kr", password: password) {
            result, error in
            if let error = error {
                print(error.localizedDescription)
                self.signupViewController?.showToast(message: "아이디, 비밀번호를 확인하세요.")
                return
            }
        
            
            if let result = result {
                print("LoginViewController result : ", result, "users : ", self.users)
                self.performSegue(withIdentifier: "GotoHome", sender: nil)
            }
        }
    }
    
    //
    override func viewDidAppear(_ animated: Bool) {
        //키보드가 나타날때 실행 함수
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { Notification in
                
            //이 함수는 키보드가 나타날때 2번 연속으로 호출 될 수도 있음
            if self.isShowKeyboard == false {
                self.isShowKeyboard = true
                //self.stackViewTopConstraint.constant -= 250
                //self.stackViewBottomConstraint.constant -= 250
            }
        }
        
        //키보드가 사라질때 실행 함수
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { Notification in
            
            //스택뷰의 제약조건을 변경하여 아래로 250만큼 이동
            //self.stackViewTopConstraint.constant += 250
            //self.stackViewBottomConstraint.constant += 250
            self.isShowKeyboard = false
            
        }
    }
    //
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil) //keyboardWillShowNotification 등록해지
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil) //keyboardWillHideNotification 등록해지
    }
    //키보드 사라지게 하는 함수
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true) //view 하위에 있는 모든 view endEditing에서
    }
    
    
}


//화면 전환 - 로그인 성공시 메인 홈 화면
extension LoginViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //let searchFriendViewController = segue.destination as? SearchFriendViewController
    }
}
