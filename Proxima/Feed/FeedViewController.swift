//
//  FeedViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/21/20.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!

    var locationManager: CLLocationManager?
    
    var locations = [PFObject]()
    var userGeoPoint = PFGeoPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.startUpdatingLocation()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        populate()
    }
    
    @IBAction func go(_ sender: Any) {
        populate()
    }
    
    func populate() {
        // User's location
        userGeoPoint = PFGeoPoint(latitude: locationManager?.location?.coordinate.latitude as! Double, longitude: locationManager?.location?.coordinate.longitude as! Double)

        let query = PFQuery(className: "Locations")
        query.whereKey("geopoint", nearGeoPoint:userGeoPoint)
        
        //query.includeKeys(["name", "description", "author", "image"])
        query.limit = 10
        
        query.findObjectsInBackground { (locations, error) in
            if locations != nil {
                self.locations = locations!
                self.tableView.reloadData()
            }
        }
        
        self.tableView.reloadData()
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedViewCell") as! FeedViewCell
                
        let post = locations[indexPath.row] //indexPath.section
        
        let location = post["name"] as! String
        cell.nameLabel.text = location
        
        cell.categoriesLabel.text = post["category"] as? String ?? ""
        
        let dist = userGeoPoint.distanceInMiles(to: post["geopoint"] as? PFGeoPoint)
        
        print(userGeoPoint.latitude)
        
        if(dist < 5) {
            cell.distanceLabel.text = String(format: "%.1f", dist) + " miles away"
        } else {
            cell.distanceLabel.text = String(format: "%.0f", dist) + " miles away"
        }
        
        
        
        let imageFile = post["image"] as! PFFileObject
        let imageUrl = URL(string: imageFile.url!)!
        cell.locationImage?.af.setImage(withURL: imageUrl)
        
        /*
        if post["image"] != nil {
            // Update location image
            let imageFile = post["image"] as! PFFileObject
            let imageUrl = URL(string: imageFile.url!)!
            cell.imageView!.af.setImage(withURL: imageUrl)
        }
 */
        //cell.distanceLabel.text = "0.2 miles away"
        
        //cell.nameLabel.text = "Spartan Stadium"
        
        cell.setNeedsLayout() //invalidate current layout
        cell.layoutIfNeeded() //update immediately
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        
        if segue.identifier == "feedToLocation" {
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            let location = locations[indexPath.row]
            
            // Pass the selected object to the new view controller.
            let locationViewController = segue.destination as! LocationViewController
            
            locationViewController.location = location
        }
 
    }
    
    @objc func refresh(){
        self.tableView.reloadData()
    }

}
