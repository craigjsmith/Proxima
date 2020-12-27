//
//  ProfileViewController.swift
//  Proxima
//
//  Created by Craig Smith on 12/26/20.
//

import UIKit

class ProfileViewController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        if(PFUser.current() == nil) {
            performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
