//
//  LoginViewController.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/8/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    // MARK: - Properties and Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var keyboardSize: CGRect? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        emailField.delegate = self
        passwordField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
         NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    // MARK: - Functions and Methods
    @objc func loggedIn(_ sender: Any) {
        let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
        appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func attemptLogin() {
        if let emailAddress = emailField.text, let password = passwordField.text {
            loginButton.isEnabled = false

            Auth.auth().signIn(withEmail: emailAddress, password: password) { (user, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error!", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: {
                        self.loginButton.isEnabled = true
                    })
                }

                if let _ = user {
                    let defaults = UserDefaults.standard
                    defaults.set(emailAddress, forKey: "email")
                    defaults.set(password, forKey: "password")

                    self.loggedIn(self)
                }
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardSize == nil {
            keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        }

        print("iPhone height: \(self.view.frame.height)")

        if self.view.frame.height <= CGFloat(667.0) && self.view.frame.origin.y == 0 {
            if let keyboardSize = keyboardSize {
                self.view.frame.origin.y -= keyboardSize.height / 3
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.height <= CGFloat(667.0) && self.view.frame.origin.y != 0 {
            if let keyboardSize = keyboardSize {
                self.view.frame.origin.y += keyboardSize.height / 3
            }
        }
    }


    // MARK: Outlet Functions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        attemptLogin()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
            attemptLogin()
        }
        
        return true
    }
}
