//
//  EntryCreationView.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/10/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EntryCreationView: UIView {
    // MARK: - Outlets and Properties
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var entryTextField: UITextField!
    @IBOutlet weak var entryTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var starredSegmentedControl: UISegmentedControl!
    @IBOutlet weak var statusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var datePickerView: UIDatePicker!

    var databaseReference: DatabaseReference!
    var userID: String!

    var typeSegmentChoices: [Int : EntryType] = [
        0 : .task,
        1 : .event,
        2 : .note
    ]

    var starredSegmentChoices: [Int : String] = [
        0 : "false",
        1 : "true"
    ]

    var stateSegmentChoices: [Int : EntryState] = [
        0 : .active,
        1 : .done,
        2 : .crossed
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        if let nib = Bundle.main.loadNibNamed("EntryCreationView", owner: self, options: nil) {
            contentView = nib[0] as! UIView
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            contentView.layer.cornerRadius = 15
            contentView.layer.masksToBounds = true
            contentView.layer.borderWidth = 3
            addSubview(contentView)

            entryTextField.delegate = self

            databaseReference = Database.database().reference()
            userID = Auth.auth().currentUser?.uid
        }
    }

    // MARK: - Functions and Methods
    @IBAction func createButtonTapped(_ sender: UIButton) {
        //        let newKey = databaseReference.child("entries").child(userID).childByAutoId().key
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "MM/dd/yyyy"
        //        let date = dateFormatter.string(from: datePickerView.date)
        //
        ////        let targetDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: datePickerView.date)
        ////        var convertedTargetDate: Date?
        ////        if let year = targetDateComponents.year, let month = targetDateComponents.month, let day = targetDateComponents.day {
        ////            convertedTargetDate = Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
        ////        }
        //
        //        if let type = typeSegmentChoices[entryTypeSegmentedControl.selectedSegmentIndex],
        //            let state = stateSegmentChoices[statusSegmentedControl.selectedSegmentIndex],
        //            let comment = entryTextField.text,
        //            let starred = starredSegmentChoices[starredSegmentedControl.selectedSegmentIndex] {
        //            let newEntry: [String : String] = [
        //                "id" : newKey,
        //                "date": date,
        //                "type": type.rawValue,
        //                "state": state.rawValue,
        //                "comment": comment,
        //                "starred": starred
        //            ]
        ////                Entry(id: newKey, date: date, type: type, state: state, comment: comment, starred: starred)
        //            self.databaseReference.child("entries").child(userID).child(newKey).setValue(newEntry)
        //        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        print("cancel tapped/n/n/n")

    }
}

extension EntryCreationView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            createButton.isEnabled = true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EntryCreationView: UIPickerViewDelegate {

}
