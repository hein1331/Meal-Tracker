//
//  AddMealContainersViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/15/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit

class AddMealContainersViewController: QRScanViewController, Downloadable {
    //Variables from the AddMeal controller
    var selectedMeal : Meal? = nil
    var editMeal : Bool = false
    
    //ID of the container found
    var contID: Int = 0
    
    //ID of the last added container
    var lastAddedContID: Int = 0
    
    //ID of the last found container
    var lastFndContID : Int = 0
    
    //Container added
    var contAdded: Bool = false
    
    //Can add new item
    var canAddAnother: Bool = true
    
    //Needs to overwritten
    var overwriteMeal: Bool = false
    
    //Needs to be cleared
    var clearMeal: Bool = false
    
    //GUI Components
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var AddContainerButton: UIButton!
    @IBOutlet weak var FinishButton: UIButton!
    
    //Models
    var containerModel: ContainerModel = ContainerModel()
    var mealsModel: MealModel = MealModel()
    
    var existingContainers: [Container] = [Container]()

    override func viewDidLoad() {
        
        //If the meal does not have a valid ID we return
        if(selectedMeal == nil)
        {
            dismiss(animated: false, completion: nil);
        }
        
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        //Bring all the items in front of the camera
        self.view.bringSubviewToFront(AddContainerButton)
        self.view.bringSubviewToFront(StatusLabel)
        self.view.bringSubviewToFront(FinishButton)
        self.view.bringSubviewToFront(TitleLabel)
        
        //Init container model type
        mealsModel.delegate = self
        containerModel.delegate = self
        
        //Get the data
        refreshData()
        
        //Show finish button hidden if meal is being edited
        contAdded = editMeal
        
        //Init the buttons
        found(code: nil)
        
        //Init buttons
        AddContainerButton.backgroundColor = UIColor.green
        FinishButton.backgroundColor = UIColor.green
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func refreshData(){
        //Download all the containers
        containerModel.downloadContainers(parameters: [String: String](), url: URLServices.GetContainers)
    }
    
    
    func didReceiveData(data: Any) {
        //Convert data to a container list if possible
        let datCont:[Container]? = (data as? [Container])
        
        //Convert data to a bool if possible
        let datBool:Bool? = (data as? Bool)
        
        //Convert data to a meal if possible
        let datMeal:Meal? = (data as? Meal)
        
        //If the it is a list of containers it means that it is from the init and that it contains all the existing containers
        if(datCont != nil) {
            existingContainers = datCont!
        }
        
            
        //If it is a meal it means a meal already exists in container
        else if(datMeal != nil) {
            DispatchQueue.main.async {
                
                //Set add container text and bool variables
                if(self.editMeal && datMeal!.id == self.selectedMeal!.id) {
                    self.AddContainerButton.setTitle("Remove", for: UIControl.State.normal)
                    self.clearMeal = true
                    self.overwriteMeal = false
                    
                    self.StatusLabel.attributedText = NSMutableAttributedString(string: "Remove container from meal?",
                                                                                attributes: self.errorTextAttributes)
                }
                else {
                    self.AddContainerButton.setTitle("Overwrite", for: UIControl.State.normal)
                    self.clearMeal = false
                    self.overwriteMeal = true
                    
                    self.StatusLabel.attributedText = NSMutableAttributedString(string: "Overwrite container?",
                    attributes: self.errorTextAttributes)
                }
                
                //Show the button
                self.AddContainerButton.isHidden = false
            }
        }
    
        //If it is a bool it meas that the container add request has returned
        else if (datBool != nil) {
            if(datBool!) {
                //Ensure we can not add another container
                canAddAnother = false
                                
                DispatchQueue.main.async {
                    //Hide add button
                    self.AddContainerButton.isHidden = true
                    
                    //Set the status label                                    
                    if(self.overwriteMeal) {
                        self.StatusLabel.attributedText = NSMutableAttributedString(string: "Overwritten!", attributes: self.goodTextAttributes)
                    }
                    else if(self.clearMeal) {
                       self.StatusLabel.attributedText = NSMutableAttributedString(string: "Removed!", attributes: self.goodTextAttributes)
                    }
                    else {
                        self.StatusLabel.attributedText = NSMutableAttributedString(string: "Added!", attributes: self.goodTextAttributes)
                    }
                    
                
                    self.setStatusLabelSize()
                }
                
                //Ensure the finish button will now show
                contAdded = true
                
                //Start a timer for when another container can be added
                startAddAnotherTimer()
                
                //Refresh all the data
                refreshData()
            }
            else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Could Not Add", message: "The container could not be added", preferredStyle: .alert)
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
            self.FinishButton.isHidden = !self.contAdded
            self.canAddAnother = true
        }
    }
    
    override func found(code: String?) {
        if(canAddAnother) {
     
            //Hide finish button if nothing has been added yet
            FinishButton.isHidden = !contAdded
            
            if(code == nil) {
                StatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a QR Code",
                attributes: defaultTextAttributes)
                AddContainerButton.isHidden = true
            }
            else if(lastAddedContID == Int(code!) ?? 0)
            {
                StatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a new QR Code",
                attributes: defaultTextAttributes)
                AddContainerButton.isHidden = true
            }
            else if (lastFndContID != Int(code!))
            {
                //Reset boolean variables
                overwriteMeal = false
                clearMeal = false
                
                //Convert value to int if possible
                contID = Int(code!) ?? 0
                
                //Set last found
                lastFndContID = contID
                
                //Ensure the ID is within range
                if contID > 0 && contID < 200 {
                    
                    //Check to make sure the container is already in the database
                    let existingContainer = existingContainers.first(where: { cont in cont.id == contID})
                    
                    //Container exists but is filled. Need to see what is in it
                    if(existingContainer != nil && existingContainer!.filled) {
                        StatusLabel.attributedText = NSMutableAttributedString(string: "Loading Meal..", attributes: defaultTextAttributes)
                        AddContainerButton.isHidden = true
                        
                        //Get meal in container
                        mealsModel.getMealInContainer(contID: existingContainer!.id)
                    }
                    //Container exists and is empty
                    else if(existingContainer != nil) {
                        
                        //Can add meal to container
                        StatusLabel.attributedText = NSMutableAttributedString(string: "Add " + selectedMeal!.name + " to container " + code!, attributes: goodTextAttributes)
                        
                        //Set the button text
                        AddContainerButton.setTitle("Add Container", for: UIControl.State.normal)
                        
                        //unhide the button
                        AddContainerButton.isHidden = false
                    }
                    //Container does not exist
                    else {
                        StatusLabel.attributedText = NSMutableAttributedString(string: "Container " + code! + " does not exist", attributes: errorTextAttributes)
                        AddContainerButton.isHidden = true
                    }
                }
                else {
                    StatusLabel.attributedText = NSMutableAttributedString(string: "Not a valid Container Label",
                    attributes: errorTextAttributes)
                    AddContainerButton.isHidden = true
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
    
    @IBAction func AddContainerPressed(_ sender: Any) {
        //Add meal
        let param = ["cont_id":String(contID), "meal_id":String(selectedMeal!.id)]
        
        if(overwriteMeal) {
            containerModel.overwriteMealInContainer(parameters: param)
        }
        else if(clearMeal) {
            containerModel.clearMealInContainer(parameters: param)
        }
        else {
            containerModel.addMealToContainer(parameters: param)
        }
        
        lastAddedContID = contID;
    }
    
    @IBAction func FinishAddPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
       
    }
    
}
