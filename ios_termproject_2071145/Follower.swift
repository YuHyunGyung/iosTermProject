import Foundation
import SwiftUI
import CoreLocation

struct Follower: Hashable, Codable, Identifiable {
    var id: Int
    
    
    init(id: Int) {
        self.id = id
    }
}

extension Follower{
    static func toDict(follower: Follower) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = follower.id
        
        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> Follower{
        let id = dict["id"] as! Int
        
        return Follower(id: id)
    }
}
