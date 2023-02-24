//
//  ChangeUsernameViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 8/23/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class ChangeUsernameViewController: UIViewController {

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = false
        nextButton.layer.cornerRadius = 20
        passwordTextBox.becomeFirstResponder()

    }
    override func viewWillDisappear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = true
    

    }
    
    @IBAction func createAccountPushed(_ sender: UIButton) {
        view.endEditing(true)
        spinner.isHidden = false
        spinner.startAnimating()
        currentUsername = passwordTextBox.text!
        checkUsername()
    }
    
    func changeUsername(){
        let userRef = db.collection("Users").document(currentUser.userID)

        // Set the "capital" field of the city 'DC'
        userRef.updateData([
            "Username": currentUsername
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                currentUser.Username = self.currentUsername
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
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
                        
                       
                            print("Changing Username")

                        changeUsername()

                        }
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


