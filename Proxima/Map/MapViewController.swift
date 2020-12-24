//
//  MapViewController.swift
//  Proxima
//
//  Created by Craig Smith on 12/6/20.
//

import UIKit
import MapKit
import Parse

let landmarkColor = UIColor(red: 61/255, green: 183/255, blue: 224/255, alpha: 1.0)
let natureColor = UIColor(red: 22/255, green: 171/255, blue: 47/255, alpha: 1.0)
let urbanColor = UIColor(red: 232/255, green: 89/255, blue: 70/255, alpha: 1.0)
let historicColor = UIColor(red: 242/255, green: 251/255, blue: 157/255, alpha: 1.0)
let photoopColor = UIColor(red: 141/255, green: 108/255, blue: 224/255, alpha: 1.0)
let unknownColor = UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1.0)

class ProximaPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?;
    var location : PFObject?;
    var emoji : String = "";
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var warningBox: UIView!
    var annotationView: MKAnnotationView!
    var locations = [PFObject]()
    var selectedAnnotation: ProximaPointAnnotation?
    
    var loadRectangle = MKMapRect(x: 0, y: 0, width: 0, height: 0)
    
    var locationManager: CLLocationManager?
    
    var mapDidLoad = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self

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
    
    override func viewDidAppear(_ animated: Bool) {
        populateMap()
    }
    
    //Calculate new rectangle (double previous size) to load points from
    func increaseLoadRectangle(rect :MKMapRect) {
        let newX = rect.minX
        let newY = rect.minY
        let newWidth = rect.width
        let newHeight = rect.height
        loadRectangle = MKMapRect(x: (newX - (newWidth/2)), y: (newY - (newHeight/2)), width: (newWidth*2), height: (newHeight*2))
    }
    
    func populateMap() {
        // Query to get locations from database
        //let query = PFQuery(className: "Locations")
        //query.includeKeys(["name", "description", "author", "lat", "long", "category"])
        //query.limit = 50
        
        // User's location
        let ne = MKMapPoint(x: loadRectangle.maxX, y: loadRectangle.minY)
        let sw = MKMapPoint(x: loadRectangle.minX, y: loadRectangle.maxY)
        /*
        let ne = MKMapPoint(x: map.visibleMapRect.maxX + 0.05, y: map.visibleMapRect.origin.y + 0.05)
        let sw = MKMapPoint(x: map.visibleMapRect.origin.x + 0.05, y: map.visibleMapRect.maxY + 0.05)
        */
        let ne_coord = PFGeoPoint(latitude: ne.coordinate.latitude, longitude: ne.coordinate.longitude)
        let sw_coord = PFGeoPoint(latitude: sw.coordinate.latitude, longitude: sw.coordinate.longitude)
        
        let userGeoPoint = PFGeoPoint(latitude: locationManager?.location?.coordinate.latitude as! Double, longitude: locationManager?.location?.coordinate.longitude as! Double)
        // Create a query for places
        var query = PFQuery(className:"Locations")
        // Interested in locations near user.
        query.whereKey("geopoint", withinGeoBoxFromSouthwest:sw_coord, toNortheast:ne_coord)
        // Limit what could be a lot of points.
        // Final list of objects
        query.includeKeys(["name", "description", "author", "lat", "long", "category"])
        //locations = query.findObjects()
        
        /*
        let dragPin = DropPin()
        dragPin.coordinate = CLLocationCoordinate2D(latitude: 42.725202 as! Double, longitude: -84.47999 as! Double)
        dragPin.title = "TEST"
        self.map.addAnnotation(dragPin)
        */
        
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
                        // Set color
                        if (category == "Art") {
                            pin.pinTintColor = photoopColor
                            pin.emoji = "🎨"
                        }
                        else if (category == "Nature") {
                            pin.pinTintColor = natureColor
                            pin.emoji = "🌳"
                        }
                        else if (category == "Urban") {
                            pin.pinTintColor = urbanColor
                            pin.emoji = "🏬"
                        }
                        else if (category == "Rustic") {
                            pin.pinTintColor = urbanColor
                            pin.emoji = "🏚"
                        }
                        else if (category == "Historical") {
                            pin.pinTintColor = historicColor
                            pin.emoji = "📜"
                        }
                        else if (category == "Landmark") {
                            pin.pinTintColor = landmarkColor
                            pin.emoji = "📍"
                        }
                        else {
                            pin.pinTintColor = unknownColor
                            pin.emoji = "❓"
                        }
                    
                    // Add pin to map
                    self.map.addAnnotation(pin)
                }
 
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        
            //let annotationViewButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
            //annotationViewButton.setImage(UIImage(named: "Pin-Square.png"), for: .normal)
            
            //annotationView?.leftCalloutAccessoryView = annotationViewButton
            
            let rightButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = rightButton
        } else {
            annotationView?.annotation = annotation
        }

        // Draw user location with default view rather than with ProximaPointAnnotation
        if (annotation.isKind(of: MKUserLocation.self)){
            return nil
        }
        
        /*
        if let annotation = annotation as? DropPin {
            // Color of marker
            //annotationView?.markerTintColor = annotation.pinTintColor
    
            annotationView?.canShowCallout = false
            annotationView?.isDraggable = true
            annotationView?.setDragState(MKAnnotationView.DragState.dragging, animated: true)
            
            // Color of inner icon of marker
            annotationView?.glyphTintColor = .white
            
            annotationView?.setSelected(true, animated: true)
            
            // Icon of marker
        }
        */
        
        if let annotation = annotation as? ProximaPointAnnotation {
            
            annotationView?.canShowCallout = true
            // Color of marker
            annotationView?.markerTintColor = annotation.pinTintColor
    
            //annotationView?.isDraggable = true
            //annotationView?.setDragState(MKAnnotationView.DragState.dragging, animated: true)
            
            // Color of inner icon of marker
            annotationView?.glyphTintColor = .white
            
            // Icon of marker
            annotationView?.glyphText = annotation.emoji
        }
        
        return annotationView

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "mapToLocationView", sender: nil)
    }
    
    // Runs every time map is moved
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
    
    // Runs when map tiles load
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        // Runs the first time map tiles load with non-null location
        // (first time GPS becomes available)
        if(!mapDidLoad && locationManager?.location?.coordinate.latitude != 0) {
            //Calculate new rectangle (double previous size) to load points from

            increaseLoadRectangle(rect: map.visibleMapRect)

            mapDidLoad = true
            populateMap()
        }
 
    }

    
    /*
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // This illustrates how to detect which annotation type was tapped on for its callout.
        if let annotation = view.annotation, annotation.isKind(of: BridgeAnnotation.self) {
            print("Tapped Golden Gate Bridge annotation accessory view")
            
            if let detailNavController = storyboard?.instantiateViewController(withIdentifier: "DetailNavController") {
                detailNavController.modalPresentationStyle = .popover
                let presentationController = detailNavController.popoverPresentationController
                presentationController?.permittedArrowDirections = .any
                
                // Anchor the popover to the button that triggered the popover.
                presentationController?.sourceRect = control.frame
                presentationController?.sourceView = control
                
                present(detailNavController, animated: true, completion: nil)
            }
        }
    }
    */

    // Sets selectedAnnotation to the currently selected pin
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
