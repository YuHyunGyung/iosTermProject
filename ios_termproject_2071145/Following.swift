import Foundation
import SwiftUI
import CoreLocation

struct Following: Hashable, Codable, Identifiable {
    var id: Int
    var userId: String
    
    init(id: Int, userId: String) {
        self.id = id
        self.userId = userId
    }
}

extension Following{
    static func toDict(following: Following) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = following.id
        dict["userId"] = following.userId
        
        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> Following{
        let id = dict["id"] as! Int
        let userId = dict["userId"] as! String
        
        return Following(id: id, userId: userId)
    }
}
