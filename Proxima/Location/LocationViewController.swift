//
//  LocationViewController.swift
//  Proxima
//
//  Created by Craig Smith on 12/5/20.
//

import UIKit
import Parse

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    var location: PFObject?
    
    var locationManager: CLLocationManager?
    
    // If user has visted location
    var visited = false
    
    /// User's current location
    var userGeoPoint = PFGeoPoint()
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var addLocationButton: UIButton!
    
    // Becomes either delete/report location
    @IBOutlet weak var destructiveButton: UIButton!
    
    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if location != nil {
            // Setup location manager
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.distanceFilter = 25
            locationManager?.startUpdatingLocation()
            locationManager?.startMonitoringSignificantLocationChanges()
            
            // Set location name
            nameLabel.text = location!["name"] as! String
            
            // Set location description
            descriptionLabel.text = location!["description"] as! String
            
            // Set owner
            let user = location?["author"] as! PFUser
            user.fetchIfNeededInBackground { (user, error) in
                if user != nil {
                    let userPF = user as! PFUser
                    self.userLabel.text = String("Shared by ") + (userPF["name"] as! String)
                } else {
                    self.userLabel.text = String("Shared by a Proxima user")
                }
                
            }
            
            // Set categories
            categoryLabel.text = location!["category"] as! String
            
            // Set weather
            let coord = location?["geopoint"] as! PFGeoPoint
            
            
            // Set image
            if location?["image"] != nil {
                let imageFile = location?["image"] as! PFFileObject
                let imageUrl = URL(string: imageFile.url!)!
                self.pictureView?.af.setImage(withURL: imageUrl, placeholderImage: UIImage.imageWithColor(color: UIColor.quaternaryLabel))
            }
            
            getWeather(lat:coord.latitude, long:coord.longitude)
            
            // If user has already visited, disable button
            PFUser.current()?.fetchInBackground(block: { (user: PFObject?, error: Error?) in
                let arr = user?["visited_locations"] as? [PFObject] ?? []
                for visitedLocation in user?["visited_locations"] as? [PFObject] ?? [] {
                    if(visitedLocation.objectId == self.location?.objectId) {
                        self.visited = true
                        self.disableVisitButton(visited: self.visited)
                        break
                    }
                }
            })
            
            
            // If author show delete button, otherwise report button
            if (user.objectId == PFUser.current()?.objectId) {
                self.destructiveButton.setTitle("Delete Location", for: .normal)
                self.destructiveButton.addTarget(self, action: #selector(onDelete), for: .touchUpInside)
            } else {
                self.destructiveButton.setTitle("Report Location", for: .normal)
                self.destructiveButton.addTarget(self, action: #selector(onReport), for: .touchUpInside)
            }
        }
        
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /**
     Runs whenever new GPS data is available
     */
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        userGeoPoint = PFGeoPoint(latitude: locationManager?.location?.coordinate.latitude as! Double, longitude: locationManager?.location?.coordinate.longitude as! Double)
        
        // Get user's distance from location
        let dist = userGeoPoint.distanceInMiles(to: location!["geopoint"] as? PFGeoPoint)
        
        // If user geo point is valid and is in range of location, enable visit button
        if(userGeoPoint.latitude != 0 && !visited && dist < 0.1) {
            enableVisitButton()
        } else {
            disableVisitButton(visited: visited)
        }
    }
    
    /**
     Get weather conditions at location
     */
    func getWeather(lat: Double, long: Double) {
        let filePath = Bundle.main.path(forResource: "keys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: filePath!)
        let openWeatherAPI = plist?.object(forKey: "OPENWEATHER_KEY") as! String
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=" + String(lat) + "&lon=" + String(long) + "&units=imperial" + "&appid=" + openWeatherAPI)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
        
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
                let mainJSON = dataDictionary["main"] as! [String: Any]
                let temp = mainJSON["temp"] as! Double
            
                let weatherJSON = dataDictionary["weather"] as! [[String: Any]]
                let subWeatherJSON = weatherJSON.first!
                let condition = subWeatherJSON["main"] as! String
            
                var emoji = "🌥"
                if(condition == "Thunderstorm") {
                    emoji = "⚡️"
                }
                else if(condition == "Drizzle") {
                    emoji = "☔️"
                }
                else if(condition == "Rain") {
                    emoji = "☔️"
                }
                else if(condition == "Snow") {
                    emoji = "🌨"
                }
                else if(condition == "Clear") {
                    emoji = "☀️"
                }
                else if(condition == "Clouds") {
                    emoji = "☁️"
                }
                else if(condition == "Drizzle") {
                    emoji = "🌦"
                }
            
                self.weatherLabel.text = emoji + String(Int(temp)) + "°"
 
           }
        }
        task.resume()
    }
    
    /**
     Delete location, only visible and functional by author
     */
    func deleteLocation() {
        destructiveButton.isEnabled = false;
        PFUser.current()?.remove(location!, forKey: "created_locations")
        PFUser.current()?.incrementKey("score", byAmount: -1) // Remove star from user
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if(success) {                
                self.location?.deleteInBackground(block: { (success, error) in
                    if(success) {
                        self.dismiss(animated: true) {
                          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalDismissed"), object: nil)
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                })
                
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    /**
     Runs when delete button is tapped, confirms with user
     */
    @objc func onDelete() {
        
        let alert = UIAlertController(title: "Delete Location?", message: "Are you sure you want to pernamently delete this location?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Destructive action"), style: .destructive, handler: { _ in
            self.deleteLocation()
            //self.dismiss(animated: true, completion: {})
            
            self.dismiss(animated: true) {
              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalIsDimissed2"), object: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { _ in
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /**
     Handles content reporting
     */
    @objc func onReport() {
        let reportAlert = UIAlertController(title: "Report Content?", message: "Please let us know why you are reporting this content.", preferredStyle: .alert)
        reportAlert.addTextField { (reportMessage) in }
        
        reportAlert.addAction(UIAlertAction(title: NSLocalizedString("Report", comment: "Destructive action"), style: .destructive, handler: { _ in
            
            // Post report to db
            let post = PFObject(className: "Reports")
            post["content"] = self.location
            post["message"] = reportAlert.textFields![0].text
            post.saveInBackground { (success, error) in
            
                // Display confirmation
                let confirmAlert = UIAlertController(title: "Report Submitted", message: "Thanks for reporting, we'll take a look soon.", preferredStyle: .alert)
                    confirmAlert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                self.present(confirmAlert, animated: true, completion: nil)
            
            }

        }))
        
        reportAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { _ in
        }))
        
        self.present(reportAlert, animated: true, completion: nil)
    }
    
    /**
     Marks location as visited by current user
     */
    @IBAction func visitLocation(_ sender: Any) {
        if(PFUser.current() == nil) {
            let alert = UIAlertController(title: "Not logged in", message: "Only registered users can earn points for visiting locations. Go to the Profile tab to login or singup.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok action"), style: .default, handler: { _ in
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            visited = true
            disableVisitButton(visited: visited)
            PFUser.current()?.incrementKey("score", byAmount: 1) // Award user a star
            PFUser.current()?.add(location!, forKey: "visited_locations")
            PFUser.current()?.saveInBackground()
        }
    }
    
    /**
     Disables visit button
     - Parameters:
     - visited : if location was visited, otherwise 'out of range' is assumed
     */
    func disableVisitButton(visited: Bool) {
        if(visited) {
            addLocationButton.setTitle("Visited", for: .normal)
        } else {
            
            // Check that user location is valid
            if(userGeoPoint.latitude != 0) {
                // Set distance label
                let dist = userGeoPoint.distanceInMiles(to: location!["geopoint"] as? PFGeoPoint)
                
                var distString = ""
                // If distance is more than 5 miles away, don't show floating point
                if(dist < 5) {
                    distString = String(format: "%.1f", dist)
                } else {
                    distString = String(format: "%.0f", dist)
                }
                addLocationButton.setTitle(String(distString + " miles away"), for: .normal)
            } else {
                addLocationButton.setTitle("Out of range", for: .normal)
            }
        }
        
        self.addLocationButton.isEnabled = false
        addLocationButton.backgroundColor = UIColor.darkGray
    }
    
    /**
     Enables visit button
     */
    func enableVisitButton() {
        addLocationButton.setTitle("I'm Here", for: .normal)
        self.addLocationButton.isEnabled = true
        addLocationButton.backgroundColor = UIColor.systemBlue
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
