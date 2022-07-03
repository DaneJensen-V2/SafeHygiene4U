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
class LoginViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    
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
        
      
       
    }
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }

 //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false


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
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
            // ...
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {

                  print(error.localizedDescription)
                    return
                  }
                else{
                  
                    let user = Auth.auth().currentUser
                    
                    let newUser = UserData(Username: "Test", userID: user!.uid, email: user!.email!, ratings: [])
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
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
