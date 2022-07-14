
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import GooglePlaces
var servicesList:[HygieneAnnotation] = []

class DBManager{
    //Connects to the database
    let placesClient = GMSPlacesClient()

    let db = Firestore.firestore()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //Loads data from database and stores it into a list of services
    func loadData(completion: @escaping (Bool) -> Void){
        print("Loading Data")
        db.collection("Services").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let result = Result {
                        try document.data(as: fullServiceInfo.self)
                    }
                    switch result {
                    case .success(let newService):
                        self.parseData(data: newService){success in
                            completion(true)
                        }
                        break
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        completion(true)
                        print("Error decoding city: \(error)")
                    }
                }
            }
        }
    }
    func parseData(data : fullServiceInfo, completion: @escaping (Bool) -> Void){
        if data.isOnGoogle{
            getGoogleID(dataX: data){ success in
                completion(true)

            }
        }
        
        /*
        var type : serviceTypes = .shower
        switch data.serviceType{
        case "Bathroom" :
            type = .bathroom
        case "Shower" :
            type = .shower
        case "Laundromat" :
            type = .laundromat
        case "Partner" :
            type = .partner
         default :
            type = .bathroom
        }
        
        let newAnnoation = HygieneAnnotation(data.latitude, data.longitude, title: data.title, subtitle: data.info, type: type, rating: data.rating, distance: 0)
        servicesList.append(newAnnoation)
         */
    }
    func getGoogleID(dataX : fullServiceInfo, completion: @escaping (Bool) -> Void){

        
        let nameString = dataX.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var baseURL = """
https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=place_id%2Cname&input=\(nameString)&inputtype=textquery&locationbias=circle%3A2000%\(dataX.latitude)%2C\(dataX.longitude)&key=AIzaSyD_6-EQYz6EfnqTrrCWafUeZBqmNB_0ocw
"""
        let url = URL(string : baseURL)
        print(baseURL)
        
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
                
                for business in businesses{
                   let ID = business.value(forKey: "place_id") as? String
                    
                    print("ID = \(ID)")
                    self.getGoogleInfo(ID: ID!, data: dataX){success in
                        completion(true)
                    }
                   // completionHandler(venue, nil)
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
              print(place)
              let serviceInfo = ServiceInfo(context: self.context)
              serviceInfo.phoneNumber = place.phoneNumber
              serviceInfo.longitude = -data.longitude
              serviceInfo.latitude = data.latitude
              serviceInfo.isOnGoogle = data.isOnGoogle
              serviceInfo.address = place.formattedAddress
              serviceInfo.name = place.name!
              serviceInfo.hostName = data.hostName
              serviceInfo.rating = data.rating
              serviceInfo.hours = []
              serviceInfo.pricing = data.Pricing
              serviceInfo.reviews = []
              serviceInfo.serviceDetails = []
              serviceInfo.website = place.website?.absoluteString
              serviceInfo.serviceType = data.serviceType
            print("The selected place is: \(place.name)")
              self.saveImage(place: place){image in
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
    func saveImage(place : GMSPlace, completion: @escaping (String) -> Void){
        let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

           // Call loadPlacePhoto to display the bitmap and attribution.
          placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
             if let error = error {
               // TODO: Handle the error.
               print("Error loading photo metadata: \(error.localizedDescription)")
               return
             } else {
               // Display the first image and its attributions.
                 let image : UIImage = photo ?? UIImage(named: "logo")!
                 print("Set Image")
                 completion(self.convertImageToBase64String(img: image))

             }
           })
    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    }


