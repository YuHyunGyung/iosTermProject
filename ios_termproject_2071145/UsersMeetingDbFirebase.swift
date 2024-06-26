import Foundation
import FirebaseFirestore

class UsersMeetingDbFirebase: Database {
    
    //데이터 저장할 위치 설정
    var reference: CollectionReference = Firestore.firestore().collection("Meetings")
    
    //데이터 변화가 생기면 알려주기 위한 클로즈
    var parentNotification: (([String: Any]?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration? //이미 설정한 Query의 존재여부
    
    required init(parentNotification: (([String: Any]?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification //클로저 보관
    }
    
    
    //
    func setQuery(from: Any, to: Any) {
        if let query = existQuery { //이미 쿼리가 있으면 삭제
            query.remove()
        }
        
        //새로운 쿼리 설정
        //원하는 필드, 원하는 데이터를 적절히 설정
        let query = reference.whereField("id", isGreaterThanOrEqualTo: 0).whereField("id", isLessThanOrEqualTo: 20000)
        existQuery = query.addSnapshotListener(onChangingData)
    }
    
    //
    func saveChange(key: String, object: [String: Any], action: DbAction) {
        //이런한 key에 대하여 add, delete, modify를 하라
        if action == .delete {
            reference.document(key).delete()
            return
        }
        
        //key에 대한 데이터가 이미 있으면 overwrite, 없으면 insert
        reference.document(key).setData(object)
    }
    
    //
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnapshot = querySnapshot else { return }
        
        //setQuery의 쿼리를 만족하는 데이터가 없는 경우 count가 0
        if(querySnapshot.documentChanges.count == 0) {
            return
        }
        
        //쿼리를 만족하는 데이터가 많은 경우 속도 문제로 한꺼번에 여러 데이터가 온다
        for documentChange in querySnapshot.documentChanges {
            
            let dict = documentChange.document.data()
            var action: DbAction?
            switch(documentChange.type) {
            case .added: action = .add
            case .modified: action = .modify
            case .removed: action = .delete
            }
            
            //부모에게 알림
            if let parentNotification = parentNotification { parentNotification(dict, action) }
        }
    }
}
