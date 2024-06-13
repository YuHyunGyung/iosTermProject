//
//  User.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/13/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct User: Hashable, Codable, Identifiable {
    static var imagePool: [String: UIImage] = [:]
    var id: Int
    var userId: String
    var password: String
    var name: String
    var imageName: String
    
    init(id: Int, userId: String, password: String, name: String, imageName: String) {
        self.id = id
        self.userId = userId
        self.password = password
        self.name = name
        self.imageName = imageName
    }
    
    func uiImage(size: CGSize? = nil, completion: @escaping (UIImage) -> Void) -> Void{

        var image = User.imagePool[imageName]
        if image == nil{
            image = UIImage(named: imageName)!
        }
        if image != nil{
            guard let size = size else{
                completion(image!)
                return
            }
            let resizedImage = image!.resized(to: size)
            User.imagePool[name] = resizedImage
            completion(resizedImage)
            return
        }

//        DbFirebase.downloadImage(imageName: imageName){ image in
//
//            let resizedImage = image!.resized(to: size!)
//            City.imagePool[name] = resizedImage
//            completion(resizedImage)
//
//        }


    }

    var image: Image {
        Image(imageName)
    }
}

extension User{
    static func toDict(user: User) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = user.id
        dict["userId"] = user.userId
        dict["password"] = user.password
        dict["name"] = user.name
        dict["imageName"] = user.imageName
        dict["datetime"] = Date().timeIntervalSince1970

        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> User{
        
        let id = dict["id"] as! Int
        let userId = dict["userId"] as! String
        let password = dict["password"] as! String
        let name = dict["name"] as! String
        let imageName = dict["imageName"] as! String

        return User(id: id, userId: userId, password: password, name: name, imageName: imageName)
    }
}
