//
//  HistoryViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/09/29.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore
import PKHUD

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let dateLabel = cell.contentView.viewWithTag(1) as! UILabel
        let ruleLabel = cell.contentView.viewWithTag(2) as! UILabel
        let rankingLabel = cell.contentView.viewWithTag(3) as! UILabel
        let scoreLabel = cell.contentView.viewWithTag(4) as! UILabel
        let pointLabel = cell.contentView.viewWithTag(5) as! UILabel
        let modeImageView = cell.contentView.viewWithTag(6) as! UIImageView

        dateLabel.text = "\(getRuleIdentifierString(date: self.results[indexPath.row].date.dateValue()))"
        ruleLabel.text = "\(self.results[indexPath.row].rule)"
        rankingLabel.text = "\(self.results[indexPath.row].ranking)着"
        
        switch self.results[indexPath.row].mode {
        case "4":
            modeImageView.image = UIImage(named: "Mode4")
        case "3":
            modeImageView.image = UIImage(named: "Mode3")
        default:
            self.present(.errorAlert(errorMsg: "モードエラーです。 エラーコード:DEV021") { _ in
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
            })
        }
        
        if self.results[indexPath.row].score == 0 {
            scoreLabel.text = "0点"
        } else {
            scoreLabel.text = "\(self.results[indexPath.row].score)00点"
        }
        
        var point = self.results[indexPath.row].point
        
        point = round(point * 10) / 10
        
        if (point > 0) {
            pointLabel.text = "+\(point)P"
        } else {
            pointLabel.text = "\(point)P"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    //スワイプしたセルを削除　※arrayNameは変数名に変更してください
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            removeDataFromFirestore(index: indexPath.row)
            
            results.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        presentToEditResultViewController(resultID: resultsID[indexPath.row])
        
    }

    
    //画面遷移のための関数
    private func presentToEditResultViewController(resultID: String) {
        let storyboard = UIStoryboard(name: "EditResult", bundle: nil)
        let editResultViewController = storyboard.instantiateViewController(identifier: "EditResultViewController") as! EditResultViewController
        editResultViewController.resultID = resultID
        editResultViewController.modalPresentationStyle = .fullScreen
        self.present(editResultViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var historyTableView: UITableView!
    
    let db = Firestore.firestore()
    var results:[Result] = []
    var resultsID:[String] = []
    
    
    //フッターボタンの処理
    @IBAction func tappedAddResultButton(_ sender: Any) {
        presentToHomeViewController()
    }
    
    @IBOutlet weak var tappedToHistoryButton: UIButton!
    
    @IBAction func tappedAddRuleButton(_ sender: Any) {
        presentToAddRuleViewController()
    }
    
    @IBAction func tappedToAnalyticsButton(_ sender: Any) {
        presentToAnalyticsViewController()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tappedToHistoryButton.isEnabled = false
        tappedToHistoryButton.setTitleColor(UIColor.rgb(red: 0, green: 45, blue: 95), for: .normal)
        tappedToHistoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    private func loadData() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("mahjang").document("results").collection(uid).order(by: "date").getDocuments { [self] (snapShots, err) in
            
            if let err = err {
                
                self.present(.errorAlert(errorMsg: "Firestoreからのルールの取得に失敗しました。\(err)　エラーコード:DEV022") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            }
            
            snapShots?.documents.forEach({ (snapShot) in
                let dic = snapShot.data()
                let result = Result.init(dic: dic)
                
                let resultID: String = snapShot.documentID
                  self.resultsID.append(resultID)
                
                self.results.insert(result, at: 0)
                self.resultsID.insert(resultID, at: 0)
                
            })
            self.historyTableView.reloadData()
        }
    }
    
    private func removeDataFromFirestore(index: Int) {
        
//        print("\(index)番目のデータを削除します。")
        guard let uid = Auth.auth().currentUser?.uid else { return }

        
        Firestore.firestore().collection("mahjang").document("results").collection(uid).document(resultsID[index]).delete() { err in
            if let err = err {
                self.present(.errorAlert(errorMsg: "Firestoreからのデータの削除に失敗しました。\(err)　エラーコード:DEV023") { _ in
                    
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    
                    return
                })
            } else {
                self.historyTableView.reloadData()
            }
        }
        
    }
    
    //時刻を見やすく修正する関数
    private func getRuleIdentifierString(date: Date) -> String {
        
        let f = DateFormatter()
            f.locale = Locale(identifier: "ja_JP")
            f.dateStyle = .long
            f.timeStyle = .short
            let formattedDate = f.string(from: date)
        
        return formattedDate
    }
    
    private func presentToHomeViewController() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: false, completion: nil)
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
