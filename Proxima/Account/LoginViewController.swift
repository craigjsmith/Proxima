//
//  LoginViewController.swift
//  Proxima
//

import UIKit
import Parse
import AuthenticationServices
    
/// Delegate class for Parse 3rd party authentication
class AuthDelegate:NSObject, PFUserAuthenticationDelegate {
    func restoreAuthentication(withAuthData authData: [String : String]?) -> Bool {
        return true
    }
    
    func restoreAuthenticationWithAuthData(authData: [String : String]?) -> Bool {
        return true
    }
}
    
/// Login view controller
class LoginViewController: UIViewController, UITextFieldDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Setup nav bar
        navigationItem.hidesBackButton = true
    }
    
    /**
     Called when view will appear
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sign In with Apple button
        let signInWithAppleButton = ASAuthorizationAppleIDButton(type: .default, style: .whiteOutline)
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(signInWithAppleButton)

        // Constraints for button
        NSLayoutConstraint.activate([
            signInWithAppleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 375.0),
            signInWithAppleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            signInWithAppleButton.widthAnchor.constraint(equalToConstant: 250.0),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])

        signInWithAppleButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchDown)
    }
 
    /**
     Sign In with Apple prompt will display over current window
     */
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
    }
    
    /**
     Handles authentication failure
     */
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
    
        // Alert user
        let alert = UIAlertController(title: "Login failed", message: error.localizedDescription.localizedCapitalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        
        self.present(alert, animated: true, completion: nil)

            switch error.code {
            case .canceled:
                // user press "cancel" during the login prompt
                print("Apple Login: Canceled")
            case .unknown:
                // user didn't login their Apple ID on the device
                print("Apple Login: Unknown")
            case .invalidResponse:
                // invalid response received from the login
                print("Apple Login: Invalid Respone")
            case .notHandled:
                // authorization request not handled, maybe internet failure during login
                print("Apple Login: Not handled")
            case .failed:
                // authorization failed
                print("Apple Login: Failed")
            @unknown default:
                print("Apple Login: Default")
            }
        }
    
    /**
     Handles authentication
     */
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            let userID = appleIDCredential.user

            var identityToken : String?
            if let token = appleIDCredential.identityToken {
                identityToken = String(bytes: token, encoding: .utf8)
            }

            PFUser.logInWithAuthType(inBackground: "apple", authData: ["token": String(identityToken!), "id": userID]).continueWith { task -> Any? in
                    // Apple Sign In failed
                    if ((task.error) != nil){
                        let alert = UIAlertController(title: "Login failed", message: task.error!.localizedDescription.localizedCapitalized, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                        return task
                    }
                
                    // Apple Sign In success
                    DispatchQueue.main.async {
                        // If new account (display name not set), set a default and direct to profile edit
                        if(PFUser.current()?["name"] as? String ?? "" == "Proxima User" || PFUser.current()?["name"] as? String ?? "" == "") {
                            let firstName = appleIDCredential.fullName?.givenName ?? ""
                            let lastName = appleIDCredential.fullName?.familyName ?? ""
                            PFUser.current()!["name"] = String(firstName + " " + lastName)
                            PFUser.current()?.saveInBackground(block: { (success, error) in
                                self.performSegue(withIdentifier: "toAccountSetup", sender: self)
                            })
                            
                        } else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                
                return nil
            }
        }
    }
    
    /**
     Runs when Sign In with Apple button is pressed
     */
    @objc func appleSignInTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        request.requestedScopes = [.fullName]

        // Pass the request to the initializer of the controller
        let authController = ASAuthorizationController(authorizationRequests: [request])
    
        authController.presentationContextProvider = self
        authController.delegate = self
          
        authController.performRequests()
    }
    
    @IBAction func openTos(_ sender: Any) {
        if let url = URL(string: "https://www.craigsmith.dev/proxima/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func openPrivacy(_ sender: Any) {
        if let url = URL(string: "https://www.craigsmith.dev/proxima/privacy") {
            UIApplication.shared.open(url)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
