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
    
    var finishedInitialRequest:Bool = false {
        didSet{
            self.generateTestTransaction()
            table.reloadData()
        }
    }
    
    
    ///Stores the processed data retrieved from Firebase. Automatically updates when new data is detected. See the "Auto-Retrieve Data" mark to observe the auto-updating procedure.
    var tableContent: [ processed ] = [] {
        didSet{
            table.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableContent = []
        currentUser.financeData = []
        
        table.dataSource = self
        table.delegate = self
        
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
        let welcomeText = ("Hello " + currentUser.firstName)
        print(welcomeText) // First
        nameLabel.text = welcomeText
        
        getFinanceData()
        
    }
    
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
    
    
    //MARK: Test Transaction
    func generateTestTransaction(){
        //Replace 0 with the minimum, and replace 6 with the maximum
        let random:Double = Double.random(in: 0..<100).rounded(toPlaces: 2)
        let name:String = ("TEST TRANSACTION").withDate()
        currentUser.newTransaction(name: name, amount: random)
    }
    
    
    //MARK: Manually Getting Data
    ///Used mainly to trigger the 'finishedInitialRequest' variable, which enables further user interaction. This is in place to prevent inaccurate loading or crashing of the app while current data has not yet been fectched
    func getFinanceData(){
        if Auth.auth().currentUser != nil {
            let docRef = db.collection(currentUser.id).document("finance")
            var returnValue: [String:Any] = ["":""]
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    returnValue = document.data()!
                    
                    //By default, Firebase returns arrays as an __NSArrayM which doesn't make any sense. This turns that __NSArrayM data to what it's supposed to be, which is an array full of dictionaries.
                    let processedData = returnValue["financeData"] as! [[String : Double]]
                    
                    currentUser.financeData = returnValue["financeData"] as! [[String : Double]]
                    
                    
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

