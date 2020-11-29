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
        let query = PFQuery(className: "UserTest")
        query.limit = 20 // keeps only 20 results
        query.includeKeys(["name", "score"]) // gets name and score, can add other attributes later
        query.addDescendingOrder("score")
        
        query.findObjectsInBackground { (profiles, error) in
            if profiles != nil {
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
        
        cell.nameLabel.text = profile["name"] as? String
        
        let score: Int = profile["score"] as! Int
        cell.starsLabel.text = String(score)
        
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
