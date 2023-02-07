//
//  LoginViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/26/22.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
var googleUser = UserData(Username: "", userID: "", email: "", ratings: [])
var googleAccount = false
var credential: AuthCredential?
class LoginViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet weak var googleButton: UIButton!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 10
        googleButton.layer.cornerRadius = 10
        googleButton.layer.borderWidth = 1
        googleSignIn.alpha = 0.05
        // Do any additional setup after loading the view.
        logoImage.layer.cornerRadius = logoImage.frame.height / 2
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        
    }
    func addNewUser(newUser : UserData ){
        let user = Auth.auth().currentUser
        
        try! self.db.collection("Users").document(user!.uid).setData(from : newUser)
        { (error) in
            if let e = error{
                print("There was an issue saving data to firestore, \(e)")
            }
            else{
                print("Successfully saved data.")
            }
        }
    }
    
    @IBAction func signinPressed(_ sender: GIDSignInButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self ){ [unowned self] signInResult, error in
            
            guard let result = signInResult else {
                return
            }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            
                let authentication = result.user
                let idToken = authentication.idToken
            
            
            
            credential = GoogleAuthProvider.credential(withIDToken: idToken!.tokenString,
                                                       accessToken: authentication.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential!) { authResult, error in
                if let error = error {
                    
                    print(error.localizedDescription)
                    return
                }
                else{
                    
                   let authManager = AuthManager()
                    let user = Auth.auth().currentUser
                    authManager.loadCurrentUser(user: user!){result in
                        if result == true{
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        else{
                            //Google User is Logged in but has no username

                            googleUser = UserData(Username: "", userID: user!.uid, email: user!.email!, ratings: [])
                            googleAccount = true
                            self.performSegue(withIdentifier: "googleToUsername", sender: nil)
                        }
                    }
    
                }
            }
        }
    
    }
}
