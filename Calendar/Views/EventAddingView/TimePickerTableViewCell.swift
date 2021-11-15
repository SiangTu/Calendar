//
//  TimePickerTableViewCell.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/10/5.
//

import UIKit

class TimePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var TimePickerStackView: UIStackView!
    @IBOutlet weak var datePickerTopConstraint: NSLayoutConstraint!
    
    var settingItem: SettingItem!
    weak var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func datePickerChanged(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let data = formatter.string(from: datePicker.date)
        delegate?.storeData(data: data, property: settingItem)
    }
    @IBAction func timePickerChanged(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        let data = formatter.string(from: timePicker.date)
        delegate?.storeData(data: data, property: settingItem)
    }
    
}
