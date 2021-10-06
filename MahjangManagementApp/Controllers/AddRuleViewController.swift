//
//  AddRuleViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/01.
//

import UIKit
import SnapKit
import PKHUD
import Firebase
import FirebaseAuth

class AddRuleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return zyunitenData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return zyunitenData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
                case 0:
                    umaString = zyunitenData[0][row]
                case 1:
                    okaString = zyunitenData[1][row]
                default:
                    break
                }
        
        zyunitenString = umaString + "  /  " + okaString
        
        print("->", zyunitenString)
        zyunitenTextField.text = zyunitenString
    }
    
    let zyunitenData = [["順位点(ウマ)", "無し", "5-10", "10-20", "10-30", "0-10", "0-20"],
                ["オカ", "無し", "5(トップ+20)"]]
    
    var pickerView2 = UIPickerView()
    
    var mode = String()
    
    var umaString = String()
    var okaString = String()
    var zyunitenString = String()
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ruleNameTextField.delegate = self
        gentenTextField.delegate = self
        kaeshitenTextField.delegate = self
        zyunitenTextField.delegate = self
        
        
        addRuleButton.isEnabled = false
        addRuleButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        addRuleButton.layer.cornerRadius = 10
        
        pickerView2.delegate = self
        pickerView2.dataSource = self
        createPickerView()
        
        mode = "4"
        modeSelectSegmentedControl.addTarget(self, action: #selector(modeSegmentChanged(_:)), for: UIControl.Event.valueChanged)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        zyunitenTextField.endEditing(true)
    }
    
    @IBAction func tappedAddRuleButton(_ sender: Any) {
        
        guard let zyunitenText = zyunitenTextField.text else { return }
        
        if zyunitenText.contains("順位点(ウマ)") || zyunitenText.contains("オカ") {
            print("選択エラー：タイトルを選択しないでください。")
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
                print("Firestoreへの保存に失敗しました。\(err)")
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
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
    
    private func presentToHomeViewController() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    private func presentToHistoryViewController() {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        let historyViewController = storyboard.instantiateViewController(identifier: "HistoryViewController") as! HistoryViewController
        historyViewController.modalPresentationStyle = .fullScreen
        self.present(historyViewController, animated: true, completion: nil)
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
            addRuleButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            addRuleButton.isEnabled = true
            addRuleButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
        
    }
}
