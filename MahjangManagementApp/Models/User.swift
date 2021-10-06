//
//  User.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/09/29.
//

import Foundation
import Firebase

struct User {
    let name: String
    let createdAt: Timestamp
    let email: String
    
    init(dic: [String : Any]){
        self.name = dic["name"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
    }
}
