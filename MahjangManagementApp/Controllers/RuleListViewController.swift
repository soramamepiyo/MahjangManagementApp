//
//  RuleListViewController.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2022/01/04.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore
import PKHUD

class RuleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ruleListTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let ruleNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let gentenLabel = cell.contentView.viewWithTag(2) as! UILabel
        let kaeshitenLabel = cell.contentView.viewWithTag(3) as! UILabel
        let zyunitenLabel = cell.contentView.viewWithTag(4) as! UILabel
        let modeImageView = cell.contentView.viewWithTag(5) as! UIImageView

        ruleNameLabel.text = "\(self.results[indexPath.row].ruleName)"
        gentenLabel.text = "\(self.results[indexPath.row].genten)"
        kaeshitenLabel.text = "\(self.results[indexPath.row].kaeshiten)"
        zyunitenLabel.text = "\(self.results[indexPath.row].zyuniten)"
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    
    //まだ未実装（削除時に対応するResultsデータを削除する必要があるため）
//    //スワイプしたセルを削除　※arrayNameは変数名に変更してください
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//
//            removeDataFromFirestore(index: indexPath.row)
//
//            results.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
//        }
//    }
    
    //画面遷移のための関数
    private func presentToEditResultViewController(resultID: String) {
        let storyboard = UIStoryboard(name: "EditResult", bundle: nil)
        let editResultViewController = storyboard.instantiateViewController(identifier: "EditResultViewController") as! EditResultViewController
        editResultViewController.resultID = resultID
        editResultViewController.modalPresentationStyle = .fullScreen
        self.present(editResultViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var ruleListTableView: UITableView!
    
    let db = Firestore.firestore()
    var results:[Rule] = []
    var resultsID:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ruleListTableView.delegate = self
        ruleListTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    private func loadData() {
        
        results = []
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("mahjang").document("rules").collection(uid).order(by: "createdAt").getDocuments { [self] (snapShots, err) in
            
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
                let result = Rule.init(dic: dic)
                
                let resultID: String = snapShot.documentID
                  self.resultsID.append(resultID)
                
                self.results.insert(result, at: 0)
                self.resultsID.insert(resultID, at: 0)
                
            })
            self.ruleListTableView.reloadData()
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
                self.ruleListTableView.reloadData()
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
