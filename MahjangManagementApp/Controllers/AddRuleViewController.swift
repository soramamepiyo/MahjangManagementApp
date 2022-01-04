//
//  AddRuleViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/01.
//

import UIKit
import PKHUD
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AddRuleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return zyunitenData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return zyunitenData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        zyunitenString = zyunitenData[row]
        zyunitenTextField.font = UIFont.systemFont(ofSize: 17)
        zyunitenTextField.text = zyunitenString
    }
    
    let zyunitenData = ["順位点(ウマ)", "無し", "5-10", "10-20", "10-30", "0-10", "0-20"]
    
    var pickerView2 = UIPickerView()
    
    var mode = String()
    
    let maxLength: Int = 12
    
    var umaString = String()
    var okaString = String()
    var zyunitenString = String()
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var modeSelectSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ruleNameTextField: UITextField!
    @IBOutlet weak var gentenTextField: UITextField!
    @IBOutlet weak var kaeshitenTextField: UITextField!
    @IBOutlet weak var zyunitenTextField: UITextField!
    
    @IBOutlet weak var addRuleButton: UIButton!
    
    @IBAction func tappedAddResultButton(_ sender: Any) {
        presentToHomeViewController()
    }
    
    @IBAction func tappedHistoryButton(_ sender: Any) {
        presentToHistoryViewController()
    }
    
    @IBOutlet weak var tappedToAddRuleButton: UIButton!
    
    @IBAction func tappedToAnalyticsButton(_ sender: Any) {
        presentToAnalyticsViewController()
    }
    
    @IBAction func tappedToRuleListButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "RuleList", bundle: nil)
        let ruleListViewController = storyboard.instantiateViewController(identifier: "RuleListViewController") as! RuleListViewController
        self.present(ruleListViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tappedToAddRuleButton.isEnabled = false
        tappedToAddRuleButton.setTitleColor(UIColor.rgb(red: 0, green: 45, blue: 95), for: .normal)
        tappedToAddRuleButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        ruleNameTextField.delegate = self
        gentenTextField.delegate = self
        kaeshitenTextField.delegate = self
        zyunitenTextField.delegate = self
        
        
        addRuleButton.isEnabled = false
        addRuleButton.backgroundColor = UIColor.rgb(red: 141, green: 171, blue: 197)
        addRuleButton.layer.cornerRadius = 10
        
        pickerView2.delegate = self
        pickerView2.dataSource = self
        createPickerView()
        
        mode = "4"
        modeSelectSegmentedControl.addTarget(self, action: #selector(modeSegmentChanged(_:)), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //ユーザー名を表示させる処理
        guard let uid = Auth.auth().currentUser?.uid else {
            self.present(.errorAlert(errorMsg: "ユーザIDが取得できません。　エラーコード:DEV024") { _ in
                return
            })
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { [self] (snapshot, err) in
            if let err = err {
                self.present(.errorAlert(errorMsg: "ユーザー情報の取得に失敗しました。\(err)　エラーコード:DEV025") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            guard let data = snapshot?.data() else { return }
            let user: User = User.init(dic: data)
            
            userNameLabel.text = user.name + "さん"
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textFieldDidChange(notification:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: ruleNameTextField)
        
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // 入力チェック(文字数チェック)処理
        @objc func textFieldDidChange(notification: NSNotification) {
            let textField = notification.object as! UITextField

            if let text = textField.text {
                if textField.markedTextRange == nil && text.count > maxLength {
                    textField.text = text.prefix(maxLength).description
                }
            }
        }
    
    func createPickerView() {
        
        pickerView2.delegate = self
        zyunitenTextField.inputView = pickerView2
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        zyunitenTextField.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        zyunitenTextField.endEditing(true)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        zyunitenTextField.endEditing(true)
//    }
    
    @IBAction func tappedAddRuleButton(_ sender: Any) {
        
        guard let zyunitenText = zyunitenTextField.text else { return }
        
        if zyunitenText.contains("順位点(ウマ)") || zyunitenText.contains("オカ") {
            self.present(.errorAlert(errorMsg: "選択エラー：タイトルを選択しないでください。") { _ in
            })
        } else {
            addRuleToFirestore()
            clearTextField()
        }
    }
    
    @objc func modeSegmentChanged(_ segment:UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            mode = "4"
            print("4麻を選択しました。")
        case 1:
            mode = "3"
            print("3麻を選択しました。")
        default:
            break
        }
    }
    
    private func addRuleToFirestore() {
        
        guard let ruleName = self.ruleNameTextField.text else { return }
        guard let genten: Int = Int(self.gentenTextField.text!) else { return }
        guard let kaeshiten: Int = Int(self.kaeshitenTextField.text!) else { return }
        guard let zyuniten = self.zyunitenTextField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let date = Timestamp()
        
        let docData = ["mode": mode, "ruleName": ruleName, "genten": genten, "kaeshiten": kaeshiten, "zyuniten": zyuniten, "createdAt": date] as [String : Any]
        
        let ruleRef = Firestore.firestore().collection("mahjang").document("rules").collection(uid)
        
        
        ruleRef.addDocument(data: docData) { (err) in
            if let err = err {
                
                self.present(.errorAlert(errorMsg: "Firestoreへの保存に失敗しました。\(err)　エラーコード:DEV026") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                print("Firestoreへの保存に成功しました。")
            }
        }
    }
        
    private func clearTextField() {
        ruleNameTextField.text = ""
        gentenTextField.text = ""
        kaeshitenTextField.text = ""
        zyunitenTextField.text = ""
    }
    
    @objc func showKeyboard(notification: Notification) {
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else { return }
        let addRuleButtonMaxY = addRuleButton.frame.maxY
        
        let distance = addRuleButtonMaxY - keyboardMinY + 20
        
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
    
    private func presentToHomeViewController() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: false, completion: nil)
    }
    
    private func presentToHistoryViewController() {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        let historyViewController = storyboard.instantiateViewController(identifier: "HistoryViewController") as! HistoryViewController
        historyViewController.modalPresentationStyle = .fullScreen
        self.present(historyViewController, animated: false, completion: nil)
    }
    
    private func presentToAnalyticsViewController() {
        let storyboard = UIStoryboard(name: "Analytics", bundle: nil)
        let analyticsViewController = storyboard.instantiateViewController(identifier: "AnalyticsViewController") as! AnalyticsViewController
        analyticsViewController.modalPresentationStyle = .fullScreen
        self.present(analyticsViewController, animated: false, completion: nil)
    }
    
}

extension AddRuleViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let ruleNameIsEmpty = ruleNameTextField.text?.isEmpty ?? true
        let gentenIsEmpty = gentenTextField.text?.isEmpty ?? true
        let kaeshitenIsEmpty = kaeshitenTextField.text?.isEmpty ?? true
        let zyunitenIsEmpty = zyunitenTextField.text?.isEmpty ?? true
        
        if ruleNameIsEmpty || gentenIsEmpty || kaeshitenIsEmpty || zyunitenIsEmpty {
            addRuleButton.isEnabled = false
            addRuleButton.backgroundColor = UIColor.rgb(red: 141, green: 171, blue: 197)
        } else {
            addRuleButton.isEnabled = true
            addRuleButton.backgroundColor = UIColor.rgb(red: 23, green: 96, blue: 161)
        }
        
    }
}
