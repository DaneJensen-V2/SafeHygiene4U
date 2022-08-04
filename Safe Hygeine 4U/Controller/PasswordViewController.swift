//
//  PasswordViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/29/22.
//

import UIKit

var currentPassword = ""
class PasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
        nextButton.isEnabled = false
        nextButton.backgroundColor = .lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = false
        nextButton.layer.cornerRadius = 20
        passwordTextBox.becomeFirstResponder()

    }
    
    @IBAction func EyeClicked(_ sender: Any) {
        passwordTextBox.togglePasswordVisibility()
    }
    @IBAction func textChanged(_ sender: UITextField) {
        if sender.text!.count >= 8 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(named: "LogoBlue")

        }
        else{
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightGray

        }
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        currentPassword = passwordTextBox.text!
    }
    
}
extension UITextField {
    func togglePasswordVisibility() {
        isSecureTextEntry = !isSecureTextEntry

        if let existingText = text, isSecureTextEntry {
            /* When toggling to secure text, all text will be purged if the user
             continues typing unless we intervene. This is prevented by first
             deleting the existing text and then recovering the original text. */
            deleteBackward()

            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }

        /* Reset the selected text range since the cursor can end up in the wrong
         position after a toggle because the text might vary in width */
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
}
