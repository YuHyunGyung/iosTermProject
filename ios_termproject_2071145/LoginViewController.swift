//
//  LoginViewController.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/12/24.
//

import UIKit


//로그인 컨트롤러
class LoginViewController: UIViewController {
    var isShowKeyboard = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //키보드 제스쳐
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
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
