//
//  CalendarView+ExtensionTableView.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/10/15.
//

import UIKit

//MARK: - UITableViewDataSource Methods

extension CalendarViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return eventsOfCurrentDay?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let events = eventsOfCurrentDay else {
            fatalError()
        }
        
        if events[indexPath.row].isAllDay{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.fullDayEventTableViewCell, for: indexPath) as! fullDayEventTableViewCell
            
            cell.titleLabel.text = events[indexPath.row].title
            
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.eventTableViewCell, for: indexPath) as! eventTableViewCell
            
            cell.titleLabel.text = events[indexPath.row].title
            
            let formatter = DateFormatter()
            formatter.dateFormat = "a h:mm"
            formatter.locale = Locale(identifier: "zh")
            cell.startDateLabel.text = formatter.string(from: events[indexPath.row].beginDate)
            cell.endDateLabel.text = formatter.string(from: events[indexPath.row].endDate)
            
            return cell
        }
       
    }
}

//MARK: - UITableViewDelegate Delegate Methods

extension CalendarViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedEvent = indexPath.row
        performSegue(withIdentifier: Constants.presentDetailSegue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.presentDetailSegue{
            let destination = segue.destination as! EventDetailViewController
            destination.event = eventsOfCurrentDay![selectedEvent!]
            destination.delegate = self
        }else{
            let destination = segue.destination as! EventAddingViewController
            let date = DateComponents(calendar: Calendar.current,
                                      year: calendarViewModel.currentYear,
                                      month: calendarViewModel.currentMonth,
                                      day: calendarViewModel.currentDay,
                                      hour: Calendar.current.component(.hour, from: Date()
                                            )
            ).date
            destination.selectedDate = date
            destination.delegate = self
        }
    }

}

//MARK: - UpperVCDelegate Method

extension CalendarViewController: UpperVCDelegate{
    func upperVCWillDismiss() {
        eventDisplayTable.reloadData()
    }
}
