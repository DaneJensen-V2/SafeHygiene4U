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
    var delegate: SideMenuViewControllerDelegate?
    var defaultHighlightedCell: Int = 0
    var menu : [SideMenuModel] = []
    let authManager = AuthManager()
    var loggedIn = false
    let darkMode =    SideMenuModel(icon: UIImage(systemName: "moon.fill")!, title: "Dark Mode")
    let lightMode =  SideMenuModel(icon: UIImage(systemName: "sun.min.fill")!, title: "Light Mode")

    let formLink = "https://docs.google.com/forms/d/e/1FAIpQLSdbxoWU08oIgeQ_DxLz3GqV8hDJGctRwwECAT3v3da-JTXknA/viewform?usp=sf_link"
    
    var LoggedInmenu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "map.circle")!, title: "Map"),
        SideMenuModel(icon: UIImage(systemName: "person.fill")!, title: "Profile"),
        SideMenuModel(icon: UIImage(systemName: "star")!, title: "Favorites"),
        SideMenuModel(icon: UIImage(systemName: "mappin.circle")!, title: "Suggest a Location"),
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
    
        if UserDefaults.standard.string(forKey: "theme") == "light"{
            setMenuToDark()
        }
        else{
            setMenuToLight()
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
        self.footerLabel.text = "Version 1.0"
        
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
    func setMenuToLight(){
        
        menu[menu.count - 1] = lightMode
        DispatchQueue.main.async {
            self.sideMenuTableView.reloadData()
        }
    }
    func setMenuToDark(){
        menu[menu.count - 1] = darkMode

        DispatchQueue.main.async {
            self.sideMenuTableView.reloadData()
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
       if UserDefaults.standard.string(forKey: "theme") == "light"{
           setMenuToDark()
       }
       else{
           setMenuToLight()
       }
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
                self.performSegue(withIdentifier: "profileSegue", sender: nil)

                setDefaultCell()
            }else{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                setDefaultCell()

            }
        }
        if indexPath.row == 2{
            if authManager.checkIfLoggedIn(){
                self.performSegue(withIdentifier: "favorites", sender: nil)

                setDefaultCell()
            }else{
                self.performSegue(withIdentifier: "aboutSegue", sender: nil)
                setDefaultCell()

            }
        }
        else if indexPath.row == 3 {
            if authManager.checkIfLoggedIn(){
                guard let url = URL(string: formLink) else { return }
                UIApplication.shared.open(url)
                setDefaultCell()
            }else{
                    if   UserDefaults.standard.string(forKey: "theme") == "light"{
                        UserDefaults.standard.setValue(Theme.dark.rawValue, forKey: "theme")
                        setMenuToLight()
                    }
                                                
                    else{
                        UserDefaults.standard.setValue(Theme.light.rawValue, forKey: "theme")
                        setMenuToDark()
                    }
                }
            }
        
        else if indexPath.row == 4{
            if authManager.checkIfLoggedIn(){
                authManager.logout()
                setDefaultCell()
            }
            
            setDefaultCell()
        }
        else if indexPath.row == 5{
            self.performSegue(withIdentifier: "aboutSegue", sender: nil)
            setDefaultCell()
        }
        
        else if indexPath.row == 6{
            print(UserDefaults.standard.integer(forKey: "theme"))
           
            if   UserDefaults.standard.string(forKey: "theme") == "light"{
                UserDefaults.standard.setValue(Theme.dark.rawValue, forKey: "theme")
              setMenuToLight()
            }
                                        
            else{
                UserDefaults.standard.setValue(Theme.light.rawValue, forKey: "theme")
                setMenuToDark()
            }
            setDefaultCell()

        }

        
      
      
        
      
        // Remove highlighted color when you press the 'Profile' and 'Like us on facebook' cell
        //if indexPath.row == 4 || indexPath.row == 6 {
       //     tableView.deselectRow(at: indexPath, animated: true)
        //}
    }
}