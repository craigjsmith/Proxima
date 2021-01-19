//
//  RegistrationViewController.swift
//  Proxima
//

import UIKit
import Parse
import AlamofireImage

/// Registration view controller
class RegistrationViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    // If profile image is set
    var imageSet = false
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    

    /**
     Called when profile picture is tapped, allows user to upload picture
     */
    @IBAction func onProfileImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
            
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    /**
     Image picker controller for profile picture
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 500, height: 500)
        let scaledImage = image.af_imageScaled(to: size)
        
        // Set image preview to newly uploaded image
        profileImageView.image = scaledImage
        
        // Set profile image to circle
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = (profileImageView.frame.width / 2)
        
        imageSet = true
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Remove keyboard when background is tapped
     */
    @IBAction func tapOnScreen(_ sender: Any) {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    /**
     Called when user taps sign up button, registers user
     */
    @IBAction func onSignupButton(_ sender: Any) {
        
        let user = PFUser()
        user.username = usernameTextField.text?.lowercased()
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        if(user.username != nil && user.password != nil) {
            user.signUpInBackground {(success, error)   in
                if success {
                    
                    if self.imageSet {
                        let imageData = self.profileImageView.image!.jpegData(compressionQuality: 0.5)
                        let file = PFFileObject(data: imageData!)
                        user["profile_image"] = file
                    }
    
                    user["score"] = 0
                    
                    user.saveInBackground{(success, error) in
                        if success {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                    
                } else {
                    
                    // Could not register, display error
                    let alert = UIAlertController(title: "Registration Error", message: error?.localizedDescription.localizedCapitalized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    /**
     Logic for order of text fields
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case emailTextField:
                emailTextField.resignFirstResponder()
                usernameTextField.becomeFirstResponder()
            case usernameTextField:
                usernameTextField.resignFirstResponder()
                passwordTextField.becomeFirstResponder()
            default:
                emailTextField.resignFirstResponder()
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
