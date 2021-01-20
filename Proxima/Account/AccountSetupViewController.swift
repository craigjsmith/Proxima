//
//  AccountSetupViewController.swift
//  Proxima
//
//  Created by Craig Smith on 1/19/21.
//

import UIKit
import Parse

class AccountSetupViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {

    var imageSet = false
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        
        // Set profile image to circle
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = (profileImageView.frame.width / 2)

        // Set user's current name
        nameField.text = PFUser.current()!["name"] as! String

        // Set user's current profile picture
        if PFUser.current()!["profile_image"] != nil {
            let imageFile = PFUser.current()!["profile_image"] as! PFFileObject
            let imageUrl = URL(string: imageFile.url!)!
            self.profileImageView.af.setImage(withURL: imageUrl)
        }
        
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
    
    @IBAction func onSubmit(_ sender: Any) {
        let name = nameField.text
        PFUser.current()!["name"] = name
        
        if self.imageSet {
            let imageData = self.profileImageView.image!.jpegData(compressionQuality: 0.5)
            let file = PFFileObject(data: imageData!)
            PFUser.current()!["profile_image"] = file
        }
        
        PFUser.current()?.saveInBackground(block: { (success, error) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalDismissed"), object: nil)
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true)
        })

    }
    
    @IBAction func onBackground(_ sender: Any) {
        nameField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {

        textField.resignFirstResponder()
        return true
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
