
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import GooglePlaces
import CoreData
var servicesList:[HygieneAnnotation] = []

class DBManager{
    //Connects to the database
    let placesClient = GMSPlacesClient()
    var serviceLIst = [ServiceInfo]()
    let db = Firestore.firestore()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //Loads data from database and stores it into a list of services
    func loadData(completion: @escaping (Bool) -> Void){
        var count = 0
        print("Loading Data")
        db.collection("Services").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                //    print("\(document.documentID) => \(document.data())")
                    let result = Result {
                        try document.data(as: fullServiceInfo.self)
                    }
                    switch result {
                    case .success(let newService):
                        self.parseData(data: newService){success in
                            print("Completion Ran")
                            count += 1
                            if count == querySnapshot!.documents.count{
                                completion(true)
                            }
                        }
                        break
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding city: \(error)")
                        completion(true)
                        break
                    }
                }
            }
        }
    }
    func parseData(data : fullServiceInfo, completion: @escaping (Bool) -> Void){
            getGoogleID(dataX: data){ success in
                completion(true)

            }
        }
    func DeleteAllData(){


        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ServiceInfo"))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
        
    func updateReviews(completion: @escaping (Bool) -> Void){
        let serviceFetch: NSFetchRequest<ServiceInfo> = ServiceInfo.fetchRequest()
        do {
                let results = try context.fetch(serviceFetch)
                serviceLIst = results
            }
        catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        var count = 0
        print("Loading Reviews")
        db.collection("Reviews").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    

                            guard let dict = document.data() else { return }
                            
                            print(dict)

                            guard let orderItems = dict as? NSDictionary else {return}

                            let numReviews = orderItems.value(forKey: "Review Count") as? Int ?? 0
                            let overallRating = orderItems.value(forKey: "Overall Rating") as? Double ?? 0.0


                    self.updateData(Reviews: numReviews, Rating: overallRating, location: document.documentID){success in
                            
                        }
                }
                completion(true)
            }
        }
         
    }
    func updateData(Reviews : Int, Rating : Double, location : String, completion: @escaping (Bool) -> Void){
      
            //Matches the clicked point to the point in the services list based on title
                
        getCount(location: location){count in
            self.serviceLIst[count].setValue(Reviews, forKey: #keyPath(ServiceInfo.reviews))
            self.serviceLIst[count].setValue(Rating, forKey: #keyPath(ServiceInfo.rating))
            do {
                print("saved")
                try self.context.save()
                completion(true)
            }
            catch{
                print("Could not save data")
            }
        }

}
func getCount(location: String, completion: @escaping (Int) -> Void){
    var count = 0
    var found = false
        for point in services! {
               if point.name == location {
                   
                   found = true
                    break
                }
            else{
                count = count + 1
            }
            }
    if found{
            completion(count)
    }
}

    func getGoogleID(dataX : fullServiceInfo, completion: @escaping (Bool) -> Void){

        var nameString = ""
        if  dataX.hostName != ""{
            nameString = dataX.hostName!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        else{
            nameString = dataX.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        
        let baseURL = """
https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=place_id%2Cname&input=\(nameString)&inputtype=textquery&locationbias=point%3A\(dataX.latitude)%2C\(dataX.longitude)&key=AIzaSyD_6-EQYz6EfnqTrrCWafUeZBqmNB_0ocw
"""
        let url = URL(string : baseURL)
     //   print(baseURL)
        
        let request = URLRequest(url: url!)
       // request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
     //   request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
              //  completionHandler(nil, error)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                guard let resp = json as? NSDictionary else {return}
                
                guard let businesses = resp.value(forKey: "candidates") as? [NSDictionary] else {return}
                    
                if businesses.count >= 1{
                    print(dataX.latitude)
                    print(dataX.longitude)
                    let business = businesses[0]
                    print(businesses)
                    let ID = business.value(forKey: "place_id") as? String
                    
                    //   print("ID = \(ID)")
                    self.getGoogleInfo(ID: ID!, data: dataX){success in
                        completion(true)
                    }
                    // completionHandler(venue, nil)
                    
                }
                else{
                    print("Business Not Found")
                    completion(true)
                }
            }
            catch{
                print("Caught Error")
            }
        }.resume()
    }
    
    func getGoogleInfo(ID : String, data : fullServiceInfo, completion: @escaping (Bool) -> Void){
        // Specify the place data types to return.
        // A hotel in Saigon with an attribution.
        let placeID = ID

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue) |
                                                  UInt(GMSPlaceField.website.rawValue) |
                                                  UInt(GMSPlaceField.phoneNumber.rawValue) |
                                                  UInt(GMSPlaceField.formattedAddress.rawValue) |
        UInt(GMSPlaceField.openingHours.rawValue) |
        UInt(GMSPlaceField.iconImageURL.rawValue) |
        UInt(GMSPlaceField.photos.rawValue))
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            
            return
          }
          if let place = place {
              print(data.name)
              let serviceInfo = ServiceInfo(context: self.context)
              if data.isOnGoogle == true{
                  serviceInfo.phoneNumber = place.phoneNumber
                  serviceInfo.longitude = data.longitude
                  serviceInfo.latitude = data.latitude
                  serviceInfo.isOnGoogle = data.isOnGoogle
                  serviceInfo.address = place.formattedAddress
                  serviceInfo.name = place.name!
                  serviceInfo.hostName = data.hostName
                  serviceInfo.rating = data.rating ?? 0.0
                  serviceInfo.hours = []
                  serviceInfo.reviews = data.reviews ?? 0
                  serviceInfo.serviceDetails = []
                  serviceInfo.website = place.website?.absoluteString
                  serviceInfo.serviceType = data.serviceType
                  serviceInfo.isEvent = data.isEvent
                  serviceInfo.isVerified = data.isVerified
                  serviceInfo.notes = data.notes
              }
              else{
                  serviceInfo.phoneNumber = data.phoneNumber
                  serviceInfo.longitude = data.longitude
                  serviceInfo.latitude = data.latitude
                  serviceInfo.isOnGoogle = data.isOnGoogle
                  serviceInfo.address = place.formattedAddress
                  serviceInfo.name = data.name
                  serviceInfo.hostName = data.hostName
                  serviceInfo.rating = data.rating ?? 0.0
                  serviceInfo.hours = []
                  serviceInfo.reviews = data.reviews ?? 0
                  serviceInfo.website = data.website
                  serviceInfo.serviceType = data.serviceType
                  serviceInfo.isEvent = data.isEvent
                  serviceInfo.isVerified = data.isVerified
                  serviceInfo.notes = data.notes


              }
              if let sDetails = data.serviceDetails{
                  serviceInfo.serviceDetails =  sDetails.components(separatedBy: ",")
              }
              else{
                  serviceInfo.serviceDetails = []
              }
              self.saveImage(place: place, image: data.image){image in
                  serviceInfo.image = image
                  do {
                      print("saved")
                      try self.context.save()
                      completion(true)
                  }
                  catch{
                      
                  }
              }
              
          }
        })
    }
    func saveImage(place : GMSPlace, image : String?, completion: @escaping (String) -> Void){
        
        if image != ""{
            print("Loading image from URL for place \(place.name)" )
            let url = URL(string: image!)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            completion(convertImageToBase64String(img: UIImage(data: data!)!))
            
        }
        
        else if let photoMetadata: GMSPlacePhotoMetadata = place.photos?[0] {
            print("Loading image from Google for place \(place.name)" )

            // Call loadPlacePhoto to display the bitmap and attribution.
            placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                if let error = error {
                    // TODO: Handle the error.
                    print("Error loading photo metadata: \(error.localizedDescription)")
                    return
                } else {
                    // Display the first image and its attributions.
                    let image : UIImage = photo ?? UIImage(named: "logo")!
                    //  print("Set Image")
                    completion(self.convertImageToBase64String(img: image))
                    
                }
            })
        }
    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    }


