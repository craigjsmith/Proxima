//
//  LocationTableViewController.swift
//  Proxima
//
//  Created by Craig Smith on 12/24/20.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UITableViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    let tableRefreshControl = UIRefreshControl()
    
    var locations = [PFObject]()
    var userGeoPoint = PFGeoPoint()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.startUpdatingLocation()
        
        // Important for loading in new locations with correct scroll bar size
        tableView.estimatedRowHeight = 127
        
        tableRefreshControl.addTarget(self, action: #selector(reset), for: .valueChanged)
        tableView.refreshControl = tableRefreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reset()
        self.tableView.contentOffset = CGPoint.zero
    }
    
    @objc func reset() {
        locations = [PFObject]()
        populate(limit: 10, skip: 0)
        self.tableView.reloadData()
    }

    func populate(limit: Int, skip: Int) {
        // User's location
        userGeoPoint = PFGeoPoint(latitude: locationManager?.location?.coordinate.latitude as! Double, longitude: locationManager?.location?.coordinate.longitude as! Double)

        let query = PFQuery(className: "Locations")
        query.whereKey("geopoint", nearGeoPoint:userGeoPoint)
        
        query.limit = limit
        query.skip = skip
        
        query.findObjectsInBackground { (newLocations, error) in
            if newLocations != nil {
                self.locations.append(contentsOf: newLocations!)
                self.tableView.reloadData()
                self.tableRefreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row + 1 == locations.count && locations.count > 0 {

            let query = PFQuery(className:"Locations")
            query.countObjectsInBackground { (count: Int32, error: Error?) in
                if let error = error {
                    // The request failed
                    print(error.localizedDescription)
                } else {
                    if(count > self.locations.count) {
                        // Load 10 more, skip for rows already created
                        self.populate(limit: 10, skip: tableView.numberOfRows(inSection: 0))
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "FeedViewCell") as! FeedViewCell
         let location = locations[indexPath.row]
         
        // Set name and category
        cell.nameLabel.text = location["name"] as? String
         cell.categoryLabel.text = location["category"] as? String ?? ""
         
        // Set distance label
         let dist = userGeoPoint.distanceInMiles(to: location["geopoint"] as? PFGeoPoint)
        
        if(dist < 5) {
             cell.distanceLabel.text = String(format: "%.1f", dist) + " miles away"
         } else {
             cell.distanceLabel.text = String(format: "%.0f", dist) + " miles away"
         }
         
        // Set image
         let imageFile = location["image"] as? PFFileObject ?? nil
        
         if(imageFile != nil) {
             let imageUrl = URL(string: (imageFile?.url!)!)
             cell.locationImage?.af.setImage(withURL: imageUrl!)
            
         } else {
            cell.locationImage.image = nil
         }
         
         cell.setNeedsLayout() // invalidate current layout
         cell.layoutIfNeeded() // update immediately
         
         return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToLocation" {
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            let location = locations[indexPath.row]
            
            // Pass the selected object to the new view controller.
            let locationViewController = segue.destination as! LocationViewController
            
            locationViewController.location = location
            
            // Deselect cell before segue
            if let path = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: path, animated: true)
            }
        }
    }
    
}
