//
//  EntryManager.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/25/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class EntryManager {
    // MARK: Database properties
    var databaseReference: DatabaseReference!
    var userID: String!
    var entryKey: String?

    // MARK: Date-related properties
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
    var view: UIView!
    var tableView: UITableView!

    // MARK: - Init
    init(view: UIView, tableView: UITableView) {
        self.view = view
        self.tableView = tableView
        self.databaseReference = Database.database().reference()
        self.userID = Auth.auth().currentUser?.uid
        setupCalendarProperties()
        setUpYearView()
        loadDataFromFirebase(true)
    }

    // MARK: Database functions
    func loadDataFromFirebase(_ firstLoad: Bool = false) {
        databaseReference.child("entries").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            self.entries.removeAll()

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                    let valueDict = snap.value as? [String : String],
                    let dateString = valueDict["date"],
                    let type = valueDict["type"],
                    let convertedType = EntryType(rawValue: type),
                    let state = valueDict["state"],
                    let convertedState = EntryState(rawValue: state),
                    let comment = valueDict["comment"],
                    let starred = valueDict["starred"] {

                    self.dateFormatter.dateFormat = "MM/dd/yyyy"
                    let dateToConvert = self.dateFormatter.date(from: dateString)!

                    let convertedComponents = self.calendar.dateComponents([.month, .day, .year], from: dateToConvert)

                    guard let year = convertedComponents.year else { return }
                    guard let month = convertedComponents.month else { return }
                    guard let day = convertedComponents.day else { return }

                    let convertedDate = self.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!

                    let entry = Entry(id: snap.key, date: convertedDate, type: convertedType, state: convertedState, comment: comment, starred: Bool(starred)!)

                    self.entries.append(entry)
                }
            }

            if self.entries.count > 0 {
                self.placeEntries()
            } else {
                self.onboardingEntries()
            }

            if firstLoad {
                self.zoomToToday()
            }
        }
    }

    @objc func createEntry() {
        manipulateEntry(false)
    }

    @objc func editEntry() {
        manipulateEntry(true)
    }

    func manipulateEntry(_ edit: Bool) {
        var key: String!

        if edit {
            key = entryKey
            entryKey = nil
        } else {
            key = databaseReference.child("entries").child(userID).childByAutoId().key
        }

        let cev = createEntryView!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.string(from: cev.datePickerView.date)

        if let type = cev.typeSegmentChoices[cev.entryTypeSegmentedControl.selectedSegmentIndex],
            let state = cev.stateSegmentChoices[cev.statusSegmentedControl.selectedSegmentIndex],
            let comment = cev.entryTextField.text,
            let starred = cev.starredSegmentChoices[cev.starredSegmentedControl.selectedSegmentIndex] {
            let newEntry: [String : String] = [
                "id" : key,
                "date": date,
                "type": type.rawValue,
                "state": state.rawValue,
                "comment": comment,
                "starred": starred
            ]

            self.databaseReference.child("entries").child(userID).child(key).setValue(newEntry)
            self.createEntryView.removeFromSuperview()
            loadDataFromFirebase()
        }
    }

    // MARK: Popup-related Functions
    @objc func setupAndShowEntryCreationPopup() {
        setUpEntryPopup()
    }

    @objc func entryCancelPressed(_ sender: UIButton) {
        self.createEntryView.removeFromSuperview()
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
            self.createEntryView.createButton.addTarget(self, action: #selector(createEntry), for: .touchUpInside)
        } else if let entry = entry {
            // This is for editing the entry
            entryKey = entry.id
            self.createEntryView.entryTextField.text = entry.comment
            self.createEntryView.headlineLabel.text = "Edit Entry"
            self.createEntryView.datePickerView.setDate(entry.date, animated: true)
            self.createEntryView.createButton.addTarget(self, action: #selector(editEntry), for: .touchUpInside)

            switch entry.type {
            case .task:
                self.createEntryView.entryTypeSegmentedControl.selectedSegmentIndex = 0
            case .event:
                self.createEntryView.entryTypeSegmentedControl.selectedSegmentIndex = 1
            case .note:
                self.createEntryView.entryTypeSegmentedControl.selectedSegmentIndex = 2
            }

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
            self.createEntryView.createButton.addTarget(self, action: #selector(createEntry), for: .touchUpInside)
        }

        self.view.addSubview(createEntryView)
    }

    // MARK: Setup Functions
    func setupCalendarProperties() {
        let todaysDate = Date()
        let todaysDateComponents = calendar.dateComponents([.month, .day, .year], from: todaysDate)

        if let year = todaysDateComponents.year,
            let month = todaysDateComponents.month,
            let day = todaysDateComponents.day {
            today = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
            thisYear = year
        }

        startDate = calendar.date(from: DateComponents(year: thisYear, month: 1, day: 1, hour: 12))!
    }

    func placeEntries() {
        daysDict.removeAll()

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

        self.tableView.reloadData()
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
    }

    // MARK: QOL functions
    func onboardingEntries() {
        if UserDefaults.standard.object(forKey: "onboarding") == nil {
            let entry1 = Entry(id: "0001", date: today, type: .task, state: .active, comment: "This is an active Task!", starred: false)
            let entry2 = Entry(id: "0002", date: today, type: .task, state: .active, comment: "This is a Task that's important!", starred: true)
            let entry3 = Entry(id: "0003", date: today, type: .task, state: .done, comment: "This is a finished Task!", starred: false)
            let entry4 = Entry(id: "0004", date: today, type: .event, state: .active, comment: "This is an Event!", starred: false)
            let entry5 = Entry(id: "0005", date: today, type: .note, state: .active, comment: "This is a Note of something that happened!", starred: false)
            let entry6 = Entry(id: "0006", date: today, type: .task, state: .crossed, comment: "This is a Task that we abandoned!", starred: false)
            _ = [entry1, entry2, entry3, entry4, entry5, entry6].map { entries.append($0) }
            UserDefaults.standard.set("true", forKey: "onboarding")
        }

        placeEntries()
    }

    @objc func zoomToToday() {
        zoomToDate(startDate, to: today)
    }

    func zoomToDate(_ startDate: Date, to targetDate: Date) {
        let components = self.calendar.dateComponents([.day], from: startDate, to: targetDate).day!
        let indexPath = IndexPath(row: 0, section: components)

        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }

}
