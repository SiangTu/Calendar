//
//  LoginViewController.swift
//  Calendar
//
//  Created by 杜襄 on 2021/11/9.
//

import UIKit
import RealmSwift

let app = App(id: Secret.appID)
var realm: Realm!

class LoginViewController: UIViewController {
    
    deinit{
        print("bye login")
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)

        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        emailTextField.layer.cornerRadius = 15
        passwordTextField.layer.cornerRadius = 15

        passwordTextField.clipsToBounds = true
        emailTextField.clipsToBounds = true
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = "1234@mail.com"
        passwordTextField.text = "123456"
        loginButton.isEnabled = true
        errorLabel.isHidden = true
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        self.login()
    }
    
    func login(){
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        activityIndicator.startAnimating()
        app.login(credentials: Credentials.emailPassword(email: email, password: password))
        { [unowned self] (result) in
            switch result {
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
                DispatchQueue.main.sync {
                    errorLabel.isHidden = false
                    activityIndicator.stopAnimating()
                }
            case .success(let user):
                print("Successfully logged in as user \(user)")
                DispatchQueue.main.sync {
                    self.openRealm()
                }
            }
        }
    }
 
    func openRealm(){
        guard let user = app.currentUser else{
            fatalError()
        }
        var teamPartition = ""
        
        Realm.asyncOpen(configuration: user.configuration(partitionValue: user.id)) { (result) in
                    switch result {
                    case .failure(let error):
                        print("Failed to open realm: \(error.localizedDescription)")
                    case .success(let userRealm):
                        print("Sucessed to open realm")
                        let userResult = userRealm.objects(User.self)
                        teamPartition = userResult.first!.teams[0].partition
                        
                        DispatchQueue.main.async { [unowned self] in
                            realm = try! Realm(configuration: user.configuration(partitionValue: teamPartition))
                            
                            self.performSegue(withIdentifier: "toCalendarView", sender: self)
                        }
                    }
                }
                        
        
        print("OK")
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(self.TextFieldDidChange), for: .editingChanged)
    }

    @objc func TextFieldDidChange() {
        if emailTextField.text != "", passwordTextField.text != ""{
            loginButton.isEnabled = true
        }else{
            loginButton.isEnabled = false
        }
        errorLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else{
            textField.endEditing(true)
        }
        
        return false
    }

    
}
