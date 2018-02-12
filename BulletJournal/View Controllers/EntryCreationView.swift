//
//  EntryCreationView.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/10/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit

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
        }
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
