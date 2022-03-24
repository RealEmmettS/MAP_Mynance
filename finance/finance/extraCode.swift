//
//  extraCode.swift
//  Voluntracker
//
//  Created by Emmett Shaughnessy on 12/1/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseAuthUI

//MARK: Global Variables
var userID = "" {
    didSet{
        print("\n\nUser ID: \(userID)\n\n")
    }
}

var userName = "" {
    didSet{
        print("\n\nUser's Name: \(userName)\n\n")
        let nonOptional:String = userName.withoutOptional()
        firstName = nonOptional.components(separatedBy: " ").first!
    }
}

var firstName = ""

struct financeUser{
    public var id = ""
    public var fullName = ""
    public var firstName = ""
    public var lastName = ""
    public var email = ""
}

var didSignOut = false




//MARK: Updating Data
let db = Firestore.firestore()
//let dataRef = db.collection(userID).

enum userInfoType{
    case name
    case email
    case working
}

func updateUser(type: userInfoType, value: String){
    if Auth.auth().currentUser != nil {
        db.collection(userID).document("userInfo").setData([ "\(type)": value ], merge: true)
    }
}

//MARK: Manually Getting Data
func getData(documentName: String) -> [String:Any]{
    if Auth.auth().currentUser != nil {
        let docRef = db.collection(userID).document(documentName)
        var returnValue: [String:Any] = ["":""]
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                returnValue = document.data()!
            } else {
                print("Document does not exist")
                returnValue = ["no":"no"]
                print("Return Value: \(returnValue)\n\n")
            }
        }
        
        return returnValue
    }else{
        return ["no":"no"]
    }
    
    
}



//MARK: Exra Stuff
extension UITextField{
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}


//MARK: Extensions
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}



extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }//end of toDouble()
    
    func withoutOptional() -> String{
        var string = self
        string = (string.components(separatedBy: NSCharacterSet.decimalDigits) as NSArray).componentsJoined(by: "")
        let wordToRemove = "Optional(\""
        
        if let range = string.range(of: wordToRemove) {
            string.removeSubrange(range)
        }
        
        return string
    }//end of withoutOptional()
    
}// end of "extension String"
