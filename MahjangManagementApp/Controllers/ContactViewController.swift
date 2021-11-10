//
//  ContactViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/11/05.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class ContactViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func tappedSendButton(_ sender: Any) {
        tappedSendButton()
    }
    
    var uid: String = ""
    var mailAdress: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.layer.cornerRadius = 10
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            self.present(.errorAlert(errorMsg: "ユーザIDの取得に失敗しました。エラーコード:DEV047") { _ in
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
            })
            
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { [self] (snapshot, err) in
            if let err = err {
                
                self.present(.errorAlert(errorMsg: "ユーザ情報の取得に失敗しました。\(err)　エラーコード:DEV048") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            guard let data = snapshot?.data() else { return }
            let user: User = User.init(dic: data)
            
            userNameLabel.text = user.name + "さん"
            
            self.uid = uid
            self.mailAdress = user.email
        }
    
    }
    
    private func tappedSendButton() {
        
        let comment = commentTextView.text
        
        if comment == "" {
            //空白エラー
            
            return
        }
        
        let date = Timestamp()
        
        let docData = ["date": date, "uid": uid, "comment": comment, "email": mailAdress] as [String : Any]
        
        let resultRef = Firestore.firestore().collection("mahjang").document("comments").collection(uid)
        
        resultRef.addDocument(data: docData) { (err) in
            
            if let err = err {
                self.present(.errorAlert(errorMsg: "お問い合わせの送信に失敗しました。\(err) エラーコード:DEV049") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
        
            }
            
            HUD.flash(.success, onView: self.view, delay: 1) { (_) in
//                    print("Firestoreへの保存に成功しました。")
//                    print(docData)
                
                self.commentTextView.text = ""
                
            }
        }
    }
    
}

