//
//  HomeViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/09/29.
//

import UIKit
import Firebase
import PKHUD

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //PickerViewの設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ruleData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ruleData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        ruleID = ruleIDData[row]
        ruleTextField.text = ruleData[row]
    }
    
    var user: User? {
        didSet {
        }
    }
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var modeSelectSwitch: UISegmentedControl!
    @IBOutlet weak var ruleTextField: UITextField!
    @IBOutlet weak var rankingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var scoreTextField: UITextField!
    @IBOutlet weak var addResultButton: UIButton!
    
    //追加ボタンを押した時の処理
    @IBAction func tappedAddResultButton(_ sender: Any) {
        addResultToFirestore()
    }
    
    //フッターボタンの設定
    
    @IBOutlet weak var tappedToHomeButton: UIButton!
    
    @IBAction func tappedHistoryButton(_ sender: Any) {
        presentToHistoryViewController()
    }
    
    @IBAction func tappedAddRuleButton(_ sender: Any) {
        presentToAddRuleViewController()
    }
    
    @IBAction func tappedAnalyticsButton(_ sender: Any) {
        presentToAnalyticsViewController()
    }
    
    
    //グローバル変数
    var mode = String()
    var ranking = Int()
    var ruleID = String()
    
    var pickerView = UIPickerView()
    
    //標準ルールの設定
    var ruleData = [String]()
    var ruleIDData = [String]()
    
    
    //ログアウトボタンを押した場合の処理
    @IBAction func tappedLogoutButton(_ sender: Any) {
        handleLogout()
    }
    
    //ログアウトのための関数
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            presentToSignUpViewController()
        } catch (let err) {
            print("ログアウトに失敗しました。\(err)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tappedToHomeButton.isEnabled = false
        tappedToHomeButton.setTitleColor(.gray, for: .normal)
        tappedToHomeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        addResultButton.isEnabled = false
        addResultButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        
        addResultButton.layer.cornerRadius = 10
        logoutButton.layer.cornerRadius = 10
        
        scoreTextField.delegate = self
        
        modeSelectSwitch.addTarget(self, action: #selector(modeSegmentChanged(_:)), for: UIControl.Event.valueChanged)
        rankingSegmentedControl.addTarget(self, action: #selector(rankingSegmentChanged(_:)), for: UIControl.Event.valueChanged)
        
        loadRules()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        createPickerView()
        
        mode = "4"
        ranking = 1
        
        if let user = user {
            userNameLabel.text = user.name + "さん"
        } else {
            
            guard let uid = Auth.auth().currentUser?.uid else {
                print("エラー：ユーザ情報を取得できません。")
                return
            }
            
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { [self] (snapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                let user: User = User.init(dic: data)
                
                userNameLabel.text = user.name + "さん"
            }
        }
    }
    
    private func loadRules() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("mahjang").document("rules").collection(uid).order(by: "createdAt").getDocuments { (snapShots, err) in
            
            if let err = err {
                print("Firestoreからのデータの取得に失敗しました。\(err)")
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
            }
            
            snapShots?.documents.forEach({ (snapShot) in
                let dic = snapShot.data()
                let rule = Rule.init(dic: dic)
                
                let ruleName: String = rule.ruleName
                let ruleID: String = snapShot.documentID
                                
                self.ruleData.append(ruleName)
                self.ruleIDData.append(ruleID)                
            })
        }
    }
    
    func createPickerView() {
        pickerView.delegate = self
        ruleTextField.inputView = pickerView
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        ruleTextField.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        ruleTextField.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ruleTextField.endEditing(true)
    }
    
    @objc func modeSegmentChanged(_ segment:UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            mode = "4"
            print("4麻を選択しました。")
            
            let rankList = ["1着", "2着", "3着", "4着"]
            rankingSegmentedControl.changeAllSegmentWithArray(arr: rankList)
            
        case 1:
            mode = "3"
            print("3麻を選択しました。")
            
            let rankList = ["1着", "2着", "3着"]
            rankingSegmentedControl.changeAllSegmentWithArray(arr: rankList)
            
        default:
            break
        }
    }
    
    @objc func rankingSegmentChanged(_ segment:UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            ranking = 1
            print("1着を選択しました。")
        case 1:
            ranking = 2
            print("2着を選択しました。")
        case 2:
            ranking = 3
            print("3着を選択しました。")
        case 3:
            ranking = 4
            print("4着を選択しました。")
        default:
            break
        }
    }
    
    //Firestoreにデータを追加
    private func addResultToFirestore() {
                
        guard let rule = self.ruleTextField.text else { return }
        guard let score: Int = Int(self.scoreTextField.text!) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let date = Timestamp()
        
        let docData = ["date": date, "mode": mode, "rule": rule, "ruleID": ruleID, "ranking": ranking, "score": score] as [String : Any]
        
        let resultRef = Firestore.firestore().collection("mahjang").document("results").collection(uid)
        
        
        resultRef.addDocument(data: docData) { (err) in
            if let err = err {
                print("Firestoreへの保存に失敗しました。\(err)")
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
            }
            
            HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                print("Firestoreへの保存に成功しました。")
                
                self.scoreTextField.text = ""
                self.rankingSegmentedControl.selectedSegmentIndex = 0
                
            }
        }
    }
    
    private func presentToSignUpViewController() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    private func clearTextField() {
        
        rankingSegmentedControl.selectedSegmentIndex = 0
        scoreTextField.text = ""
    }
    
    private func presentToHistoryViewController() {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        let historyViewController = storyboard.instantiateViewController(identifier: "HistoryViewController") as! HistoryViewController
        historyViewController.modalPresentationStyle = .fullScreen
        self.present(historyViewController, animated: false, completion: nil)
    }
    
    private func presentToAddRuleViewController() {
        let storyboard = UIStoryboard(name: "AddRule", bundle: nil)
        let addRuleViewController = storyboard.instantiateViewController(identifier: "AddRuleViewController") as! AddRuleViewController
        addRuleViewController.modalPresentationStyle = .fullScreen
        self.present(addRuleViewController, animated: false, completion: nil)
    }
    
    private func presentToAnalyticsViewController() {
        let storyboard = UIStoryboard(name: "Analytics", bundle: nil)
        let analyticsViewController = storyboard.instantiateViewController(identifier: "AnalyticsViewController") as! AnalyticsViewController
        analyticsViewController.modalPresentationStyle = .fullScreen
        self.present(analyticsViewController, animated: false, completion: nil)
    }
    
    
}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let ruleIsEmpty = ruleTextField.text?.isEmpty ?? true
        let scoreIsEmpty = scoreTextField.text?.isEmpty ?? true
        
        if scoreIsEmpty || ruleIsEmpty {
            addResultButton.isEnabled = false
            addResultButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            addResultButton.isEnabled = true
            addResultButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
        
    }
}

extension UISegmentedControl {
    func changeAllSegmentWithArray(arr: [String]){
        self.removeAllSegments()
        for str in arr {
            self.insertSegment(withTitle: str, at: self.numberOfSegments, animated: false)
        }
        self.selectedSegmentIndex = 0
    }
}
