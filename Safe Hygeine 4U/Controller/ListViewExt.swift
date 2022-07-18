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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servicesList.count
    }
    func getDistance( completion: @escaping (Bool) -> Void){
        var count = 0
        var distanceInMiles = 0.0
        for point in servicesList{
            let location = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
            let distanceInMeters = locationManager.location?.distance(from: location)
            
            distanceInMiles = (distanceInMeters ?? 0)/1609.344
            servicesList[count].distance = distanceInMiles
            count+=1
        }
        servicesList = servicesList.sorted(by: { $0.distance < $1.distance })
        completion(true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let service = servicesList[indexPath.row]
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
        default:
            print("Default")
            break
        }
        cell.titleLabel.text = service.title
        cell.starsLabel.text = String(service.rating)
        cell.distanceLabel.text = String(format: "%.1f", service.distance) + " mi away"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var pointInArray : ServiceInfo?
               
            //gets title of point clicked
        let cell = self.tableView(serviceTable, cellForRowAt: indexPath) as! ServiceTableViewCell

        if let cellTitle = cell.titleLabel.text{
                   
                   //Matches the clicked point to the point in the services list based on title
                   for point in services! {
                          if point.name == cellTitle {
                               pointInArray = point
                              selectedService = point
                               break
                           }
                       }
                   }
               //Sets image for view based on type
            switch pointInArray?.serviceType{
               case "Bathroom":
                   pinClickedImage.image =  UIImage(named: "bathroom", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
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
        print(selectedService!.rating )
      
            
        
        performSegue(withIdentifier: "cellToInfo", sender: nil)
        
        serviceTable.deselectRow(at: indexPath, animated: true)
    }
}
extension MapViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
/*
        if searchText == ""{
            filteredData = data
        }
        for value in data{
            
            if  value.WebsiteName.uppercased().contains(searchText.uppercased())
            {
                filteredData.append(value)
            }
        }
        self.websiteTable.reloadData()
 */
    }
}
