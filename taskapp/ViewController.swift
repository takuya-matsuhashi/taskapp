//
//  ViewController.swift
//  taskapp
//
//  Created by 松橋拓哉 on 2021/02/14.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var seachBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
        let realm = try! Realm()  // ←追加
    
    // DB内のタスクが格納されるリスト。
       // 日付の近い順でソート：昇順
       // 以降内容をアップデートするとリスト内は自動的に更新される。
       var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        seachBar.delegate = self
        
    }
    
    // データの数（＝セルの数）を返すメソッド
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return taskArray.count
        }

        // 各セルの内容を返すメソッド
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // 再利用可能な cell を得る
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            // Cellに値を設定する.
                   let task = taskArray[indexPath.row]
                   cell.textLabel?.text = task.title

                   let formatter = DateFormatter()
                   formatter.dateFormat = "yyyy-MM-dd HH:mm"

                   let dateString:String = formatter.string(from: task.date)
                   cell.detailTextLabel?.text = dateString

            return cell
        }

        // 各セルを選択した時に実行されるメソッド
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "cellSegue",sender: nil)
        }
    

        // セルが削除が可能なことを伝えるメソッド
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
            return .delete
        }

        // Delete ボタンが押された時に呼ばれるメソッド
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            // --- ここから ---
            if editingStyle == .delete {
                // 削除するタスクを取得する
                let task = self.taskArray[indexPath.row]

                // ローカル通知をキャンセルする
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

                // データベースから削除する
                try! realm.write {
                    self.realm.delete(task)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }

                // 未通知のローカル通知一覧をログ出力
                center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                    for request in requests {
                        print("/---------------")
                        print(request)
                        print("---------------/")
                    }
                }
            } // --- ここまで変更 ---
            
            if editingStyle == .delete {
                       // データベースから削除する
                       try! realm.write {
                           self.realm.delete(self.taskArray[indexPath.row])
                           tableView.deleteRows(at: [indexPath], with: .fade)
                       }
                   }
        }
    
    // segue で画面遷移する時に呼ばれる
        override func prepare(for segue: UIStoryboardSegue, sender: Any?){
            let inputViewController:InputViewController = segue.destination as! InputViewController

            if segue.identifier == "cellSegue" {
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray[indexPath!.row]
            } else {
                let task = Task()

                let allTasks = realm.objects(Task.self)
                if allTasks.count != 0 {
                    task.id = allTasks.max(ofProperty: "id")! + 1
                }

                inputViewController.task = task
            }
        }
    // 入力画面から戻ってきた時に TableView を更新させる
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           tableView.reloadData()
       }
    
   
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        if let text = seachBar.text{
            
            let predicate = NSPredicate(format: "category = %@" , text)
            
            // Query using a predicate string
            var task = realm.objects(Task.self).filter(predicate)
            
        }
      
        //検索絞り込み
        
        tableView.reloadData()
      
    
        }
    
}

