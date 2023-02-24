//
//  TableViewCell.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/5/22.
//

import UIKit
import Cosmos
class ServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starView: CosmosView!
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
