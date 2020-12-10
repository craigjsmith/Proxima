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
    
    let openWeatherAPI = "1aaa65db3029bc25e901f1b3db518f2c"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if location != nil {
            
            // Set location name
            nameLabel.text = location!["name"] as! String
            
            // Set location description
            descriptionLabel.text = location!["description"] as! String
            
            // Set owner
            let user = location?["author"] as! PFUser
            user.fetchIfNeededInBackground { (user, error) in
                if user != nil {
                    let userPF = user as! PFUser
                    self.userLabel.text = userPF.username
                } else {
                    print("Error: \(error?.localizedDescription)")
                }
                
            }
            
            // Set categories
            let categories = location!["categories"] as? [String] ?? []
            categoryLabel.text = categories.joined(separator: ", ")
            
            // Set weather
            let lat = location?["lat"] as! Double
            let long = location?["long"] as! Double
            
            getWeather(lat:lat, long:long)
            
        }
        
        else {
            self.dismiss(animated: true, completion: nil)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func getWeather(lat: Double, long: Double) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=" + String(lat) + "&lon=" + String(long) + "&units=imperial" + "&appid=" + openWeatherAPI)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
                let mainJSON = dataDictionary["main"] as! [String: Any]
                let temp = mainJSON["temp"] as! Double
            
                let weatherJSON = dataDictionary["weather"] as! [[String: Any]]
                let subWeatherJSON = weatherJSON.first!
                let condition = subWeatherJSON["main"] as! String
            
                print(condition)
            
                var emoji = ""
                if(condition == "Thunderstorm") {
                    emoji = "⚡️"
                }
                else if(condition == "Drizzle") {
                    emoji = "☔️"
                }
                else if(condition == "Rain") {
                    emoji = "☔️"
                }
                else if(condition == "Snow") {
                    emoji = "🌨"
                }
                else if(condition == "Clear") {
                    emoji = "☀️"
                }
                else if(condition == "Clouds") {
                    emoji = "☁️"
                }
                else if(condition == "Drizzle") {
                    emoji = "🌦"
                }
            
                self.weatherLabel.text = emoji + String(Int(temp)) + "°"
 
           }
        }
        task.resume()
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
