//
//  LeaderboardTableViewController.swift
//  Proxima
//

import UIKit
import Parse
import SkeletonView

/// VIew controller for Leaderboard view
class LeaderboardTableViewController: UITableViewController, SkeletonTableViewDataSource {

    let tableRefreshControl = UIRefreshControl()
    
    /// Collection of Profile objects to show on feed
    var profiles = [PFObject]()
    
    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        // Important for loading in new locations with correct scroll bar size
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
        
        tableRefreshControl.addTarget(self, action: #selector(reset), for: .valueChanged)
        tableView.refreshControl = tableRefreshControl
        
        super.viewDidAppear(true)
        self.tableView.isSkeletonable = true
        self.tableView.showAnimatedSkeleton()
        
    }
    
    /**
     Called when view is about to appear
     */
    override func viewWillAppear(_ animated: Bool) {
        reset()
    }
    
    /**
     Called when view appears
     */
    override func viewDidAppear(_ animated: Bool) {
        // Scroll to top
        self.tableView.scrollRectToVisible(CGRect(x:0, y:0, width:1, height:1), animated: false)
    }
    
    /**
     Reset and reload the Leaderboard
     */
    @objc func reset() {
        profiles = [PFObject]()
        populate(limit: 15, skip: 0)
        self.tableView.contentOffset = CGPoint.zero
        self.tableView.reloadData()
    }

    /**
     Populate the leaderboard with users
     */
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
                self.tableView.hideSkeleton()
            }
        }
    }
    
    // MARK: - Table view data source

    /**
     Returns number of sections in table view, always 1
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     Returns number of rows in section, one per location
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    /**
     Called when feed is scrolled
     */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // When near end of feed, load more
        if indexPath.row + 1 == profiles.count && profiles.count > 0 {
            let query = PFQuery(className:"_User")
            query.countObjectsInBackground { (count: Int32, error: Error?) in
                if let error = error {
                    // The request failed
                    print(error.localizedDescription)
                } else {
                    if(count > self.profiles.count) {
                        // Load more, skip for rows already created
                        self.populate(limit: 15, skip: tableView.numberOfRows(inSection: 0))
                    }
                }
            }
        }
    }

    /**
     Logic for creating Leaderboard cells
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell") as! LeaderboardCell
        
        // Gets profile
        let profile = profiles[indexPath.row]
        
        // Set username
        cell.nameLabel.text = profile["name"] as? String
        
        // Set score (if nil assume 0)
        let score: Int = profile["score"] as? Int ?? 0
        cell.starsLabel.text = String(score) + " ⭐️"
        
        // Set profile image
        if profile["profile_image"] != nil {
            let imageFile = profile["profile_image"] as! PFFileObject
            let imageUrl = URL(string: imageFile.url!)
            cell.profileImage.af.setImage(withURL: imageUrl!, placeholderImage: UIImage.imageWithColor(color: UIColor.quaternaryLabel))
        } else {
            cell.profileImage.image = UIImage(systemName: "person.circle.fill")
            cell.profileImage.tintColor = UIColor.darkGray
        }
        
        cell.hideSkeleton()
        
        return cell
    }
    
    /**
     Tell SkeletonView reusable cell identifier
     */
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
       return "LeaderboardCell"
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        
        if let indexPath = tableView.indexPath(for: cell) {
            let profile = profiles[indexPath.row]
            let profileController = segue.destination as! ProfileViewController
            profileController.currentUser = profile as! PFUser
        }
        
        // Deselect cell before segue
        if let path = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: path, animated: true)
        }
 
    }
    

}
