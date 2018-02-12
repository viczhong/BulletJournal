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
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var datePickerView: UIDatePicker!

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
            createButton.isEnabled = false
        }
    }

    // MARK: - Functions and Methods
    @IBAction func createButtonTapped(_ sender: UIButton) {
        print("create tapped/n/n/n")
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
