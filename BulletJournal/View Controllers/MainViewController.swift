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
    var today: Date!
    var thisYear: Int!
    var createEntryView: EntryCreationView!
    var startDate: Date!
    var indexPathDirectory = [Int : Date]()
    var daysDict = [Date : [Entry]]()
    var entries = [Entry]()


    override func viewDidLoad() {
        super.viewDidLoad()

        setupCalendarProperties()
//        tryExampleEntry()
        setupUIElements()
        setUpYearView()
    }

    // MARK: Functions and Methods
    func tryExampleEntry() {
        //        if UserDefaults.standard.object(forKey: "Onboarding") == nil {
        //        let date = calendar.date(from: DateComponents(year: 2018, month: 2, day: 10, hour: 12))!
        let entry1 = Entry(id: "0001", date: today, type: .task, state: .active, comment: "This is an active Task!", starred: false)
        let entry2 = Entry(id: "0002", date: today, type: .task, state: .active, comment: "This is a Task that's important!", starred: true)
        let entry3 = Entry(id: "0003", date: today, type: .task, state: .done, comment: "This is a finished Task!", starred: false)
        let entry4 = Entry(id: "0004", date: today, type: .event, state: .active, comment: "This is an Event!", starred: false)
        let entry5 = Entry(id: "0005", date: today, type: .note, state: .active, comment: "This is a Note of something that happened!", starred: false)
        let entry6 = Entry(id: "0006", date: today, type: .task, state: .crossed, comment: "This is a Task that we abandoned!", starred: false)
        _ = [entry1, entry2, entry3, entry4, entry5, entry6].map { entries.append($0) }
        //            UserDefaults.standard.set("True", forKey: "Onboarding")
        //        }
    }

    func setupCalendarProperties() {
        let todaysDate = Date()
        let todaysDateComponents = calendar.dateComponents([.month, .day, .year], from: todaysDate)

        if let year = todaysDateComponents.year,
            let month = todaysDateComponents.month,
            let day = todaysDateComponents.day {
            today = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
            thisYear = year
        }

        dateFormatter.dateFormat = "YYYY"
        title = "\(thisYear!)"

        startDate = calendar.date(from: DateComponents(year: thisYear, month: 1, day: 1, hour: 12))!
        dateFormatter.dateFormat = "MMM d EEE"

        tryExampleEntry()
        placeEntries()
    }

    func setupUIElements() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dateCell")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(zoomToToday))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(setupAndShowEntryCreationPopup))

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

    @objc func setupAndShowEntryCreationPopup() {
        setUpEntryPopup()
    }

    func setUpEntryPopup(editEntry entry: Entry? = nil, withDate date: Date? = nil) {
        if self.createEntryView != nil {
            self.createEntryView.removeFromSuperview()
        }

        self.createEntryView = EntryCreationView(frame: CGRect(x: ((self.view.frame.width - self.view.frame.width * 0.8) / 2), y: self.view.frame.height * 0.15, width: self.view.frame.width * 0.8, height: 400))
        self.createEntryView.cancelButton.addTarget(self, action: #selector(entryCancelPressed(_:)), for: .touchUpInside)

        if let date = date {
            // This is if the user tapped from an empty cell
            self.createEntryView.datePickerView.setDate(date, animated: true)
            self.createEntryView.createButton.isEnabled = false
        } else if let entry = entry {
            // This is for editing the entry
            self.createEntryView.entryTextField.text = entry.comment
            self.createEntryView.headlineLabel.text = "Edit Entry"
            self.createEntryView.datePickerView.setDate(entry.date, animated: true)

            if entry.starred {
                self.createEntryView.starredSegmentedControl.selectedSegmentIndex = 1
            }

            switch entry.state {
            case .active:
                self.createEntryView.statusSegmentedControl.selectedSegmentIndex = 0
            case .done:
                self.createEntryView.statusSegmentedControl.selectedSegmentIndex = 1
            case .crossed:
                self.createEntryView.statusSegmentedControl.selectedSegmentIndex = 2
            }
        } else {
            // This is if the user clicked the bar button to add
            self.createEntryView.createButton.isEnabled = false
        }

        self.view.addSubview(createEntryView)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dateAtSection = indexPathDirectory[section], let tempDateArray = daysDict[dateAtSection] {
            return tempDateArray.count + 1
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
            if indexPath.row < tempDateArray.count {
                let entry = tempDateArray[indexPath.row]

                if entry.starred {
                    cellString = "★"
                } else {
                    cellString = "   "
                }

                switch entry.type {
                case .task:
                    switch entry.state {
                    case .active, .crossed:
                        cellString += "•  "
                    case .done:
                        cellString += "✕ "
                    }
                case .event:
                    cellString += "◦  "
                case .note:
                    cellString += "-  "
                }

                cellString += "\(tempDateArray[indexPath.row].comment)"
            }
        }

        cell.textLabel?.text = cellString

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let dateAtCell = indexPathDirectory[indexPath.section] {
            if let tempDateArray = daysDict[dateAtCell] {
                guard indexPath.row < tempDateArray.count else {
                    setUpEntryPopup(withDate: dateAtCell)
                    return
                }

                let entry = tempDateArray[indexPath.row]
                setUpEntryPopup(editEntry: entry)
            } else {
                setUpEntryPopup(withDate: dateAtCell)
            }
        }
    }
}
