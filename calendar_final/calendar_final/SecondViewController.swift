//
//  SecondViewController.swift
//  calendar_final
//
//  Created by vincent on 2020/12/28.
//

import UIKit
//import SwiftyJSON
import RealmSwift
import Foundation
import UITextView_Placeholder

class SecondViewController: UIViewController {

    //@IBOutlet var OKbtn: UIButton!
    @IBOutlet var textviewinsert: UITextView!
    @IBOutlet weak var datelabel: UILabel!
    // OK Button
    @IBAction func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
       }
    // Back button
    @IBAction func backtoMain(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
       }
    
    
    var showText: String = ""
    var showTexttoSave: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- View Setting
        datelabel.textColor = .systemBlue
        datelabel.layer.borderColor = UIColor.lightGray.cgColor
        datelabel.layer.borderWidth = 1
        datelabel.layer.cornerRadius = 6
        datelabel.sizeToFit()
        datelabel.text = showText
        //MARK:- Textview setting
        textviewinsert.layer.borderColor = UIColor.lightGray.cgColor
        textviewinsert.layer.borderWidth = 1
        textviewinsert.layer.cornerRadius = 6
        textviewinsert.placeholder = "輸入待辦事項詳情"
        textviewinsert.placeholderColor = UIColor.lightGray// optional
    }
   
    //MARK:- Write Data & Print it
    @IBAction func createEvent(success: @escaping () -> Void) {
        //let textviewText = String(textviewinsert.text)
        let DateArr = String(showTexttoSave).components(separatedBy: ",")
        for DateItem in DateArr{
            do {
                //print(DateItem)
                //let dateformatter = DateFormatter()
                //dateformatter.dateFormat = "yyyy-MM-dd"
                let realm = try! Realm()
                let results = realm.objects(EventModel.self)
                let eventModel = EventModel()
                //let formatstring = dateformatter.date(from: showTexttoSave)!
                eventModel.memo = textviewinsert.text
                eventModel.date = DateItem
                //=-print(DateItem)
                //let Event = List<EventModel>()
                try! realm.write {realm.add(eventModel)}
                //Event.add(eventModel)
                print(results)
//              delete
//                try! realm.write {
//                   realm.deleteAll()
//                }
            } 
        }
        
    }
}
