//
//  CalenderCalculator.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/9/1.
//

import Foundation

struct MonthData {
    
    var year: Int?
    var month: Int?
    
    var numOfDaysInThisMonth: Int{
        let dateComponent = DateComponents(year: year!, month: month!)
        let date = Calendar.current.date(from: dateComponent)
        let range = Calendar.current.range(of: .day, in: .month, for: date!)
        let num = range!.count
        
        return num
    }

    var additionDay: Int{
        let dateComponent = DateComponents(year: year!, month: month!)
        let date = Calendar.current.date(from: dateComponent)
        
        return Calendar.current.component(.weekday, from: date!) - 1
    }
}
