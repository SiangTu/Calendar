//
//  CalenderCalculator.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/9/6.
//

import Foundation
import RealmSwift

class CalendarViewModel {
    
    private var monthsData = [MonthData(), MonthData(), MonthData()]
    
    private let thisYear = Calendar.current.component(.year, from: Date())
    private let thisMonth = Calendar.current.component(.month, from: Date())
    private let today = Calendar.current.component(.day, from: Date())

    var currentYear: Int
    var currentMonth: Int
    var currentDay: Int
    
    init() {
        currentYear = thisYear
        currentMonth = thisMonth
        currentDay = today
        updateMonthsData()
    }
    
    //MARK: - getEventsOfCurrentDay
    
    func getEventsOfCurrentDay() -> Results<Event>{
        
        let startDateComponent = DateComponents(calendar: Calendar.current, year: currentYear, month: currentMonth, day: currentDay)
        let dayStart = startDateComponent.date!
        let dayEnd = dayStart.advanced(by: 86400)
//        let realm2 = try! Realm(configuration: app.currentUser!.configuration(partitionValue: "123"))
//        let a = Array(realm.objects(Event.self))
//        let b = Array(realm2.objects(Event.self))
//        var c = a + b
//        c.sort(by: { $0.beginDate > $1.beginDate })
//        c.sort(by: { $0.isAllDay && !$1.isAllDay })
//        realm2.objects(Event.self)
        
        return realm.objects(Event.self).filter("(endDate >= %@ AND beginDate < %@) || (endDate < %@ AND endDate >= %@)" , dayEnd, dayEnd, dayEnd, dayStart).sorted(byKeyPath: "beginDate", ascending: true).sorted(byKeyPath: "isAllDay", ascending: false)
        
    }
    
    //MARK: - Update MonthsData with currentYear and currentMonth
    
    func updateMonthsData(){
        monthsData[1].year = currentYear
        monthsData[1].month = currentMonth
        
        if currentMonth == 1{
            monthsData[0].year = currentYear - 1
            monthsData[0].month = 12
        }else{
            monthsData[0].year = currentYear
            monthsData[0].month = currentMonth - 1
        }
        
        if currentMonth == 12{
            monthsData[2].year = currentYear + 1
            monthsData[2].month = 1
        }else{
            monthsData[2].year = currentYear
            monthsData[2].month = currentMonth + 1
        }

    }
    
    //MARK: - update currentYear and currentMonth when user scroll the view
    
    func backToLastMonth() {
        if currentMonth == 1{
            currentYear -= 1
            currentMonth = 12
        }else{
            currentMonth -= 1
        }
    }
    
    func comeToNextMonth() {
        if currentMonth == 12{
            currentYear += 1
            currentMonth = 1
        }else{
            currentMonth += 1
        }
    }
    
    func getDefaultSelectedDay(viewTag: Int) -> Int{
        if monthsData[viewTag].year == thisYear, monthsData[viewTag].month == thisMonth{
            return today
        }else{
            return 1
        }
    }
    
    func getYearAndMonthStr() -> String{
        return String(currentYear) + "年" + String(currentMonth) + "月"
    }
    
    func getDate(viewTag: Int, cellIndex: IndexPath) -> String{
        var date = String(cellIndex.row + 1 - monthsData[viewTag].additionDay)
        if cellIndex.row + 1 - monthsData[viewTag].additionDay <= 0{
            date = ""
        }
        return date
    }
    
    func getNumOfCell(viewTag: Int) -> Int{
        return monthsData[viewTag].numOfDaysInThisMonth + monthsData[viewTag].additionDay
    }
    
}
