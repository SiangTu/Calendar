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
    @IBOutlet weak var calendarScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var eventDisplayTable: UITableView!
    
    private var didScrollViewSet = false
    
    var calendarViewModel = CalendarViewModel()
    var selectedEvent: Int?
    var eventsOfCurrentDay: Results<Event>?
    
    //MARK: - Set ScrollView, CollectionView and DataBase
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setLayout()
        setRelationship()
    }
    
    func setLayout(){
        
        calendarScrollViewHeight.constant = collectionViews[1].frame.height + 20
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
        }
    }
    
    func setRelationship(){
        
        calendarScrollView.delegate = self

        eventDisplayTable.dataSource = self
        eventDisplayTable.delegate = self
        
        collectionViews[0].tag = 0
        collectionViews[1].tag = 1
        collectionViews[2].tag = 2
        
        for view in collectionViews{
            
            view.register(UINib(nibName: Constants.calenderReusableView, bundle: nil), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: Constants.calenderReusableView)
            view.register(
                UINib(nibName: Constants.calenderViewCell, bundle: nil),
                forCellWithReuseIdentifier: Constants.calenderViewCell)
            view.delegate = self
            view.dataSource = self
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        didScrollViewSet = true
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        
        let alertText = app.currentUser!.profile.email! + "確定要登出嗎"
        let alertController = UIAlertController(title: alertText, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "登出", style: .destructive) { action in
           
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
        
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - updateUI Method
    
    func updateUI(){
        
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
        
        cell.isHidden = dayStr == ""

        let selectedDay = calendarViewModel.getDefaultSelectedDay(viewTag: collectionView.tag)
        cell.isSelected = (Int(dayStr) == selectedDay)
        
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

        calendarViewModel.currentDay = Int(cell.textLabel.text!)!
        eventsOfCurrentDay = calendarViewModel.getEventsOfCurrentDay()
        eventDisplayTable.reloadData()
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
                updateUI()
            }
            if scrollView.contentOffset.x == scrollViewWidth * 2 {
                calendarViewModel.comeToNextMonth()
                calendarViewModel.updateMonthsData()
                updateUI()
            }
            
        }
        
    }
}

