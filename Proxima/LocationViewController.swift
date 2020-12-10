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
    @IBOutlet weak var pictureView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if location != nil {
            nameLabel.text = location!["name"] as! String
            descriptionLabel.text = location!["description"] as! String
            
            let user = location?["author"] as! PFUser
            // Loads the user if needed
            user.fetchIfNeededInBackground { (user, error) in
                if user != nil {
                    let userPF = user as! PFUser
                    self.userLabel.text = userPF.username
                } else {
                    print("Error: \(error?.localizedDescription)")
                }
                
            }
            
            let categories = location!["categories"] as? [String] ?? []
            categoryLabel.text = categories.joined(separator: ", ")
            
        }
        
        else {
            self.dismiss(animated: true, completion: nil)
        }
        
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
