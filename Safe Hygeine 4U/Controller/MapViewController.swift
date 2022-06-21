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
    let regionInMeters : Double = 2000
    let db = Firestore.firestore()
    let dbManager = DBManager()
    
    var pointList : [hygieneService] = []
    let hygieneAnnotations = HygieneAnnotations()
    //ViewDidLoad
    override func viewDidLoad() {
        pinClickedView.isHidden = true
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()

        
        //Map follows user by default
        mapView.userTrackingMode = .none

        locationButton.layer.cornerRadius = 10
        //used to add test pin to map
        
        
        pinClickedView.layer.cornerRadius = 10
        
       // mapView.addAnnotations(hygieneAnnotations.services)
       
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(mytapGestureRecognizer)
        //self.isUserInteractionEnabled = true
       // addDocument()
        dbManager.loadData(){ success in
            print("Data Loaded")
            self.mapView.addAnnotations(servicesList)
        }
    }
    func addDocument(){
      
        let newService = hygieneService(latitude: 33.58667, longitude: -111.84747, serviceType: "Bathroom", rating: 5, title: "Market Bathroom", info: "Free Bathroom")
        do {
            try db.collection("Services").document(newService.title).setData(from: newService)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
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
        mapView.userTrackingMode = .none
    }
    

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
    

    
    //prompts user with different location authorization options depending on what they selected
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
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        print("Tap Handled")
        if pinClickedView.isHidden == false{
            if !pinClickedView.isHidden {
                UIView.animate(withDuration: 0.2) {
                    self.pinClickedView.transform = CGAffineTransform(translationX: 0, y: 150)
                }
            }
            else {
                pinClickedView.isHidden = false
                
                // Show the Calendar Here
            }
        }
    }

}


extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? HygieneAnnotation else {return nil}
        var identifier = ""
        print("map view ran")
        var color = ""
        var image = UIImage(named: "SC")
      
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(" did select ran")
        var pointInArray = hygieneService(latitude: 0, longitude: 0, serviceType: "", rating: 0, title: "", info: "")
        
        
        
        if let annotationTitle = view.annotation?.title{
            pinClickedLabel.text = annotationTitle


            
            for point in pointList {
                   if point.title == annotationTitle {
                        pointInArray = point
                        break
                    }
                }
            }
        print("User tapped on annotation with title: \(pointInArray.title)")
        
        switch pointInArray.serviceType{
        case "":
            pinClickedImage.image =  UIImage(named: "bathroom", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break
        case "1" :
            pinClickedImage.image =  UIImage(named: "shower", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            break
        default:
            print("Default")
            break
        }
                
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
extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
