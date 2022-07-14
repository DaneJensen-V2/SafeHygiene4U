//
//  serviceDetailsViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/2/22.
//

import UIKit
import MapKit
import CoreLocation
let apiKey = "yqcMF9Xf3uXc-SpamX8Pa-YurcBuhVvNkxrC8Avwk4l3gMOPWYDBwRzKQBGwmijQC6S2NxlDk_SXs1G3tjoLJ4TyUnbtyEYY8zQdJFOh66L8n9hAoNwpzFDNvA1mYnYx"




class serviceDetailsViewController: UIViewController {

    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mapSnapshot: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var venueInfo = VenueInfo()
    var newVenue = VenueID()

    override func viewDidLoad() {
      //  phoneButton.widthAnchor.constraint(equalToConstant: phoneButton.frame.size.height).isActive = true
    
        print()
        
       
        
        mapSnapshot.imageView?.layer.cornerRadius = 25
        mapSnapshot.imageView?.clipsToBounds = true
        directionsView.layer.cornerRadius = 10
        
        setSpacing(){ [self] success in
            print(phoneButton.bounds.size.height)

            print(buttonStack.frame.size.height)
            makeViewCircular(view: phoneButton)
          makeViewCircular(view: reviewButton)
                makeViewCircular(view: emailButton)
            
        }
      
        getMapPreview()
        startSpinner()
        super.viewDidLoad()
        //let snapshot = MKLookAroundScene()
        // Do any additional setup after loading the view.
    }
    func setSpacing(completion: @escaping (Bool) -> Void){
       // let total = buttonStack.frame.size.width
      //  let X = buttonStack.frame.size.height
       // let space = total - (3 * X)
       // buttonStack.spacing = space / 2
            completion(true)
    }
    
    func startSpinner(){
        DispatchQueue.main.async { [self] in
            spinner.isHidden = false
            spinner.startAnimating()
        }
    }
    func stopSpinner(){
        DispatchQueue.main.async { [self] in
            spinner.isHidden = true
            spinner.stopAnimating()
            updateUI()
        }
     
    }
    @IBAction func mapClicked(_ sender: UIButton) {
        if let selectedService = selectedService{
            let coordinate = CLLocationCoordinate2DMake(selectedService.latitude, selectedService.longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = selectedService.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
        }
    }
    func makeViewCircular(view: UIButton) {
        view.layer.cornerRadius = view.frame.size.height / 2.0
        view.clipsToBounds = true
    }
    
    @IBAction func callPressed(_ sender: UIButton) {
        if let selectedService = selectedService{
            
            print(selectedService.phoneNumber!)
            self.callNumber(phoneNumber: selectedService.phoneNumber!)
            
        }
    }
    @IBAction func websiteButton(_ sender: UIButton) {
        if let selectedService = selectedService{
            
            guard let url = URL(string: selectedService.website ?? "www.google.com") else { return }
            UIApplication.shared.open(url)
        }
        }
    private func callNumber(phoneNumber: String) {
       let phoneNumberFiltered = phoneNumber.filter("0123456789.".contains)
        guard let url = URL(string: "telprompt://\(phoneNumberFiltered)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    func getMapPreview(){
        print("TEST1")
            
            let coords = CLLocationCoordinate2D(latitude: selectedService!.latitude, longitude: selectedService!.longitude)
            let distanceInMeters: Double = 500
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coords, latitudinalMeters: distanceInMeters, longitudinalMeters: distanceInMeters)
        options.size = mapSnapshot.frame.size

        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start(completionHandler: { [weak self] (snapshot, error) in
            guard error == nil else {
                print("error")
                return
            }
            print("TEST2")

            if let snapShotImage = snapshot?.image, let coordinatePoint = snapshot?.point(for: coords){
                snapShotImage.draw(at: CGPoint.zero)
                print("TEST3")

                /// 5.
                // need to fix the point position to match the anchor point of pin which is in middle bottom of the frame

                UIGraphicsBeginImageContextWithOptions(snapShotImage.size, true, snapShotImage.scale)

                snapShotImage.draw(at: CGPoint.zero)

                        let point: CGPoint = snapshot!.point(for: coords)
                        let annotation = MKPointAnnotation()
                annotation.title    =  selectedService!.name
                        self?.drawPin(point: point, annotation: annotation)

         
                                
                            
                            let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
             
                DispatchQueue.main.async {
                    print("TEST4")

                    self?.mapSnapshot.setImage(compositeImage, for: .normal)
                    //self!.mapSnapshot.contentMode = .scaleToFill
                    self?.stopSpinner()
                       }
                       UIGraphicsEndImageContext()
                   }
            
               })
        

    }
   
    private func drawPin(point: CGPoint, annotation: MKAnnotation) {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "test")
        annotationView.contentMode = .scaleAspectFit
        annotationView.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        annotationView.drawHierarchy(in: CGRect(
            x: point.x - annotationView.bounds.size.width / 2.0,
            y: point.y - annotationView.bounds.size.height,
            width: annotationView.bounds.width,
            height: annotationView.bounds.height),
                                     afterScreenUpdates: true)
    }
    
    func updateUI(){
        if let selectedService = selectedService{
            if selectedService.reviews?.count == 0{
                ratingNumber.text = "No Reviews"
            }
            else{
                ratingNumber.text = String(selectedService.rating)

            }
            venueImage.image = convertBase64StringToImage(imageBase64String: selectedService.image!)
            name.text = selectedService.name
            self.navigationController?.navigationBar.topItem?.title = selectedService.name
            address.text = selectedService.address!
        }
        else{
            print("no service")
        }
    }
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }

    /*
    func retrieveID(name : String, address : String, limit : Int, City : String, State : String, Country : String, completionHandler : @escaping (VenueID?, Error?) -> Void){
        var baseURL2 = """
https://maps.googleapis.com/maps/api/place/findplacefromtext/json
  ?fields=formatted_address%2Cname%2Crating%2Copening_hours%2Cgeometry
      &input=Museum%20of%20Contemporary%20Art%20Australia
      &inputtype=textquery
      &key=YOUR_API_KEY

    https://maps.googleapis.com/maps/api/place/findplacefromtext/json
      ?input=%2B16239329135
      &inputtype=phonenumber
      &key=
        
"""
   
        var baseURL = "https://api.yelp.com/v3/businesses/matches?address1=\(address)&name=\(name)&city=\(City)&state=\(State)&country=\(Country)&limit=1"
        baseURL = baseURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string : baseURL)
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                guard let resp = json as? NSDictionary else {return}
                
                guard let businesses = resp.value(forKey: "businesses") as? [NSDictionary] else {return}
                
                var venue = VenueID()
                for business in businesses{
                    venue.name = business.value(forKey: "name") as? String
                    venue.id = business.value(forKey: "id") as? String
                    
                    
                    completionHandler(venue, nil)
                }
            }
            catch{
                print("Caught Error")
            }
        }.resume()
    }
    func retrieveInfo(ID : String, completionHandler : @escaping (VenueInfo?, Error?) -> Void){
        
        var baseURL = "https://api.yelp.com/v3/businesses/\(ID)"
        baseURL = baseURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string : baseURL)
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                guard let resp = json as? NSDictionary else {return}
                print(resp)
                
                var venue = VenueInfo()
                venue.name = resp.value(forKey: "name") as? String
                venue.image = resp.value(forKey: "image_url") as? String
                venue.is_closed = resp.value(forKey: "is_closed") as? Bool
                venue.phone = resp.value(forKey: "phone") as? String
                let locationDict = resp.object(forKey: "location") as? NSDictionary
                venue.location = locationDict?.value(forKey: "display_address") as? [String]
                
                    
                    completionHandler(venue, nil)
                
            }
            catch{
                print("Caught Error")
            }
        }.resume()
    }
     */
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }

 //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false


    }

    @IBAction func getDirectionsClicked(_ sender: UIButton) {
      
    }
}
