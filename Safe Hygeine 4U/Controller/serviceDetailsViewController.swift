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
    
    @IBOutlet weak var shadowWidth: NSLayoutConstraint!
    @IBOutlet weak var curveWidth: NSLayoutConstraint!
    @IBOutlet weak var starButton: UIBarButtonItem!
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
    @IBOutlet weak var shadowView: UIView!
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
    @IBOutlet weak var curveView: UIView!
    var venueInfo = VenueInfo()
    var newVenue = VenueID()
    var isFavorite = false
    var favoriteChanged = false
    var height : CGFloat = 0
    var width : CGFloat = 0
    
    override func viewDidLoad() {
        //  phoneButton.widthAnchor.constraint(equalToConstant: phoneButton.frame.size.height).isActive = true
        
        closeButton.layer.cornerRadius = 5
        width = self.view.frame.width
        hoursView.layer.cornerRadius = 10
        collectionView.dataSource = self
        collectionView.delegate = self
        mapSnapshot.layer.cornerRadius = 25

        shadowView.backgroundColor = .darkGray
        shadowView.alpha = 0.5
        verifiedView.layer.masksToBounds = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateReviews), name: Notification.Name("ReviewAdded"), object: nil)
        
        setSpacing(){ [self] success in
            
            makeViewCircular(view: phoneButton)
            makeViewCircular(view: reviewButton)
            makeViewCircular(view: emailButton)
            
        }
  
        makeViewCircular(view: verifiedView)
        if selectedService?.isVerified == false{
            verifiedLabel.text = "Not Verified"
            verifiedView.backgroundColor = UIColor(named: "RedPin")
            verifiedImage.image = UIImage(systemName: "multiply")
        }
        DispatchQueue.main.async {
            self.curveWidth.constant = self.venueImage.frame.size.width
            self.curveView.layer.cornerRadius = 15
            self.shadowWidth.constant = self.venueImage.frame.size.width
            self.shadowView.layer.cornerRadius = 15

        }
        starView.rating = selectedService?.rating ?? 0
        getMapPreview()
        startSpinner()
        collectionView.isHidden = true
        super.viewDidLoad()
        //let snapshot = MKLookAroundScene()
        // Do any additional setup after loading the view.
        checkForFavorites { success in
            if self.isFavorite{
                self.starButton.image = UIImage(systemName: "star.fill")
                self.starButton.tintColor = .orange
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        if favoriteChanged{
            updateFavorites()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        height = self.view.frame.height
       
        print(self.view.frame.width)
        
        
        print(width)
        if height > 925 + notesLabel.frame.height{
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: 100)
            
        }
        else{
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: 925 + notesLabel.frame.height)
            
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
    
    func checkForFavorites(completion: @escaping (Bool) -> Void){
        for point in currentUser.favorites{
            
            if point == selectedService?.name{
                isFavorite = true
                completion(true)
                break
            }
        }
        completion(false)
    }
    
    func updateFavorites(){
        let userRef = db.collection("Users").document(currentUser.userID)

        // Set userRef "capital" field of the city 'DC'
        userRef.updateData([
            "favorites": currentUser.favorites
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    @IBAction func favoritesClicked(_ sender: UIBarButtonItem) {
        if !AuthManager().checkIfLoggedIn() {
            let alert = UIAlertController(title: "Login Required", message: "Please login to add a service to favorites.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        else{
            favoriteChanged = true
            if isFavorite{
                self.starButton.image = UIImage(systemName: "star")
                self.starButton.tintColor = UIColor(named: "DarkBlue")
                isFavorite = false
                var count = 0
                for point in currentUser.favorites{
                    if point == selectedService?.name!{
                        currentUser.favorites.remove(at: count)
                    }
                    count += 1
                }
                
            }
            else{
                self.starButton.image = UIImage(systemName: "star.fill")
                self.starButton.tintColor = .orange
                isFavorite = true
                currentUser.favorites.append(selectedService!.name!)
            }
        }
        let generator = UIImpactFeedbackGenerator(style: .medium)
              generator.impactOccurred()
       
       
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
        
        if let imageData = Data(base64Encoded: imageBase64String) {
            let image = UIImage(data: imageData)
            return image ?? UIImage(named: "Logo")!
        }
        else {
            return UIImage(named: "Logo")!
        }
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
        case "Laundry":
            cell.cellImage.image = UIImage(named: "washer")
            cell.circleView.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
            break
        case "Haircuts":
            cell.cellImage.image = UIImage(systemName: "scissors")
            cell.circleView.backgroundColor = UIColor(named: "DarkBlue")
        case "Pool":
            cell.cellImage.image = UIImage(named: "figure.pool.swim")
            cell.circleView.backgroundColor = UIColor(named: "DarkBlue")

            break
        case "Public Park":
            cell.cellImage.image = UIImage(systemName: "leaf.fill")
            cell.circleView.backgroundColor = UIColor(named: "GreenPin")
        case "Park":
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
        let dimensions = (width - 106) / 3
        return CGSize(width: dimensions, height: dimensions)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 30
    }
    
}
