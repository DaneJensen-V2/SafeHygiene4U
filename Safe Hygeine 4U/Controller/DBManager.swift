
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import GooglePlaces
import CoreData

var servicesList: [[HygieneAnnotation]] = [[], [], []]


class DBManager{
    //Connects to the database
    let placesClient = GMSPlacesClient()
    var serviceLIst = [ServiceInfo]()
    let db = Firestore.firestore()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //Loads data from database and stores it into a list of services
    
    func loadData(completion: @escaping (Bool) -> Void){
        print("Load Data Entered")
        var count = 0
        print("Loading Data")
        db.collection("Test").getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false)
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: fullServiceInfo.self)
                    }
                    switch result {
                    case .success(let newService):
                        self.addServiceToDB(serviceToAdd: newService) {success in
                            
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
    
    func addServiceToDB(serviceToAdd service : fullServiceInfo, completion: @escaping (Bool) -> Void){
        
        let serviceInfo = ServiceInfo(context: self.context)
     
            serviceInfo.phoneNumber = service.phoneNumber
            serviceInfo.longitude = service.longitude
            serviceInfo.latitude = service.latitude
            serviceInfo.isOnGoogle = service.isOnGoogle
            serviceInfo.address = service.address
            serviceInfo.name = service.name
            serviceInfo.hostName = service.hostName
            serviceInfo.rating = service.rating ?? 0.0
            serviceInfo.reviews = service.reviews ?? 0
            serviceInfo.website = service.website
            serviceInfo.serviceType = service.serviceType
            serviceInfo.isEvent = service.isEvent
            serviceInfo.isVerified = service.isVerified
            serviceInfo.notes = service.notes
        
            let sDetails = service.serviceDetails
            serviceInfo.serviceDetails =  sDetails.components(separatedBy: ",")
        
            serviceInfo.image = service.image
            
        self.parseHours(hoursString: service.hours ?? "", isOnGoogle: service.isOnGoogle ){days in
                serviceInfo.hours = days
            }
        
        do {
            try self.context.save()
            completion(true)
        }
        catch {
            print("Unable to save " + service.name)
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
                    

                             let dict = document.data() 
                            
                            //print(dict)

                            guard let orderItems = dict as? NSDictionary else {return}

                            let numReviews = orderItems.value(forKey: "Review Count") as? Int ?? 0
                            let overallRating = orderItems.value(forKey: "Overall Rating") as? Double ?? 0.0


                    self.updateData(Reviews: numReviews, Rating: overallRating, location: document.documentID){success in
                            
                        }
                }
                NotificationCenter.default.post(name: Notification.Name("ReviewAdded"), object: nil)
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
    print("Get Count Entered")

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

   
    
   
    
    func parseHoursGoogle(hours: GMSOpeningHours, completion: @escaping ([String]) -> Void){
        print("Parse Google Hours Entered")

     
        
    }
    
    func parseHours(hoursString: String, isOnGoogle : Bool, completion: @escaping ([String]) -> Void){
        print("Parse Hours Entered")
        print(hoursString)
        
        if  (hoursString == "" || hoursString == "Hours not available.") {
            completion([])

        }
        else{
            let charSet = CharacterSet(charactersIn: ",")
            let seperatedHours = hoursString.components(separatedBy: charSet)
            
            if isOnGoogle {
   
                
                var result = [String](repeating: "Closed", count: 7) // 1 dimension array

                for i in 0...seperatedHours.count - 1{
                        let time = seperatedHours[i].split(separator: ":", maxSplits: 1).map(String.init)
                        
                        result[i] = time[1]
                    }
                
                
                completion(result)
            }
            else {
                var days = [String](repeating: "Closed", count: 7) // 1 dimension array
                
                for s in seperatedHours{
                    let noSpace = s.trimmingCharacters(in: .whitespacesAndNewlines)
                    if noSpace[1] == "-"{
                        let start = Int(noSpace[0])
                        let end = Int(noSpace[2])
                        for i in start!...end! {
                            let time = s.split(separator: ":", maxSplits: 1).map(String.init)
                            
                            days[i] = time[1]
                        }
                    }
                    else {
                        let day = Int(noSpace[0])
                        let time = s.split(separator: ":", maxSplits: 1).map(String.init)
                        
                        days[day!] = time[1]
                    }
                    print("Done")
                }
                print("Completion Ran")
                completion(days)
            }
         
        }
    }

  
    func saveImage(place : GMSPlace, image : String?, completion: @escaping (String) -> Void){
        print("Save Image Entered")

        if image != ""{
          //  print("Loading image from URL for place \(place.name)" )
            let url = URL(string: image!)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            completion(convertImageToBase64String(img: UIImage(data: data!)!))
            
        }
        
        else if let photoMetadata: GMSPlacePhotoMetadata = place.photos?[0] {

            
            // Call loadPlacePhoto to display the bitmap and attribution.
            placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                if let error = error {
                    // TODO: Handle the error.
                    print("Error loading photo metadata: \(error.localizedDescription)")
                    completion(self.convertImageToBase64String(img: UIImage(named: "Logo")!))
                    return
                } else {
                    // Display the first image and its attributions.
                    let image : UIImage = photo ?? UIImage(named: "Logo")!
                    //  print("Set Image")
                    completion(self.convertImageToBase64String(img: image))
                    
                }
            })
        }
        else{
            completion(self.convertImageToBase64String(img: UIImage(named: "Logo")!))
        }
    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    }


extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
