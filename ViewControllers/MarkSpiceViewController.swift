//
//  MarkSpiceViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 1/20/22.
//  Copyright © 2022 Heinrich Enslin. All rights reserved.
//

import UIKit

class MarkSpiceViewController: QRScanViewController, Downloadable {
    
    //Name of the space found
    var spiceName: String? = nil
    
    // Spice found
    var spiceToEdit: Spice? = nil
    
    // Whether another spice can be edited
    var canEditAnother: Bool = true
    var hasRefill: Int = 0
    
    // List of spices
    var spices: [Spice] = [Spice]()
    
    //Models
    var spiceModel: SpiceModel = SpiceModel()
    
    
    // GUI Components
    @IBOutlet weak var MarkSpiceTitleLabel: UILabel!
    @IBOutlet weak var MarkSpiceStatusLabel: UILabel!
    @IBOutlet weak var MarkLowButton: UIButton!
    @IBOutlet weak var MarkEmptyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Bring all the items in front of the camera
        self.view.bringSubviewToFront(MarkLowButton)
        self.view.bringSubviewToFront(MarkEmptyButton)
        self.view.bringSubviewToFront(MarkSpiceTitleLabel)
        self.view.bringSubviewToFront(MarkSpiceStatusLabel)
        
        //Init spice model type
        spiceModel.delegate = self
        
        //Get the data
        refreshData()
        
        //Init the buttons
        found(code: nil)
        
        //Init buttons
        MarkLowButton.backgroundColor = UIColor.green
        
        MarkEmptyButton.backgroundColor = UIColor.red
        
        // Init text
        self.MarkSpiceTitleLabel.attributedText = NSMutableAttributedString(string: "Scan Spice",
                                                                    attributes: self.defaultTextAttributes)
    }
    
    func refreshData(){
        //Download all the spices
        spiceModel.downloadAllSpices()
    }
    
    func didReceiveData(data: Any) {
        //Convert data to a spice list if possible
        let datSpices:[Spice]? = (data as? [Spice])
        
        //Convert data to a bool if possible
        let datBool:Bool? = (data as? Bool)
        
        //If the it is a list of containers it means that it is from the init and that it contains all the existing containers
        if(datSpices != nil) {
            spices = datSpices!
        }

        //If it is a bool it means the edit spice request has returned
        else if (datBool != nil) {
            if(datBool!) {
                //Ensure we can edit another spice
                canEditAnother = false
                                
                DispatchQueue.main.async {
                    //Hide add button
                    self.MarkLowButton.isHidden = true
                    self.MarkEmptyButton.isHidden = true
                    
                    self.MarkSpiceStatusLabel.attributedText = NSMutableAttributedString(string: "Marked!", attributes: self.goodTextAttributes)
                    self.setStatusLabelSize()
                }
                
                //Start a timer for when another container can be added
                startAddAnotherTimer()
                
                //Refresh all the data
                refreshData()
            }
            else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Could Not Mark", message: "The spice could not be marked", preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            
        }
    }
    
    func startAddAnotherTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.MarkSpiceStatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a Spice",
                                                                        attributes: self.defaultTextAttributes)
            self.canEditAnother = true
        }
    }
    
    override func found(code: String?) {
        if(canEditAnother) {
            
            if(code == nil) {
                MarkSpiceStatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a Spice",
                attributes: defaultTextAttributes)
                MarkLowButton.isHidden = true
                MarkEmptyButton.isHidden = true
            }
            else
            {
                // Get spice name
                spiceName = code!
                let prettySpiceName = spiceName!.replacingOccurrences(of: "_", with: " ")
                    
                //Check to make sure the spice is already in the database
                spiceToEdit = spices.first(where: { spice in spice.decoded_name == spiceName})
                
                // Spice does not exist in database
                if(spiceToEdit == nil) {
                    MarkSpiceStatusLabel.attributedText = NSMutableAttributedString(string: prettySpiceName + " Has Not Been Added", attributes: errorTextAttributes)
                    MarkLowButton.isHidden = true
                    MarkEmptyButton.isHidden = true
                }
                // Spice exist and it is in stock
                else if(spiceToEdit != nil && spiceToEdit!.status == "Stocked") {
                    
                    // Set button text
                    MarkLowButton.setTitle("Mark Low", for: UIControl.State.normal)
                    MarkEmptyButton.setTitle("Mark Empty", for: UIControl.State.normal)
                    
                    //Can add meal to container
                    MarkSpiceStatusLabel.attributedText = NSMutableAttributedString(string: "Mark " + prettySpiceName, attributes: goodTextAttributes)
                    
                    //unhide the button
                    MarkLowButton.isHidden = false
                    MarkEmptyButton.isHidden = false
                }
                // Spice exist and it is empty or low
                else if(spiceToEdit != nil && (spiceToEdit!.status == "Empty" || spiceToEdit!.status == "Low" || spiceToEdit!.status == "Needs Refill")) {
                    
                    // Set button text
                    MarkLowButton.setTitle("Mark Filled", for: UIControl.State.normal)
                    MarkEmptyButton.isHidden = spiceToEdit!.status != "Low"
                    
                    //Can add meal to container
                    MarkSpiceStatusLabel.attributedText = NSMutableAttributedString(string: "Mark " + prettySpiceName, attributes: goodTextAttributes)
                    
                    //unhide the button
                    MarkLowButton.isHidden = false
                }
            }
            setStatusLabelSize()
        }
    }
    
    func setStatusLabelSize() {
        MarkSpiceStatusLabel.sizeToFit()
        var myFrame = MarkSpiceStatusLabel.frame
        myFrame = CGRect(x: myFrame.minX, y: myFrame.minY, width: 343, height: myFrame.height)
        MarkSpiceStatusLabel.frame = myFrame
    }
    
    
    func fillSpice() {
        //Convert date to string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        
        //Fill spice
        let param = ["name":spiceName!, "date_filled":dateStr, "status":"Stocked", "leftover":hasRefill] as [String : Any]

        spiceModel.editSpice(parameters: param as [String : Any])
    }
    
    
    @IBAction func MarkLowPressed(_ sender: Any) {
        
        // Spice is filled
        if(spiceToEdit!.status == "Empty" || spiceToEdit!.status == "Low" || spiceToEdit!.status == "Needs Refill") {
            // Check to see if refill is present
            let refreshAlert = UIAlertController(title: "Refill?", message: "Is there any leftover spice after the fill?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.hasRefill = 1
                self.fillSpice()
            }))

            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                self.hasRefill = 0
                self.fillSpice()
            }))

            present(refreshAlert, animated: true, completion: nil)
            
        } else if(spiceToEdit!.status == "Stocked" && spiceToEdit!.leftover == 1) {
            //Fill spice
            let param = ["name":spiceToEdit!.decoded_name, "date_filled":spiceToEdit!.date_filled, "status":"Needs Refill", "leftover":spiceToEdit!.leftover] as [String : Any]

            spiceModel.editSpice(parameters: param as [String : Any])
        } else if(spiceToEdit!.status == "Stocked" && spiceToEdit!.leftover == 0) {
            //Fill spice
            let param = ["name":spiceToEdit!.decoded_name, "date_filled":spiceToEdit!.date_filled, "status":"Low", "leftover":spiceToEdit!.leftover] as [String : Any]

            spiceModel.editSpice(parameters: param as [String : Any])
        }
    }
            
    
    
    @IBAction func MarkEmptyPressed(_ sender: Any) {
        if((spiceToEdit!.status == "Stocked" || spiceToEdit!.status == "Low") && spiceToEdit!.leftover == 1) {
            //Mark spice as needing refill
            let param = ["name":spiceToEdit!.decoded_name, "date_filled":spiceToEdit!.date_filled, "status":"Needs Refill", "leftover":spiceToEdit!.leftover] as [String : Any]

            spiceModel.editSpice(parameters: param as [String : Any])
        } else if((spiceToEdit!.status == "Stocked" || spiceToEdit!.status == "Low") && spiceToEdit!.leftover == 0) {
            //Fill spice
            let param = ["name":spiceToEdit!.decoded_name, "date_filled":spiceToEdit!.date_filled, "status":"Empty", "leftover":spiceToEdit!.leftover] as [String : Any]

            spiceModel.editSpice(parameters: param as [String : Any])
        }
    }
}
