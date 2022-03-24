//
//  SignIn-ViewController.swift
//  finance
//
//  Created by Emmett Shaughnessy on 3/24/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FirebasePhoneAuthUI
import FirebaseEmailAuthUI


class SignIn_ViewController: UIViewController, FUIAuthDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        
        if didSignOut == true{
            signOutWithFirebase()
            didSignOut = false
        }
        
        if isUserSignedIn() {
            //userName = getData(documentName: "userInfo")
            performSegue(withIdentifier: "movePastSignIn", sender: nil)
        }
        
    }
    
    //MARK: Sign In Pressed
    @IBAction func pressed(_ sender: Any) {
        print("\n\n\nPresenting AuthUI\n\n\n")
        
        let authUI = FUIAuth.defaultAuthUI()
        authUI!.delegate = self
        
        
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(),
            //          FUIGoogleAuth(),
            //          FUIFacebookAuth(),
            //          FUITwitterAuth(),
            //          FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
        ]
        authUI!.providers = providers
        
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: true, completion: nil)
    }
    //MARK: authUI
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error == nil{
            print("\n\n –– success –– \n\n")
            //userName = getData(documentName: "userInfo")
            guard let user = Auth.auth().currentUser else {return}
            userID = user.uid
            userName = user.displayName ?? ""
            performSegue(withIdentifier: "movePastSignIn", sender: nil)
        }else{
            print("\n\n –– error –– \n\n")
        }
        
        //        switch error{
        //        case nil:
        //            print("\n\n –– success –– \n\n")
        //        default:
        //            print("\n\n –– error –– \n\n")
        //        }
    }
    
    //MARK: isUserSignedIn()
    func isUserSignedIn() -> Bool{
        if Auth.auth().currentUser != nil {
            // User is signed in.
            let user = Auth.auth().currentUser
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                let uid = user.uid
                userID = uid
                let email = user.email
                updateUser(type: .email, value: user.email!)
                let photoURL = user.photoURL
                var multiFactorString = "MultiFactor: "
                for info in user.multiFactor.enrolledFactors {
                    multiFactorString += info.displayName ?? "[DispayName]"
                    multiFactorString += " "
                }
                // ...
            }
            
            //MARK: Auto-Retrieve Data
            db.collection(userID).document("userInfo")
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        userName = "false"
                        return
                    }
                    print("Current data: \(data)")
                    userName = "\(user?.displayName)"
                    print("\n\n\n\n\nhello \(firstName)\n\n\n\n\n")
                }
            
            return true
        } else {
            // No user is signed in.
            return false
        }
    }
    
    //MARK: Sign Out
    func signOutWithFirebase(){
        //Resetting AuthUI and its properties
        let authUI = FUIAuth.defaultAuthUI()
        authUI!.delegate = self
        let providers: [FUIAuthProvider] = [
            //3FUIGoogleAuth(),
            FUIEmailAuth(),
            /*FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),*/
        ]
        authUI!.providers = providers
        
        //Signing out of everything...
        let firebaseAuth = Auth.auth()
        do {
            try authUI!.signOut()
            try firebaseAuth.signOut()
            userID = ""
        } catch {
            print("Uh-Oh")
        }
    }
    
    
    
}
