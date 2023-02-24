//
//  LoginViewController.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/26/22.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CryptoKit
import AuthenticationServices
var googleUser = UserData(Username: "", userID: "", email: "", favorites: [])
var googleAccount = false
var appleAccount = false
var credential: AuthCredential?
class LoginViewController: UIViewController {
  
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet weak var googleButton: UIButton!
    let db = Firestore.firestore()
    fileprivate var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 10
        googleButton.layer.cornerRadius = 10
        appleButton.layer.cornerRadius = 10
        googleButton.layer.borderWidth = 1
        googleSignIn.alpha = 0.05
        // Do any additional setup after loading the view.
        logoImage.layer.cornerRadius = logoImage.frame.height / 2
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //   Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //   }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        
    }
    func addNewUser(newUser : UserData ){
        let user = Auth.auth().currentUser
        
        try! self.db.collection("Users").document(user!.uid).setData(from : newUser)
        { (error) in
            if let e = error{
                print("There was an issue saving data to firestore, \(e)")
            }
            else{
                print("Successfully saved data.")
            }
        }
    }
    
    @IBAction func appleSignIn(_ sender: UIButton) {
        startSignInWithAppleFlow()
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
     // authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    @IBAction func signinPressed(_ sender: GIDSignInButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
      
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
      
            
            guard let authentication = user?.user, let idToken = authentication.idToken
                     else {
                       return
                     }

            
            credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                       accessToken: authentication.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential!) { authResult, error in
                if let error = error {
                    
                    print(error.localizedDescription)
                    return
                }
                else{
                    
                   let authManager = AuthManager()
                    let user = Auth.auth().currentUser
                    authManager.loadCurrentUser(user: user!){result in
                        if result == true{
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        else{
                            //Google User is Logged in but has no username

                            googleUser = UserData(Username: "", userID: user!.uid, email: user!.email!, favorites: [])
                            googleAccount = true
                            self.performSegue(withIdentifier: "googleToUsername", sender: nil)
                        }
                    }
    
                }
            }
        }
    
    }
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      print("RUNNING")
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.
       credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      // Sign in with Firebase.
        Auth.auth().signIn(with: credential!) { (authResult, error) in
        if let error = error{
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
          print(error.localizedDescription)
          return
        }
          else{
              let user = Auth.auth().currentUser
              let authManager = AuthManager()
              authManager.loadCurrentUser(user: user!){result in
                  if result == true{
                      self.navigationController?.popToRootViewController(animated: true)
                  }
                  else{
                      //Google User is Logged in but has no username

                      googleUser = UserData(Username: "", userID: user!.uid, email: user!.email!, favorites: [])
                      appleAccount = true
                      self.performSegue(withIdentifier: "googleToUsername", sender: nil)
                  }
              }          }
       
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}
