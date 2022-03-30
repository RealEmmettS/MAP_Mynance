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


//MARK: User Struct
struct financeUser{
    var id = ""
    var fullName = "" {
        didSet{
            self.firstName = self.fullName.components(separatedBy: " ").first!
        }
    }
    var firstName = ""
    var lastName = ""
    var email = ""
    var financeData:[transaction] = []
    
    func uploadToCloud() {
        if self.fullName != nil || self.fullName != ""{
            updateUser(type: .name, value: self.fullName)
        }
        if self.firstName != nil || self.firstName != ""{
            updateUser(type: .firstName, value: self.firstName)
        }
        if self.email != nil || self.email != ""{
            updateUser(type: .email, value: self.email)
        }
        
    }
    
    func uploadFinanceData() {
        if self.financeData != nil || self.financeData != []{
            if Auth.auth().currentUser != nil {
                db.collection(currentUser.id).document("finances").setData([ "financeData": self.financeData ], merge: true)
            }
        }
    }
    
    mutating func clear(){
        self.id = ""
        self.fullName = ""
        self.firstName = ""
        self.lastName = ""
        self.email = ""
    }
}

var didSignOut = false

struct transaction:Equatable {
    var transactionName:String = ""
    var transactionAmount:Double = 0.0
}


//MARK: Updating Data
let db = Firestore.firestore()
//let dataRef = db.collection(userID).

enum userInfoType{
    case name
    case firstName
    case email
    case transaction
}

func updateUser(type: userInfoType, value: String){
    if Auth.auth().currentUser != nil {
        db.collection(currentUser.id).document("userInfo").setData([ "\(type)": value ], merge: true)
    }
}

//MARK: Manually Getting Data
func getData(documentName: String) -> [String:Any]{
    if Auth.auth().currentUser != nil {
        let docRef = db.collection(currentUser.id).document(documentName)
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
