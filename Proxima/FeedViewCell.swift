//
//  FeedViewCell.swift
//  Proxima
//
//  Created by Avni Avdulla on 11/22/20.
//

import UIKit

class FeedViewCell: UITableViewCell {

    
    @IBOutlet weak var locationImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
