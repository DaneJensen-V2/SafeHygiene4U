//
//  ListViewExt.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/5/22.
//

import Foundation
import UIKit
import CoreLocation

extension MapViewController {

}
extension MapViewController : UITableViewDelegate, UITableViewDataSource{
  
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
        let service = filteredData![indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! ServiceTableViewCell
        
        switch service.type{
        case .shower:
            cell.iconImage.image =  UIImage(named: "shower", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break
        case .clothing :
            cell.iconImage.image =  UIImage(named: "shirt", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break
        case .nonProfit :
            cell.iconImage.image =  UIImage(named: "shirt", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break

        }
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
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return servicesList.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }

        return nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?[section].count ?? 0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               
            //gets title of point clicked
        let cell = self.tableView(serviceTable, cellForRowAt: indexPath) as! ServiceTableViewCell

        if let cellTitle = cell.titleLabel.text{
                   
                   //Matches the clicked point to the point in the services list based on title
                   for point in services! {
                          if point.name == cellTitle {
                              selectedService = point
                               break
                           }
                       }
                   }
               //Sets image for view based on type
            switch selectedService?.serviceType{
               case "Bathroom":
                   pinClickedImage.image =  UIImage(named: "toilet", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
                   break
               case "Shower":
                   pinClickedImage.image =  UIImage(named: "shower", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
                   break
               case "Laundromat":
                   pinClickedImage.image =  UIImage(named: "shirt", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
                   break
               default:
                   print("Default")
                   break
               }
      
            
        
        performSegue(withIdentifier: "cellToInfo", sender: nil)
        
        serviceTable.deselectRow(at: indexPath, animated: true)
    }
}

extension MapViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = [[], [], []]
        var count = 0
        if searchText == ""{
            filteredData = servicesList
        }
        
        for list in servicesList{
            
            for value in list {
                if  value.title!.uppercased().contains(searchText.uppercased())
                {
                    filteredData![count].append(value)
                }
                
            }
            count = count + 1

        }
        self.serviceTable.reloadData()

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
