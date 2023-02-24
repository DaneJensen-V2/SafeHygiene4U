//
//  ProfileViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 8/19/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
class ProfileViewController: UIViewController {
    @IBOutlet weak var usernameLabelk: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var settingsTable: UITableView!
    
    let authManager = AuthManager()
    var profileSettings: [settingsMenuModel] = [
        settingsMenuModel(icon: UIImage(systemName: "person")!, title: "Change Username", tint: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)),
        settingsMenuModel(icon: UIImage(systemName: "lock")!, title: "Password Reset", tint: .black),
        settingsMenuModel(icon: UIImage(systemName: "envelope")!, title: "Change Email",tint: #colorLiteral(red: 0.1959999949, green: 0.6779999733, blue: 0.90200001, alpha: 1)),
        settingsMenuModel(icon: UIImage(systemName: "rectangle.portrait.and.arrow.right")!, title: "Logout",tint: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)),
        settingsMenuModel(icon: UIImage(systemName: "trash")!, title: "Delete Account", tint: .red),
       


    ]
    @IBOutlet weak var bgView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        emailLabel.text = "Email: " + currentUser.email
        usernameLabelk.text = currentUser.Username
        
       // bgView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
      
        settingsTable.delegate = self
        settingsTable.dataSource = self
        settingsTable.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "settingsCell")

    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
    }

 //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes


    }

}
extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! ProfileTableViewCell
        cell.settingsImage.image = profileSettings[indexPath.row].icon
        cell.settingsImage.backgroundColor  = profileSettings[indexPath.row].tint
        cell.label.text = profileSettings[indexPath.row].title
        cell.layer.masksToBounds = true

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            print("Change Username")
            performSegue(withIdentifier: "changeUsername", sender: nil)
            break
            
        case 1 :
            print("Reset Password")
            print("Are you sure that you want to reset password?")
            print("Error, password was unable to be reset. Please contact safehygiene4U@gmail.com")
            
            print(currentUser.email)
            Auth.auth().sendPasswordReset(withEmail: currentUser.email) { error in
                if let error = error{
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let alert = UIAlertController(title: "Password Reset", message: "Password reset email sent.", preferredStyle: UIAlertController.Style.alert)
                    print("Password reset email was sent. Contacting user")
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
          
            break
        case 2:
            print("Change Email")
            print("Change how the men look at the app. Don't meeed and and")
            performSegue(withIdentifier: "emailChange", sender: nil)
        
            break
        case 3:
            authManager.logout()
            self.navigationController?.popToRootViewController(animated: true)
            print("Logout")

            break
        case 4:
            print("Delete Account")
            let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertController.Style.alert)

                    // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
                
                db.collection("Users").document(currentUser.userID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                    
                    let user = Auth.auth().currentUser

                    user?.delete { error in
                      if let error = error {
                          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                          alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: nil))

                          // show the alert
                          self.present(alert, animated: true, completion: nil)                      } else {
                          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                          self.navigationController?.popToRootViewController(animated: true)
                      }
                    }
                }
            }))
        
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
            break
        default:
            print("Default")
        }
    }
    
}
