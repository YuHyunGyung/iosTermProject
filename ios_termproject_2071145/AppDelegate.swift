//
//  AppDelegate.swift
//  ios_termproject_2071145
//
//  Created by 유현경 on 6/12/24.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //firebase 연결
        FirebaseApp.configure()
        
        //firebase에 저장
        Firestore.firestore().collection("test").document("name").setData(["name":"yhg"])
        
        //storeage에 이미지 저장
        let image = UIImage(named: "Seoul")!
        let imageData = image.jpegData(compressionQuality: 1.0)
        let reference = Storage.storage().reference().child("test").child("Hansung")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        reference.putData(imageData!, metadata: metaData) { _ in }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

