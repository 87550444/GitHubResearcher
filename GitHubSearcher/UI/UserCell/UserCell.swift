//
//  UserCell.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repoNumberLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(with model: UserCellModel) {
        userNameLabel.text = model.userName
        
    }
}
