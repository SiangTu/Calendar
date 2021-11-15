//
//  TableViewCellDelegate.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/10/7.
//

import Foundation

protocol TableViewCellDelegate: AnyObject {
    func storeData(data: Any, property: SettingItem)
}
