//
//  ProfileViewController.swift
//  Proxima
//

import UIKit
import Parse
import SkeletonView

/// View controller for Profile
class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SkeletonCollectionViewDataSource  {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var achievementTableView: UITableView!
    @IBOutlet weak var addedLocationsCollectionView: UICollectionView!
    @IBOutlet weak var visitedLocationsCollectionView: UICollectionView!
    
    var currentUser: PFUser!
    var createdLocations: [PFObject] = []
    var visitedLocations: [PFObject] = []
    var achievements: [String] = []


    /**
     Called when view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        view.showSkeleton()
        view.startSkeletonAnimation()
        
        self.addedLocationsCollectionView.isSkeletonable = true
        self.addedLocationsCollectionView.showAnimatedSkeleton()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ProfileViewController.handleModalDismissed),
                                               name: NSNotification.Name(rawValue: "modalDismissed"),
                                               object: nil)
        
        //achievementTableView.delegate = self
        //achievementTableView.dataSource = self
        
        addedLocationsCollectionView.delegate = self
        addedLocationsCollectionView.dataSource = self
        
        visitedLocationsCollectionView.delegate = self
        visitedLocationsCollectionView.dataSource = self

        // Configure collection view layout
        let layout = addedLocationsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        // Space between rows
        layout.minimumLineSpacing = 20

    }
    
    /**
     Called when view appears
     */
    override func viewDidAppear(_ animated: Bool) {

        if(currentUser == nil && PFUser.current() == nil) {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            return
        }
        
        super.viewDidAppear(animated)
        
        // If user logged in, show logout button (only on Profile tab, not leaderboard)
        if(PFUser.current() != nil && currentUser == nil){
            let backButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: Selector("logout"))
            navigationItem.rightBarButtonItem = backButton
        }
        
        // If passing in from leaderboard
        if(self.currentUser != nil) {
            populate(limit: 10, skip: 0)
        }
        // Not passing from leaderboard, use current logged in user
        else {
            self.currentUser = PFUser.current()!
            populate(limit: 10, skip: 0)
        }
        
        self.createdLocations = (currentUser["created_locations"] as? [PFObject]) ?? []

        
        self.visitedLocations = (currentUser["visited_locations"] as? [PFObject]) ?? []
        
        // Check that all locations still exist, if not remove from db and local array
        for location in visitedLocations {
            
            location.fetchInBackground { (loc, error) in
                if loc == nil {
                    self.visitedLocations.remove(at: self.visitedLocations.firstIndex(of: location)!)
                    
                    PFUser.current()?.remove(location, forKey: "visited_locations")
                }
                self.visitedLocationsCollectionView.reloadData()
                PFUser.current()?.saveInBackground()
            }
            
        }
        
        view.hideSkeleton()
        addedLocationsCollectionView.reloadData()
        visitedLocationsCollectionView.reloadData()
        //achievementTableView.reloadData()
    }
    
    @objc func handleModalDismissed() {
      // Do something
        print("GOOD")
        createdLocations.removeAll()
        visitedLocations.removeAll()
        addedLocationsCollectionView.reloadData()
        visitedLocationsCollectionView.reloadData()
        populate(limit: 10, skip: 0)
    }
    
    /**
     Loads user info
     */
    func populate(limit: Int, skip: Int){
        
        // User name
        self.nameLabel.text = currentUser["username"] as? String

        // User score
        let score = currentUser["score"] as? Int ?? 0
        self.starsLabel.text = "⭐️ " + String(score)

        // User profile image
        if currentUser["profile_image"] != nil {
            let imageFile = currentUser["profile_image"] as! PFFileObject
            let imageUrl = URL(string: imageFile.url!)!
            self.profileImage.af.setImage(withURL: imageUrl)
        }
    }

    
    /**
     Tell SkeletonView reusable cell identifier
     */
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "LocationHorizontalCell"
    }
    
    /**
     Returns number of created locations to load from user
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == addedLocationsCollectionView {
            return createdLocations.count
        }
        else {
            return visitedLocations.count
        }
    }
    
    /**
     Logic for creating Shared Location cells
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        if collectionView == addedLocationsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationHorizontalCell", for: indexPath) as! LocationHorizontalCell
            
            let location = self.createdLocations[indexPath.row] as! PFObject
            
            // Loads each location associated with this user
            location.fetchIfNeededInBackground { (location, error) in
                if location != nil {
                    cell.nameLabel.text = location!["name"] as! String
                    // Set image
                    let imageFile = location?["image"] as? PFFileObject ?? nil
                    
                    if(imageFile != nil) {
                        let imageUrl = URL(string: (imageFile?.url!)!)
                        cell.imageView?.af.setImage(withURL: imageUrl!)
                        
                    } else {
                        cell.imageView.image = nil
                    }

                    
                } else {
                    print("error loading location: \(error?.localizedDescription)")
                    }
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationHorizontalCell", for: indexPath) as! LocationHorizontalCell
            
            let location = self.visitedLocations[indexPath.row] as! PFObject
            
            // Loads each location associated with this user
            location.fetchIfNeededInBackground { (location, error) in
                if location != nil {
                    
                    cell.nameLabel.text = location!["name"] as! String
                    // Set image
                    let imageFile = location?["image"] as? PFFileObject ?? nil
                    
                    if(imageFile != nil) {
                        let imageUrl = URL(string: (imageFile?.url!)!)
                        cell.imageView?.af.setImage(withURL: imageUrl!)
                        
                    } else {
                        cell.imageView.image = nil
                    }
                    
                } else {
                    print("error loading location: \(error?.localizedDescription)")
                    }
            }
            
            return cell
        }
    }
    
    /**
     Returns number of rows in section, one per achievement
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return achievements.count
    }
    
    /**
     Called when user image tapped, allows user to change their image
     */
    @IBAction func updateProfilePicture(_ sender: Any) {
        
        // Check that logged in user matches profile being viewed
        if(PFUser.current() == currentUser) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                picker.sourceType = .photoLibrary
                
            }
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    /**
     Processes and uploads user profile image
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        self.profileImage.image = scaledImage
        
        let user = PFUser.current()!
        let imageData = self.profileImage.image!.jpegData(compressionQuality: 0.5)
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
    
    /**
     Log out from current account
     */
    @objc func logout() {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let map = main.instantiateViewController(identifier: "FeedNavigationController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = map
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Prepares profile to location segue
        // Loads location then passes it to locationViewController
        if segue.identifier == "profileToSharedLocation" {
            let cell = sender as! UICollectionViewCell
            let indexPath = addedLocationsCollectionView.indexPath(for: cell)!
            
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
        
        if segue.identifier == "profileToVisitedLocation" {
            let cell = sender as! UICollectionViewCell
            let indexPath = visitedLocationsCollectionView.indexPath(for: cell)!
            
            // Pass the selected object to the new view controller.
            let locationViewController = segue.destination as! LocationViewController
            let location = visitedLocations[indexPath.row].fetchIfNeededInBackground { (location, error) in
                if location != nil {
                    locationViewController.location = location
                } else {
                    print("Error: \(error?.localizedDescription) ")
                }
                
            }
        }
    }
    

}
