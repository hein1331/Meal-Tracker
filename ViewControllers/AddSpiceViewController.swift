//
//  AddSpiceViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 1/18/22.
//  Copyright © 2022 Heinrich Enslin. All rights reserved.
//

import UIKit

class AddSpiceViewController: QRScanViewController, Downloadable {

    //Name of the space found
    var spiceName: String? = nil
    
    //Name of the last added spice
    var lastAddedSpiceName: String? = nil
    
    //Can add new item
    var canAddAnother: Bool = true
    
    // Whether the refill is empty
    var hasRefill: Int = 0
    
    // Refill Alert
    var refreshAlert: UIAlertController? = nil
    
    //GUI Components
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var AddSpiceButton: UIButton!
    
    //Models
    var spiceModel: SpiceModel = SpiceModel()
    
    var existingSpices: [Spice] = [Spice]()

    override func viewDidLoad() {
                
        super.viewDidLoad()

        //Bring all the items in front of the camera
        self.view.bringSubviewToFront(AddSpiceButton)
        self.view.bringSubviewToFront(StatusLabel)
        self.view.bringSubviewToFront(TitleLabel)
        
        //Init spice model type
        spiceModel.delegate = self
        
        //Get the data
        refreshData()
        
        //Init the buttons
        found(code: nil)
        
        //Init buttons
        AddSpiceButton.backgroundColor = UIColor.green
        
        // Init text
        self.TitleLabel.attributedText = NSMutableAttributedString(string: "Scan Spice",
                                                                    attributes: self.defaultTextAttributes)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
            existingSpices = datSpices!
        }
    
        //If it is a bool it meas that the container add request has returned
        else if (datBool != nil) {
            if(datBool!) {
                //Ensure we can not add another spice
                canAddAnother = false
                                
                DispatchQueue.main.async {
                    //Hide add button
                    self.AddSpiceButton.isHidden = true
                    self.StatusLabel.attributedText = NSMutableAttributedString(string: "Added!", attributes: self.goodTextAttributes)
                    self.setStatusLabelSize()
                }
                
                //Start a timer for when another container can be added
                startAddAnotherTimer()
                
                //Refresh all the data
                refreshData()
            }
            else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Could Not Add", message: "The spice could not be added", preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            
        }
    }
    
    func startAddAnotherTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.StatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a QR Code",
                                                                        attributes: self.defaultTextAttributes)
            self.canAddAnother = true
        }
    }
    
    override func found(code: String?) {
        if(canAddAnother) {
            
            if(code == nil) {
                StatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a QR Code",
                attributes: defaultTextAttributes)
                AddSpiceButton.isHidden = true
            }
            else if(lastAddedSpiceName == code ?? "")
            {
                StatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a new QR Code",
                attributes: defaultTextAttributes)
                AddSpiceButton.isHidden = true
            }
            else if (lastAddedSpiceName != code!)
            {
                //Convert value to int if possible
                spiceName = code!
                let prettySpiceName = spiceName!.replacingOccurrences(of: "_", with: " ")
                    
                //Check to make sure the spice is already in the database
                let existingSpice = existingSpices.first(where: { spice in spice.decoded_name == spiceName})
                
                //Container exists but is filled. Need to see what is in it
                if(existingSpice != nil) {
                    StatusLabel.attributedText = NSMutableAttributedString(string: prettySpiceName + " Already Added", attributes: errorTextAttributes)
                    AddSpiceButton.isHidden = true
                }
                //Container exists and is empty
                else if(existingSpice == nil) {
                    
                    //Can add meal to container
                    StatusLabel.attributedText = NSMutableAttributedString(string: "Add " + prettySpiceName, attributes: goodTextAttributes)
                    
                    //Set the button text
                    AddSpiceButton.setTitle("Add Spice", for: UIControl.State.normal)
                    
                    //unhide the button
                    AddSpiceButton.isHidden = false
                }
            }
            setStatusLabelSize()
        }
    }
    
    func setStatusLabelSize() {
        StatusLabel.sizeToFit()
        var myFrame = StatusLabel.frame
        myFrame = CGRect(x: myFrame.minX, y: myFrame.minY, width: 343, height: myFrame.height)
        StatusLabel.frame = myFrame
    }
    
    @IBAction func AddSpicePressed(_ sender: Any) {
        // Check to see if refill is present
        if(refreshAlert == nil) {
            refreshAlert = UIAlertController(title: "Refill?", message: "Is there any leftover spice after the fill?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert!.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.hasRefill = 1
                self.addSpice()
            }))

            refreshAlert!.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                self.hasRefill = 0
                self.addSpice()
            }))

            present(refreshAlert!, animated: true, completion: nil)
        }
        
        
        
    }
    
    func addSpice() {
        //Convert date to string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        
        //Add spice
        let param = ["name":spiceName!, "date_filled":dateStr, "status":"Stocked", "leftover":hasRefill] as [String : Any]

        spiceModel.addSpice(parameters: param as [String : Any])
       
        lastAddedSpiceName = spiceName;
        refreshAlert = nil
    }

}
