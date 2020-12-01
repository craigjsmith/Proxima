//
//  AddLocationViewController.swift
//  Proxima
//
//  Created by Craig Smith on 11/30/20.
//

import UIKit
import Parse

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationName: UITextField!
    
    @IBOutlet weak var descriptionName: UITextField!
    
    @IBOutlet weak var landmarkCheck: UISwitch!
    @IBOutlet weak var natureCheck: UISwitch!
    @IBOutlet weak var urbanCheck: UISwitch!
    @IBOutlet weak var historicalCheck: UISwitch!
    @IBOutlet weak var photoCheck: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let post = PFObject(className: "Locations")
        
        post["name"] = locationName.text as! String
        post["description"] = descriptionName.text as! String
        
        var categories: [String] = []
        
        if(landmarkCheck.isOn) {
            categories.append("Landmark")
        }
        if(natureCheck.isOn) {
            categories.append("Nature")
        }
        if(urbanCheck.isOn) {
            categories.append("Urban")
        }
        if(historicalCheck.isOn) {
            categories.append("Historical")
        }
        if(photoCheck.isOn) {
            categories.append("Photo Op")
        }
        
        post["categories"] = categories
        
        post.saveInBackground { (success, error) in
            if success {
                print("Location saved");
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error saving location!");
            }
        }
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
