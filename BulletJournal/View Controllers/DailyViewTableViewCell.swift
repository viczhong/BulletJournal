//
//  DailyViewTableViewCell.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/12/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit

class DailyViewTableViewCell: UITableViewCell {
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
