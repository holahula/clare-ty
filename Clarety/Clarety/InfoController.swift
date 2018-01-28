//
//  ViewController.swift
//  clarety
//
//  Created by Amy Jian on 2018-01-28.
//  Copyright © 2018 Amy Jian. All rights reserved.
//

import UIKit

class InfoController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    //variables to store user information
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var birthTextField: UITextField!
    
    @IBOutlet weak var address1TextField: UITextField!
    
    @IBOutlet weak var address2TextField: UITextField!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var peopleTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //presses anywhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func printName (myname: String) {
        nameLabel.text = myname
    }
    
}


