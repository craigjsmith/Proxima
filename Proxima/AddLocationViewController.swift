//
//  AddLocationViewController.swift
//  Proxima
//
//  Created by Craig Smith on 11/30/20.
//
import UIKit
import Parse
import AlamofireImage
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var descriptionName: UITextField!
    @IBOutlet weak var landmarkCheck: UISwitch!
    @IBOutlet weak var natureCheck: UISwitch!
    @IBOutlet weak var urbanCheck: UISwitch!
    @IBOutlet weak var historicalCheck: UISwitch!
    @IBOutlet weak var photoCheck: UISwitch!
   
    var locationManager: CLLocationManager?
    
    var locationImageFile: PFFileObject?
    
    var lat = 0.0
    var lon = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationName.delegate = self
        descriptionName.delegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let post = PFObject(className: "Locations")
        
        // Set write access to this user only
        let acl = PFACL()
        acl.setWriteAccess(true, for: PFUser.current()!)
        acl.hasPublicWriteAccess = false
        acl.hasPublicReadAccess = true
        post.acl = acl
        
        post["name"] = locationName.text as! String
        post["description"] = descriptionName.text as! String
        
        // Set coordinates of location
        // TODO: Make this GPS location, hard coded for now
        post["lat"] = lat;
        post["long"] = lon;
        
        var categories: [String] = []
        
        if(landmarkCheck.isOn) {
            categories.append("Landmark")
        }
        if(natureCheck.isOn) {
            categories.append("Nature")
        }
        if(urbanCheck.isOn) {
            categories.append("Urban")
        }
        if(historicalCheck.isOn) {
            categories.append("Historical")
        }
        if(photoCheck.isOn) {
            categories.append("Photo Op")
        }
        
        post["categories"] = categories
        post["author"] = PFUser.current()
        
        if locationImageFile != nil {
            post["image"] = locationImageFile
        } 
        
        post.saveInBackground { (success, error) in
            if success {
                let user = PFUser.current()
                user?.add(post, forKey: "created_locations") // Add this location to the ones created by the current user
                user?.incrementKey("score") // Increase score every time they add location
                user?.saveInBackground() // Save user with new info
                
                print("Location saved");
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error saving location: \(error?.localizedDescription)")
            }
        }
        
        
    }
    
    @IBAction func tapOnScreen(_ sender: Any) {
        locationName.resignFirstResponder()
        descriptionName.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case locationName:
                locationName.resignFirstResponder()
                descriptionName.becomeFirstResponder()
            case descriptionName:
                descriptionName.resignFirstResponder()
                locationName.becomeFirstResponder()
            default:
                locationName.resignFirstResponder()
                descriptionName.becomeFirstResponder()
        }
        return false
    }
    
    @IBAction func onImageButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .photoLibrary
            
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 1920, height: 1080)
        let scaledImage = image.af_imageScaled(to: size)
        
        let imageData = scaledImage.pngData()
        let file = PFFileObject(data: imageData!)
        
        self.locationImageFile = file
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        lat = userLocation.coordinate.latitude
        lon = userLocation.coordinate.longitude
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
