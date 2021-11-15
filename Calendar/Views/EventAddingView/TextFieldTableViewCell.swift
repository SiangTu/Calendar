//
//  TextFieldTableViewCell.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/9/24.
//
import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    var settingItem: SettingItem!
    weak var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self

        // Initialization code
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(self.TextFieldDidChange), for: .editingChanged)
    }
    
    @objc func TextFieldDidChange() {
        delegate?.storeData(data: textField.text ?? "", property: settingItem)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.storeData(data: textField.text ?? "", property: settingItem)
    }
    
    

//    @IBAction func textFieldEndEditing(_ sender: Any) {
//        delegate?.storeData(data: textField.text ?? "", title: title)
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
