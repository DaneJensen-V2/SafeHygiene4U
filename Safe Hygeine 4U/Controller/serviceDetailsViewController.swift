//
//  serviceDetailsViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/2/22.
//

import UIKit
import MapKit
import CoreLocation
import Cosmos
let apiKey = "yqcMF9Xf3uXc-SpamX8Pa-YurcBuhVvNkxrC8Avwk4l3gMOPWYDBwRzKQBGwmijQC6S2NxlDk_SXs1G3tjoLJ4TyUnbtyEYY8zQdJFOh66L8n9hAoNwpzFDNvA1mYnYx"




class serviceDetailsViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var tuesLabel: UILabel!
    @IBOutlet weak var wedLabel: UILabel!
    @IBOutlet weak var thursLabel: UILabel!
    @IBOutlet weak var fridLabel: UILabel!
    @IBOutlet weak var sundLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var hoursView: UIView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var serviceTypeImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var verifiedImage: UIImageView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mapSnapshot: UIButton!
    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var verifiedView: UIView!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var venueInfo = VenueInfo()
    var newVenue = VenueID()
    var height : CGFloat = 0
    var width : CGFloat = 0

    override func viewDidLoad() {
      //  phoneButton.widthAnchor.constraint(equalToConstant: phoneButton.frame.size.height).isActive = true

        print(selectedService?.reviews)
        closeButton.layer.cornerRadius = 5
        width = self.view.frame.width
        
        hoursView.layer.cornerRadius = 10
        collectionView.dataSource = self
        collectionView.delegate = self
        mapSnapshot.layer.cornerRadius = 25
        directionsView.layer.cornerRadius = 10
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateReviews), name: Notification.Name("ReviewAdded"), object: nil)

        setSpacing(){ [self] success in

            makeViewCircular(view: phoneButton)
          makeViewCircular(view: reviewButton)
                makeViewCircular(view: emailButton)
            
        }
        switch selectedService?.serviceType{
        case "Shower":
            serviceTypeImage.image =  UIImage(named: "shower")
            break
        case "Clothing":
            serviceTypeImage.image =  UIImage(named: "shirt")
            break
 
        default:
            serviceTypeImage.image =  UIImage(named: "shower")
            break
        }
        makeViewCircular(view: verifiedView)
        if selectedService?.isVerified == false{
            verifiedLabel.text = "Not Verified"
            verifiedView.backgroundColor = UIColor(named: "RedPin")
            verifiedImage.image = UIImage(systemName: "multiply")
        }
        starView.rating = selectedService?.rating ?? 0
        getMapPreview()
        startSpinner()
        collectionView.isHidden = true
        super.viewDidLoad()
        //let snapshot = MKLookAroundScene()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

        height = self.view.frame.height

        print(width)
        if height > 900{
            scrollView.contentSize = CGSizeMake(self.view.frame.width, 100)
            
        }
        else{
            scrollView.contentSize = CGSizeMake(self.view.frame.width, 850 + notesLabel.frame.height)

        }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        

    }
    @IBAction func closeClicked(_ sender: UIButton) {
        hoursView.fadeOut()
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
    @objc func updateReviews(){
        if serviceDetailsReviews != 0{
            starView.rating = serviceDetailsRating
            ratingNumber.text = String(format: "%.1f (%d reviews)", serviceDetailsRating, serviceDetailsReviews)
            
        }
    }
    func stopSpinner(){
        DispatchQueue.main.async { [self] in
          
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
            
            let coords = CLLocationCoordinate2D(latitude: selectedService!.latitude, longitude: selectedService!.longitude)
            let distanceInMeters: Double = 500
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coords, latitudinalMeters: distanceInMeters, longitudinalMeters: distanceInMeters)
        options.size = mapSnapshot.bounds.size

        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start(completionHandler: { [weak self] (snapshot, error) in
            guard error == nil else {
                print("error")
                return
            }

            if let snapShotImage = snapshot?.image, let coordinatePoint = snapshot?.point(for: coords){
                snapShotImage.draw(at: CGPoint.zero)

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

                  //  self?.mapSnapshot.setImage(compositeImage, for: .normal)
                    self?.mapSnapshot.setBackgroundImage(compositeImage, for: .normal)
                self?.mapSnapshot.clipsToBounds = true
                    self?.mapSnapshot.contentMode = .scaleAspectFill
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
    func setHours(){
        if let hours = selectedService?.hours{
            monLabel.text = hours[0]
            tuesLabel.text = hours[1]
            wedLabel.text = hours[2]
            thursLabel.text = hours[3]
            fridLabel.text = hours[4]
            saturdayLabel.text = hours[5]
            sundLabel.text = hours[6]

        }
    }
    func updateUI(){
        if let selectedService = selectedService{
            if selectedService.reviews == 0{
                ratingNumber.text = "No Reviews"
            }
            else{
                ratingNumber.text = String(format: "%.1f (%d reviews)", selectedService.rating, selectedService.reviews)

            }
            venueImage.image = convertBase64StringToImage(imageBase64String: selectedService.image!)
            name.text = selectedService.name
            self.navigationController?.navigationBar.topItem?.title = selectedService.name
            address.text = selectedService.address!
        }
        else{
            print("no service")
        }
        if selectedService?.notes == ""{
            notesLabel.text = "None"

        }
        else{
            notesLabel.text = selectedService?.notes

        }
        if selectedService?.serviceDetails?.count ?? 0 > 3 {
            arrowImage.isHidden = false
        }
        else{
            arrowImage.isHidden = true
        }
        hoursLabel.text = selectedService?.hours![dayOfWeek]
        setHours()
        spinner.isHidden = true
        spinner.stopAnimating()
        collectionView.isHidden = false

    }
    
    @IBAction func timeDetailsPushed(_ sender: Any) {
        hoursView.fadeIn()
    }
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    } 

    
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.navigationController?.navigationBar.isHidden = false
    }

 //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true


    }
    func makeViewCircular(view: UIView) {
        view.layer.cornerRadius = view.bounds.size.width / 2.0
        view.clipsToBounds = true
    }

    @IBAction func getDirectionsClicked(_ sender: UIButton) {
      
    }
}
extension serviceDetailsViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(selectedService?.serviceDetails)
       return selectedService?.serviceDetails?.count ?? 0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if arrowImage.isHidden == false{
            arrowImage.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! serviceDetailsCollectionViewCell
        cell.detailLabel.text = selectedService!.serviceDetails![indexPath.row]
        let detailsNoSpace = selectedService!.serviceDetails![indexPath.row].trimmingCharacters(in: .whitespaces)
        print(detailsNoSpace)
        switch detailsNoSpace{
        case "Shower":
            cell.cellImage.image = UIImage(named: "shower")
            cell.circleView.backgroundColor = UIColor(named: "LogoBlue")
            break
        case "Bathroom":
            cell.cellImage.image = UIImage(named: "toilet")
            cell.circleView.backgroundColor = UIColor(named: "LogoBlue")
            break
        case "Gym":
            cell.cellImage.image = UIImage(named: "dumbbell")
            cell.circleView.backgroundColor = UIColor(named: "DarkBlue")

            break
        case "Clothing":
            cell.cellImage.image = UIImage(named: "shirt")
            cell.circleView.backgroundColor = UIColor(named: "LogoBlue")
            break
        case "Hygiene":
            cell.cellImage.image = UIImage(systemName: "hands.sparkles")
            cell.circleView.backgroundColor = UIColor(named: "LogoBlue")
            break
        case "Truck Stop":
            cell.cellImage.image = UIImage(named: "box.truck")
            cell.circleView.backgroundColor = UIColor(named: "DarkBlue")
            break
        case "Rec Center":
            cell.cellImage.image = UIImage(named: "figure.run")
            break
        case "Haircuts":
            cell.cellImage.image = UIImage(systemName: "scissors")
            cell.circleView.backgroundColor = UIColor(named: "DarkBlue")

            break
        case "Public Park":
            cell.cellImage.image = UIImage(systemName: "leaf.fill")
            cell.circleView.backgroundColor = UIColor(named: "GreenPin")

            break
        case "Nonprofit":
            cell.cellImage.image = UIImage(systemName: "face.smiling")
            cell.circleView.backgroundColor = UIColor(named: "GreenPin")

            break
        default:
            cell.cellImage.image = UIImage(systemName: "cross")

        }
        cell.cellImage.tintColor = .white

        
        
   //     makeViewCircular(view: cell.circleView)
        cell.circleView.layer.cornerRadius = 15
        return cell
    }
    
    
}
extension serviceDetailsViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // handle tap events
            print("You selected cell #\(indexPath.item)!")
        }
    
}
extension serviceDetailsViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let dimensions = (width - 91) / 3
        return CGSize(width: dimensions, height: dimensions)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 25
    }
    
}
