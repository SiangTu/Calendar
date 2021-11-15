//
//  AddScheduleViewController.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/9/14.
//

import UIKit

class EventAddingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: UpperVCDelegate?
    private var eventAddingViewModel = EventAddingViewModel()
    
//    var selectedDay: Int!
    var selectedDate: Date!
    var existEvent: Event?
    private var newEvent: Event!
    private var settingItemList = [[SettingItem.title],
    [.allDays, .starts, .ends],
    [.notes]
    ]
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.upperVCWillDismiss()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        if existEvent != nil{
            eventAddingViewModel.event = Event(title: existEvent!.title, beginDate: existEvent!.beginDate, endDate: existEvent!.endDate, isAllDay: existEvent!.isAllDay, notes: existEvent!.notes)
            titleLabel.text = "編輯行程"
            addButton.setTitle("完成", for: .normal)
        }else{
            eventAddingViewModel.event = Event(selectedDate: selectedDate)
        }
        
        newEvent = eventAddingViewModel.event
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.timePickerTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.timePickerTableViewCell)
        
        addButton.isEnabled = false
        addKeyboardNotification()
    }
    
    @IBAction func addEvent(_ sender: UIButton) {
        
        textFieldEndEditing()
        if existEvent != nil{
            try! realm.write({
                existEvent?.title = newEvent.title
                existEvent?.isAllDay = newEvent.isAllDay
                existEvent?.beginDate = newEvent.beginDate
                existEvent?.endDate = newEvent.endDate
                existEvent?.notes = newEvent.notes
            })
        }else{
            try! realm.write{
                realm.add(newEvent)
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDataSource Methods

extension EventAddingViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return settingItemList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingItemList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let settingItem = settingItemList[indexPath.section][indexPath.row]
        
        if [.title, .notes].contains(settingItem) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.textFieldTableViewCell, for: indexPath) as! TextFieldTableViewCell
            
            cell.settingItem = settingItem
            cell.delegate = self
            
            cell.textField.placeholder = settingItem.rawValue
            switch settingItem {
            case .title :
                cell.textField.text = newEvent.title
            default:
                cell.textField.text = newEvent.notes
            }

            return cell
        }
        else if settingItem == .allDays{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.switchTableViewCell, for: indexPath) as! SwitchTableViewCell

            cell.settingItem = settingItem
            cell.delegate = self
            
            cell.titleLabel.text = settingItem.rawValue
            cell.switch.isOn = newEvent.isAllDay
            
            return cell
        }
        else if [.timeStart, .timeEnd].contains(settingItem){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.timePickerTableViewCell, for: indexPath) as! TimePickerTableViewCell
            
            cell.settingItem = settingItem
            cell.delegate = self
           
            if indexPath.row == 2{
                cell.timePicker.date = newEvent.beginDate
                cell.datePicker.date = newEvent.beginDate
            }else{
                cell.timePicker.date = newEvent.endDate
                cell.datePicker.date = newEvent.endDate
            }
            cell.timePicker.locale = .current
            //delete picker's padding
            cell.timePicker.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            cell.datePicker.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            //when isAllDay true, hidden timePicker and adjust position of datePicker
            cell.TimePickerStackView.isHidden = newEvent.isAllDay
            cell.datePickerTopConstraint.constant = newEvent.isAllDay ? -35 : 0
            
            return cell
        }
        else if settingItem == .starts{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.labelTableViewCell, for: indexPath) as! LabelTableViewCell
            
            cell.titleLabel.text = settingItem.rawValue
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: eventAddingViewModel.getBeginDateStr())
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
            cell.contentLabel.attributedText = attributeString
            
            return cell
        }
        else if settingItem == .ends{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.labelTableViewCell, for: indexPath) as! LabelTableViewCell
            
            cell.titleLabel.text = settingItem.rawValue
            
            if eventAddingViewModel.isDateRangeLegal{
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: eventAddingViewModel.getEndDateStr())
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
                cell.contentLabel.attributedText = attributeString
            }else{
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: eventAddingViewModel.getEndDateStr())
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.contentLabel.attributedText = attributeString
            }
            
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.labelTableViewCell, for: indexPath) as! LabelTableViewCell
            
            cell.titleLabel.text = settingItem.rawValue
            cell.contentLabel.text = ""
            
//            if let event = existEvent{
//                cell.contentLabel.text = existEvent.notes
//            }
            
            return cell
        }
    }
}

//MARK: - UITableViewDelegate Methods

extension EventAddingViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        
        if settingItemList[section][row] == .starts || settingItemList[section][row] == .ends{
            
            if settingItemList[section].count > row + 1,
               (settingItemList[section][row+1] == .timeStart || settingItemList[section][row+1] == .timeEnd){
                
                settingItemList[section].remove(at: row+1)
                let deleteIndex = IndexPath(row: row+1, section: section)
                tableView.deleteRows(at: [deleteIndex], with: .top)
                
            }else{
                
                if settingItemList[section][row] == .starts{
                    settingItemList[section].insert(.timeStart, at: row+1)
                }else{
                    settingItemList[section].insert(.timeEnd, at: row+1)
                }
                let insertIndex = IndexPath(row: row+1, section: section)
                tableView.insertRows(at: [insertIndex], with: .top)

            }
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Identify if user actually scroll the view
        if tableView.isDragging || tableView.isDecelerating{
            textFieldEndEditing()
        }
    }
    
    private func textFieldEndEditing(){
        
        var cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell
        cell?.textField.endEditing(true)
        
        cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? TextFieldTableViewCell
        cell?.textField.endEditing(true)
    }
}

//MARK: - Store Data(TableViewCellDelegate Methods)

extension EventAddingViewController: TableViewCellDelegate{
    func storeData(data: Any, property: SettingItem) {
        
        eventAddingViewModel.storeData(data: data, property: property)
        
        if property == .title || property == .notes{
            
        }else{
            tableView.reloadData()
        }
        
        addButton.isEnabled = eventAddingViewModel.canAddEvent
    }
    
}

//MARK: - KeyboardNotification (Making input fields will never covered by keyboard)

extension EventAddingViewController {
    
    func addKeyboardNotification(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillbeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
    }
    
    @objc func keyboardWillbeHidden(){
        
        let contentInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
    }
}

