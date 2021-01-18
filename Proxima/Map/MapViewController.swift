//
//  MapViewController.swift
//  Proxima
//

import UIKit
import MapKit
import Parse

/// Pin to be displayed on interactive map
class ProximaPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?;
    var location : PFObject?;
    var emoji : String = "";
}

/// View controller for interactive map
class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    func modalDismissed() {
        populateMap()
    }
    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var warningBox: UIView!
    var locationManager: CLLocationManager?
    
    /// Annotation view of map for ProximaPointAnnotation
    var annotationView: MKAnnotationView!
    
    /// Collection of Location objects to show on map
    var locations = [PFObject]()
    
    /// Currently selected ProximaPointAnnotation, used for passing to segue
    var selectedAnnotation: ProximaPointAnnotation?
    
    /// Rectangle that defines geographical region to load locations for
    var loadRectangle = MKMapRect(x: 0, y: 0, width: 0, height: 0)
    
    /// If map has completed loading for the first time
    var mapDidLoad = false;
    
    /// Colors to use for ProximaPointAnnotation
    let landmarkColor = UIColor(red: 61/255, green: 183/255, blue: 224/255, alpha: 1.0)
    let natureColor = UIColor(red: 22/255, green: 171/255, blue: 47/255, alpha: 1.0)
    let urbanColor = UIColor(red: 232/255, green: 89/255, blue: 70/255, alpha: 1.0)
    let historicColor = UIColor(red: 242/255, green: 251/255, blue: 157/255, alpha: 1.0)
    let photoopColor = UIColor(red: 141/255, green: 108/255, blue: 224/255, alpha: 1.0)
    let unknownColor = UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1.0)
    
    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        // Observer for modal dismissal
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MapViewController.handleModalDismissed),
                                               name: NSNotification.Name(rawValue: "modalIsDimissed"),
                                               object: nil)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.startUpdatingLocation()
        
        // Adds user tracking mode toggle button to nav bar
        let buttonItem = MKUserTrackingBarButtonItem(mapView: map)
        self.navigationItem.leftBarButtonItem = buttonItem
        
        // Set default user tracking mode
        map.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
        

        
    }
    
    /**
     Called when view appears
     */
    override func viewDidAppear(_ animated: Bool) {
        populateMap()
    }
    
    /**
     Called when Add Location/View Location modal is dismissed
     */
    @objc func handleModalDismissed() {
        reset()
    }
    
    /**
     Called when add location button is pressed
     - Parameters:
     - sender : sender passed to segue
     */
    @IBAction func onAddLocation(_ sender: Any) {
        if((PFUser.current()) != nil) {
            performSegue(withIdentifier: "toAddLocation", sender: self)
        } else {
            let error = UIAlertController(title: "Not logged in", message: "Only registered users can add new locations. Go to the Profile tab to login or signup.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            error.addAction(okButton)
            self.present(error, animated: true, completion: nil)
        }
    }
    
    /**
     Calculate new rectangle (double previous size) to load locations from
     - Parameters:
     - rect : rectangle to increase
     */
    func increaseLoadRectangle(rect :MKMapRect) {
        let newX = rect.minX
        let newY = rect.minY
        let newWidth = rect.width
        let newHeight = rect.height
        loadRectangle = MKMapRect(x: (newX - (newWidth/2)), y: (newY - (newHeight/2)), width: (newWidth*2), height: (newHeight*2))
    }
    
    /**
     Reset map and fetch locations again
     */
    func reset() {
        map.removeAnnotations(map.annotations)
        locations.removeAll()
        populateMap()
    }
    
    /**
     Populate map with locations from the locations array
     */
    func populateMap() {
        
        // User's location
        let ne = MKMapPoint(x: loadRectangle.maxX, y: loadRectangle.minY)
        let sw = MKMapPoint(x: loadRectangle.minX, y: loadRectangle.maxY)
        
        let ne_coord = PFGeoPoint(latitude: ne.coordinate.latitude, longitude: ne.coordinate.longitude)
        let sw_coord = PFGeoPoint(latitude: sw.coordinate.latitude, longitude: sw.coordinate.longitude)
        
        let userGeoPoint = PFGeoPoint(latitude: locationManager?.location?.coordinate.latitude as? Double ?? 0, longitude: locationManager?.location?.coordinate.longitude as? Double ?? 0)
        
        // Query for places
        let query = PFQuery(className:"Locations")
        
        // Limits query to rectangle
        query.whereKey("geopoint", withinGeoBoxFromSouthwest:sw_coord, toNortheast:ne_coord)
        
        // Query the database
        query.findObjectsInBackground { (locations, error) in
            // After results are returned, iterate through them and add points
            for location in locations ?? [PFObject]() {
                // Make new pin
                let pin = ProximaPointAnnotation()
                
                pin.location = location
                
                // Set coords of pin
                let geopoint = location["geopoint"] as! PFGeoPoint
                
                pin.coordinate = CLLocationCoordinate2D(latitude: geopoint.latitude as! Double, longitude: geopoint.longitude as! Double)
                
                pin.title = location["name"] as! String
                
                // Set color of pin based on category
                
                // Unwrap category array
                let category = location["category"] as! String
                
                if (category == "Art") {
                    pin.pinTintColor = self.photoopColor
                    pin.emoji = "🎨"
                }
                else if (category == "Nature") {
                    pin.pinTintColor = self.natureColor
                    pin.emoji = "🌳"
                }
                else if (category == "Urban") {
                    pin.pinTintColor = self.urbanColor
                    pin.emoji = "🏬"
                }
                else if (category == "Rustic") {
                    pin.pinTintColor = self.urbanColor
                    pin.emoji = "🏚"
                }
                else if (category == "Historical") {
                    pin.pinTintColor = self.historicColor
                    pin.emoji = "📜"
                }
                else if (category == "Landmark") {
                    pin.pinTintColor = self.landmarkColor
                    pin.emoji = "📍"
                }
                else {
                    pin.pinTintColor = self.unknownColor
                    pin.emoji = "❓"
                }
                
                // Add pin to map
                self.map.addAnnotation(pin)
            }
        }
    }
    
    /**
     Processes annotations to show on map
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            let rightButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = rightButton
        } else {
            annotationView?.annotation = annotation
        }
        
        // Draw user location with default view rather than with ProximaPointAnnotation
        if (annotation.isKind(of: MKUserLocation.self)){
            return nil
        }
        
        if let annotation = annotation as? ProximaPointAnnotation {
            annotationView?.canShowCallout = true
            
            // Color of marker
            annotationView?.markerTintColor = annotation.pinTintColor
            
            // Color of inner icon of marker
            annotationView?.glyphTintColor = .white
            
            // Icon of marker
            annotationView?.glyphText = annotation.emoji
        }
        
        return annotationView
        
    }
    
    /**
     Called when annotation pin's popup is pressed
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "mapToLocationView", sender: nil)
    }
    
    /**
     Runs every time map is moved
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // If map view is of radius smaller than 600 miles
        if(Double(map.visibleMapRect.width) < (160934 * 100)) {
            warningBox.isHidden = true
            
            // If previously loaded view fully contains new view
            if(!loadRectangle.contains(map.visibleMapRect)) {
                
                // If loadRectangle was reset after going out of bounds,
                // set it back to the visible map view
                if(loadRectangle.width == 0) {
                    loadRectangle = map.visibleMapRect
                }
                
                populateMap()
                print("populated")
                
                increaseLoadRectangle(rect: map.visibleMapRect)
            }
        } else {
            if(mapDidLoad) {
                warningBox.isHidden = false
                
                // Reset load rectangle when out of range, forcing map to repopulate
                // when back in range
                loadRectangle = MKMapRect(x: 0, y: 0, width: 0, height: 0)
            }
        }
        
    }
    
    /**
     Runs the first time map tiles load with non-null and valid (non-zero) location (first time GPS becomes available)
     */
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        let lat = locationManager?.location?.coordinate.latitude
        if(!mapDidLoad && locationManager?.location?.coordinate.latitude != 0 && locationManager?.location?.coordinate.latitude != nil) {
            map.reloadInputViews()
            increaseLoadRectangle(rect: map.visibleMapRect)
            mapDidLoad = true
            populateMap()
        }
    }
    
    /**
     Sets selectedAnnotation to the currently selected pin
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? ProximaPointAnnotation
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "mapToLocationView" {
            let locationViewController = segue.destination as! LocationViewController
            
            // Set location of LocationViewController to that of the selected pin
            locationViewController.location = self.selectedAnnotation?.location as! PFObject
        }
    }
    
    
}
