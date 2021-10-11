//
//  EditResultViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/11.
//

import UIKit


class EditResultViewController: UIViewController {
    
    var resultID: String? {
        didSet {
             print("resultID: ", resultID!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
}
