//
//  LocationViewController.swift
//  Proxima
//
//  Created by Craig Smith on 12/5/20.
//

import UIKit
import Parse

class LocationViewController: UIViewController {
    
    var location: PFObject?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = location!["name"] as! String
        descriptionLabel.text = location!["description"] as! String
        
        let user = location?["author"] as! PFUser
        userLabel.text = user.username
        
        let categories = location!["categories"] as? [String] ?? []
        categoryLabel.text = categories.joined(separator: ", ")
        
        // Do any additional setup after loading the view.
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
