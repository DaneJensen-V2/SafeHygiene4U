//
//  MapViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/15/22.
//
import CoreLocation
import UIKit
import MapKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CoreData
import FirebaseFirestoreSwift
import Cosmos
var dataLoaded = false
var viewdidLoad = false
var selectedService : ServiceInfo?
var services : [ServiceInfo]?
var filteredData : [HygieneAnnotation]?

class MapViewController: UIViewController {

    //Outlets to UIVIew
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pinClickedReviews: UILabel!
    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinClickedView: UIView!
    @IBOutlet weak var pinClickedImage: UIImageView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var pinClickedLabel: UILabel!
    @IBOutlet weak var listButon: UIButton!
    @IBOutlet weak var serviceTable: UITableView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    var bathroomView: UIView!
    
    //Declarations for Side Menu
     var sideMenuViewController: SideMenuViewController!
     var sideMenuRevealWidth: CGFloat = 260
     let paddingForRotation: CGFloat = 150
     var isExpanded: Bool = false
    
    // Expand/Collapse the side menu by changing trailing's constant
     var sideMenuTrailingConstraint: NSLayoutConstraint!
     var revealSideMenuOnTop: Bool = true
     var sideMenuShadowView: UIView!
     var draggingIsEnabled: Bool = false
     var panBaseLocation: CGFloat = 0.0
    
    @IBAction open func revealSideMenu() {
        self.sideMenuState(expanded: self.isExpanded ? false : true)

    }
    
    //Allows us to get the users location for the map
    let locationManager = CLLocationManager()
    //sets initial region that map displays in meters around user
    let regionInMeters : Double = 2000
    //sets up connection to Database
    let db = Firestore.firestore()
    let dbManager = DBManager()
    let authManager = AuthManager()
    var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //ViewDidLoad
    override func viewDidLoad() {
        print("VIEW DID LOAD RAN")
        super.viewDidLoad()
        
        //Hides the view that shows up when a pin is clicked
        pinClickedView.isHidden = true
        mapView.delegate = self
        mapButton.roundCorners([.topLeft, .bottomLeft], radius: 10)
        listButon.roundCorners([.topRight, .bottomRight], radius: 10)
        searchBar.delegate = self
        
        
        makeViewCircular(view: locationButton)
        makeViewCircular(view: menuButton)
        makeViewCircular(view: filterButton)
        filterView.layer.cornerRadius = 20
        selectButton.layer.cornerRadius = 15
        self.hideKeyboardWhenTappedAround()

        var listenerRan = false
        pinClickedView.layer.cornerRadius = 10
        
        //Checks if user has location services enabled
        checkLocationServices()
        
        //Sets up the side menu with functions from SideMenuFunctions File
        if viewdidLoad == false{
            setupSideMenu()
            viewdidLoad = true

        }
        let listener = db.collection("Reviews").addSnapshotListener { querySnapshot, error in
            if listenerRan == true{
                self.updateReviewsMap(){success in
                    print("sucessfully updated")
                    DispatchQueue.main.async {
                        self.mapView.addAnnotations(servicesList)
                    }
                }
            }
            listenerRan = true

        }
        
    
        //Uncomment to add a document to the database
       // addDocument()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        
        
        serviceTable.delegate = self
        serviceTable.dataSource = self
        serviceTable.register(UINib(nibName: "ServiceTableViewCell", bundle: nil), forCellReuseIdentifier: "serviceCell")

        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.getDistance { success in
                DispatchQueue.main.async {
                    self.serviceTable.reloadData()
                }
            }
        }

        // Do any additional setup after loading the view.
        serviceTable.rowHeight = 95
        
        //Calls the load data method from dbManager class to get all the points for the map
        if dataLoaded == false {
            compareDB()
                }
            
           
         else if dataLoaded == true{
           // self.mapView.addAnnotations(servicesList)
        }
        
        if (authManager.checkIfLoggedIn() == false){
            print("Displaying Login Message")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)

        }

        else {
            print("Loading User")
            let user = Auth.auth().currentUser
            AuthManager().loadCurrentUser(user: user!, completion: { success in
            })
        }
    }
    func updateReviewsMap(completion: @escaping (Bool) -> Void){
        print("Reviews changed")
        self.dbManager.updateReviews(){success in
            print("reviews Updated")
            do {
                
                services = try self.context.fetch(ServiceInfo.fetchRequest())
                self.addAnnotationsFromCD(){ success in
                    completion(true)
                }
            }
            catch{
                print("Could not fetch CoreData")
            }
        }
    }
    func compareDB(){
        print("CompareDB Ran")
       getFirestoreSize(){ [self] firestoreSize in
            
            
            
            var coreDataSize = 0
            do {
                services = try context.fetch(ServiceInfo.fetchRequest())
                coreDataSize = services!.count
            }
            catch{
                print("Could not fetch CoreData")
            }
            print("Firestore size: \(firestoreSize)")
            print("coreData size: \(coreDataSize)")
            
            if firestoreSize != coreDataSize{
                print("DOWNLOADING NEW DATA")
                dbManager.DeleteAllData()
                dbManager.loadData(){ success in
                    print("Load data ran count")
                    do {
                        services = try context.fetch(ServiceInfo.fetchRequest())
                        coreDataSize = services!.count
                    }
                    catch{
                        print("Could not fetch CoreData")
                    }
                    updateReviewsMap(){ success in
                        print("Service List : \(servicesList[0].coordinate)")
                        DispatchQueue.main.async {
                            self.mapView.addAnnotations(servicesList)
                        }
                        dataLoaded = true
                        self.getDistance { success in
                            filteredData = servicesList

                            self.serviceTable.reloadData()
                        }
                        
                    }
                }
            }
            else{
                print("LOADING SAVED DATA")
                updateReviewsMap(){ success in
                    print("")
                    dataLoaded = true
                    self.getDistance { success in
                        print("adding annotations")

                        self.mapView.addAnnotations(servicesList)
                        filteredData = servicesList

                        self.serviceTable.reloadData()
                        
                    }
                }
            }
        }
    }
    func getFirestoreSize(completion: @escaping (Int) -> ()) {
        print("Getting size")
        var firestoreSize = 0
        db.collection("Services").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents{
                    print("Incrementing size")
                    firestoreSize = firestoreSize + 1
                }
                 completion(firestoreSize)
            }
        }
        print("returning")

    }
    func addAnnotationsFromCD(completion: @escaping (Bool) -> Void){
        print("Services Count: \(services?.count)")
        self.mapView.removeAnnotations(servicesList)
        servicesList = [] 
        for service in services! {
            var type : serviceTypes = .shower
            switch service.serviceType{
            case "Shower" :
                type = .shower
            case "Clothing" :
                type = .clothing
            case "nonProfit" :
                type = .nonProfit
             default :
                type = .shower
            }
            
            let newAnnoation = HygieneAnnotation(service.latitude, service.longitude, title: service.name!, type: type, rating: service.rating, distance: 0, reviews: service.reviews)
            servicesList.append(newAnnoation)
        }
        print("annotations completion ran")
        completion(true)
        
    }
    @IBAction func selectClicked(_ sender: UIButton) {
        filterView.fadeOut()

    }
    @IBAction func filterClicked(_ sender: UIButton) {
        filterView.fadeIn()
    }
    //Turns button into a circle
    func makeViewCircular(view: UIButton) {
        view.layer.cornerRadius = view.bounds.size.width / 2.0
        view.clipsToBounds = true
    }
    //Adds a document to the database, edit values and uncomment function in viewDidLoad and run to add to the database.
    func addDocument(){
    /*
        let newService = fullServiceInfo(name: "Mountainside Fitness", latitude: 33.58425, longitude: 111.82943, serviceType: "Shower", Pricing: "Paid", isOnGoogle: false, hours: "", serviceDetails: "", rating: 0, reviews: [], isEvent: false)
  
        do {
            try db.collection("Services").document(newService.name).setData(from: newService)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
     */
    }
    func UIChange(state: Bool){
        menuButton.isHidden = state
        mapView.isHidden = state
        locationButton.isHidden = state
        filterButton.isHidden = state
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        switch state{
        case false:
            listButon.backgroundColor = UIColor(named: "DarkBlue")
            listButon.tintColor = .lightGray
            mapButton.backgroundColor = UIColor(named: "LogoBlue")
            mapButton.tintColor = .white
            break
        case true:
            mapButton.backgroundColor = UIColor(named: "DarkBlue")
            mapButton.tintColor = .lightGray
            listButon.backgroundColor = UIColor(named: "LogoBlue")
            listButon.tintColor = .white
            break
        }
    }
    @IBAction func mapClicked(_ sender: UIButton) {
        UIChange(state: false)
       tapGestureRecognizer.isEnabled = true

    }
    @IBAction func listClicked(_ sender: UIButton) {
        UIChange(state: true)
         tapGestureRecognizer.isEnabled = false

    }
    @IBAction func pinLabelClicked(_ sender: UIButton) {
        print("Pin Clicked")
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
    
 
    
    @IBAction func menuClicked(_ sender: UIButton) {
        revealSideMenu()
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
        case .clothing:
            identifier = "Clothing"
            image = UIImage(named: "shirt", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
        case .nonProfit:
            identifier = "Non-Profit"
            image = UIImage(named: "shirt", in: .main, with: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
   
        }

        //Sets color based on rating
        if annotation.reviews == 0{
            color = "GreenPin"
        }
        else{
            color = getColor(rating: Int(annotation.rating))

        }
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView.markerTintColor = UIColor(named: color)
        annotationView.glyphImage = image
        annotationView.glyphTintColor = .white
        annotationView.clusteringIdentifier =  annotation.type.rawValue
       // annotationView.
        
        
        return annotationView
    }
    
    //Displays a view when a user clicks a point
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //Temporary point
        var pointInArray : ServiceInfo?
               
            //gets title of point clicked
               if let annotationTitle = view.annotation?.title{
                   pinClickedLabel.text = annotationTitle
                   //Matches the clicked point to the point in the services list based on title
                   for point in services! {
                          if point.name == annotationTitle {
                               pointInArray = point
                              selectedService = point
                               break
                           }
                       }
                   }
        if pointInArray?.reviews == 0{
            pinClickedReviews.text = "No Reviews"
            starView.rating = 0

        }
        else{
            starView.rating = pointInArray?.rating ?? 0
            pinClickedReviews.text = "\(pointInArray!.reviews) Reviews"

        }
               //Sets image for view based on type
            switch pointInArray?.serviceType{
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
        print(selectedService!.rating)

        let coordinate = CLLocationCoordinate2DMake(pointInArray!.latitude, pointInArray!.longitude)
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion((region), animated: true)            //Animates view on screen
            pinClickedView.isHidden = false
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            UIView.animate(withDuration: 0.2) {
                self.pinClickedView.transform = CGAffineTransform(translationX: 0, y: -160)
                
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

extension UIViewController {
    
    // With this extension you can access the MainViewController from the child view controllers.
    func revealViewController() -> MapViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is MapViewController {
            return viewController! as? MapViewController
        }
        while (!(viewController is MapViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is MapViewController {
            return viewController as? MapViewController
        }
        return nil
    }
    // Call this Button Action from the View Controller you want to Expand/Collapse when you tap a button
    
    
}

extension UIView {
   func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath

      self.layer.mask = mask
   }
}
extension UIView {
  func fadeTo(_ alpha: CGFloat, duration: TimeInterval = 0.3) {
    DispatchQueue.main.async {
      UIView.animate(withDuration: duration) {
        self.alpha = alpha
      }
    }
  }

  func fadeIn(_ duration: TimeInterval = 0.3) {
    fadeTo(1.0, duration: duration)
  }

  func fadeOut(_ duration: TimeInterval = 0.3) {
    fadeTo(0.0, duration: duration)
  }
}
extension MapViewController: UIGestureRecognizerDelegate {
    
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            if self.isExpanded {
                self.sideMenuState(expanded: false)
            }
            else{
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
    }
    
    // Close side menu when you tap on the shadow background view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.sideMenuViewController.view))! {
            return false
        }
        return true
    }
}
