//
//  SignInViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/30/22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class SignInViewController: UIViewController {
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var passwordBox: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        loginButton.layer.cornerRadius = 20
        emailBox.becomeFirstResponder()

    }
    @IBAction func eyeClicked(_ sender: UIButton) {
        passwordBox.togglePasswordVisibility()
    }
    
   
    @IBAction func loginClicked(_ sender: UIButton) {
        view.endEditing(true)
        spinner.isHidden = false
        spinner.startAnimating()
        loginUser(email: emailBox.text!, password: passwordBox.text!, completion: {success in
            self.navigationController?.popToRootViewController(animated: true)

        })
    }
    func loginUser(email : String, password : String, completion:  @escaping (Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            
            if let e = error{
                let alert = UIAlertController(title: "Registration Error", message: e.localizedDescription, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

                self.present(alert, animated: true)
                self.spinner.isHidden = true
                print(e.localizedDescription)
            }else{
                let currentID = Auth.auth().currentUser
                AuthManager().loadCurrentUser(user: currentID!) { success in
                    print("User Loaded")
                    completion(true)
                    self.tabBarController?.tabBar.isHidden = false
                    self.navigationController?.navigationBar.isHidden = true
                }
            }
        }
                print("Success")
               // signedIn = true

                //dismissParent = true
                
            
    }
}
