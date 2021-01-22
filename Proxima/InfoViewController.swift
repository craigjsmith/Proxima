//
//  InfoViewController.swift
//  Proxima
//
//  Created by Craig Smith on 1/20/21.
//

import UIKit

/// App information screen
class InfoViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    }
    
    /**
     Open TOS in webbrowser
     */
    @IBAction func openTos(_ sender: Any) {
        if let url = URL(string: "https://www.craigsmith.dev/proxima/terms.html") {
            UIApplication.shared.open(url)
        }
    }
    
    /**
     Open Privacy Policy in webbrowser
     */
    @IBAction func openPrivacy(_ sender: Any) {
        if let url = URL(string: "https://www.craigsmith.dev/proxima/privacy.html") {
            UIApplication.shared.open(url)
        }
    }
    
    /**
     Open developer website
     */
    @IBAction func openSite(_ sender: Any) {
        if let url = URL(string: "https://craigsmith.dev") {
            UIApplication.shared.open(url)
        }
    }
    
    /**
     Open email
     */
    @IBAction func openContact(_ sender: Any) {
        let email = "proxima@craigsmith.dev"
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
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
