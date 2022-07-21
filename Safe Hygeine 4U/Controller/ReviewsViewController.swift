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

class ReviewsViewController: UIViewController {
    @IBOutlet weak var reviewsTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    let auth = AuthManager()
    @IBOutlet weak var addReviewButton: UIButton!
    override func viewDidLoad() {
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
            spinner.isHidden = false
            spinner.startAnimating()
            fetchReviews(){ [self] success in
                spinner.stopAnimating()
                spinner.isHidden = true
                self.reviewsTable.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
     //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
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
            performSegue(withIdentifier: "writeReview", sender: nil)
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
        return loadedReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! reviewCell
        
        cell.reviewLabel.sizeToFit()
        cell.cosmosView.rating = Double(loadedReviews[indexPath.row].rating)
        cell.dateLabel.text = loadedReviews[indexPath.row].date
        cell.usernameLabel.text = loadedReviews[indexPath.row].user
        cell.reviewLabel.text = loadedReviews[indexPath.row].content
        if loadedReviews[indexPath.row].user == currentUser.Username{
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


