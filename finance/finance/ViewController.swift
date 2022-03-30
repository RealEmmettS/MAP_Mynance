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

class ViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                print("Current data: \(data)")
                //someVariableName = "\(data["name"]!)"
                //code goes here
            }
        
    }//end viewDidLoad()
    
    override func viewDidAppear(_ animated: Bool) {
        //String name = user.getDisplayName();
        let welcomeText = ("Hello " + currentUser.firstName)
        print(welcomeText) // First
        nameLabel.text = welcomeText
    }
    
    //MARK: Update Data Example
//    if Auth.auth().currentUser != nil {
//        db.collection(currentUser.id).document("DOCNAME").setData([ "name": value ], merge: true)
//    }
    
    


}

