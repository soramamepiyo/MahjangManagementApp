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
                print("ログイン情報の取得に失敗しました。\(err)")
                return
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
