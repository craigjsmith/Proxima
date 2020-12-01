//
//  LoginViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/22/20.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func onLoginButton(_ sender: Any) {
        
        let username = usernameField.text!
                let password = passwordField.text!
                       
                PFUser.logInWithUsername(inBackground: username, password: password)
                       {
                           (user, error) in
                           if user != nil {
                               self.performSegue(withIdentifier: "loginSegue", sender: nil)
                           } else {
                               print("Error: \(error?.localizedDescription)")
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
