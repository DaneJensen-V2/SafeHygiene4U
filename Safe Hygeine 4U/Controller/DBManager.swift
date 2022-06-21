
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
var servicesList:[HygieneAnnotation] = []

class DBManager{
    let db = Firestore.firestore()
    
    
    func loadData(completion: @escaping (Bool) -> Void){
        
        db.collection("Services").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let result = Result {
                        try document.data(as: hygieneService.self)
                    }
                    switch result {
                    case .success(let newService):
                        print(newService.title)
                        self.parseData(data: newService)
                        completion(true)
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
    func parseData(data : hygieneService){
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
        
        let newAnnoation = HygieneAnnotation(data.latitude, data.longitude, title: data.title, subtitle: data.info, type: type, rating: data.rating)
        servicesList.append(newAnnoation)
    }
}

