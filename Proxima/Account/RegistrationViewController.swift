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

    var imageSet = false
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
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
        
        // Set image preview to newly uploaded image
        profileImageView.image = scaledImage
        
        // Set profile image to circle
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = (profileImageView.frame.width / 2)
        
        imageSet = true
        
        dismiss(animated: true, completion: nil)
    }
    
    // Removes the keyboard
    @IBAction func tapOnScreen(_ sender: Any) {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //
    // Signs up user and adds their information to the database
    //
    @IBAction func onSignupButton(_ sender: Any) {
        
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        if(user.username != nil && user.password != nil) {
            user.signUpInBackground {(success, error)   in
                if success {
                    
                    if self.imageSet {
                        let imageData = self.profileImageView.image!.pngData()
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
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
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
