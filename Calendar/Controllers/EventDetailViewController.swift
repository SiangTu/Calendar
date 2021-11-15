//
//  EventDetailViewController.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/10/18.
//

import UIKit

class EventDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    var event: Event!
    weak var delegate: UpperVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.upperVCWillDismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventAddingViewController
        destination.existEvent = event
        destination.delegate = self
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "確定要刪除此行程嗎", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "刪除行程", style: .destructive) { action in
            try! realm.write({
                realm.delete(self.event)
            })
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
}

//MARK: - UITableViewDataSource Methods

extension EventDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if event.notes.isEmpty{
            return 1
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
           let cell = tableView.dequeueReusableCell(withIdentifier: Constants.mainDetailTableViewCell, for: indexPath) as! mainDetailTableViewCell
            
            cell.titleLabel.text = event.title
            let formatter = DateFormatter()
            if event.isAllDay{
                formatter.dateFormat = "yyyy年MM月d日 EEEE"
            }else{
                formatter.dateFormat = "yyyy年MM月d日 EEEE a h:mm"
            }
            
            formatter.locale = Locale(identifier: "zh")
            cell.timeLabel.text = "開始： \(formatter.string(from: event.beginDate))\n結束： \(formatter.string(from: event.endDate))"
            
             return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.optionDetailTableViewCell, for: indexPath) as! notesDetailTableViewCell
            cell.notesLabel.text = event.notes
            
            return cell
        }
    }
    
    
}

//MARK: - UITableViewDelegate Methods

extension EventDetailViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UpperVCDelegate Method

extension EventDetailViewController: UpperVCDelegate{
    
    func upperVCWillDismiss() {
        tableView.reloadData()
    }
}
