//
//  LoginViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/09/29.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func tappedDontHaveAccountButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
        // print("Tapped!")
        HUD.show(.progress, onView: view)
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                
                var errorMsg = String()
                
                switch err.code {
                
                case 17008:
                    errorMsg = "メールアドレスの形式が不正です。メールアドレスを確認してください。"
                    
                case 17009:
                    errorMsg = "パスワードが間違っています。再度確認してください。"
                    
                case 17011:
                    errorMsg = "このメールアドレスで登録されたアカウントがありません。"
                    
                default:
                    errorMsg = "不明なエラーです。開発者に連絡してください。エラーコード：\(String(err.code))"
                }
                
                self.present(.errorAlert(errorMsg: errorMsg) { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    return
                })
                
                print("認証情報の保存に失敗しました。\(err)")
                
            }
            
            print("ログイン情報の取得に成功しました。")
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let userRef = Firestore.firestore().collection("users").document(uid)
            userRef.getDocument { (snapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました。\(err)")
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                let user = User.init(dic: data)
                
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                        self.presentToHomeViewController(user: user)
                    }
                }
            }
        }
    }
    
    private func presentToHomeViewController(user: User) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.user = user
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.rgb(red: 141, green: 171, blue: 197)
        
        loginButton.layer.cornerRadius = 10
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 141, green: 171, blue: 197)
        } else {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 0, green: 45, blue: 95)
        }
    }
}
