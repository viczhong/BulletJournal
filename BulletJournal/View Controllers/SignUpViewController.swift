//
//  SignUpViewController.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/8/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    // MARK: - Properties and Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var registerButton: UIButton!

    var keyboardSize: CGRect? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        emailField.delegate = self
        passwordField.delegate = self
        confirmField.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    // MARK: - Functions and Methods
    func registerUser() {
        if let emailAddress = emailField.text, let password = passwordField.text, let confirmation = confirmField.text {
            guard password == confirmation else {
                displayMessage(nil, "Your passwords must match!")
                return
            }

            Auth.auth().createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
                if let error = error {
                    self.displayMessage(error)
                }

                if let _ = user {
                    self.logIn(emailAddress, password)
                }
            })
        }
    }

    func logIn(_ emailAddress: String, _ password: String) {
        Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
            if let error = error {
                self.displayMessage(error)
            }

            if let _ = user {
                let defaults = UserDefaults.standard
                defaults.set(emailAddress, forKey: "email")
                defaults.set(password, forKey: "password")

                let completion: (UIAlertAction) -> Void = { [unowned self] (action) in
                    self.displayMainView()
                }

                self.displayMessage(nil, "Registration Successful!", nil, completion)
            }
        })
    }

    func displayMainView() {
        let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
        appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
    }

    func displayMessage(_ error: Error? = nil,_ title: String? = "Error!", _ customString: String? = nil, _ completion: ((UIAlertAction) -> Void)? = nil) {
        var messageString = customString

        if let error = error {
            messageString = error.localizedDescription
        }

        let alert = UIAlertController(title: title, message: messageString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardSize == nil {
            keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        }

        print("iPhone height: \(self.view.frame.height)")

        if self.view.frame.height <= CGFloat(600) && self.view.frame.origin.y == 0 {
            if let keyboardSize = keyboardSize {
                self.view.frame.origin.y -= keyboardSize.height / 3
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.height <= CGFloat(600) && self.view.frame.origin.y != 0 {
            if let keyboardSize = keyboardSize {
                self.view.frame.origin.y += keyboardSize.height / 3
            }
        }
    }

    // MARK: Outlet Functions
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        registerUser()
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmField.becomeFirstResponder()
        case confirmField:
            registerUser()
            fallthrough
        default:
            dismissKeyboard()
        }

        return true
    }
}


