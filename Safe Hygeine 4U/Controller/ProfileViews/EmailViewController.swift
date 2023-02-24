//
//  EmailViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/29/22.
//

import UIKit

var currentEmail : String = ""
class EmailViewController: UIViewController {

    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
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


    @IBAction func nextClicked(_ sender: UIButton) {
        currentEmail = emailTextBox.text!
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
extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
