//
//  SettingsViewController.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/9/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let signedInEmail = Auth.auth().currentUser?.email!

        emailLabel.text = "Email: \(signedInEmail ?? "your@email.com")"
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        logOut()
    }

    func logOut() {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "email")
        defaults.set(nil, forKey: "password")

        do {
            try Auth.auth().signOut()

            let alert = UIAlertController(title: "Signed Out!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] (action) in
                self.returnToLoginScreen()
            })
            self.present(alert, animated: true, completion: nil)
        }
        catch {
            print(error.localizedDescription)
        }
    }

    func returnToLoginScreen() {
        //Remove user credentials
        UserDefaults.standard.set(nil, forKey: "onboarding")

        guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }

        let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginInScreen")

        appDel.window?.rootViewController = rootController
    }
}
