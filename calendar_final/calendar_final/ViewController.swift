//
//  ViewController.swift
//  calendar_final
//
//  Created by vincent on 2020/12/27.
//

import UIKit
import Foundation
import FSCalendar
import RealmSwift

class EventModel: Object {
    //@objc dynamic var title = ""
    @objc dynamic var memo = ""
    @objc dynamic var date = "" //yyyy.MM.dd
}

//MARK:- Main
class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource,  UITableViewDelegate, UITableViewDataSource {
    var dataTables:[String]! = ["待辦的事情會顯示在這裡"]
    @IBOutlet var calendar: FSCalendar!
    //@IBOutlet weak var TODOUIVIEW: UIView!
    @IBOutlet var todobtn: UIButton!
    @IBOutlet var tableView:UITableView!
    //private var gradient: CAGradientLayer!
    var formatter = DateFormatter()
    var text:String = ""
    //let ducumentPath = NSHomeDirectory() + "/Documents/data.json"
    //let fileManager = FileManager.default
    let realm = try! Realm()
    let Event = List<EventModel>()
    var DatedidSelect:[String]!=[]
    var textshow = ""
    var textshowtosave = ""
    var nowSelectedDate = ""
    var filterdModels:[[String:String]] = []
    
    //MARK:- Tableview Row Seclect
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTables.count
    }
    
    //MARK:- Tableview Insert
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = dataTables[indexPath.row]
        return cell
    }
    //MARK:- Tableview Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if dataTables[indexPath.row] == "今日無待辦的事情" || dataTables[indexPath.row] == "待辦的事情會顯示在這裡"{
                return
            }
            dataTables.remove(at: indexPath.row)
            let results = realm.objects(EventModel.self).filter("date == '\(nowSelectedDate)'")
            do {
                try realm.write {
                    realm.delete(results[indexPath.row])
                    getModel()
                    filterModel()
                    updateTableDatas()
                }
            } catch {
                print("delete data error.")
            }
            //tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //MARK:- View Misc
        //view.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.7450980392, blue: 0.8274509804, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red:62.0/255.0, green: 190.0/255.0, blue: 211.0/255.0, alpha: 1.0).cgColor,UIColor(red:120.0/255.0, green: 190.0/255.0, blue: 211.0/255.0, alpha: 1.0).cgColor]
        gradient.frame = todobtn.bounds
        todobtn.layer.insertSublayer(gradient, at: 0)
        todobtn.clipsToBounds = true
        todobtn.layer.cornerRadius = 21
        //MARK:- Calendar Setting
        //calendar.scrollDirection = .vertical
        view.addSubview(calendar)
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.locale = Locale(identifier: "zh_TW")
        calendar.appearance.headerDateFormat = "yyyy 年 MM 月"
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 17.0)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18.0)
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 16.0)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        //calendar.calendarHeaderView.backgroundColor = .systemBlue
        calendar.appearance.todayColor = .systemGreen
        calendar.appearance.titleTodayColor = .white
        calendar.appearance.titleDefaultColor = .systemBlue
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.titleWeekendColor = .systemRed
        calendar.appearance.eventDefaultColor = .systemPink
        calendar.dataSource = self
        calendar.delegate = self
        // muti select
        calendar.allowsMultipleSelection = true
        print("viewdidload")
    }
    
    //MARK:- FSCalendar Select Date
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        formatter.dateFormat = "yyyy-MM-dd"
        nowSelectedDate = formatter.string(from: date)
        DatedidSelect.append(String(formatter.string(from: date)))
        getModel()
        print("Date selected == \(formatter.string(from: date))")
        filterModel()
        updateTableDatas()
        //allDateWithEvents()
    }
    
    //MARK:- FSCalendar EventDate
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        print(dateString)
        //print(allDateWithEvents())
        if self.allDateWithEvents().contains(dateString) {
            return 1
        }
        return 0
    }
    
    //MARK:-
    func allDateWithEvents() -> [String]{
        var allDates:[String]!=[]
        let results = realm.objects(EventModel.self)
        for result in results {
            allDates.append(result.date)
        }
        return allDates
    }
    
    //MARK:- FSCalendar Deselect Date
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        formatter.dateFormat = "yyyy-MM-dd"
        DatedidSelect.removeAll { value in
            return value == formatter.string(from: date)
        }
        if DatedidSelect.count == 0{
            dataTables.removeAll()
            dataTables.append("待辦的事情會顯示在這裡")
            self.tableView.reloadData()
        }else{
            nowSelectedDate = DatedidSelect[DatedidSelect.count-1]
            getModel()
            filterModel()
            updateTableDatas()
        }
        print("Date De-selected == \(formatter.string(from: date))")
    }
    
    //MARK:- Update Table Memo
    func updateTableDatas(){
        dataTables.removeAll()
        if filterdModels.count != 0
        {
            for split in filterdModels{
                dataTables.append(String(split["memo"]!))
            }
        }else{
            dataTables.append("今日無待辦的事情")
        }
        tableView.reloadData()
        self.calendar.reloadData()
    }
    
    var eventModels: [[String:String]] = []
    //MARK:- Date and Memo Get
    func getModel() {
        eventModels.removeAll()
        let results = realm.objects(EventModel.self)
        for result in results {
            eventModels.append(["memo": result.memo,"date": result.date])
        }
    }
    
    //MARK:- Date and Memo Filter
    func filterModel() {
        var filterdEvents: [[String:String]] = []
        for eventModel in eventModels {
            //if eventModel["date"] == stringFromDate(date: selectedDate as Date, format: "yyyy-MM-dd") {
            if eventModel["date"] == nowSelectedDate{
                filterdEvents.append(eventModel)
            }
            filterdModels = filterdEvents
        }
        //print(String(filterdModels[1]["memo"]!))
    }
    
    //MARK:- Non Segue Pass Date
    @IBAction func nonsegueCall(sender: Any){
        DatedidSelect.sort()
        textshow = DatedidSelect.joined(separator: "\t")
        textshowtosave = DatedidSelect.joined(separator: ",")
        let childViewController = storyboard?.instantiateViewController(identifier: "SecondViewController") as? SecondViewController
        childViewController?.showText = textshow
        childViewController?.showTexttoSave = textshowtosave
        print(textshowtosave)
        present(childViewController!, animated: true, completion: nil)
    }
    
}
