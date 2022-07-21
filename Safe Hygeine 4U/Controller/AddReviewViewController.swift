//
//  AddReviewViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/17/22.
//

import UIKit
import Cosmos
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class AddReviewViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starRating: CosmosView!
    
    @IBOutlet weak var submitButtom: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backgroundTextView: UITextView!
    var bottomButtonConstraint = NSLayoutConstraint()
    var buttonChanged = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View did load ran")
        // Do any additional setup after loading the view.
        nameLabel.text = selectedService?.name
        submitButtom.isEnabled = false
        self.textView.delegate = self
        submitButtom.layer.cornerRadius = 10
        textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

      
        bottomButtonConstraint = submitButtom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        bottomButtonConstraint.isActive = true
        
        starRating.didTouchCosmos = { [self] rating in
            let generator = UIImpactFeedbackGenerator(style: .medium)
                     generator.impactOccurred()
            if rating > 0 && textView.text.isEmpty == false{
                submitButtom.isEnabled = true

            }
        }
        
    }
    @IBAction func submitReviewClicked(_ sender: UIButton) {
        addReview()
    }
    func addReview(){
        let reviewCount = loadedReviews.count
        // get the current date and time
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium

        // get the date time String from the date object
        let dateString = formatter.string(from: currentDateTime) // October 8, 2016 at 10:48:53 PM
        let newReview = review(location: (selectedService?.name)!, date:dateString, rating: Int(starRating.rating), content: textView.text, user: currentUser.Username)
        let encoded: [String: Any]
                do {
                    // encode the swift struct instance into a dictionary
                    // using the Firestore encoder
                    encoded = try Firestore.Encoder().encode(newReview)
                } catch {
                    // encoding error
                    print(error)
                    return
                }
    
        if reviewCount > 0 {
    
            
            getReviewTotals(){ reviews, rating in
            
                print("Reviews: \(reviews) Rating: \(rating)")

                print("Option 1")
                db.collection("Reviews").document(selectedService!.name!).updateData(["Review Count" : reviews, "Overall Rating" : rating, "allReviews" : FieldValue.arrayUnion([encoded])])
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        else{
          
            db.collection("Reviews").document(selectedService!.name!).setData(["Review Count" : 1, "Overall Rating" : starRating.rating, "allReviews" : FieldValue.arrayUnion([encoded])])
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    self.dismiss(animated: true)

                }
            }
        }
    }
    func getReviewTotals(completion: @escaping (Int, Double) -> Void){
        let orderRef = db.collection("Reviews") //self.db = my Firestore
        let thisUser = orderRef.document(selectedService!.name!)
        var numReviews = 0
        var overallRating = 0.0
            thisUser.getDocument(completion: { snapshot, error in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }

                guard let snap = snapshot else { print("1"); return }

                guard let dict = snap.data() else {print("2"); return }
                
                print(dict)

                guard let orderItems = dict as? NSDictionary else {return}

                numReviews = orderItems.value(forKey: "Review Count") as? Int ?? 0
                overallRating = orderItems.value(forKey: "Overall Rating") as? Double ?? 0.0


                print("Reviews: \(numReviews) Rating: \(overallRating)")
                
                let rating = ((overallRating * Double(numReviews)) +  self.starRating.rating) / Double((numReviews + 1))
                completion(numReviews + 1, rating)
            })
       // var numReviewsInt : Int = Int(numReviews) ?? 0
       // var ratingInt : Double = Double(numReviews) ?? 0.0
        
     
        }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if buttonChanged == false{
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                bottomButtonConstraint.constant -= keyboardSize.height - 40
                print("Keyboard show ran")
                buttonChanged = true
            }
        }
    }

 
    @IBAction func xClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
extension AddReviewViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != ""{
            backgroundTextView.isHidden = true
            if starRating.rating > 0{
                submitButtom.isEnabled = true
            }
        }
        else{
            backgroundTextView.isHidden = false
            submitButtom.isEnabled = false

        }
           print("exampleTextView: BEGIN EDIT")
       }
    func textFieldShouldReturn(_ textView: UITextView) -> Bool {
           textView.resignFirstResponder()
           addReview()
           return true
       }
}
