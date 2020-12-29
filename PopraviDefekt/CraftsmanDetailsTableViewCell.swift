//
//  CraftsmanDetailsTableViewCell.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/21/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit

class CraftsmanDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageI: UIImageView!
    @IBOutlet weak var dateFinished: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
