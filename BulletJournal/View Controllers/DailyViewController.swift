//
//  DailyViewController.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/9/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DailyViewController:  UIViewController {
    // MARK: - Outlets and Properties
    @IBOutlet weak var tableView: UITableView!
    
    //    //MARK: Database properties
    //    var databaseReference: DatabaseReference!
    //    var userID: String!
    //    var entryKey: String?
    var entryManager: EntryManager!

    //    //MARK: Date-related properties
    //    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    //    var dateArray = [Date]()
    //    var today: Date!
    //    var thisYear: Int!
    //    var createEntryView: EntryCreationView!
    //    var startDate: Date!
    //    var indexPathDirectory = [Int : Date]()
    //    var daysDict = [Date : [Entry]]()
    //    var entries = [Entry]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Journal"
        entryManager = EntryManager(view: self.view, tableView: self.tableView)
        
        //        databaseReference = Database.database().reference()
        //        userID = Auth.auth().currentUser?.uid
        
        //        setupCalendarProperties()
        setupUIElements()
        //        setUpYearView()
        //        loadDataFromFirebase(true)
    }
    
    // MARK: - Functions and Methods
    func setupUIElements() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 32
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(zoomToToday))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(setupAndShowEntryCreationPopup))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func zoomToToday() {
        entryManager.zoomToDate(entryManager.startDate, to: entryManager.today)
    }

    @objc func setupAndShowEntryCreationPopup() {
        entryManager.setUpEntryPopup()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension DailyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return entryManager.dateArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dateAtSection = entryManager.indexPathDirectory[section], let tempDateArray = entryManager.daysDict[dateAtSection] {
            return tempDateArray.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateForSection = entryManager.dateArray[section]
        dateFormatter.dateFormat = "MMM d E"
        let dateString = dateFormatter.string(from: dateForSection)
        return dateString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyCell", for: indexPath) as! DailyViewTableViewCell
        
        cell.entryLabel.text = nil
        cell.entryLabel.attributedText = nil
        cell.starLabel.text = nil
        cell.typeLabel.text = nil
        
        var cellString = String()
        
        if let dateAtCell = entryManager.indexPathDirectory[indexPath.section], let tempDateArray = entryManager.daysDict[dateAtCell] {
            if indexPath.row < tempDateArray.count {
                let entry = tempDateArray[indexPath.row]
                
                if entry.starred {
                    cell.starLabel.text = "★"
                } else {
                    cell.starLabel.text = " "
                }
                
                switch entry.type {
                case .task:
                    switch entry.state {
                    case .active, .crossed:
                        cell.typeLabel.text = "•"
                    case .done:
                        cell.typeLabel.text = "✕"
                    }
                case .event:
                    cell.typeLabel.text = "◦"
                case .note:
                    cell.typeLabel.text = "-"
                }
                
                cellString += "\(tempDateArray[indexPath.row].comment)"
                
                if entry.state == .crossed {
                    let attributeString = NSMutableAttributedString(string: cellString)
                    attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    cell.entryLabel.attributedText = attributeString
                    
                    return cell
                }
            }
        }
        
        if cellString == "" && entryManager.indexPathDirectory[indexPath.section] == entryManager.today {
            let defaultString = "- Tap to add an entry -"
            let attributeString = NSMutableAttributedString(string: defaultString)
            
            attributeString.addAttributes([NSAttributedStringKey.font : UIFont.italicSystemFont(ofSize: 10), NSAttributedStringKey.foregroundColor : UIColor.lightGray], range: NSMakeRange(0, attributeString.length))
            
            cell.entryLabel.attributedText = attributeString
        } else {
            cell.entryLabel.text = cellString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let dateAtCell = entryManager.indexPathDirectory[indexPath.section] {
            if let tempDateArray = entryManager.daysDict[dateAtCell] {
                guard indexPath.row < tempDateArray.count else {
                    entryManager.setUpEntryPopup(withDate: dateAtCell)
                    return
                }
                
                let entry = tempDateArray[indexPath.row]
                entryManager.setUpEntryPopup(editEntry: entry)
            } else {
                entryManager.setUpEntryPopup(withDate: dateAtCell)
            }
        }
    }
}
