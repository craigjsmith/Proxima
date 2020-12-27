//
//  ProfileViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/29/20.
//

import UIKit
import Parse
import SkeletonView

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var createdLocations: [PFObject] = []
    var currentUser: PFUser!
    
    var achievements: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        view.isSkeletonable = true
        view.showSkeleton()
        
        // Set profile image to circle
        profileImage.layer.cornerRadius = (profileImage.frame.width / 2)
        profileImage.layer.masksToBounds = true
        
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
        
        if(PFUser.current() == nil) {
            //self.view.removeFromSuperview()
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            return
        }
        
        super.viewDidAppear(animated)
        
        // If user logged in, show logout button
        let backButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: Selector("logout"))
        navigationItem.rightBarButtonItem = backButton
        
        // If passing in from leaderboard
        if(self.currentUser != nil) {
            updateInfo(user: self.currentUser)
        }
        // Not passing from leaderboard, use current logged in user
        else {
            self.currentUser = PFUser.current()!
            updateInfo(user: self.currentUser)
        }
        
        self.createdLocations = (currentUser["created_locations"] as? [PFObject]) ?? []
//        print(createdLocations)
        self.achievements = getAchievements(user: self.currentUser)
        
        view.hideSkeleton()
        collectionView.reloadData()
        tableView.reloadData()
    }
    

    //
    // Does calculation to find achievements for this user
    //
    func getAchievements(user: PFUser) -> [String] {
        
        var achieve: [String] = []
        
        user.fetchIfNeededInBackground { (user, error) in
            let userPF = user as? PFUser
            
            if userPF != nil {
                let score = userPF?["score"] as? Int ?? 0
                
                if score == 0 {
                    return 
                }
                for i in 0...score {
                    if score >= 1 && i == 1{
                        achieve.append("First Timer")
                    }
                    else if score >= 5 && i == 5 {
                        achieve.append("Five Posts")
                    }
                    else if score >= 10 && i == 10 {
                        achieve.append("Experienced Explorer")
                    }
                    else if score >= 20 && i == 20 {
                        achieve.append("Top Contributor")
                    }
                }
                
            }

        }
        
        
        return achieve
    }
    
    //
    // Updates the labels and images using User data
    //
    func updateInfo(user: PFUser){
        
        // update name
        self.nameLabel.text = user["username"] as? String

        // update score
        let score = user["score"] as? Int ?? 0
        self.starsLabel.text = "⭐️ " + String(score)

        // Update profile image
        if user["profile_image"] != nil {
            let imageFile = user["profile_image"] as! PFFileObject
            let imageUrl = URL(string: imageFile.url!)!
            self.profileImage.af.setImage(withURL: imageUrl)
        }
        

    }
    
    
    //
    // Controls Shared Locations for this user
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return createdLocations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationHorizontalCell", for: indexPath) as! LocationHorizontalCell
        
        let location = self.createdLocations[indexPath.row] as! PFObject
        
        // Loads each location associated with this user
        location.fetchIfNeededInBackground { (location, error) in
            if location != nil {
                
                cell.nameLabel.text = location!["name"] as! String
                // Update location image
                if location?["image"] != nil {
                    let imageFile = location?["image"] as! PFFileObject
                    let imageUrl = URL(string: imageFile.url!)!
                    cell.imageView.af_setImage(withURL: imageUrl)
                }
                
            } else {
                print("error loading location: \(error?.localizedDescription)")
                }
        }
        
        return cell
    }
    
    
    //
    // Controls the achievements for this user
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return achievements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementsCell") as! AchievementsCell
        
        cell.nameLabel.text = achievements[indexPath.row] as! String
        
        return cell
    }
    
    
    ///
    // allows user to chose new profile picture from imaagePicker
    ///
    @IBAction func updateProfilePicture(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
            
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        self.profileImage.image = scaledImage
        
        let user = PFUser.current()!
        let imageData = self.profileImage.image!.pngData()
        let file = PFFileObject(data: imageData!)
        
        user["profile_image"] = file  // set profile image element
        
        user.saveInBackground { (success, error) in
            if success {
                print("Image updated")
            } else {
                print("error saving: \(error?.localizedDescription)")
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func logout() {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController = main.instantiateViewController(identifier: "FeedNavigationController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
    }

    //
    // Prepare when a segue happens
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Prepares profile to location segue
        // Loads location then passes it to locationViewController
        if segue.identifier == "profileToLocation" {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)!
            
            // Pass the selected object to the new view controller.
            let locationViewController = segue.destination as! LocationViewController
            let location = createdLocations[indexPath.row].fetchIfNeededInBackground { (location, error) in
                if location != nil {
                    locationViewController.location = location
                } else {
                    print("Error: \(error?.localizedDescription) ")
                }
                
            }
        }
    }
    

}
