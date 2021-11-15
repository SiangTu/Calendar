//
//  RegisterViewController.swift
//  Calendar
//
//  Created by 杜襄 on 2021/11/12.
//

import UIKit
import RealmSwift

class RegisterViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        emailTextField.layer.cornerRadius = 15
        passwordTextField.layer.cornerRadius = 15

        passwordTextField.clipsToBounds = true
        emailTextField.clipsToBounds = true
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
      
       
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        self.register()
    }
    
    func register(){
        
        let client = app.emailPasswordAuth
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if !isValidEmail(email){
            self.errorLabel.text = "Email is invalid"
            self.errorLabel.isHidden = false
            return
        }
        activityIndicator.startAnimating()
        client.registerUser(email: email, password: password) { (error) in
            guard error == nil else {
                print("Failed to register: \(error!.localizedDescription)")
                DispatchQueue.main.sync { [unowned self] in
                    self.activityIndicator.stopAnimating()
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.isHidden = false
                }
                return
            }
            print("Successfully registered user.")
            app.login(credentials: Credentials.emailPassword(email: email, password: password))
            {  (result) in
                
                switch result {
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                case .success(let newUser):
                    print("Successfully logged in as user \(newUser)")
                    
                    DispatchQueue.main.sync
                    {
                        realm = try! Realm(configuration: newUser.configuration(partitionValue: newUser.id))
                        let user = User(userID: newUser.id)
                        try! realm.write({
                            realm.add(user)
                        })
                        realm = try! Realm(configuration: newUser.configuration(partitionValue: user.teams[0].partition))
                        self.performSegue(withIdentifier: "registerToCalendarView", sender: self)
                    }
                }
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    

}

extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(self.TextFieldDidChange), for: .editingChanged)
    }

    @objc func TextFieldDidChange() {
        if emailTextField.text != "", passwordTextField.text != ""{
            registerButton.isEnabled = true
        }else{
            registerButton.isEnabled = false
        }
        errorLabel.isHidden = true
    }
}
