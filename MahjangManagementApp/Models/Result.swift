//
//  Result.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/01.
//

import Foundation
import Firebase

struct Result {
    
    let date: Timestamp
    let mode: String
    let rule: String
    let ruleID: String
    let ranking: Int
    let score: Int
    let point: Float
    
    init(dic: [String : Any]){
        self.date = dic["date"] as! Timestamp
        self.mode = dic["mode"] as! String
        self.rule = dic["rule"] as! String
        self.ruleID = dic["ruleID"] as! String
        self.ranking = dic["ranking"] as! Int
        self.score = dic["score"] as! Int
        self.point = dic["point"] as! Float
    }
}
