//
//  AddLocationViewController.swift
//  Proxima
//

import UIKit
import Parse
import AlamofireImage
import MapKit

/// Add location view controller
class AddLocationViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var locationDescription: UITextField!
    @IBOutlet weak var categoryChecker: UIPickerView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var postButton: UIButton!
    
    var locationManager: CLLocationManager?
    
    /// Location image
    var locationImageFile: PFFileObject?
    
    /// Location latitude
    var lat = 0.0
    /// Location longitude
    var lon = 0.0
    
    /// If pin location was set by user,
    var pinSet = false
    
    /// Pin representing location, draggable by user
    let dragPin = MKPointAnnotation()
    
    /// Collection of all location categories
    var pickerData: [String] = ["Landmark", "Nature", "Art", "Urban", "Rustic", "Historical"]
    
    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self;

        locationName.delegate = self
        locationDescription.delegate = self
        
        self.categoryChecker.delegate = self
        self.categoryChecker.dataSource = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.startUpdatingLocation()
    }
    
    /**
     Returns annotation view to display pins on
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        }
    
        annotationView?.canShowCallout = false
        annotationView?.isDraggable = true
        annotationView?.setDragState(MKAnnotationView.DragState.dragging, animated: true)
        annotationView?.glyphTintColor = .white
        annotationView?.setSelected(true, animated: true)

        return annotationView
    }
    
    /**
     Runs when submit button on Add location tapped
     */
    @IBAction func onSubmit(_ sender: Any) {
        postButton.isEnabled = false
        
        // Prevents non-registered user from adding location. This screen should
        // never show if that's the case, this is an extra catch
        if(PFUser.current() == nil) {
            let error = UIAlertController(title: "Not logged in", message: "Only registered users can add new locations.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            error.addAction(okButton)
            self.present(error, animated: true, completion: nil)
            
            return
        }
        
        let post = PFObject(className: "Locations")
        
        // Set write access to this user only
        let acl = PFACL()
        acl.setWriteAccess(true, for: PFUser.current()!)
        acl.hasPublicWriteAccess = false
        acl.hasPublicReadAccess = true
        post.acl = acl
        
        // Check that required fields are entered
        if (locationName.text == "") {
            let error = UIAlertController(title: "Missing Field", message: "The Name field is required.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            error.addAction(okButton)
            self.present(error, animated: true, completion: nil)
            postButton.isEnabled = true
        } else if (locationImageFile == nil) {
            let error = UIAlertController(title: "No Image Set", message: "You must upload an image.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            error.addAction(okButton)
            self.present(error, animated: true, completion: nil)
            postButton.isEnabled = true
        } else {
            // Set location name
            post["name"] = locationName.text as! String
            
            // Set location description
            post["description"] = locationDescription.text as! String
            
            // Set location coordinate
            let point = PFGeoPoint(latitude:dragPin.coordinate.latitude, longitude:dragPin.coordinate.longitude)
            post["geopoint"] = point

            // Set location category
            var category = pickerData[categoryChecker.selectedRow(inComponent: 0)] as! String
            post["category"] = category
            
            // Set location author
            post["author"] = PFUser.current()
            
            // Set location image
            if locationImageFile != nil {
                post["image"] = locationImageFile
            }
            
            // Save location to database
            post.saveInBackground { (success, error) in
                if success {
                    let user = PFUser.current()
                    user?.add(post, forKey: "created_locations") // Add this location to the ones created by the current user
                    user?.incrementKey("score") // Award user a star
                    user?.saveInBackground() // Save user with new info
                    print("Location saved");
                    
                    self.dismiss(animated: true) {
                      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalDismissed"), object: nil)
                    }
                } else {
                    print("error saving location: \(error?.localizedDescription)")
                }
            }
            }
            
        
    }
    
    /**
     Close keyboard when background tapped
     */
    @IBAction func tapOnScreen(_ sender: Any) {
        locationName.resignFirstResponder()
        locationDescription.resignFirstResponder()
    }
    
    /**
     Logic for input order
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case locationName:
                locationName.resignFirstResponder()
                locationDescription.becomeFirstResponder()
            case locationDescription:
                locationDescription.resignFirstResponder()
                locationName.becomeFirstResponder()
            default:
                locationName.resignFirstResponder()
                locationDescription.becomeFirstResponder()
        }
        return false
    }
    
    /**
     Runs when upload image button tapped on Add Location screen
     */
    @IBAction func onImageButton(_ sender: Any) {
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
        
        // Compress image before uploading
        let imageCompressed = image.jpegData(compressionQuality: 0.5)
        let file = PFFileObject(data: imageCompressed!)
        
        self.locationImageFile = file
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Runs when new location data is available (user location only updated once)
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(!pinSet) {
            let userLocation :CLLocation = locations[0] as CLLocation
            lat = userLocation.coordinate.latitude
            lon = userLocation.coordinate.longitude
            
            addPinToLocation()
            pinSet = true
        }
    }
    
    /**
     Add pin at user's current location
     */
    func addPinToLocation() {
        dragPin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        let region = self.map.regionThatFits(MKCoordinateRegion(center: dragPin.coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
        self.map.setRegion(region, animated: false)
        
        self.map.addAnnotation(dragPin)
    }
    
    /// Functions for location category scroll picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// Number of categories to show in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    /// Get current selected location from scroll index
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        pinSet = false;
        
    }
    

}
