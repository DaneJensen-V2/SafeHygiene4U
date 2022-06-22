import UIKit
import MapKit
 



 //A custom annotation class that takes the Hygiene Service and converts it into an annotation for the map
class HygieneAnnotation:NSObject,MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: serviceTypes
    var rating : Int
    
    
    init(_ latitude:CLLocationDegrees,_ longitude:CLLocationDegrees,title:String,subtitle:String,type:serviceTypes,rating : Int){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.rating = rating
        
     
    }
    
    
}