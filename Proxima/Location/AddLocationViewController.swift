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

class AddLocationViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var descriptionName: UITextField!
    @IBOutlet weak var categoryChecker: UIPickerView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var postButton: UIButton!
    
    var locationManager: CLLocationManager?
    
    var locationImageFile: PFFileObject?
    
    var lat = 0.0
    var lon = 0.0
    
    var pinSet = false
    
    let dragPin = MKPointAnnotation()
    
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self;

        locationName.delegate = self
        descriptionName.delegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.startUpdatingLocation()
        
        pickerData = ["Landmark", "Nature", "Art", "Urban", "Rustic", "Historical"]
        self.categoryChecker.delegate = self
        self.categoryChecker.dataSource = self
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        }
    
        annotationView?.canShowCallout = false
        annotationView?.isDraggable = true
        annotationView?.setDragState(MKAnnotationView.DragState.dragging, animated: true)
        annotationView?.glyphTintColor = .white
        annotationView?.setSelected(true, animated: true)

        return annotationView
    }
    
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
        
        post["name"] = locationName.text as! String
        post["description"] = descriptionName.text as! String
        
        // Set coordinates of location
        let point = PFGeoPoint(latitude:dragPin.coordinate.latitude, longitude:dragPin.coordinate.longitude)
        post["geopoint"] = point

        
        var category = pickerData[categoryChecker.selectedRow(inComponent: 0)] as! String
        post["category"] = category
        
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
        
        // Compress image before uploading
        let imageCompressed = image.jpegData(compressionQuality: 0.5)
        let file = PFFileObject(data: imageCompressed!)
        
        self.locationImageFile = file
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        lat = userLocation.coordinate.latitude
        lon = userLocation.coordinate.longitude
        
        if(!pinSet) {
            addPinToLocation()
            pinSet = true
        }
    }
    
    func addPinToLocation() {
        dragPin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        let region = self.map.regionThatFits(MKCoordinateRegion(center: dragPin.coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
        self.map.setRegion(region, animated: false)
        
        self.map.addAnnotation(dragPin)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        pinSet = false;
    }
    

}
