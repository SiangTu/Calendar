//
//  SwitchTableViewCell.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/10/2.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    var settingItem: SettingItem!
    weak var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.storeData(data: sender.isOn, property: settingItem)
    }
    
}
