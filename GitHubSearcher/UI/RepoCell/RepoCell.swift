//
//  RepoCell.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var repoNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
