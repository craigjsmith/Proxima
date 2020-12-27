//
//  LoginViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/22/20.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        // Setup nav bar
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        
        let username = usernameField.text!
        let password = passwordField.text!
                       
        PFUser.logInWithUsername(inBackground: username, password: password)
        {
            (user, error) in
            
            if user != nil {
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            else {
                let alert = UIAlertController(title: "Invalid Credentials", message: error?.localizedDescription.localizedCapitalized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case usernameField:
                usernameField.resignFirstResponder()
                passwordField.becomeFirstResponder()
            default:
                usernameField.resignFirstResponder()
                passwordField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func onTapScreen(_ sender: Any) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @IBAction func resetPasswordPressed(sender: AnyObject) {

        let titlePrompt = UIAlertController(title: "Reset password",
            message: "Enter the email you registered with:",
            preferredStyle: .alert)

        var titleTextField: UITextField?
        titlePrompt.addTextField { (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Email"
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        titlePrompt.addAction(cancelAction)

        titlePrompt.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action) -> Void in
                if let textField = titleTextField {
                    self.resetPassword(email: textField.text as! String)
                }
        }))

        self.present(titlePrompt, animated: true, completion: nil)
    }

    func resetPassword(email : String){

        // convert the email string to lower case
        let emailClean = email.lowercased()

        PFUser.requestPasswordResetForEmail(inBackground: emailClean) { (success, error) -> Void in
            if (success) {
                let success = UIAlertController(title: "Success", message: "If this email matches an account, you will receive a link to reset your password.", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                success.addAction(okButton)
                self.present(success, animated: true, completion: nil)

            } else {
                let errormessage = error as! NSString
                let error = UIAlertController(title: "Cannot complete request", message: errormessage as String, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                error.addAction(okButton)
                self.present(error, animated: true, completion: nil)
            }
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
