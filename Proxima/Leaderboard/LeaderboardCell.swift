//
//  LeaderboardCell.swift
//  Proxima
//

import UIKit

/// Cell for Leaderboard table view
class LeaderboardCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Set profile image to circle
        profileImage.layer.cornerRadius = (profileImage.frame.width / 2)
        profileImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
