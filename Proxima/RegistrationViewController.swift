//
//  RegistrationViewController.swift
//  Proxima
//
//  Created by Emmanuel Bangura on 11/30/20.
//

import UIKit
import Parse
import AlamofireImage

class RegistrationViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullnameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .photoLibrary
            
        } else {
            picker.sourceType = .camera
        }
        
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
       profileImageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // Removes the keyboard
    @IBAction func tapOnScreen(_ sender: Any) {
        fullnameTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //
    // Signs up user and adds their information to the database
    //
    @IBAction func onSignupButton(_ sender: Any) {
        
        // User has not filled all fields
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty || fullnameTextField.text!.isEmpty {
            
            // show something on screen that tells user they need to fill text fields
            errorLabel.text = "Please fill in all fields to register"
        }
        // All fields have been filled in so you can try to register the user
        else {
            // Creates a new row in _User table
            var user = PFUser()
                          user.username = usernameTextField.text
                          user.password = passwordTextField.text
                           
            
            user.signUpInBackground {(success, error)   in
                if success {
                    // only creates table entry if User was succesfuly signed up
                    let imageData = self.profileImageView.image!.pngData()
                    let file = PFFileObject(data: imageData!)
                    
                    user["profile_image"] = file  // set profile image element
                    user["full_name"] = self.fullnameTextField.text // set full name element
                    user["score"] = 0 // set initial score to zero
                    
                    
                    user.saveInBackground{(success, error) in
                        if success {
                            print("saved!")
                            self.performSegue(withIdentifier: "registrationSegue", sender: nil)

                        } else { // Could not 
                            print("error saving: \(error?.localizedDescription)")
                            self.errorLabel.text = error?.localizedDescription
                            }
                        
                        }
                    
                } else { // Could not sign up user
                    print("Error: \(error?.localizedDescription)")
                    self.errorLabel.text = error?.localizedDescription
                }
            }
        
        }
        
    
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case fullnameTextField:
                fullnameTextField.resignFirstResponder()
                usernameTextField.becomeFirstResponder()
            case usernameTextField:
                usernameTextField.resignFirstResponder()
                passwordTextField.becomeFirstResponder()
            default:
                fullnameTextField.resignFirstResponder()
                usernameTextField.resignFirstResponder()
                passwordTextField.resignFirstResponder()
        }
        return false
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
