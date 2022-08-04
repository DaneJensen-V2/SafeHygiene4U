//
//  AboutViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/30/22.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About"

    }
    
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.navigationController?.navigationBar.isHidden = false
    }

 //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true



    }
  

}
