//
//  ViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/09/27.
//

import UIKit
import Firebase
import PKHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        handleAuthToFirebase()
        // print("TAPPED!")
    }
    
    @IBAction func tappedAlreadyHaveAccountButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setUpViews() {
        registerButton.isEnabled = false
        registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        
        registerButton.layer.cornerRadius = 10
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func handleAuthToFirebase() {
        
        HUD.show(.progress, onView: view)
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] (res, err) in
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                return
            }
            
            // print("認証情報の保存に成功しました。")
            
            self.addUserInfoToFirestore(email: email)
        }
    }
    
    //Firestoreにユーザー情報を保存
    private func addUserInfoToFirestore(email: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let name = self.userNameTextField.text else { return }
        
        let docData = ["email": email, "name": name, "createdAt": Timestamp()] as [String : Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.setData(docData) { (err) in
            if let err = err {
                print("Firestoreへの保存に失敗しました。\(err)")
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
            }
            
            // print("Firestoreへの保存に成功しました。")
            
            self.fetchUserInfoFromFirestore(userRef: userRef)
        }
    }
    
    //Firestoreからユーザー情報を取得
    private func fetchUserInfoFromFirestore(userRef: DocumentReference) {
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
            // print("ユーザー情報の取得に成功しました。\(user.name)")
            
            self.addDefaultRuleToFirestore()
            
            HUD.hide { (_) in
                HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                    self.presentToHomeViewController(user: user)
                }
            }
        }
    }
    
    //初期対局ルールを追加するための関数
    private func addDefaultRuleToFirestore() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docData = [["mode": "4", "ruleName": "5-10", "genten": 250, "kaeshiten": 250, "zyuniten": "5-10", "createdAt": Timestamp()],
                       ["mode": "4", "ruleName": "10-20", "genten": 250, "kaeshiten": 250, "zyuniten": "10-20", "createdAt": Timestamp()],
                       ["mode": "4", "ruleName": "10-30", "genten": 250, "kaeshiten": 250, "zyuniten": "10-30", "createdAt": Timestamp()],
                       ["mode": "4", "ruleName": "Mリーグルール", "genten": 250, "kaeshiten": 300, "zyuniten": "10-30", "createdAt": Timestamp()]] as [[String : Any]]
        
        let ruleRef = Firestore.firestore().collection("mahjang").document("rules").collection(uid)
        
        for i in 0..<4 {
                        
            ruleRef.addDocument(data: docData[i]) { (err) in
                if let err = err {
                    print("Firestoreへの保存に失敗しました。\(err)")
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    return
                }
            }            
        }
    }
    
    //画面遷移のための関数
    private func presentToHomeViewController(user: User) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.user = user
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    
    @objc func showKeyboard(notification: Notification) {
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else { return }
        let registerButtonMaxY = registerButton.frame.maxY
        
        let distance = registerButtonMaxY - keyboardMinY + 20
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
    }
    
    @objc func hideKeyboard() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let userNameIsEmpty = userNameTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty || userNameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
}
