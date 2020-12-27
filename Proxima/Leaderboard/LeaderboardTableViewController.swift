//
//  LeaderboardTableViewController.swift
//  Proxima
//
//  Created by Craig Smith on 12/26/20.
//

import UIKit
import Parse

class LeaderboardTableViewController: UITableViewController {

    let tableRefreshControl = UIRefreshControl()
    
    var profiles = [PFObject]()
    var selectedProfile: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Important for loading in new locations with correct scroll bar size
        tableView.estimatedRowHeight = 100
        
        tableRefreshControl.addTarget(self, action: #selector(reset), for: .valueChanged)
        tableView.refreshControl = tableRefreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populate(limit: 10, skip: 0)
    
    }
    
    @objc func reset() {
        profiles = [PFObject]()
        populate(limit: 10, skip: 0)
        self.tableView.reloadData()
    }


    func populate(limit: Int, skip: Int) {
        let query = PFQuery(className: "_User")
        query.addDescendingOrder("score")
        query.limit = limit
        query.skip = skip
        
        query.findObjectsInBackground { (newProfiles, error) in
            if newProfiles != nil {
                self.profiles.append(contentsOf: newProfiles!)
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
        return profiles.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == profiles.count && profiles.count > 0 {
            
            let query = PFQuery(className:"_User")
            query.countObjectsInBackground { (count: Int32, error: Error?) in
                if let error = error {
                    // The request failed
                    print(error.localizedDescription)
                } else {
                    if(count > self.profiles.count) {
                        // Load 10 more, skip for rows already created
                        self.populate(limit: 10, skip: tableView.numberOfRows(inSection: 0))
                    }
                }
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell") as! LeaderboardCell
        
        // Gets profile
        let profile = profiles[indexPath.row]
        
        // Set username
        cell.nameLabel.text = profile["username"] as? String
        
        // Set score (if nil assume 0)
        let score: Int = profile["score"] as? Int ?? 0
        cell.starsLabel.text = String(score) + " ⭐️"
        
        // Set profile image
        if profile["profile_image"] != nil {
            let imageFile = profile["profile_image"] as! PFFileObject
            let imageUrl = URL(string: imageFile.url!)
            cell.profileImage.af.setImage(withURL: imageUrl!)
        } else {
            cell.profileImage.image = UIImage(systemName: "person.circle.fill")
            cell.profileImage.tintColor = UIColor.darkGray
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        
        if let indexPath = tableView.indexPath(for: cell) {
            let profile = profiles[indexPath.row]
            let profileController = segue.destination as! ProfileViewController
            profileController.currentUser = profile as! PFUser
        }
    }
    

}
