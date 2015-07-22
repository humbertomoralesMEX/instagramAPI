//
//  TableViewCell.swift
//  
//
//  Created by Humberto Morales on 7/17/15.
//
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var imageLowRes: UIImageView!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelText.numberOfLines = 2
        self.labelText.adjustsFontSizeToFitWidth = true
        self.labelText.minimumScaleFactor = 0.8
    }

}
