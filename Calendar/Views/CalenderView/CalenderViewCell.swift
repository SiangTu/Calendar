//
//  CalenderViewCell.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/8/30.
//

import UIKit

class CalenderViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    override var isSelected: Bool{
        didSet{
            textLabel.textColor = isSelected ? .systemBackground : .label
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .label
        
    }

}
