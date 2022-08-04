//
//  ReviewsViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/17/22.
//

import UIKit
import Cosmos
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

var loadedReviews : [review] = []
var reviewsDated : [reviewDate] = []
var reviewWritten = false
var writtenReview = review(location: "", date: "", rating: 0, content: "", user: "")
class ReviewsViewController: UIViewController {
    @IBOutlet weak var reviewsTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    let auth = AuthManager()
    @IBOutlet weak var addReviewButton: UIButton!
    override func viewDidLoad() {
        reviewWritten = false
        loadedReviews = []
        reviewsDated = []
        super.viewDidLoad()
        reviewsTable.delegate = self
        reviewsTable.dataSource = self

        makeViewCircular(view: addReviewButton)
        // Do any additional setup after loading the view.
        if selectedService!.reviews == 0{
            reviewsTable.isHidden = true
            spinner.isHidden = true
            
        }
        else{
            updateReviews()
         
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateReviews), name: Notification.Name("ReviewAdded"), object: nil)

    }
   
    @objc func updateReviews(){
        loadedReviews = []
        reviewsDated = []
        spinner.isHidden = false
        spinner.startAnimating()
        fetchReviews(){ [self] success in
            sortReviews(){ success in
                reviewsTable.isHidden = false
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.reviewsTable.reloadData()

            }
        
        }
    }
    func sortReviews(completion: @escaping (Bool) -> Void){
        convertReviewsDate(){ success in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"// yyyy-MM-dd"
            let result = reviewsDated.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
            reviewsDated = result
            var count = 0
            for reviews in reviewsDated{
                print(currentUser.Username)
                if reviews.user == currentUser.Username{
                    reviewsDated.move(fromOffsets: [count], toOffset: 0)
                    reviewWritten = true
                    writtenReview = review(location: reviews.location, date: dateFormatter.string(from: reviews.date), rating: reviews.rating, content: reviews.content, user: reviews.user)
                    completion(true)
                    return
                }
                count += 1
            }
            completion(true)

        }
    }
    
    func convertReviewsDate(completion: @escaping (Bool) -> Void){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"// yyyy-MM-dd"
        for review in loadedReviews {
            let newReview = reviewDate(location: review.location, date: dateFormatter.date(from: review.date)!, rating: review.rating, content: review.content, user: review.user)
            
            reviewsDated.append(newReview)
        }
        completion(true)
    }
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.navigationController?.navigationBar.isHidden = false
    }
    
    func fetchReviews(completion: @escaping (Bool) -> Void){
        let docRef = db.collection("Reviews").document(selectedService!.name!)

        docRef.getDocument { (document, err) in
                
                //    print("\(document.documentID) => \(document.data())")
                if let document = document {
                    
                    do {
                        let reviews = document.get("allReviews")
                        let json = try JSONSerialization.data(withJSONObject: reviews)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let reviewList = try decoder.decode([review].self, from: json)
                        loadedReviews = reviewList
                        print(loadedReviews)
                        completion(true)
                    } catch {
                        print(error)
                    }
                    
  
                          
                           }
                                else {
                               print("Document does not exist in cache")
                           }
                       }
              
 
        
    }
    func makeViewCircular(view: UIButton) {
        view.layer.cornerRadius = view.frame.size.height / 2.0
        view.clipsToBounds = true
    }
    @IBAction func addReview(_ sender: UIButton) {
        if auth.checkIfLoggedIn() {
            if reviewWritten {
                let alert = UIAlertController(title: "Change Review", message: "You have already written a review. Writing a new one will replace the previous one.", preferredStyle: .alert)

                let notNow = UIAlertAction(title: "Cancel", style: .default)
                let login = UIAlertAction(title: "Okay", style: .default, handler: {(alert: UIAlertAction!) in
                    self.performSegue(withIdentifier: "writeReview", sender: nil)
                })

                alert.addAction(notNow)
                alert.addAction(login)


                present(alert, animated: true)
            }
            else{
                performSegue(withIdentifier: "writeReview", sender: nil)
            }
        }
        else{
            let alert = UIAlertController(title: "Log In", message: "Please log in to be able to write a review.", preferredStyle: .alert)

            let notNow = UIAlertAction(title: "Not Now", style: .default)
            let login = UIAlertAction(title: "Login", style: .default, handler: {(alert: UIAlertAction!) in
                self.performSegue(withIdentifier: "reviewToLogin", sender: nil)
            })

            alert.addAction(notNow)
            alert.addAction(login)


            present(alert, animated: true)
        }
    }
    
}
class reviewCell : UITableViewCell{
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!


}
extension ReviewsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ran rows")
        return reviewsDated.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"// yyyy-MM-dd"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! reviewCell
        
        cell.reviewLabel.sizeToFit()
        cell.cosmosView.rating = Double(reviewsDated[indexPath.row].rating)
        cell.dateLabel.text = dateFormatter.string(from: reviewsDated[indexPath.row].date)
        cell.usernameLabel.text = reviewsDated[indexPath.row].user
        cell.reviewLabel.text = reviewsDated[indexPath.row].content
        if reviewsDated[indexPath.row].user == currentUser.Username{
            cell.usernameLabel.textColor = .orange
            cell.usernameLabel.text = "You"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 200
        }
    }

     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 200
        }
    }
}


