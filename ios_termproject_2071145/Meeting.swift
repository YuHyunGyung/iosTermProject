//
//  Meeting.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct Meeting: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var title: String
    var date: String
    
    
    init(id: Int, name: String, title: String, date: String) {
        self.id = id
        self.name = name
        self.title = title
        self.date = date
    }
}

extension Meeting{
    static func toDict(meeting: Meeting) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = meeting.id
        dict["name"] = meeting.name
        dict["title"] = meeting.title
        dict["date"] = meeting.date

        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> Meeting{
        
        let id = dict["id"] as! Int
        let name = dict["name"] as! String
        let title = dict["title"] as! String
        let date = dict["date"] as! String
        
        return Meeting(id: id, name: name, title: title, date: date)
    }
}

