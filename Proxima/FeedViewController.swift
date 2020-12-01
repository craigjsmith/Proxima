//
//  FeedViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/21/20.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var tableView: UITableView!
    
    var locations = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: "Locations")
        query.includeKeys(["name", "description"])
        query.limit = 20
        
        query.findObjectsInBackground { (locations, error) in
            if locations != nil {
                self.locations = locations!
                self.tableView.reloadData()
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedViewCell") as! FeedViewCell
        
        if indexPath.row < locations.count {
            
            let post = locations[indexPath.row] //indexPath.section
            
            let location = post["name"] as! String
            cell.nameLabel.text = location
            
            let categories = post["categories"] as? [String] ?? []
            let categoriesString = categories.joined(separator: ", ")

            cell.categoriesLabel.text = categoriesString
        }
        
        //cell.distanceLabel.text = "0.2 miles away"
        
        //cell.nameLabel.text = "Spartan Stadium"
        
        return cell
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
