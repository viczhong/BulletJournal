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
    let dateFormatter = DateFormatter()
    var dateArray = [Date]()
    let today = Date()
    var yearDict = [String : IndexPath]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dateCell")
                dateFormatter.dateFormat = "MMM d EEE"
        setUpYearView()
    }

    // MARK: Functions and Methods
    func setUpYearView() {
        let calendar = Calendar.current
        let startDateComponents = DateComponents(year: 2018, month: 1, day: 1)
        let endDateComponents = DateComponents(year: 2018, month: 12, day: 31)
        let offsetComponents = DateComponents(day: 1)

        let startDate = calendar.date(from: startDateComponents)!
        let endDate = calendar.date(from: endDateComponents)!

        var currentDate = startDate
        dateArray = [currentDate]

        while currentDate.timeIntervalSince1970 < endDate.timeIntervalSince1970 {
            currentDate = calendar.date(byAdding: offsetComponents, to: currentDate)!
            dateArray.append(currentDate)
        }

        print("\n\nDate count: \(dateArray.count)")
        self.tableView.reloadData()
        zoomToDate(startDate, to: today, for: calendar)
    }

    func zoomToDate(_ startDate: Date, to targetDate: Date, for calender: Calendar) {
        let components = calender.dateComponents([.day], from: startDate, to: targetDate).day!
        print(components)

        let indexPath = IndexPath(row: 0, section: components)

        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateForSection = dateArray[section]

        let dateString = dateFormatter.string(from: dateForSection)

        return dateString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
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
}
