//
//  Event.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/10/14.
//

import Foundation
import RealmSwift

class Event: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title = ""
    @Persisted var beginDate: Date
    @Persisted var endDate: Date
    @Persisted var isAllDay = false
    @Persisted var notes = ""
//    @Persisted var teamID: UUID

    
    override init() {
        super.init()
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMddHH"
        
        let beginDateString = formatter.string(from: Date())
        beginDate = formatter.date(from: beginDateString)!
        
        let EndDateString = formatter.string(from: Date().advanced(by: 3600))
        endDate = formatter.date(from: EndDateString)!
    }
    
    init(title: String, beginDate: Date, endDate: Date, isAllDay: Bool, notes: String) {
        self.title = title
        self.beginDate = beginDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.notes = notes
    }
    
    init(selectedDate: Date){
        beginDate = selectedDate
        endDate = selectedDate.advanced(by: 3600)
    }
    
}
