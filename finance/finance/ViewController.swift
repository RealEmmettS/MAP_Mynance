//
//  ViewController.swift
//  finance
//
//  Created by Emmett Shaughnessy on 3/24/22.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseAuthUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: @IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var newTransactionButton: UIButton!
    
    var finishedInitialRequest:Bool = false {
        didSet{
            //self.generateTestTransaction()
            table.reloadData()
        }
    }
    
    
    ///Stores the processed data retrieved from Firebase. Automatically updates when new data is detected. See the "Auto-Retrieve Data" mark to observe the auto-updating procedure.
    var tableContent: [ processed ] = [] {
        didSet{
            table.reloadData()
        }
    }
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableContent = []
        currentUser.financeData = []
        
        currentUser.uploadToCloud()
        
        table.dataSource = self
        table.delegate = self
        table.layer.cornerRadius = 10
        
        //MARK: Auto-Retrieve Data
        ///This method is constantly listening for data changes on the server, and will run automatically whenever new data is found
        db.collection(currentUser.id).document("finances")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    //code goes here
                    return
                }
                
                //By default, Firebase returns arrays as an __NSArrayM which doesn't make any sense. This turns that __NSArrayM data to what it's supposed to be, which is an array full of dictionaries.
                let processedData = data["financeData"] as! [[String : Double]]
                
                currentUser.financeData = data["financeData"] as! [[String : Double]]
                
                self.tableContent = []
                self.table.reloadData()
                //Adding the processed data to a variable that can be used throughout this ViewController
                for pData in processedData{
                    for (key, value) in pData {
                        
                        let components = key.components(separatedBy: "&&&")
                        //print(components)
                        let n:String = components[0]
                        let d:Date = components[1].toDate()
                        
                        let newDataPoint:processed = processed(name: n, amount: value, Date: d)
                        
                        self.tableContent.append(newDataPoint)
                    }
                }
                
                print("\n\n\(self.tableContent)\n\n")
                
                
            }
        
    }//end viewDidLoad()
    
    //MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        //String name = user.getDisplayName();
        let welcomeText = ("Hello, " + currentUser.firstName)
        print(welcomeText) // First
        nameLabel.text = welcomeText
        
        getFinanceData()
        
    }
    
    //MARK: Add New Transaction
    @IBAction func addNewTransactionPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Submit New Transaction", message: "", preferredStyle: .alert)
        
        //textField 1
        alert.addTextField { (textField) in
            textField.placeholder = "Pizza"
        }
        //textField 2
        alert.addTextField { (textField) in
            textField.placeholder = "19.98"
        }
        
        //textField actions
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let textField1 = alert?.textFields![0] // Force unwrapping because we know it exists.
            let textField2 = alert?.textFields![1] // Force unwrapping because we know it exists.
            if textField1!.text != "" && textField2!.text != ""{
                print("New Transaction –> \(textField1!.text!): \(textField2!.text!)")
                currentUser.newTransaction(name: textField1!.text!, amount: textField2!.text!.replacingOccurrences(of: "$", with: "").toDouble()!)
            }
        }))
        
        
        
        //Cancel action button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true)
    }
    
   //https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-an-alert
//    func showAlert(title: String, message: String, continueTitle: String, cancelTitle: String, addCancelButton cancel: Bool){
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        //Continue action button
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
//
//        //textField and action
//        alert.addTextField { (textField) in
//            textField.placeholder = "Pizza"
//        }
//
//        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            if textField?.text != "" {
//                print("Text field: \(textField!.text)")
//            }
//        }))
//
//        //Cancel action button
//        if cancel {
//            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//        }
//
//        self.present(alert, animated: true)
//    }
    
    //MARK: -tableView Code
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        cell.textLabel!.text = tableContent[indexPath.row].name
        cell.detailTextLabel?.text = "$\(tableContent[indexPath.row].amount)"
        
        return cell
        
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    //defines what happens when a user swipes left on a tableView cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            currentUser.removeTransaction(indexNumber: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            //generateTestTransaction()
        }
    }
    
    //MARK: -Test Transaction
    func generateTestTransaction(){
        //Replace 0 with the minimum, and replace 6 with the maximum
        let random:Double = Double.random(in: 0..<100).rounded(toPlaces: 2)
        let name:String = ("TEST TRANSACTION")
        currentUser.newTransaction(name: name, amount: random)
    }
    
    
    //MARK: Manually Getting Data
    ///Used mainly to trigger the 'finishedInitialRequest' variable, which enables further user interaction. This is in place to prevent inaccurate loading or crashing of the app while current data has not yet been fectched
    func getFinanceData(){
        if Auth.auth().currentUser != nil {
            let docRef = db.collection(currentUser.id).document("finances")
            var returnValue: [String:Any] = ["":""]
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    returnValue = document.data()!
                    
                    //By default, Firebase returns arrays as an __NSArrayM which doesn't make any sense. This turns that __NSArrayM data to what it's supposed to be, which is an array full of dictionaries.
                    let processedData = returnValue["financeData"] as! [[String : Double]]
                    
                    currentUser.financeData = returnValue["financeData"] as! [[String : Double]]
                    
                    self.tableContent = []
                    self.table.reloadData()
                    
                    //Adding the processed data to a variable that can be used throughout this ViewController
                    for pData in processedData{
                        for (key, value) in pData {
                            
                            let components = key.components(separatedBy: "&&&")
                            //print(components)
                            let n:String = components[0]
                            let d:Date = components[1].toDate()
                            
                            let newDataPoint:processed = processed(name: n, amount: value, Date: d)
                            
                            self.tableContent.append(newDataPoint)
                        }
                    }
                    
                    print("\n\n\(self.tableContent)\n\n")
                    self.finishedInitialRequest = true
                } else {
                    print("Document does not exist")
                    returnValue = ["no":"no"]
                    print("Return Value: \(returnValue)\n\n")
                    
                    self.finishedInitialRequest = true
                }
            }
        }
    }//end of getFinanceData
    
}

