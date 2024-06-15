import Foundation
import SwiftUI
import CoreLocation

struct Meeting: Hashable, Codable, Identifiable {
    var id: Int //주최자 primary key
    var meetingId: Int //meeting primary key
    var name: String //주최자 이름
    var title: String //제목
    var date: String //약속 날짜
    var memo: String //메모
    var member:Array<Int> = Array<Int>() //모임 멤버
    var account: String //잔액
    
    
    
    init(id: Int, meetingId: Int, name: String, title: String, date: String, memo: String, member: Array<Int>, account: String) {
        self.id = id
        self.meetingId = meetingId
        self.name = name
        self.title = title
        self.date = date
        self.memo = memo
        self.member = member
        self.account = account
    }
}

extension Meeting{
    static func toDict(meeting: Meeting) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = meeting.id
        dict["meetingId"] = meeting.meetingId
        dict["name"] = meeting.name
        dict["title"] = meeting.title
        dict["date"] = meeting.date
        dict["memo"] = meeting.memo
        dict["member"] = meeting.member
        dict["account"] = meeting.account

        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> Meeting{
        
        let id = dict["id"] as! Int
        let meetingId = dict["meetingId"] as! Int
        let name = dict["name"] as! String
        let title = dict["title"] as! String
        let date = dict["date"] as! String
        let memo = dict["memo"] as! String
        let member = dict["member"] as! Array<Int>
        let account = dict["account"] as! String
        
        return Meeting(id: id, meetingId: meetingId, name: name, title: title, date: date, memo: memo, member: member, account: account)
    }
}

