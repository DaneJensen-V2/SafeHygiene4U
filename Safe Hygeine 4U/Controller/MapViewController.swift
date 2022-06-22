//
//  MapViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/15/22.
//
import CoreLocation
import UIKit
import MapKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
class MapViewController: UIViewController {

    //Outlets to UIVIew
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinClickedView: UIView!
    @IBOutlet weak var pinClickedImage: UIImageView!
    @IBOutlet weak var pinClickedLabel: UILabel!
    var bathroomView: UIView!
    
    //Allows us to get the users location for the map
    let locationManager = CLLocationManager()
    //sets initial region that map displays in meters around user
    let regionInMeters : Double = 2000
    //sets up connection to Database
    let db = Firestore.firestore()
    let dbManager = DBManager()
    
    //ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //Hides the view that shows up when a pin is clicked
        pinClickedView.isHidden = true
        mapView.delegate = self
        
        //Checks if user has location services enabled
        checkLocationServices()

        
        locationButton.layer.cornerRadius = 10
        pinClickedView.layer.cornerRadius = 10
               
        //Work in progress, to allow the user to tap outside of the view to dismiss it.
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(mytapGestureRecognizer)
        
        //Uncomment to add a document to the database
        //addDocument()
        
        //Calls the load data method from dbManager class to get all the points for the map
        dbManager.loadData(){ success in
            print("Data Loaded")
            self.mapView.addAnnotations(servicesList)
        }
    }
    
    //Adds a document to the database, edit values and uncomment function in viewDidLoad and run to add to the database.
    func addDocument(){
      
        let newService = hygieneService(latitude: 33.58667, longitude: -111.84747, serviceType: "Bathroom", rating: 5, title: "Market Bathroom 2", info: "Free Bathroom")
        do {
            try db.collection("Services").document(newService.title).setData(from: newService)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    //Sets properties for location manager
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //Checks if location services are on, else prompt user to turn them on
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else{
            //Show alert letting user know how to turn this on
        }
    }
    
    //centers the map on the user
    func centerViewOnUser(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion((region), animated: true)

        }
    }
   
    //Brings map to user location
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        print("Centering on user")
        centerViewOnUser()
    }
    
//Gets color of pin based on the rating, we will want to change this to Double from Int
    func getColor(rating : Int) -> String{
        switch rating{
        case 0...2:
            return "RedPin"
        case 3:
            return "YellowPin"
        case 4...5:
            return "GreenPin"
        default:
            return "Black"
        }
    }
    

    
    //Prompts user with different location authorization options depending on what they selected
    func checkLocationAuthorization(){
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUser()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            //Show alert asking user to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //Show alert to tell what is up
            break
        case .authorizedAlways:
            break
        }
    }
    
    //Work in progress, used to dismiss pinclickedView if user taps outside of the view
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        print("Tap Handled")
        if pinClickedView.isHidden == false{
            if !pinClickedView.isHidden {
                //animates view out of screen
                UIView.animate(withDuration: 0.2) {
                    self.pinClickedView.transform = CGAffineTransform(translationX: 0, y: 150)
                }
            }
            else {
                pinClickedView.isHidden = false
                
            }
        }
    }

}


extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? HygieneAnnotation else {return nil}
        
        //Temporary values that change based on pin type
        var identifier = ""
        var color = ""
        var image = UIImage(named: "SC")
        
        //Sets pin image based on service type
        switch annotation.type{
        case .shower:
            identifier = "Shower"
            image = UIImage(named: "shower", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
        case .bathroom:
            identifier = "Bathroom"
            image = UIImage(named: "bathroom", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
        case .laundromat:
            identifier = "Laundromat"
            image = UIImage(named: "shirt", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
        case .partner:
            identifier = "Partner"
            image = UIImage(named: "shower", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))           }
        
        //Sets color based on rating
        color = getColor(rating: annotation.rating)
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView.markerTintColor = UIColor(named: color)
        annotationView.glyphImage = image
        annotationView.glyphTintColor = .white
        annotationView.clusteringIdentifier = "Service"
        
        
        return annotationView
    }
    
    //Displays a view when a user clicks a point
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //Temporary point
        var pointInArray = HygieneAnnotation(0, 0, title: "", subtitle: "", type: .shower, rating: 0)
               
            //gets title of point clicked
               if let annotationTitle = view.annotation?.title{
                   pinClickedLabel.text = annotationTitle
                   
                   //Matches the clicked point to the point in the services list based on title
                   for point in servicesList {
                          if point.title == annotationTitle {
                               pointInArray = point
                               break
                           }
                       }
                   }
               //Sets image for view based on type
               switch pointInArray.type{
               case .bathroom:
                   pinClickedImage.image =  UIImage(named: "bathroom", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
                   break
               case .shower :
                   pinClickedImage.image =  UIImage(named: "shower", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
                   break
               default:
                   print("Default")
                   break
               }
            //Animates view on screen
            pinClickedView.isHidden = false
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            UIView.animate(withDuration: 0.2) {
                self.pinClickedView.transform = CGAffineTransform(translationX: 0, y: -150)
                
            }
            
        }
    }


extension MapViewController: CLLocationManagerDelegate {
    
    //If authorization changes, prompt user again
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("extension ran")

        checkLocationAuthorization()
    }
}

