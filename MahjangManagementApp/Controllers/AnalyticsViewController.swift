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
    
    let termList = [
        "全期間",
        "1月", "2月", "3月", "4月", "5月", "6月",
        "7月", "8月", "9月", "10月", "11月", "12月"
        ]
    
    var selectedTerm: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tappedToAnalyticsButton.isEnabled = false
        tappedToAnalyticsButton.setTitleColor(.gray, for: .normal)
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
        
        termIsAllShowResults()
        
        //ユーザー名を表示させるための処理
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
        
        print("\(selectedTerm)が選択されました。")
        
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
        
        Firestore.firestore().collection("mahjang").document("results").collection(uid).order(by: "date").getDocuments { [self] (snapShots, err) in
            
            if let err = err {
                print("Firestoreからのデータの取得に失敗しました。\(err)")
                
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
                        print("4麻で1着のデータが見つかりました。")
                        firstOf4 = firstOf4 + 1
                        firstOf4Label.text = String(firstOf4)
                    
                    case 2:
                        print("4麻で2着のデータが見つかりました。")
                        secondOf4 = secondOf4 + 1
                        secondOf4Label.text = String(secondOf4)
                        
                    case 3:
                        print("4麻で3着のデータが見つかりました。")
                        thirdOf4 = thirdOf4 + 1
                        thirdOf4Label.text = String(thirdOf4)
                        
                    case 4:
                        print("4麻で4着のデータが見つかりました。")
                        forthOf4 = forthOf4 + 1
                        forthOf4Label.text = String(forthOf4)
                        
                    default:
                        break
                    }
                    
                case "3":
                    switch result.ranking {
                    
                    case 1:
                        print("3麻で1着のデータが見つかりました。")
                        firstOf3 = firstOf3 + 1
                        firstOf3Label.text = String(firstOf3)
                    
                    case 2:
                        print("3麻で2着のデータが見つかりました。")
                        secondOf3 = secondOf3 + 1
                        secondOf3Label.text = String(secondOf3)
                        
                    case 3:
                        print("3麻で3着のデータが見つかりました。")
                        thirdOf3 = thirdOf3 + 1
                        thirdOf3Label.text = String(thirdOf3)
                        
                    default:
                        break
                    }
                    
                    
                default:
                    break
                    
                }
            })
            
            let totalOf4: Float = Float(firstOf4 + secondOf4 + thirdOf4 + forthOf4)
            let totalOf3: Float = Float(firstOf3 + secondOf3 + thirdOf3)
            
            let totalRankOf4: Float = Float(firstOf4 * 1 + secondOf4 * 2 + thirdOf4 * 3 + forthOf4 * 4)
            let avarageOf4 = totalRankOf4 / totalOf4
            print(avarageOf4)
            
            let totalRankOf3: Float = Float(firstOf3 * 1 + secondOf3 * 2 + thirdOf3 * 3)
            let avarageOf3 = totalRankOf3 / totalOf3

            showAnalytics(totalOf4: Int(totalOf4), totalOf3: Int(totalOf3), avarageOf4: avarageOf4, avarageOf3: avarageOf3)
        }
    }
    
    private func showAnalytics(totalOf4: Int, totalOf3: Int, avarageOf4: Float, avarageOf3: Float) {
        print("ここで分析するよ")
        
        totalOf4Label.text = String(totalOf4)
        totalOf3Label.text = String(totalOf3)
        
        //表示桁数を丸める
        let avarageOf4Text = String(format: "%.3f", avarageOf4)
        let avarageOf3Text = String(format: "%.3f", avarageOf3)
        
        avarageRankOf4Label.text = avarageOf4Text
        avarageRankOf3Label.text = avarageOf3Text
    
        if totalOf4 == 0 {
            avarageRankOf4Label.text = "------"
        }
        
        if totalOf3 == 0 {
            avarageRankOf3Label.text = "------"
        }
        
        
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
    
    private func presentToAddRuleViewController() {
        let storyboard = UIStoryboard(name: "AddRule", bundle: nil)
        let addRuleViewController = storyboard.instantiateViewController(identifier: "AddRuleViewController") as! AddRuleViewController
        addRuleViewController.modalPresentationStyle = .fullScreen
        self.present(addRuleViewController, animated: true, completion: nil)
    }
    
    
}
