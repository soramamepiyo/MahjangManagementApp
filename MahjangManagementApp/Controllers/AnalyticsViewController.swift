//
//  AnalyticsViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/10.
//

import UIKit
import PKHUD
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AnalyticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return termList.count
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var termPickerView: UIPickerView!
    
    @IBOutlet weak var firstOf4Label: UILabel!
    @IBOutlet weak var secondOf4Label: UILabel!
    @IBOutlet weak var thirdOf4Label: UILabel!
    @IBOutlet weak var forthOf4Label: UILabel!
    @IBOutlet weak var firstOf3Label: UILabel!
    @IBOutlet weak var secondOf3Label: UILabel!
    @IBOutlet weak var thirdOf3Label: UILabel!
    @IBOutlet weak var totalOf4Label: UILabel!
    @IBOutlet weak var totalOf3Label: UILabel!
    @IBOutlet weak var avarageRankOf4Label: UILabel!
    @IBOutlet weak var avarageRankOf3Label: UILabel!
    @IBOutlet weak var pointOf4Label: UILabel!
    @IBOutlet weak var pointOf3Label: UILabel!
    
    var termList = [
        "全期間",
        "2021年10月", "2021年11月", "2021年12月",
        "2022年1月", "2022年2月", "2022年3月", "2022年4月", "2022年5月", "2022年6月"]
        
    var selectedTerm: String = ""
    
    var ruleData = [String]()
    var ruleIDData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tappedToAnalyticsButton.isEnabled = false
        tappedToAnalyticsButton.setTitleColor(UIColor.rgb(red: 0, green: 45, blue: 95), for: .normal)
        tappedToAnalyticsButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        termPickerView.delegate = self
        termPickerView.dataSource = self
        
        firstOf4Label.text = "0"
        secondOf4Label.text = "0"
        thirdOf4Label.text = "0"
        forthOf4Label.text = "0"
        
        firstOf3Label.text = "0"
        secondOf3Label.text = "0"
        thirdOf3Label.text = "0"
        
        selectedTerm = "全期間"
        
        print("\(selectedTerm)が選択されました。")
        
        loadRules()
        
        termIsAllShowResults()
        
        //ユーザー名を表示させるための処理
        guard let uid = Auth.auth().currentUser?.uid else {
            
            self.present(.errorAlert(errorMsg: "ユーザIDの取得に失敗しました。　エラーコード:DEV027") { _ in
                
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
                
                self.present(.errorAlert(errorMsg: "ユーザー情報の取得に失敗しました。\(err)　エラーコード:DEV028") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            guard let data = snapshot?.data() else { return }
            let user: User = User.init(dic: data)
            // print("ユーザー情報の取得に成功しました。\(user.name)")
            
            userNameLabel.text = user.name + "さん"
        }
    }
    
    @IBAction func tappedToHomeViewController(_ sender: Any) {
        presentToHomeViewController()
    }
    
    @IBAction func tappedToHistoryViewController(_ sender: Any) {
        presentToHistoryViewController()
    }
    
    @IBAction func tappedToAddRulebutton(_ sender: Any) {
        presentToAddRuleViewController()
    }
    
    @IBOutlet weak var tappedToAnalyticsButton: UIButton!
    
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
            
        return termList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        
        selectedTerm = termList[row]
                
        if row == 0 {
            termIsAllShowResults()
        } else if row <= 9 {
            
            var month = row + 9
            var year = 2021
            
            if month > 12 {
                year += 1
                month -= 12
            }
            
            print("\(year)年\(month)月のデータを探索します")
            termIsMonthShowResults(year: year, month: month)
            
        } else if row <= ruleData.count + 9 {
            print("\(ruleData[row - 10])のデータを探索します")
            print("ID: \(ruleIDData[row - 10])")
            
            termIsRuleShowResults(id: ruleIDData[row - 10])
        } else {
            self.present(.errorAlert(errorMsg: "探索エラーが発生しました。　エラーコード:DEV029") { _ in
                
                return
            })
        }
            
    }
    
    @IBAction func tappedContactButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Contact", bundle: nil)
        let contactViewController = storyboard.instantiateViewController(identifier: "ContactViewController") as! ContactViewController
        self.present(contactViewController, animated: true, completion: nil)
    }
    
    
    private func termIsAllShowResults() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var firstOf4 = 0
        var secondOf4 = 0
        var thirdOf4 = 0
        var forthOf4 = 0
        
        var firstOf3 = 0
        var secondOf3 = 0
        var thirdOf3 = 0
        
        var pointOf4: Float = 0
        var pointOf3: Float = 0
        
        Firestore.firestore().collection("mahjang").document("results").collection(uid).order(by: "date").getDocuments { [self] (snapShots, err) in
            
            if let err = err {
                
                self.present(.errorAlert(errorMsg: "Firestoreからのデータの取得に失敗しました。\(err)　エラーコード:DEV030") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
            }
            
            snapShots?.documents.forEach({ (snapShot) in
                let dic = snapShot.data()
                let result = Result.init(dic: dic)
            
                switch result.mode {
                
                case "4":
                    
                    switch result.ranking {
                    
                    case 1:
                        firstOf4 = firstOf4 + 1
                                        
                    case 2:
                        secondOf4 = secondOf4 + 1
                        
                    case 3:
                        thirdOf4 = thirdOf4 + 1
                        
                    case 4:
                        forthOf4 = forthOf4 + 1
                        
                    default:
                        break
                    }
                    
                    pointOf4 = pointOf4 + result.point
                    
                case "3":
                    switch result.ranking {
                    
                    case 1:
                        firstOf3 = firstOf3 + 1
                        firstOf3Label.text = String(firstOf3)
                    
                    case 2:
                        secondOf3 = secondOf3 + 1
                        secondOf3Label.text = String(secondOf3)
                        
                    case 3:
                        thirdOf3 = thirdOf3 + 1
                        thirdOf3Label.text = String(thirdOf3)
                        
                    default:
                        break
                    }
                    
                    pointOf3 = pointOf3 + result.point
                    
                default:
                    break
                    
                }
            })
            
            let totalOf4: Float = Float(firstOf4 + secondOf4 + thirdOf4 + forthOf4)
            let totalOf3: Float = Float(firstOf3 + secondOf3 + thirdOf3)
            
            let firstOf4Rate: String = String(format: "%.1f", Float(firstOf4 * 100) / totalOf4)
            let secondOf4Rate: String = String(format: "%.1f", Float(secondOf4 * 100) / totalOf4)
            let thirdOf4Rate: String = String(format: "%.1f", Float(thirdOf4 * 100) / totalOf4)
            let forthOf4Rate: String = String(format: "%.1f", Float(forthOf4 * 100) / totalOf4)
            
            let firstOf3Rate: String = String(format: "%.1f", Float(firstOf3 * 100) / totalOf3)
            let secondOf3Rate: String = String(format: "%.1f", Float(secondOf3 * 100) / totalOf3)
            let thirdOf3Rate: String = String(format: "%.1f", Float(thirdOf3 * 100) / totalOf3)
            
            if totalOf4 == 0 {
                firstOf4Label.text = "0回 (0.0)%"
                secondOf4Label.text = "0回 (0.0)%"
                thirdOf4Label.text = "0回 (0.0)%"
                forthOf4Label.text = "0回 (0.0)%"
            } else {
                firstOf4Label.text = "\(firstOf4)回 (\(firstOf4Rate))%"
                secondOf4Label.text = "\(secondOf4)回 (\(secondOf4Rate))%"
                thirdOf4Label.text = "\(thirdOf4)回 (\(thirdOf4Rate))%"
                forthOf4Label.text = "\(forthOf4)回 (\(forthOf4Rate))%"
            }
            
            if totalOf3 == 0 {
                firstOf3Label.text = "0回 (0.0)%"
                secondOf3Label.text = "0回 (0.0)%"
                thirdOf3Label.text = "0回 (0.0)%"
            } else {
                firstOf3Label.text = "\(firstOf3)回 (\(firstOf3Rate))%"
                secondOf3Label.text = "\(secondOf3)回 (\(secondOf3Rate))%"
                thirdOf3Label.text = "\(thirdOf3)回 (\(thirdOf3Rate))%"
            }
            
            let totalRankOf4: Float = Float(firstOf4 * 1 + secondOf4 * 2 + thirdOf4 * 3 + forthOf4 * 4)
            let avarageOf4 = totalRankOf4 / totalOf4
//            print(avarageOf4)
            
            let totalRankOf3: Float = Float(firstOf3 * 1 + secondOf3 * 2 + thirdOf3 * 3)
            let avarageOf3 = totalRankOf3 / totalOf3
            
            pointOf4Label.text = "\(String(format: "%.1f", pointOf4))P"
            pointOf3Label.text = "\(String(format: "%.1f", pointOf3))P"

            showAnalytics(totalOf4: Int(totalOf4), totalOf3: Int(totalOf3), avarageOf4: avarageOf4, avarageOf3: avarageOf3)
        }
    }
    
    
    private func termIsMonthShowResults(year: Int, month: Int) {
        
        labelReset()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var firstOf4 = 0
        var secondOf4 = 0
        var thirdOf4 = 0
        var forthOf4 = 0
        
        var firstOf3 = 0
        var secondOf3 = 0
        var thirdOf3 = 0
        
        var pointOf4: Float = 0
        var pointOf3: Float = 0
        
        Firestore.firestore().collection("mahjang").document("results").collection(uid).order(by: "date").getDocuments { [self] (snapShots, err) in
        
            if let err = err {
                
                self.present(.errorAlert(errorMsg: "Firestoreからのデータの取得に失敗しました。\(err)　エラーコード:DEV031") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            
            snapShots?.documents.forEach({ (snapShot) in
                let dic = snapShot.data()
                let result = Result.init(dic: dic)
                
                let term = getRuleIdentifierString(date: result.date.dateValue())
                                                
                let zeroPaddingMonth = String(format: "%02d", month)
                let targetTerm = String(year) + String(zeroPaddingMonth)
                
                if term == targetTerm {
                    switch result.mode {
                    
                    case "4":
                        
                        switch result.ranking {
                        
                        case 1:
                            firstOf4 = firstOf4 + 1
                                            
                        case 2:
                            secondOf4 = secondOf4 + 1
                            
                        case 3:
                            thirdOf4 = thirdOf4 + 1
                            
                        case 4:
                            forthOf4 = forthOf4 + 1
                            
                        default:
                            break
                        }
                        
                        pointOf4 = pointOf4 + result.point
                        
                    case "3":
                        switch result.ranking {
                        
                        case 1:
                            firstOf3 = firstOf3 + 1
                            firstOf3Label.text = String(firstOf3)
                        
                        case 2:
                            secondOf3 = secondOf3 + 1
                            secondOf3Label.text = String(secondOf3)
                            
                        case 3:
                            thirdOf3 = thirdOf3 + 1
                            thirdOf3Label.text = String(thirdOf3)
                            
                        default:
                            break
                        }
                        
                        pointOf3 = pointOf3 + result.point
                        
                    default:
                        break
                        
                    }
                }
            
                
            })
            
            let totalOf4: Float = Float(firstOf4 + secondOf4 + thirdOf4 + forthOf4)
            let totalOf3: Float = Float(firstOf3 + secondOf3 + thirdOf3)
            
            let firstOf4Rate: String = String(format: "%.1f", Float(firstOf4 * 100) / totalOf4)
            let secondOf4Rate: String = String(format: "%.1f", Float(secondOf4 * 100) / totalOf4)
            let thirdOf4Rate: String = String(format: "%.1f", Float(thirdOf4 * 100) / totalOf4)
            let forthOf4Rate: String = String(format: "%.1f", Float(forthOf4 * 100) / totalOf4)
            
            let firstOf3Rate: String = String(format: "%.1f", Float(firstOf3 * 100) / totalOf3)
            let secondOf3Rate: String = String(format: "%.1f", Float(secondOf3 * 100) / totalOf3)
            let thirdOf3Rate: String = String(format: "%.1f", Float(thirdOf3 * 100) / totalOf3)
            
            if totalOf4 == 0 {
                firstOf4Label.text = "0回 (0.0)%"
                secondOf4Label.text = "0回 (0.0)%"
                thirdOf4Label.text = "0回 (0.0)%"
                forthOf4Label.text = "0回 (0.0)%"
            } else {
                firstOf4Label.text = "\(firstOf4)回 (\(firstOf4Rate))%"
                secondOf4Label.text = "\(secondOf4)回 (\(secondOf4Rate))%"
                thirdOf4Label.text = "\(thirdOf4)回 (\(thirdOf4Rate))%"
                forthOf4Label.text = "\(forthOf4)回 (\(forthOf4Rate))%"
            }
            
            if totalOf3 == 0 {
                firstOf3Label.text = "0回 (0.0)%"
                secondOf3Label.text = "0回 (0.0)%"
                thirdOf3Label.text = "0回 (0.0)%"
            } else {
                firstOf3Label.text = "\(firstOf3)回 (\(firstOf3Rate))%"
                secondOf3Label.text = "\(secondOf3)回 (\(secondOf3Rate))%"
                thirdOf3Label.text = "\(thirdOf3)回 (\(thirdOf3Rate))%"
            }
            
            let totalRankOf4: Float = Float(firstOf4 * 1 + secondOf4 * 2 + thirdOf4 * 3 + forthOf4 * 4)
            let avarageOf4 = totalRankOf4 / totalOf4
            print(avarageOf4)
            
            let totalRankOf3: Float = Float(firstOf3 * 1 + secondOf3 * 2 + thirdOf3 * 3)
            let avarageOf3 = totalRankOf3 / totalOf3
            
            pointOf4Label.text = "\(String(format: "%.1f", pointOf4))P"
            pointOf3Label.text = "\(String(format: "%.1f", pointOf3))P"

            showAnalytics(totalOf4: Int(totalOf4), totalOf3: Int(totalOf3), avarageOf4: avarageOf4, avarageOf3: avarageOf3)
        }
    }
    
    private func termIsRuleShowResults(id: String) {
        
        labelReset()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var firstOf4 = 0
        var secondOf4 = 0
        var thirdOf4 = 0
        var forthOf4 = 0
        
        var firstOf3 = 0
        var secondOf3 = 0
        var thirdOf3 = 0
        
        var pointOf4: Float = 0
        var pointOf3: Float = 0
        
        Firestore.firestore().collection("mahjang").document("rules").collection(uid).document(id).getDocument { (snapShot, err) in
            
            if let err = err {
                self.present(.errorAlert(errorMsg: "Firestoreからのルール情報の取得に失敗しました。\(err)　エラーコード:DEV034") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
                
            } else {
                let dic = snapShot!.data()
                let rule = Rule.init(dic: dic!)
                
                print("mode = ", rule.mode)
                
                if rule.mode == "4" {
                    
                    self.firstOf3Label.text = "------"
                    self.secondOf3Label.text = "------"
                    self.thirdOf3Label.text = "------"
                    self.totalOf3Label.text = "------"
                    self.pointOf3Label.text = "------"
                    
                } else if rule.mode == "3" {
                    
                    self.firstOf4Label.text = "------"
                    self.secondOf4Label.text = "------"
                    self.thirdOf4Label.text = "------"
                    self.forthOf4Label.text = "------"
                    self.totalOf4Label.text = "------"
                    self.pointOf4Label.text = "------"
                    
                } else {
                    self.present(.errorAlert(errorMsg: "対局ルール情報にエラーが見つかりました。　エラーコード:DEV035") { _ in

                        return
                    })
                }
                
            }
            
        }
        
        Firestore.firestore().collection("mahjang").document("results").collection(uid).order(by: "date").getDocuments { [self] (snapShots, err) in
        
            if let err = err {
                
                self.present(.errorAlert(errorMsg: "Firestoreからのデータの取得に失敗しました。\(err)　エラーコード:DEV032") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            
            snapShots?.documents.forEach({ (snapShot) in
                let dic = snapShot.data()
                let result = Result.init(dic: dic)
            
                if result.ruleID == id {
                    switch result.mode {
                    
                    case "4":
                        
                        switch result.ranking {
                        
                        case 1:
                            firstOf4 = firstOf4 + 1
                                            
                        case 2:
                            secondOf4 = secondOf4 + 1
                            
                        case 3:
                            thirdOf4 = thirdOf4 + 1
                            
                        case 4:
                            forthOf4 = forthOf4 + 1
                            
                        default:
                            break
                        }
                        
                        pointOf4 = pointOf4 + result.point
                        
                    case "3":
                        switch result.ranking {
                        
                        case 1:
                            firstOf3 = firstOf3 + 1
                            firstOf3Label.text = String(firstOf3)
                        
                        case 2:
                            secondOf3 = secondOf3 + 1
                            secondOf3Label.text = String(secondOf3)
                            
                        case 3:
                            thirdOf3 = thirdOf3 + 1
                            thirdOf3Label.text = String(thirdOf3)
                            
                        default:
                            break
                        }
                        
                        pointOf3 = pointOf3 + result.point
                        
                    default:
                        break
                        
                    }
                }
            
                
            })
            
            let totalOf4: Float = Float(firstOf4 + secondOf4 + thirdOf4 + forthOf4)
            let totalOf3: Float = Float(firstOf3 + secondOf3 + thirdOf3)
            
            let firstOf4Rate: String = String(format: "%.1f", Float(firstOf4 * 100) / totalOf4)
            let secondOf4Rate: String = String(format: "%.1f", Float(secondOf4 * 100) / totalOf4)
            let thirdOf4Rate: String = String(format: "%.1f", Float(thirdOf4 * 100) / totalOf4)
            let forthOf4Rate: String = String(format: "%.1f", Float(forthOf4 * 100) / totalOf4)
            
            let firstOf3Rate: String = String(format: "%.1f", Float(firstOf3 * 100) / totalOf3)
            let secondOf3Rate: String = String(format: "%.1f", Float(secondOf3 * 100) / totalOf3)
            let thirdOf3Rate: String = String(format: "%.1f", Float(thirdOf3 * 100) / totalOf3)
            
            if totalOf4 == 0 {
                firstOf4Label.text = "0回 (0.0)%"
                secondOf4Label.text = "0回 (0.0)%"
                thirdOf4Label.text = "0回 (0.0)%"
                forthOf4Label.text = "0回 (0.0)%"
            } else {
                firstOf4Label.text = "\(firstOf4)回 (\(firstOf4Rate))%"
                secondOf4Label.text = "\(secondOf4)回 (\(secondOf4Rate))%"
                thirdOf4Label.text = "\(thirdOf4)回 (\(thirdOf4Rate))%"
                forthOf4Label.text = "\(forthOf4)回 (\(forthOf4Rate))%"
            }
            
            if totalOf3 == 0 {
                firstOf3Label.text = "0回 (0.0)%"
                secondOf3Label.text = "0回 (0.0)%"
                thirdOf3Label.text = "0回 (0.0)%"
            } else {
                firstOf3Label.text = "\(firstOf3)回 (\(firstOf3Rate))%"
                secondOf3Label.text = "\(secondOf3)回 (\(secondOf3Rate))%"
                thirdOf3Label.text = "\(thirdOf3)回 (\(thirdOf3Rate))%"
            }
            
            let totalRankOf4: Float = Float(firstOf4 * 1 + secondOf4 * 2 + thirdOf4 * 3 + forthOf4 * 4)
            let avarageOf4 = totalRankOf4 / totalOf4
            print(avarageOf4)
            
            let totalRankOf3: Float = Float(firstOf3 * 1 + secondOf3 * 2 + thirdOf3 * 3)
            let avarageOf3 = totalRankOf3 / totalOf3
            
            pointOf4Label.text = "\(String(format: "%.1f", pointOf4))P"
            pointOf3Label.text = "\(String(format: "%.1f", pointOf3))P"

            showAnalytics(totalOf4: Int(totalOf4), totalOf3: Int(totalOf3), avarageOf4: avarageOf4, avarageOf3: avarageOf3)
        }
    }
    
    private func labelReset() {
        firstOf4Label.text = "0"
        secondOf4Label.text = "0"
        thirdOf4Label.text = "0"
        forthOf4Label.text = "0"
        firstOf3Label.text = "0"
        secondOf3Label.text = "0"
        thirdOf3Label.text = "0"
        totalOf4Label.text = "0"
        totalOf3Label.text = "0"
        avarageRankOf4Label.text = "-----"
        avarageRankOf3Label.text = "-----"
        pointOf4Label.text = "0.0P"
        pointOf3Label.text = "0.0P"
    }
    
    private func loadRules() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("mahjang").document("rules").collection(uid).order(by: "createdAt").getDocuments { (snapShots, err) in
            
            if let err = err {
                self.present(.errorAlert(errorMsg: "Firestoreからのデータの取得に失敗しました。\(err)　エラーコード:DEV033") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            snapShots?.documents.forEach({ (snapShot) in
                
                let dic = snapShot.data()
                let rule = Rule.init(dic: dic)
                
                let ruleName: String = rule.ruleName
                let ruleID: String = snapShot.documentID
                
                self.termList.append(ruleName)
                self.ruleData.append(ruleName)
                self.ruleIDData.append(ruleID)
                
            })
            
            self.termPickerView.reloadAllComponents()
//            print("ReLoad!")
        }
    }
    
    //時刻を見やすく修正する関数
    private func getRuleIdentifierString(date: Date) -> String {
    
        let dateFormatter = DateFormatter()
        
        // フォーマット設定
        dateFormatter.dateFormat = "yyyyMM"

        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // タイムゾーン設定（端末設定によらず固定にしたい場合）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        // 変換
        let str = dateFormatter.string(from: date)
        
        return str
    }
    
    private func showAnalytics(totalOf4: Int, totalOf3: Int, avarageOf4: Float, avarageOf3: Float) {
        
        totalOf4Label.text = String(totalOf4)
        totalOf3Label.text = String(totalOf3)
        
        //表示桁数を丸める
        let avarageOf4Text = String(format: "%.3f", avarageOf4)
        let avarageOf3Text = String(format: "%.3f", avarageOf3)
        
        avarageRankOf4Label.text = avarageOf4Text
        avarageRankOf3Label.text = avarageOf3Text
    
        if totalOf4 == 0 {
            avarageRankOf4Label.text = "------"
            pointOf4Label.text = "------"
        }
        
        if totalOf3 == 0 {
            avarageRankOf3Label.text = "------"
            pointOf3Label.text = "------"
        }
        
        
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
    
    private func presentToAddRuleViewController() {
        let storyboard = UIStoryboard(name: "AddRule", bundle: nil)
        let addRuleViewController = storyboard.instantiateViewController(identifier: "AddRuleViewController") as! AddRuleViewController
        addRuleViewController.modalPresentationStyle = .fullScreen
        self.present(addRuleViewController, animated: false, completion: nil)
    }
    
    
}
