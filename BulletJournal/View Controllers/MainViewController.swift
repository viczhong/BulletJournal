//
//  MainViewController.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/9/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit
import Firebase

class MainViewController:  UIViewController {
    // MARK: - Outlets and Properties
    @IBOutlet weak var tableView: UITableView!

    // Date-related properties
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    var dateArray = [Date]()
    let today = Date()
    var thisYear: Int!
    var createEntryView: EntryCreationView!
    var startDate: Date!
    var indexPathDirectory = [Int : Date]()
    var daysDict = [Date : [Entry]]() //TODO: Store IndexPaths in yearDict
    var entries = [Entry]()


    override func viewDidLoad() {
        super.viewDidLoad()

        tryExampleEntry()
        setupCalendarProperties()
        setupUIElements()
        setUpYearView()
    }

    // MARK: Functions and Methods
    func tryExampleEntry() {
//        if UserDefaults.standard.object(forKey: "Onboarding") == nil {
            let date = calendar.date(from: DateComponents(year: 2018, month: 2, day: 11, hour: 12))!
            let entry1 = Entry(id: "1111", date: date, type: .task, state: .active, comment: "Testing Task", starred: false)
            let entry2 = Entry(id: "1111", date: date, type: .event, state: .active, comment: "Testing Event", starred: true)
            let entry3 = Entry(id: "1111", date: date, type: .note, state: .active, comment: "Testing Note", starred: false)
            _ = [entry1, entry2, entry3].map { entries.append($0) }
//            UserDefaults.standard.set("True", forKey: "Onboarding")
//        }
    }

    func setupCalendarProperties() {
        dateFormatter.dateFormat = "YYYY"
        thisYear = Int(dateFormatter.string(from: today))!
        title = "\(thisYear!)"

        startDate = calendar.date(from: DateComponents(year: thisYear, month: 1, day: 1, hour: 12))!
        dateFormatter.dateFormat = "MMM d EEE"

        placeEntries()
    }

    func setupUIElements() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dateCell")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(zoomToToday))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(setupAndShowEntryCreationPop))

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func placeEntries() {
        // REF: daysDict = [Date : [Entry]]()
        for entry in entries {
            var tempEntryArray = [Entry]()

            if let existingArray = daysDict[entry.date] {
                tempEntryArray = existingArray
                tempEntryArray.append(entry)
                daysDict[entry.date] = tempEntryArray
            } else {
                daysDict[entry.date] = [entry]
            }
        }
    }

    func setUpYearView() {
        let startDateComponents = DateComponents(year: thisYear, month: 1, day: 1, hour: 12)
        let endDateComponents = DateComponents(year: thisYear, month: 12, day: 31, hour: 12)
        let offsetComponents = DateComponents(day: 1)

        let startDate = calendar.date(from: startDateComponents)!
        let endDate = calendar.date(from: endDateComponents)!

        var currentDate = startDate
        var sectionCounter = 0
        dateArray = [currentDate]
        indexPathDirectory[sectionCounter] = currentDate

        // Build a year's worth of Dates
        while currentDate.timeIntervalSince1970 < endDate.timeIntervalSince1970 {
            currentDate = calendar.date(byAdding: offsetComponents, to: currentDate)!
            dateArray.append(currentDate)
            sectionCounter += 1
            indexPathDirectory[sectionCounter] = currentDate
        }


        self.tableView.reloadData()
        zoomToToday()
    }

    @objc func zoomToToday() {
        zoomToDate(startDate, to: today)
    }

    func zoomToDate(_ startDate: Date, to targetDate: Date) {
        let components = self.calendar.dateComponents([.day], from: startDate, to: targetDate).day!
        let indexPath = IndexPath(row: 0, section: components)

        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    @objc func entryCancelPressed(_ sender:UIButton) {
        self.createEntryView.removeFromSuperview()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func setupAndShowEntryCreationPop() {
        if self.createEntryView != nil {
            self.createEntryView.removeFromSuperview()
        }

        self.createEntryView = EntryCreationView(frame: CGRect(x: ((self.view.frame.width - self.view.frame.width * 0.8) / 2), y: self.view.frame.height * 0.2, width: self.view.frame.width * 0.8, height: 340))
        self.view.addSubview(createEntryView)
        self.createEntryView.cancelButton.addTarget(self, action: #selector(entryCancelPressed(_:)), for: .touchUpInside)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dateAtSection = indexPathDirectory[section], let tempDateArray = daysDict[dateAtSection] {
            return tempDateArray.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateForSection = dateArray[section]
        let dateString = dateFormatter.string(from: dateForSection)
        return dateString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
        var cellString = String()

        if let dateAtCell = indexPathDirectory[indexPath.section], let tempDateArray = daysDict[dateAtCell] {
            let entry = tempDateArray[indexPath.row]

            if entry.starred {
                cellString = "★"
            } else {
                cellString = "   "
            }
            switch entry.type {
            case .task:
                cellString += "• "
            case .event:
                cellString += "◦ "
            case .note:
                cellString += "- "
            }

            cellString += "\(tempDateArray[indexPath.row].comment)"
        }

        cell.textLabel?.text = cellString
        // Save for later:
        //        let dateAtIndexPath = dateArray[indexPath.row]
        //        let dateString = dateFormatter.string(from: dateAtIndexPath)
        //
        //        cell.textLabel?.textColor = .black
        //        dateFormatter.dateFormat = "MMM d EEE"
        //
        //        if dateString == dateFormatter.string(from: today) {
        //            cell.textLabel?.textColor = .red
        //        }

        //        cell.textLabel?.text = dateString

        return cell
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let dateAtCell = indexPathDirectory[indexPath.section] {
           if let tempDateArray = daysDict[dateAtCell] {
                let entry = tempDateArray[indexPath.row]
                setupAndShowEntryCreationPop() // Modify to edit
            } else {
                setupAndShowEntryCreationPop() // Modify to create
            }

        }
    }
}
