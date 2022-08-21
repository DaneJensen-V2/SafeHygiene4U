//
//  ProfileViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 8/19/22.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var usernameLabelk: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var settingsTable: UITableView!
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
        self.navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes        // Do any additional setup after loading the view.
        settingsTable.delegate = self
        settingsTable.dataSource = self
        settingsTable.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "settingsCell")

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
            break
        case 1 :
            print("Reset Password")

            break
        case 2:
            print("Change Email")

            break
        case 3:
            print("Logout")

            break
        case 4:
            print("Delete Account")

            break
        default:
            print("Default")
        }
    }
    
}
