//
//  ProfileViewController.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/29/20.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var createdLocations: [PFObject] = []
    var currentUser: PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        super.viewDidAppear(animated)
        
        if(currentUser != nil) {
            updateInfo(user: currentUser)
            self.createdLocations = (currentUser["created_locations"] as? [PFObject]) ?? []
        }else {
            currentUser = PFUser.current()
            updateInfo(user: currentUser)
            self.createdLocations = (currentUser["created_locations"] as? [PFObject]) ?? []

        }
        
        
    }
    

    // Updates the labels and images using User data
    func updateInfo(user: PFUser){
        
        // update name
        self.nameLabel.text = user["full_name"] as? String
        
        //update username
        self.usernameLabel.text = user["username"]! as? String
        
        // update score
        let score: Int = user["score"] as! Int
        self.starsLabel.text = String(score)
        
        // Update profile image
        let imageFile = user["profile_image"] as! PFFileObject
        let imageUrl = URL(string: imageFile.url!)!
        self.profileImage.af_setImage(withURL: imageUrl)
        
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
                // TO DO:
                // set picture for each cell
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementsCell") as! AchievementsCell
        
        cell.nameLabel.text = "Top Contributor"
        
        return cell
    }
    
    @IBAction func updateProfilePicture(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .photoLibrary
            
        } else {
            picker.sourceType = .camera
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
