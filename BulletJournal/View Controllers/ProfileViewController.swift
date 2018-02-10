//
//  ProfileViewController.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/9/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
            print("signed out: \(defaults.value(forKey: "email") ?? "Signed out"), \(Auth.auth().currentUser?.email ?? "No user")")

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
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
        let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginInScreen")
        appDel.window?.rootViewController = rootController
    }

}
