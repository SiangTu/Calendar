//
//  EventAddingViewModel.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/10/14.
//

import Foundation

//MARK: - Logic of store temp data

class EventAddingViewModel {
    
    var event = Event()
    
    func storeData(data: Any, property: SettingItem) {
        
        switch property {
        
        case .title:
            
            event.title = data as! String
        case .allDays:
            
            event.isAllDay = data as! Bool
        case .timeStart, .timeEnd:
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyyMMddHHmm"

            let dataString = data as! String
           
            let newDateString = self.getNewDateString(dataString: dataString, property: property)
            
            if property == .timeStart{
                event.beginDate = formatter.date(from: newDateString)!
            }else{
                event.endDate = formatter.date(from: newDateString)!
            }
        default:
            
            event.notes = data as! String
        }
    }
    
    private func getNewDateString(dataString: String, property: SettingItem) -> String{
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        var newDateString = ""
        
        if dataString.count == 8{
    
            formatter.dateFormat = "HHmm"
            if property == .timeStart{
                newDateString = dataString +  formatter.string(from: event.beginDate)
            }else{
                newDateString = dataString + formatter.string(from: event.endDate)
            }
        }else{
            
            formatter.dateFormat = "yyyyMMdd"
            if property == .timeEnd{
                newDateString = formatter.string(from: event.beginDate) + dataString
            }else{
                newDateString = formatter.string(from: event.endDate) + dataString
            }
        }

        return newDateString
    }
}

//MARK: - Give information which view needed

extension EventAddingViewModel{
    
    var canAddEvent: Bool{
        return event.title != "" && isDateRangeLegal
    }
    
    var isDateRangeLegal: Bool{
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        if event.isAllDay{
            formatter.dateFormat = "yyyy-MM-dd"
            let beginDateString = formatter.string(from: event.beginDate)
            let endDateString = formatter.string(from: event.endDate)
            let beginDate = formatter.date(from: beginDateString)!
            let endDate = formatter.date(from: endDateString)!
            
            return endDate >= beginDate
        }else{
            return event.endDate >= event.beginDate
        }
    }
    
    func getBeginDateStr() -> String{
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        if event.isAllDay{
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: event.beginDate)
        }else{
            formatter.dateFormat = "yyyy-MM-dd  HH:mm"
            return formatter.string(from: event.beginDate)
        }
    }
    
    func getEndDateStr() -> String{
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        if event.isAllDay{
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: event.endDate)
        }else{
            formatter.dateFormat = "yyyy-MM-dd  HH:mm"
            return formatter.string(from: event.endDate)
        }
    }

}
