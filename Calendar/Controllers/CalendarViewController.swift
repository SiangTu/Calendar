//
//  CalenderViewController.swift
//  CollectionView
//
//  Created by 杜襄 on 2021/8/27.
//

import UIKit
import RealmSwift

class CalendarViewController: UIViewController{
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarScrollView: UIScrollView!
    @IBOutlet var collectionViews: [UICollectionView]!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var eventDisplayTable: UITableView!
    
    private var didScrollViewSet = false
    
    var calendarViewModel = CalendarViewModel()
    var selectedEvent: Int?
    var eventsOfCurrentDay: Results<Event>?
    
    //MARK: - Set ScrollView, CollectionView and DataBase
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpCollectionViews()
        
        calendarScrollView.delegate = self
        scrollViewHeight.constant = collectionViews[1].frame.height + 20

        eventDisplayTable.dataSource = self
        eventDisplayTable.delegate = self
    }
    
    deinit{
        print("bye")
    }
    func setUpCollectionViews(){
        
        collectionViews[0].tag = 0
        collectionViews[1].tag = 1
        collectionViews[2].tag = 2
        
        for view in collectionViews{
            
            let fullScreenSize =
                UIScreen.main.bounds.size
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = CGSize(
                width: (CGFloat(fullScreenSize.width - 10) / 7),
                height: CGFloat(fullScreenSize.width - 10) / 7)
            
            layout.headerReferenceSize = CGSize(width: 0, height: 20)
            view.collectionViewLayout = layout
            
            
            view.register(UINib(nibName: Constants.calenderReusableView, bundle: nil), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: Constants.calenderReusableView)
            view.register(
                UINib(nibName: Constants.calenderViewCell, bundle: nil),
                forCellWithReuseIdentifier: Constants.calenderViewCell)
            view.delegate = self
            view.dataSource = self
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        updateCollectionViews()
    }
    
    override func viewDidLayoutSubviews() {
        didScrollViewSet = true
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        
        let alertText = app.currentUser!.profile.email! + "確定要登出嗎"
        let alertController = UIAlertController(title: alertText, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "登出", style: .destructive) { action in
           
            app.currentUser?.logOut(completion: { error in
                if let error = error{
                    print(error)
                }
            })
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let rootVC = storyboard.instantiateViewController(identifier: "BeforeLoginViewController")
                let rootNC = UINavigationController(rootViewController: rootVC)

                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = rootNC
            }
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    //MARK: - updateUI Method
    
    func updateCollectionViews(){
        
        monthLabel.text = calendarViewModel.getYearAndMonthStr()
        
        collectionViews[1].reloadData()
        calendarScrollView.contentOffset.x = collectionViews[1].frame.width
        collectionViews[0].reloadData()
        collectionViews[2].reloadData()
        
        calendarViewModel.currentDay = calendarViewModel.getDefaultSelectedDay(viewTag: 1)
        eventsOfCurrentDay = calendarViewModel.getEventsOfCurrentDay()
        eventDisplayTable.reloadData()
        
    }
    
}

//MARK: - CollectionViewDataSource Methods

extension CalendarViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let numOfCell = calendarViewModel.getNumOfCell(viewTag: collectionView.tag)
        
        return numOfCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.calenderViewCell, for: indexPath)
            as! CalenderViewCell
        let dayStr = calendarViewModel.getDate(viewTag: collectionView.tag, cellIndex: indexPath)
        cell.textLabel.text = dayStr
        
        if cell.textLabel.text  == ""{
            cell.isHidden = true
        }else{
            cell.isHidden = false
        }
        var selectedDay = calendarViewModel.getDefaultSelectedDay(viewTag: collectionView.tag)
        // currentDay will change when cell selected
        if collectionView.tag == 1{
            selectedDay = calendarViewModel.currentDay
        }
        
        if Int(dayStr) == selectedDay{
            cell.textLabel.backgroundColor = UIColor(named: "cellSelected")
            cell.textLabel.textColor = UIColor.systemBackground
        }else{
            cell.textLabel.backgroundColor = UIColor.systemBackground
            cell.textLabel.textColor = UIColor(named: "cellSelected")
        }
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: Constants.calenderReusableView, for: indexPath)
        return view
    }
    
}

//MARK: - CollectionView Delegate Method

extension CalendarViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalenderViewCell
        cell.textLabel.backgroundColor = UIColor(named: "cellSelected")
        cell.textLabel.textColor = UIColor.systemBackground
        
        calendarViewModel.currentDay = Int(cell.textLabel.text!)!
        collectionViews[1].reloadData()
        eventsOfCurrentDay = calendarViewModel.getEventsOfCurrentDay()
        eventDisplayTable.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalenderViewCell
        cell.textLabel.backgroundColor = UIColor.systemBackground
        cell.textLabel.textColor = UIColor(named: "cellSelected")
    }
    
}

//MARK: - ScrollView Delegate Method

extension CalendarViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == calendarScrollView{
            
            let scrollViewWidth = collectionViews[0].frame.width
            
            if scrollView.contentOffset.x == scrollViewWidth * 0, didScrollViewSet{
                calendarViewModel.backToLastMonth()
                calendarViewModel.updateMonthsData()
                updateCollectionViews()
            }
            if scrollView.contentOffset.x == scrollViewWidth * 2 {
                calendarViewModel.comeToNextMonth()
                calendarViewModel.updateMonthsData()
                updateCollectionViews()
            }
            
        }
        
    }
}

