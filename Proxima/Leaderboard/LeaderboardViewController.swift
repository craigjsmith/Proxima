//
//  LeaderboardViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/22/20.
//

import UIKit
import Parse

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var profiles = [PFObject]()
    var selectedProfile: PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self;
        tableView.dataSource = self;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Finds 20 users in descending order of their scores
        // only gets score and name
        let query = PFQuery(className: "_User")
        query.limit = 20 // keeps only 20 results
        query.includeKeys(["score", "full_name", "profile_image"]) // gets name and score, can add other attributes later
        query.whereKeyExists("score")
        query.addDescendingOrder("score")
        
        query.findObjectsInBackground { (profiles, error) in
            if profiles != nil {
                print(profiles)
                // sets profiles to the return of query
                self.profiles = profiles!
                self.tableView.reloadData()
            } else {
                print("error: \(error?.localizedDescription)")
            }
        }
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of rows is number of profiles gotten from query
        return profiles.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell") as! LeaderboardCell
        
        // Gets profile
        let profile = profiles[indexPath.row]
        
        cell.nameLabel.text = profile["full_name"] as? String
        
        let score: Int = profile["score"] as! Int
        cell.starsLabel.text = String(score)
        
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
    
    
    

    // Send which user was clicked on to profile view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        
        if let indexPath = tableView.indexPath(for: cell) {
            let profile = profiles[indexPath.row]
            let profileController = segue.destination as! ProfileViewController
            profileController.currentUser = profile as! PFUser
        }
    }
    

}
