//
//  EmailChangeViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 8/23/22.
//

import UIKit
import FirebaseAuth

class EmailChangeViewController: UIViewController {

    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    var newEmail = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Change Email"

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
        nextButton.isEnabled = false
        nextButton.backgroundColor = .lightGray
        googleAccount = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = false
        nextButton.layer.cornerRadius = 20
        emailTextBox.becomeFirstResponder()

    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes


    }

    @IBAction func nextClicked(_ sender: UIButton) {
        newEmail = emailTextBox.text!
        Auth.auth().currentUser?.updateEmail(to: newEmail){error in
            if let error = error{
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            else{
                currentUser.email = self.newEmail
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        
    }

    @IBAction func textChanged(_ sender: UITextField) {
        if sender.text!.isValidEmail() {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(named: "LogoBlue")

        }
        else{
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightGray

        }
    }
    
}

