//
//  SideMenuViewController.swift
//  SideMenu-IOS-Swift
//
//  Created by apple on 12/01/22.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int)
}
class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet var menuView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var sideMenuTableView: UITableView!
    @IBOutlet var footerLabel: UILabel!
    var darkMode = false
    var delegate: SideMenuViewControllerDelegate?
    var defaultHighlightedCell: Int = 0
    var menu : [SideMenuModel] = []
    let authManager = AuthManager()
    var loggedIn = false
    let formLink = "https://docs.google.com/forms/d/e/1FAIpQLSeZIshvJG6vf-BsC7sJGqb2AT2s3-NMCmjRo6IkH7tDM-qYvQ/viewform?usp=sf_link"
    
    var LoggedInmenu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "map.circle")!, title: "Map"),
        SideMenuModel(icon: UIImage(systemName: "person.fill")!, title: "Profile"),
        SideMenuModel(icon: UIImage(systemName: "person.fill.questionmark")!, title: "Suggest a Location"),
        SideMenuModel(icon: UIImage(systemName: "rectangle.portrait.and.arrow.right")!, title: "Logout"),
        SideMenuModel(icon: UIImage(systemName: "questionmark.circle")!, title: "About"),
        SideMenuModel(icon: UIImage(systemName: "moon.fill")!, title: "Dark Mode")


    ]
    
    var LoggedOutmenu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "map.circle")!, title: "Map"),
        SideMenuModel(icon: UIImage(systemName: "person.fill")!, title: "Login"),
        SideMenuModel(icon: UIImage(systemName: "questionmark.circle")!, title: "About"),
        SideMenuModel(icon: UIImage(systemName: "moon.fill")!, title: "Dark Mode")

    ]
                

    override func viewDidLoad() {
        super.viewDidLoad()
        if authManager.checkIfLoggedIn(){
            menu = LoggedInmenu
        }else{
            menu = LoggedOutmenu
        }
        
        // TableView
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.backgroundColor = UIColor(named: "LogoBlue")
        self.sideMenuTableView.separatorStyle = .none
        menuView.layer.cornerRadius = 15
        
        emailLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.adjustsFontSizeToFitWidth = true

        // Set Highlighted Cell
       
        setDefaultCell()
        // Footer
        self.footerLabel.textColor = UIColor.white
        self.footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        self.footerLabel.text = "Version 1.1"
        
        // Register TableView Cell
        self.sideMenuTableView.register(SideMenuCell.nib, forCellReuseIdentifier: SideMenuCell.identifier)
        
        // Update TableView with the data
        self.sideMenuTableView.reloadData()
        
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(changeLabels),
                                                   name: NSNotification.Name(rawValue: "loginChanged"),
                                                   object: nil)
    }
    func setDefaultCell(){
        DispatchQueue.main.async {
            let defaultRow = IndexPath(row: self.defaultHighlightedCell, section: 0)
            self.sideMenuTableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
        }
    }
   @objc func changeLabels() {
            print("Setting text")
        
       if authManager.checkIfLoggedIn(){
           menu = LoggedInmenu
           emailLabel.text = currentUser.email
           usernameLabel.text = currentUser.Username
           
       }else{
           menu = LoggedOutmenu
           emailLabel.text = "Not Signed In"
           usernameLabel.text = ""
       
       }
       self.sideMenuTableView.reloadData()
       setDefaultCell()

    }
   
}

// MARK: - UITableViewDelegate

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITableViewDataSource

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuCell.identifier, for: indexPath) as? SideMenuCell else { fatalError("xib doesn't exist") }
        
        cell.iconImageView.image = self.menu[indexPath.row].icon
        cell.titleLabel.text = self.menu[indexPath.row].title
        
        // Highlighted color
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        cell.selectedBackgroundView = myCustomSelectionColorView
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedCell(indexPath.row)
        // ...
        if indexPath.row == 1{
            if authManager.checkIfLoggedIn(){
                guard let url = URL(string: formLink) else { return }
                UIApplication.shared.open(url)
                setDefaultCell()
            }else{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)

            }
        }
        else if indexPath.row == 2 {
            if authManager.checkIfLoggedIn(){
                guard let url = URL(string: formLink) else { return }
                UIApplication.shared.open(url)
                setDefaultCell()
            }else{
                self.performSegue(withIdentifier: "aboutSegue", sender: nil)
                setDefaultCell()
            }
        }
        else if indexPath.row == 3{
            if authManager.checkIfLoggedIn(){
                authManager.logout()
                setDefaultCell()
            }
            else{
                if darkMode == false{
                    UserDefaults.standard.setValue(Theme.dark.rawValue, forKey: "theme")
                    darkMode = true
                }
                else{
                    UserDefaults.standard.setValue(Theme.light.rawValue, forKey: "theme")
                    darkMode = false
                }
            }
            setDefaultCell()
        }
        else if indexPath.row == 5{
           
                if darkMode == false{
                    UserDefaults.standard.setValue(Theme.dark.rawValue, forKey: "theme")
                    darkMode = true
                }
                else{
                    UserDefaults.standard.setValue(Theme.light.rawValue, forKey: "theme")
                    darkMode = false
                
            }
           
        }
        else if indexPath.row == 6{
         
        }
        else if indexPath.row == 4{
            self.performSegue(withIdentifier: "aboutSegue", sender: nil)
            setDefaultCell()
        }
        
      
        // Remove highlighted color when you press the 'Profile' and 'Like us on facebook' cell
        //if indexPath.row == 4 || indexPath.row == 6 {
       //     tableView.deselectRow(at: indexPath, animated: true)
        //}
    }
}
