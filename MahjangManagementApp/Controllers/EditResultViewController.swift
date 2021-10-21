//
//  EditResultViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/13.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class EditResultViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        print(pickerView)
        
        if pickerView == datePickerView {
            return 5
        } else if pickerView == rulePickerView {
            return 1
        } else {
            print("PickerViewエラーです。")
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == datePickerView {
            
            switch component {
            case 0:
                return yearList.count
            case 1:
                return monthList.count
            case 2:
                return dayList.count
            case 3:
                return hourList.count
            case 4:
                return minuteList.count
            default:
                return 0
            }
            
        } else if pickerView == rulePickerView {
            return ruleData.count
        } else {
            print("PickerViewエラーです。")
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == datePickerView {
            
            switch component {
            case 0:
                return String(yearList[row])
            case 1:
                return String(monthList[row])
            case 2:
                return String(dayList[row])
            case 3:
                return String(hourList[row])
            case 4:
                return String(minuteList[row])
            default:
                return nil
            }
        } else {
            return ruleData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView == datePickerView {
            
            switch component {
            case 0:
                return 100
            case 1:
                return 68
            case 2:
                return 70
            case 3:
                return 72
            case 4:
                return 72
            default:
                return 0
            }
        } else {
            return 200
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView {
            
            switch component {
            case 0:
                let yearStr = yearList[row]
                year = Int(yearStr.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined())!
                print("year = \(year) updated!")
                
            case 1:
                let monthStr = monthList[row]
                month = Int(monthStr.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined())!
                print("month = \(month) updated!")
                
            case 2:
                let dayStr = dayList[row]
                day = Int(dayStr.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined())!
                print("day = \(day) updated!")
                
            case 3:
                let hourStr = hourList[row]
                hour = Int(hourStr.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined())!
                print("hour = \(hour) updated!")
                
            case 4:
                let minuteStr = minuteList[row]
                minute = Int(minuteStr.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined())!
                print("minute = \(minute) updated!")
                
            default: break
                
            }
            
            changeDateTextField()
        } else {
           
            rule = ruleData[row]
            ruleID = ruleIDData[row]
            
            self.ruleTextField.text = rule
            
            print("ルール: \(rule)が選択されました。")
            
        }
    }
    
    var resultID: String? {
        didSet {
            print("resultID: ", resultID!)
        }
    }
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var ruleTextField: UITextField!
    @IBOutlet weak var rankingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var scoreTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBAction func tappedUpdateButton(_ sender: Any) {
        updateResult()
    }
    @IBAction func tappedBackToHistoryButton(_ sender: Any) {
        presentToHistoryViewController()
    }
    
    //グローバル変数の宣言
    var datePickerView = UIPickerView()
    var rulePickerView = UIPickerView()
    
    var ruleData = [String]()
    var ruleIDData = [String]()
    
    var rule: String = ""
    var ruleID: String = ""
    
    var ranking: Int = 0
    
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var hour: Int = 0
    var minute: Int = 0
    
    var mode: String = ""
    
    var pointGlo :Float = 0
    
    let yearList = ["2000年", "2001年", "2002年", "2003年", "2004年", "2005年", "2006年", "2007年", "2008年", "2009年",
                    "2010年", "2011年", "2012年", "2013年", "2014年", "2015年", "2016年", "2017年", "2018年", "2019年",
                    "2020年", "2021年", "2022年", "2023年", "2024年", "2025年", "2026年", "2027年", "2028年", "2029年",
                    "2030年", "2031年", "2032年", "2033年", "2034年", "2035年", "2036年", "2037年", "2038年", "2039年",
                    "2040年", "2041年", "2042年", "2043年", "2044年", "2045年", "2046年", "2047年", "2048年", "2049年",
                    "2050年", "2051年", "2052年", "2053年", "2054年", "2055年", "2056年", "2057年", "2058年", "2059年",
                    "2060年", "2061年", "2062年", "2063年", "2064年", "2065年", "2066年", "2067年", "2068年", "2069年",
                    "2070年", "2071年", "2072年", "2073年", "2074年", "2075年", "2076年", "2077年", "2078年", "2079年",
                    "2080年", "2081年", "2082年", "2083年", "2084年", "2085年", "2086年", "2087年", "2088年", "2089年",
                    "2090年", "2091年", "2092年", "2093年", "2094年", "2095年", "2096年", "2097年", "2098年", "2099年"]
    
    let monthList = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    let dayList = ["1日", "2日", "3日", "4日", "5日", "6日", "7日", "8日", "9日", "10日",
                   "11日", "12日", "13日", "14日", "15日", "16日", "17日", "18日", "19日", "20日",
                   "21日", "22日", "23日", "24日", "25日", "26日", "27日", "28日", "29日", "30日",
                   "31日"]
    
    let hourList = ["0時", "1時", "2時", "3時", "4時", "5時", "6時", "7時", "8時", "9時",
                    "10時", "11時", "12時", "13時", "14時", "15時", "16時", "17時", "18時", "19時",
                    "20時", "21時", "22時", "23時"]
    
    let minuteList = ["0分", "1分", "2分", "3分", "4分", "5分", "6分", "7分", "8分", "9分",
                      "10分", "11分", "12分", "13分", "14分", "15分", "16分", "17分", "18分", "19分",
                      "20分", "21分", "22分", "23分", "24分", "25分", "26分", "27分", "28分", "29分",
                      "30分", "31分", "32分", "33分", "34分", "35分", "36分", "37分", "38分", "39分",
                      "40分", "41分", "42分", "43分", "44分", "45分", "46分", "47分", "48分", "49分",
                      "50分", "51分", "52分", "53分", "54分", "55分", "56分", "57分", "58分", "59分"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.layer.cornerRadius = 10
        
        scoreTextField.delegate = self
        
        datePickerView.delegate = self
        datePickerView.dataSource = self
        rulePickerView.delegate = self
        rulePickerView.dataSource = self
        
        loadRules()
        
        createPickerView()
        
        if let resultID = resultID {
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Firestore.firestore().collection("mahjang").document("results").collection(uid).document(resultID).addSnapshotListener { (snapShot, err) in
                if let err = err {
                    print("Firestoreからの対局結果データの取得に失敗しました。\(err)")
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                }
                
                let dic = snapShot?.data()
                let result = Result.init(dic: dic!)
                
//                print(result)
                
                let dateString = self.getJPTimeString(date: result.date.dateValue())
                
                self.dateStringTodateInt(dateString: dateString)
                
                //Labelに表示する処理をここで
                
                self.dateTextField.text = dateString
                self.ruleTextField.text = result.rule
                
                self.ranking = result.ranking
                self.rule = result.rule
                self.ruleID = result.ruleID
                
                self.mode = result.mode
                self.rankingSegmentedControl.selectedSegmentIndex = (result.ranking - 1)
                self.scoreTextField.text = String(result.score)
                
            }
        } else {
            print("対局結果データの取得に失敗しました。")
        }
        
        rankingSegmentedControl.addTarget(self, action: #selector(rankingSegmentChanged(_:)), for: UIControl.Event.valueChanged)

    }
    
    //時刻を見やすく修正する関数
    private func getJPTimeString(date: Date) -> String {
        
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .long
        f.timeStyle = .short
        let formattedDate = f.string(from: date)
        
        return formattedDate
    }
    
    private func dateStringTodateInt(dateString: String) {
         
        let yearStr = dateString.components(separatedBy: "年")
        year = Int(yearStr[0])!
        print("year = ", year)
        
        let monthStr = yearStr[1].components(separatedBy: "月")
        month = Int(monthStr[0])!
        print("month = ", month)
        
        let dayStr = monthStr[1].components(separatedBy: "日")
        day = Int(dayStr[0])!
        print("day = ", day)
        
        let hourStr = dayStr[1].components(separatedBy: ":")
        hour = Int(hourStr[0].trimmingCharacters(in: .whitespaces))!
        print("hour = ", hour)
        
        minute = Int(hourStr[1])!
        print("minute = ", minute)
        
        self.datePickerView.selectRow((year - 2000), inComponent: 0, animated: false)
        self.datePickerView.selectRow((month - 1), inComponent: 1, animated: false)
        self.datePickerView.selectRow((day - 1), inComponent: 2, animated: false)
        self.datePickerView.selectRow(hour, inComponent: 3, animated: false)
        self.datePickerView.selectRow(minute, inComponent: 4, animated: false)
    }
    
    //ルールを読み込む関数
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
        datePickerView.delegate = self
        rulePickerView.delegate = self
        dateTextField.inputView = datePickerView
        ruleTextField.inputView = rulePickerView
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        dateTextField.inputAccessoryView = toolbar
        ruleTextField.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        dateTextField.endEditing(true)
        ruleTextField.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dateTextField.endEditing(true)
        ruleTextField.endEditing(true)
        scoreTextField.endEditing(true)
    }
    
    private func changeDateTextField() {
        dateTextField.text = "\(year)年\(month)月\(day)日 \(hour):\(minute)"
    }
    
    //Firestoreの更新処理を行う関数
    private func updateResult() {
        let dateText = "\(year):\(month):\(day):\(hour):\(minute)"
        
        let date: Date = dateFromString(dateText, "yyyy:MM:dd:HH:mm")
        print(date)
        
        guard let score: Int = Int(self.scoreTextField.text!) else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        calcZyuniten(uid:uid, score: score, after: { point in
            
            self.pointGlo = ceil(point * 1000) / 1000
        
            let docData = ["date": date, "mode": self.mode, "rule": self.rule, "ruleID": self.ruleID, "ranking": self.ranking, "score": score, "point": self.pointGlo] as [String : Any]
            
            let resultRef = Firestore.firestore().collection("mahjang").document("results").collection(uid).document(self.resultID!)
        
            resultRef.updateData(docData) { (err) in
                if let err = err {
                    print("Firestoreの情報の更新に失敗しました。\(err)")
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                }
                
                HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                    print("Firestoreへの保存に成功しました。")
                    
                    self.presentToHistoryViewController()
                }
            }
        })
    }
    
    private func calcZyuniten(uid: String, score: Int, after:@escaping (Float) -> ()){
        
        var soten: Float = 0
        var point: Float = 0
        
        var firstPoint: Int = 0
        var secondPoint: Int = 0
        var thirdPoint: Int = 0
        var forthPoint: Int = 0
                
        
        Firestore.firestore().collection("mahjang").document("rules").collection(uid).document(self.ruleID).getDocument { (snapShot, err) in
            if let err = err {
                print("Firestoreからルール情報の取り出しに失敗しました。\(err)")
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
            }
            
            let dic = snapShot!.data()
            let rule = Rule.init(dic: dic!)
            
            soten = ((Float(score) - Float(rule.kaeshiten)) / 10)
            soten = ceil(soten * 1000) / 1000
            print("soten = ", soten)
            
            if (rule.mode == "4") {
                
                if (rule.zyuniten == "無し") {
                    
                    firstPoint = 0
                    secondPoint = 0
                    thirdPoint = 0
                    forthPoint = 0
                    
                } else {
                    let uma:[String] = rule.zyuniten.components(separatedBy: "-")
                    
                    firstPoint = Int(uma[1])! + (((rule.kaeshiten - rule.genten) / 10) * 4)
                    firstPoint = Int(ceil(Float(firstPoint) * 1000) / 1000)
                    secondPoint = Int(uma[0])!
                    thirdPoint = (-1) * Int(uma[0])!
                    forthPoint = (-1) * Int(uma[1])!
                }
                
                if self.ranking == 1 {
                    point = (soten + Float(firstPoint))
                    print(point)
                } else if self.ranking == 2 {
                    point = (soten + Float(secondPoint))
                } else if self.ranking == 3 {
                    point = (soten + Float(thirdPoint))
                } else if self.ranking == 4 {
                    point = (soten + Float(forthPoint))
                } else {
                    print("エラー: 順位が正しく認識できません。")
                }
                
            } else if (rule.mode == "3") {
                
                if (rule.zyuniten == "無し") {
                    
                    firstPoint = 0
                    secondPoint = 0
                    thirdPoint = 0
                    
                } else {
                    let uma:[String] = rule.zyuniten.components(separatedBy: "-")
                    
                    firstPoint = Int(uma[1])! + (((rule.kaeshiten - rule.genten) / 10) * 3)
                    secondPoint = Int(uma[0])!
                    thirdPoint = (-1) * Int(uma[1])!
                }
                
                if self.ranking == 1 {
                    point = (soten + Float(firstPoint))
                    print(point)
                } else if self.ranking == 2 {
                    point = (soten + Float(secondPoint))
                } else if self.ranking == 3 {
                    point = (soten + Float(thirdPoint))
                } else {
                    print("エラー: 順位が正しく認識できません。")
                }
                
            } else {
                
                print("モード選択エラーです。")
            }
            
            point = ceil(point * 1000) / 1000
            after(point)
        }
    }
    
    func dateFromString(_ dateSting : String, _ format : String) -> Date {
        // DateFormatter のインスタンスを作成
        let formatter: DateFormatter = DateFormatter()
        
        // 日付の書式を文字列に合わせて設定
        formatter.dateFormat = format
        
        formatter.locale = Locale(identifier: "ja_JP")
        
        // 日時文字列からDate型の日付を生成する
        let dt = formatter.date(from: dateSting)
        
        return dt!
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
    
    private func presentToHistoryViewController() {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        let historyViewController = storyboard.instantiateViewController(identifier: "HistoryViewController") as! HistoryViewController
        historyViewController.modalPresentationStyle = .fullScreen
        self.present(historyViewController, animated: false, completion: nil)
    }
    
}


extension EditResultViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let scoreIsEmpty = scoreTextField.text?.isEmpty ?? true
        
        if scoreIsEmpty {
            updateButton.isEnabled = false
            updateButton.backgroundColor = .systemGray
        } else {
            updateButton.isEnabled = true
            updateButton.backgroundColor = .systemGreen
        }
        
    }
}
