//
//  LeaderboardCell.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/22/20.
//

import UIKit

class LeaderboardCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
