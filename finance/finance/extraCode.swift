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
    var financeData:[ [String:Double] ] = [] {
        didSet{
            //print("\n\n\n\n\nFINANCEDATA:\n\(self.financeData)\n\n\n\n\n")
            
        }
    }
    
    mutating func newTransaction(name:String, amount:Double){
        self.financeData.append( [name.withDate(): amount] )
        uploadFinanceData()
    }
    
    func removeTransaction(indexNumber index: Int){
        print("removing data...\n")
        currentUser.financeData.remove(at: index)
        uploadFinanceData()
    }
    
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
    
    mutating func clear(){
        self.id = ""
        self.fullName = ""
        self.firstName = ""
        self.lastName = ""
        self.email = ""
    }
}

var didSignOut = false


//MARK: Updating Data
let db = Firestore.firestore()
//let dataRef = db.collection(userID).

enum userInfoType{
    case name
    case firstName
    case email
    case transaction
}

//Update User Info
func updateUser(type: userInfoType, value: String){
    if Auth.auth().currentUser != nil {
        db.collection(currentUser.id).document("userInfo").setData([ "\(type)": value ], merge: true)
    }
}

//Update Finance Data
func uploadFinanceData(){
    DispatchQueue.main.async {
        print("\n\n\n\n\nFINANCEDATA:\n\(currentUser.financeData)\n\n\n\n\n")
        if Auth.auth().currentUser != nil {
            if currentUser.financeData != nil || currentUser.financeData != []{
                db.collection(currentUser.id).document("finances").setData(["financeData" : currentUser.financeData])
            }
        }
    }
}

struct processed{
    var name:String
    var amount:Double
    var Date: Date
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
    
    func withDate() -> String{
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = df.string(from: date)
        
        let numWithDate:String = "\(self)&&&\(dateString)"
        //print(numWithDate)
        
        return numWithDate
    }
    
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let current = self
        let divisor = pow(10.0, Double(places))
        let finalNum:Double = (current * divisor).rounded() / divisor
        
        return finalNum
    }
    
}//end Double extension



extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }//end of toDouble()
    
    func withDate() -> String{
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = df.string(from: date)
        
        let strWithDate:String = "\(self)&&&\(dateString)"
        //print(numWithDate)
        
        return strWithDate
    }
    
    func withoutOptional() -> String{
        var string = self
        string = (string.components(separatedBy: NSCharacterSet.decimalDigits) as NSArray).componentsJoined(by: "")
        let wordToRemove = "Optional(\""
        
        if let range = string.range(of: wordToRemove) {
            string.removeSubrange(range)
        }
        
        return string
    }//end of withoutOptional()
    
    
    func toDate() -> Date{
        let rawDate = self
        let step1 = rawDate.components(separatedBy: " +")
        let isoDate = step1[0]
        print(isoDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from:isoDate)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        let finalDate = calendar.date(from:components)
        return finalDate!
    }
    
}// end of "extension String"
