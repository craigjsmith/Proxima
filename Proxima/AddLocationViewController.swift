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
        
        post["name"] = locationName.text as! String
        post["description"] = descriptionName.text as! String
        
        // Set coordinates of location
        // TODO: Make this GPS location, hard coded for now
        post["lat"] = 222.726840;
        post["long"] = -33.497420;
        
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
        
        
        post.saveInBackground { (success, error) in
            if success {
                let user = PFUser.current()
                user?.add(post, forKey: "created_locations")
                
                user?.saveInBackground()
                
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
        
        let image = PFObject(className: "Image")
    
       /* let imageData = photoCheck.image!.pngData()
        let file = PFFileObject(data: imageData!)
        
        image["Image"] = file
        
        image.saveInBackground {(success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            } else {
                print("error!")
            }
        }*/
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
