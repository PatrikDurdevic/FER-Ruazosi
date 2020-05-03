//
//  LeaderboardTableViewCell.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 01/05/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForScore(score: Score) {
        playerNameLabel.text = score.username
        guard let score = Double(score.score) else {
            return
        }
        playerScoreLabel.text = String(Int(score))
    }

}
