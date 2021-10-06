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
        return resuts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let dateLabel = cell.contentView.viewWithTag(1) as! UILabel
        let ruleLabel = cell.contentView.viewWithTag(2) as! UILabel
        let rankingLabel = cell.contentView.viewWithTag(3) as! UILabel
        let scoreLabel = cell.contentView.viewWithTag(4) as! UILabel

        dateLabel.text = "\(getRuleIdentifierString(date: self.resuts[indexPath.row].date.dateValue()))"
        ruleLabel.text = "ルール\n\(self.resuts[indexPath.row].rule)"
        rankingLabel.text = "\(self.resuts[indexPath.row].ranking)着"
        scoreLabel.text = "\(self.resuts[indexPath.row].score)00点"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @IBOutlet weak var historyTableView: UITableView!
    
    let db = Firestore.firestore()
    var resuts:[Result] = []
    
    
    //フッターボタンの処理
    @IBAction func tappedAddResultButton(_ sender: Any) {
        presentToHomeViewController()
    }
    
    @IBAction func tappedAddRuleButton(_ sender: Any) {
        presentToAddRuleViewController()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                print("Firestoreからのデータの取得に失敗しました。\(err)")
                
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                
                return
            }
            
            snapShots?.documents.forEach({ (snapShot) in
                let dic = snapShot.data()
                let result = Result.init(dic: dic)
                
                self.resuts.append(result)
            })
            
            self.historyTableView.reloadData()
            
        }
        
    }
    
    private func getRuleIdentifierString(date: Date) -> String {
        
        let f = DateFormatter()
            f.locale = Locale(identifier: "ja_JP")
            f.dateStyle = .long
            f.timeStyle = .short
            let formattedDate = f.string(from: date)
//            print("date: \(formattedDate)")
        
        return formattedDate
    }
    
    private func presentToHomeViewController() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    private func presentToAddRuleViewController() {
        let storyboard = UIStoryboard(name: "AddRule", bundle: nil)
        let addRuleViewController = storyboard.instantiateViewController(identifier: "AddRuleViewController") as! AddRuleViewController
        addRuleViewController.modalPresentationStyle = .fullScreen
        self.present(addRuleViewController, animated: true, completion: nil)
    }
    
}

