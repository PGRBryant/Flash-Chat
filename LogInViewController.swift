//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {
        //TODO: Log in the user
        var alert = UIAlertController()
        
        SVProgressHUD.show()
        
        //technically email/pswd checks are unnecessary (or, no special alert is thrown)
        if let email = emailTextfield.text {
            if let pswd = passwordTextfield.text {
                Auth.auth().signIn(withEmail: email, password: pswd) { (user, error) in
                    if error != nil {
                        print(error!)
                        let debugError = error.debugDescription.components(separatedBy: "\"")
                        alert = UIAlertController(title: "Uh Oh!", message: "\(debugError.dropFirst().first ?? "Something Crazy Happened!") ", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        print("Log in successful!")
                        self.performSegue(withIdentifier: "goToChat", sender: self)
                    }
                    SVProgressHUD.dismiss()
                }
            }
        }

    }
}  
