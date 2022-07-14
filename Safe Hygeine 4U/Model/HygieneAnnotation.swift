import UIKit
import MapKit
 



 //A custom annotation class that takes the Hygiene Service and converts it into an annotation for the map
class HygieneAnnotation:NSObject,MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var type: serviceTypes
    var rating : Double
    var distance : Double
    
    
    init(_ latitude:CLLocationDegrees,_ longitude:CLLocationDegrees,title:String,type:serviceTypes,rating : Double, distance : Double){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.title = title
        self.type = type
        self.rating = rating
        self.distance = distance
        
     
    }
    
    
}
