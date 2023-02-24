//
//  AuthManager.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/23/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let auth = Auth.auth()
let db = Firestore.firestore()

var currentUser = UserData(Username: "", userID: "", email: "", favorites: [])

class AuthManager{
    func loadCurrentUser(user : User,  completion: @escaping (Bool) -> Void){
        print("ID: " + user.uid)
        let docRef = db.collection("Users").document(user.uid)

        docRef.getDocument { (document, error) in

            let result = Result {
              try document?.data(as: UserData.self)
            }
            switch result {
            case .success(let loadedUser):
                if let loadedUser = loadedUser {
                    currentUser = loadedUser
                    
                    completion(true)
                    print("Loaded User")
                    print(currentUser.Username)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    completion(false)
                    print("Document does not exist")
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                completion(false)
                print("Error decoding city: \(error)")
            }
        }
        
    }
    public func checkIfLoggedIn() -> Bool{
        if Auth.auth().currentUser != nil {
            return true
        }
        else{
            loginStatus()
            return false
        }
    }
    public func loginStatus(){
        Auth.auth().addStateDidChangeListener { auth, user in
          if let user = user {
            print("SIGNED IN")
              
            print(user.uid)

          } else {
            print("NOT SIGNED IN")
              //print(Auth.auth().currentUser!.uid)
          }
        }
    }
    public func logout(){
     do {
       try auth.signOut()
         currentUser.Username = ""
         currentUser.email = ""
         currentUser.userID = ""
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
     } catch let signOutError as NSError {
       print("Error signing out: %@", signOutError)
        }
     }
}

