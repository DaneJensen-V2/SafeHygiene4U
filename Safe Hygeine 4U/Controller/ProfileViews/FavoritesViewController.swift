//
//  FavoritesViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 8/25/22.
//

import UIKit
import CoreLocation

class FavoritesViewController: UIViewController {


    @IBOutlet weak var favoritesTable: UITableView!
    
    let authManager = AuthManager()
    let locationManager = CLLocationManager()
    var favoritesList : [HygieneAnnotation] = []
    
    @IBOutlet weak var bgView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorites"
       
        if currentUser.favorites.isEmpty{
            favoritesTable.isHidden = true
        }
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.register(UINib(nibName: "ServiceTableViewCell", bundle: nil), forCellReuseIdentifier: "serviceCell")
        loadFavorites(){success in
            DispatchQueue.main.async {
                self.favoritesTable.reloadData()
            }
            
        }

    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        
        if currentUser.favorites.isEmpty{
            favoritesTable.isHidden = true
        }
        else{
            DispatchQueue.main.async {
                self.favoritesTable.reloadData()
            }
        }
    }

 //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes


    }
    func loadFavorites(completion: @escaping (Bool) -> Void){
        for name in currentUser.favorites{
            for list in servicesList{
                for service in list{
                    if name == service.title{
                        favoritesList.append(service)
                    }
                }
            }
        }
        completion(true)
    }

}
extension FavoritesViewController : UITableViewDelegate, UITableViewDataSource {
    func getDistance( completion: @escaping (Bool) -> Void){
        var count = 0
        var distanceInMiles = 0.0
        var listCount = 0
        for list in servicesList{
            count = 0
            for point in list{
                let location = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                let distanceInMeters = locationManager.location?.distance(from: location)
                
                distanceInMiles = (distanceInMeters ?? 0)/1609.344

                servicesList[listCount][count].distance = distanceInMiles
                count+=1
            }
            servicesList[listCount] = list.sorted(by: { $0.distance < $1.distance })
            listCount = listCount + 1
        }
      
        
        completion(true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let service = favoritesList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! ServiceTableViewCell
        
        switch service.type{
        case .shower:
            cell.iconImage.image =  UIImage(named: "shower", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break
        case .clothing :
            cell.iconImage.image =  UIImage(named: "shirt", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break
        case .nonProfit :
            cell.iconImage.image =  UIImage(named: "hands.sparkles", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break

        }
        cell.iconView.layer.cornerRadius = cell.iconView.frame.height / 2

        cell.titleLabel.text = service.title
        cell.starView.rating = service.rating
        if(service.reviews > 0){
            cell.starsLabel.text = String(format: "%.1f", service.rating)

        }
        else{
            cell.starsLabel.text = "None"
        }
        cell.distanceLabel.text = String(format: "%.1f", service.distance) + " mi away"
        
        return cell
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return currentUser.favorites.count
      
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               
            //gets title of point clicked
        let cell = self.tableView(favoritesTable, cellForRowAt: indexPath) as! ServiceTableViewCell

        if let cellTitle = cell.titleLabel.text{
                   //Matches the clicked point to the point in the services list based on title
                   for point in services! {
                          if point.name == cellTitle {
                              selectedService = point
                               break
                           }
                       }
                   }
       
            
        
        performSegue(withIdentifier: "cellToInfo", sender: nil)
        
        favoritesTable.deselectRow(at: indexPath, animated: true)
    }
}
