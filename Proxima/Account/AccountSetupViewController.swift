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
        nameField.text = PFUser.current()!["name"] as? String ?? "Proxima User"

        // Set user's current profile picture
        if PFUser.current()!["profile_image"] != nil {
            let imageFile = PFUser.current()!["profile_image"] as! PFFileObject
            let imageUrl = URL(string: imageFile.url!)!
            self.profileImageView.af.setImage(withURL: imageUrl)
        }
        
        self.navigationItem.hidesBackButton = true
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
     Submits and updates new user info
     */
    @IBAction func onSubmit(_ sender: Any) {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(name!.count >= 3 && name!.count <= 16 ) {
            PFUser.current()!["name"] = name
            if self.imageSet {
                let imageData = self.profileImageView.image!.jpegData(compressionQuality: 0.4)
                let file = PFFileObject(data: imageData!)
                PFUser.current()!["profile_image"] = file
            }
            
            PFUser.current()?.saveInBackground(block: { (success, error) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalDismissed"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
                self.dismiss(animated: true)
            })
        } else {
            let error = UIAlertController(title: "Invalid Name", message: "Names must be between 3 and 16 characters.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            error.addAction(okButton)
            self.present(error, animated: true, completion: nil)
        }

    }
    
    /**
     Closes keyboard when background is clicked
     */
    @IBAction func onBackground(_ sender: Any) {
        nameField.resignFirstResponder()
    }
    
    /**
     Keyboard closes when Done is pressed
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Logout current user
     */
    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOut()

        let main = UIStoryboard(name: "Main", bundle: nil)
        let map = main.instantiateViewController(identifier: "FeedNavigationController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = map
 
    }
    
    /**
     Display error to user upon account deletion failure
     */
    func deleteAccountError() {
        let alert = UIAlertController(title: "Something went wrong", message: "We could not delete your account. Please contact developer.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Delete all locations created by user
     */
    func deleteLocations() {
        let query = PFQuery(className: "Locations")
        query.whereKey("author", equalTo: PFUser.current()!)
        query.findObjectsInBackground { locations, error in
            do {
                try PFObject.deleteAll(locations)
                self.deleteAccount()
            } catch {
                self.deleteAccountError();
            }
        }
    }
    
    /**
     Delete account of user
     */
    func deleteAccount() {
        PFCloud.callFunction(inBackground: "deleteUser", withParameters: ["userId":PFUser.current()!.objectId!]) {
            (response, error) in
            if(error == nil) {
                PFUser.logOut()

                let main = UIStoryboard(name: "Main", bundle: nil)
                let map = main.instantiateViewController(identifier: "FeedNavigationController")
                let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate

                delegate.window?.rootViewController = map

            } else {
                self.deleteAccountError();
            }
        }
    }
    
    /**
     Handle delete account button press
     */
    @IBAction func deleteAccountButton(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Account?", message: "Are you sure you want to pernamently delete your Proxima account? This cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete my account", comment: "Destructive action"), style: .destructive, handler: { _ in
            self.deleteLocations()
            
            self.dismiss(animated: true) {
              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalIsDimissed2"), object: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { _ in
        }))
        
        self.present(alert, animated: true, completion: nil)
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
