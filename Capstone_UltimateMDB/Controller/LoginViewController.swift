//
//  ViewController.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/17/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = "giorell"
        passwordTextField.text = "warcraft"
    }
    

    @IBAction func loginTapped(_ sender: UIButton) {
        print("login button tapped")
        if  emailTextField.text!.isEmpty && passwordTextField.text!.isEmpty {
            let alertVC = UIAlertController(title: "Login Failed", message: "Please enter your email and password to login.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            show(alertVC, sender: nil)
        } else {
            setLoggingIn(true)
            UMDBClient.getRequestToken(completion: handleRequestTokenResponse(success:error:))
        }
    }
    
    @IBAction func loginViaWebsiteTapped() {
        setLoggingIn(true)
        UMDBClient.getRequestToken() { success, error in
            if success {
                UIApplication.shared.open(UMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
            } else {
                self.showLoginFailure(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func handleRequestTokenResponse(success: Bool, error: Error?) {
        if success {
            UMDBClient.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        if success {
            UMDBClient.createSessionId(completion: handleSessionResponse(success:error:))
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            UserDefaults.standard.set(true, forKey: "status")
            Switcher.updateRootVC()
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        loginViaWebsiteButton.isEnabled = !loggingIn
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
}

