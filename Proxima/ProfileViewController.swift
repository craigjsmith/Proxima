//
//  ProfileViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/29/20.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var currUser: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self

        // Configure collection view layout
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 20 // controls space between rows
        
    }
    
    //
    // Called when the view appears. Gets current users info.
    //
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        // Gets the current users information
        let query = PFQuery(className: "UserTest")
        
        query.includeKeys(["name", "score", "created_locations", "visited_locations", "achievements", "user"])
        query.whereKey("objectId", equalTo: "NtmiPTlYZH")
        //query.whereKey("user", equalTo: PFUser.current()!)  // should get current user
        
        query.getFirstObjectInBackground() { (object: PFObject?, error: Error?) in
            if object != nil {
                        
                self.updateInfo(user: object!)
                
                self.currUser = object!
                self.collectionView.reloadData()
                self.tableView.reloadData()
            } else {
                print("error: \(error?.localizedDescription)")
            }
        }
                
    }
    
    
    func updateInfo(user: PFObject){
        
        self.nameLabel.text = user["name"] as? String
        //self.usernameLabel.text = user["user"]!.username as? String
        let score: Int = user["score"] as! Int
        self.starsLabel.text = String(score)
        
    }
    
    //
    // Controls Shared Locations for this user
    //
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationHorizontalCell", for: indexPath) as! LocationHorizontalCell
        
        cell.nameLabel.text = "Sparty Statue"
        return cell
    }
    
    //
    // Controls the achievements for this user
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementsCell") as! AchievementsCell
        
        cell.nameLabel.text = "Top Contributor"
        
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
