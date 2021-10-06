//
//  Rule.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/04.
//

import Foundation
import Firebase

struct Rule {
    
    let mode: String
    let ruleName: String
    let genten: Int
    let kaeshiten: Int
    let zyuniten: String
    let createdAt: Timestamp
    
    init(dic: [String : Any]){
        self.mode = dic["mode"] as! String
        self.ruleName = dic["ruleName"] as! String
        self.genten = dic["genten"] as! Int
        self.kaeshiten = dic["kaeshiten"] as! Int
        self.zyuniten = dic["zyuniten"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
    }
}
