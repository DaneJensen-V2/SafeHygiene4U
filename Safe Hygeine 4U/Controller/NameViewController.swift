//
//  NameViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/29/22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class NameViewController: UIViewController {

    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var takenLabel: UILabel!
    var currentUsername = ""
    let db = Firestore.firestore()
    //let authManager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
        nextButton.isEnabled = false
        nextButton.backgroundColor = .lightGray
        spinner.isHidden = true
        AuthManager().logout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        nextButton.layer.cornerRadius = 20
        passwordTextBox.becomeFirstResponder()

    }
    
    @IBAction func createAccountPushed(_ sender: UIButton) {
        view.endEditing(true)
        spinner.isHidden = false
        spinner.startAnimating()
        currentUsername = passwordTextBox.text!
        checkUsername()
    }
    
    func createAccount(email : String, password : String, Username : String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error{
                let alert = UIAlertController(title: "Registration Error", message: e.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                self.present(alert, animated: true)
                print(e.localizedDescription)
            }
            
            else{
                
                let user = Auth.auth().currentUser
                
                let newUser = UserData(Username: Username, userID: user!.uid, email: email, ratings: [])
                currentUser = newUser
                
                self.addNewUser(newUser: newUser)
                
                AuthManager().loadCurrentUser(user: user!, completion: { success in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.tabBarController?.tabBar.isHidden = false
                    self.navigationController?.navigationBar.isHidden = true
                })
               
                
                
            }
        }
        
    }
    
    func createGoogleAccount(){
        Auth.auth().signIn(with: credential!) { authResult, error in
            if let error = error {
                
                print(error.localizedDescription)
                return
            }
            else{
                googleUser.Username = self.currentUsername
                
                self.addNewUser(newUser: googleUser)
                
                let user = Auth.auth().currentUser
                
                AuthManager().loadCurrentUser(user: user!, completion: { success in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.tabBarController?.tabBar.isHidden = false
                    self.navigationController?.navigationBar.isHidden = true
                    currentUser = googleUser
                    
                })
            }
        }
    }
    
    
    func checkUsername(){
        db.collection("Users").whereField("Username", isEqualTo: currentUsername)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot!.count > 0 {
                        takenLabel.isHidden = false
                        spinner.isHidden = true
                    }
                    else{
                    takenLabel.isHidden = true
                        spinner.isHidden = false
                        if googleAccount == true{
                            createGoogleAccount()
                        }
                        else{
                        createAccount(email: currentEmail, password: currentPassword, Username: currentUsername)

                        }
                    }
                }
        }
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
    @IBAction func textEdit(_ sender: UITextField) {
        if sender.text!.count >= 4 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(named: "LogoBlue")

        }
        else{
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightGray

        }
    }
    
    
    

  

}
