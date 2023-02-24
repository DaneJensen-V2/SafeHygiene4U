//
//  AboutViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/30/22.
//

import UIKit

class AboutViewController: UIViewController, UITextViewDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       

                                        
                                        
               
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

 //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes


    }
  
    @IBAction func linkClicked(_ sender: UIButton) {
        self.title = "About"
        
        var email = "info.safehygiene4u@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
          UIApplication.shared.open(URL)
          return false
      }
}

