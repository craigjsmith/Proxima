//
//  ProfileNavigationController.swift
//  Proxima
//
//  Created by Craig Smith on 12/26/20.
//

import UIKit
import Parse

class ProfileNavigationController: UINavigationController {

    override func viewDidLoad() {
        
        if(PFUser.current() == nil) {
            //self.view.removeFromSuperview()
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            return
        }
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ok")
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
