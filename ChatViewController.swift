//
//  ViewController.swift
//  Flash Chat
//
//  Created by Gabriel Bryant on 03/24/2018.
//  Copyright (c) 2018 Phaeroh. All rights reserved.
//


//be able to have a display name instead of an email
//edit the avatar background color too


import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray:[Message] = [Message]() //be able to delete messages
    
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    //UI Elements
    var keyboardHeight:CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
    
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
    
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO: Automatically gather the keyboardHeight for UI logic across all devices
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow),
//            name: NSNotification.Name.UIKeyboardWillShow,
//            object: nil
//        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)

    }

    ///////////////////////////////////////////
    //MARK: - TableView DataSource Methods
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String? {
            //Messages "we" sent
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
//            cell.avatarImageView.image = UIImage(named: "dark\(arc4random_uniform(28))")
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
//            cell.avatarImageView.image = UIImage(named: "light\(arc4random_uniform(28))")
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    //specify how many rows we want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
    }
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    //what if we want the table's row height to change depending on how long a text is? Well...
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0 //just roughly
    }
    
    ///////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    
    //TODO: Declare textFieldDidBeginEditing here:
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.5) {
//            print(50 + self.keyboardHeight)
//            self.heightConstraint.constant = 50 + self.keyboardHeight
//            self.view.layoutIfNeeded() //if a constraint has changed, redraw the whole thing
//        }
//    }
    
    func textFieldIsEditin() {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 20 + self.keyboardHeight
            self.view.layoutIfNeeded() //if a constraint has changed, redraw the whole thing
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded() //if a constraint has changed, redraw the whole thing
        }
    }

    //TODO: Keyboard notification info
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height //update the global
            textFieldIsEditin()
        }
    }
    
    ///////////////////////////////////////////
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        tableViewTapped() //end editing

        //TODO: Send the message to Firebase and save it in our database
        
        //make it so the user can't accidentally send something twice, so, we disable until Firebase updates
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text!]
        
        //                    "Image": Auth.auth().currentUser?.displayName
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("error: there was a problem signing out")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print ("No View Controllers to pop off")
                return
        }
    }
    


}
