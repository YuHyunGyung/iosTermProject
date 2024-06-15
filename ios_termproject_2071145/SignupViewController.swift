//
//  SignupViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/12/24.
//

import UIKit
import FirebaseAuth


//회원가입
class SignupViewController: UIViewController {
    var isShowKeyboard = false
    
    var usersDbFirebase: UsersDbFirebase?
    var users: [User] = []
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var profileImage = UIImage(named: "default_profile")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //profileImage = UIImage(named: "default_profile")! //기본 프로필 이미지 설정
        usersDbFirebase = UsersDbFirebase(parentNotification: manageDatabase)
        usersDbFirebase?.setQuery(from: 1, to: 10000)
        
        
        //키보드 제스쳐
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
    }
    
    //회원가입하기 button
    @IBAction func signupUser(_ sender: UIButton) {
        guard let userIdText = userIdTextField.text, let passwordText = passwordTextField.text, let nameText = nameTextField.text,
              userIdText.isEmpty == false || passwordText.isEmpty == false || nameText.isEmpty == false else { return }
        
        
        var id = users.count + 1001 //중복 검사할 아이디 설정
        let userId = userIdText
        let password = passwordText
        let name = nameText
        let imageName = String(id)
        let account = 0
        var user = User(id: id, userId: userId, password: password, name: name, imageName: imageName, account: account)
        
        for i in 0..<users.count {
            if userId == users[i].userId {
                id = users[i].id
                self.showToast(message: "이미 존재하는 회원입니다!")
                print("signupUser users: ", users)
                return
            }
        }
        
        ImagePool.putImage(name: imageName, image: UIImage(named: "default_profile"))
        UsersDbFirebase.uploadImage(imageName: imageName, image: UIImage(named: "default_profile")) {
            //신규삽입
            //users.append(user)
            Auth.auth().createUser(withEmail: userId+"@hansung.ac.kr", password: password) {
                result, error in
                if let error = error {
                    print(error)
                }
                if let result = result {
                    print(result)
                }
            }
            self.usersDbFirebase?.saveChange(key: String(id), object: User.toDict(user: user), action: .add)
            
            //profileImage = ImagePool.image(name: imageName)
            //modifyUser(usersDbFirebase: usersDbFirebase, user: user)
            
            self.showToast(message: "회원가입을 완료하였습니다!")
            self.performSegue(withIdentifier: "GotoLogin", sender: nil)
        }
    }
    
    
    //신규 데이터 '삽입'으로 생성된 데이터 불러오기
    func manageDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        let user = User.fromDict(dict: dict!)
        
        if dbaction == .add {
            users.append(user)
            return
        }
        
        for i in 0..<users.count {
            if user.id == users[i].id { //이미 있으면 그냥 그대로 두기
                if dbaction == .modify {
                    print("manageDatabase users : ", users)
                }
                return
            }
        }
    }
    
    
    
    
    //
    override func viewDidAppear(_ animated: Bool) {
        //키보드가 나타날때 실행 함수
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { Notification in
                
            if self.isShowKeyboard == false { //이 함수는 키보드가 나타날때 2번 연속으로 호출 될 수도 있음
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
    
    //toast - 회원 계정이 이미 있는 경우 toast 메세지 함수
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel() //UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        let maxSize = CGSize(width: self.view.frame.size.width - 40, height: CGFloat.greatestFiniteMagnitude)
        let expectedSize = toastLabel.sizeThatFits(maxSize)
        
        toastLabel.frame = CGRect(x: (self.view.frame.size.width - expectedSize.width - 20) / 2,
                                  y: self.view.frame.size.height - 100,
                                  width: expectedSize.width + 20,
                                  height: expectedSize.height + 10)
    
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

//화면 전환 - 회원가입 성공시 로그인 화면
extension SignupViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let loginViewController = segue.destination as? LoginViewController //전이 하고자 하는 뷰 컨트롤러
        loginViewController!.signupViewController = self
    }
}
