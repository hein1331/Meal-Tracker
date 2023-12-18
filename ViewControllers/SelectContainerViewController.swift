//
//  SelectContainerViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/15/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit

class SelectContainerViewController: QRScanViewController, Downloadable, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Properties
    @IBOutlet weak var ContainerTypeSelector: UIPickerView!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ContainerTypeLabel: UILabel!
    
    var model: ContainerModel = ContainerModel()
    var containerTypeData: [String] = ["Plastic", "Glass"]
    var existingContainers: [Container] = [Container]()
    var contID: Int = 0
    
    // MARK: Functions
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set labels to appropriate attributes
        TitleLabel.attributedText = NSMutableAttributedString(string: TitleLabel.text ?? "", attributes: defaultTextAttributes)
        ContainerTypeLabel.attributedText = NSMutableAttributedString(string: ContainerTypeLabel.text ?? "", attributes: defaultTextAttributes)
        
        //Bring all the items in front of the camera
        self.view.bringSubviewToFront(ContainerTypeSelector)
        self.view.bringSubviewToFront(StatusLabel)
        self.view.bringSubviewToFront(AddButton)
        self.view.bringSubviewToFront(TitleLabel)
        self.view.bringSubviewToFront(ContainerTypeLabel)

        //Set the container type delegate so that call backs come here
        self.ContainerTypeSelector.delegate = self
        self.ContainerTypeSelector.dataSource = self
        
        //Init container model type
        model.delegate = self;
        
        //Download all the containers
        model.downloadContainers(parameters: [String: String](), url: URLServices.GetContainers)
        
        //Init the buttons
        found(code: nil)

    }
    
    override func found(code: String?) {
        if(code == nil) {
            StatusLabel.attributedText = NSMutableAttributedString(string: "Please scan a QR Code",
            attributes: defaultTextAttributes)
            AddButton.isHidden = true
        }
        else
        {
            //Convert value to int if possible
            contID = Int(code!) ?? 0
            if contID > 0 && contID < 200 {
                if existingContainers.contains(where: { cont in cont.id == contID}) {
                    StatusLabel.attributedText = NSMutableAttributedString(string: "Container " + code! + " already exists",
                                                                           attributes: errorTextAttributes)
                    AddButton.isHidden = true
                }
                else {
                    StatusLabel.attributedText = NSMutableAttributedString(string: "Add container number " + code!,
                    attributes: goodTextAttributes)
                    AddButton.isHidden = false
                }
            }
            else {
                StatusLabel.attributedText = NSMutableAttributedString(string: "Not a valid Container Label",
                attributes: errorTextAttributes)
                AddButton.isHidden = true
            }
        }
        
    }

    @IBAction func AddButtonTapped(_ sender: Any) {
        let param = ["cont_id": String(contID), "cont_type":containerTypeData[ContainerTypeSelector.selectedRow(inComponent: 0)]]
        
        model.addContainer(parameters: param)
    }
    
    
    func didReceiveData(data: Any) {
        //Convert data to a container list if possible
        let datCont:[Container]? = (data as? [Container])
        
        //Convert data to a bool if possible
        let datBool:Bool? = (data as? Bool)
        
        //If the it is a list of containers it means that it is from the init and that it contains all the existing containers
        if(datCont != nil) {
            existingContainers = datCont!
        }
            
        //If it is a bool it meas that the container add request has returned
        else if (datBool != nil) {
            DispatchQueue.main.async {
                if(datBool!) {
                    (self.presentingViewController as! ContainerTableViewController).reloadTableView()
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Could Not Add", message: "The container could not be added", preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return containerTypeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)  {
            pickerLabel = UILabel()

            pickerLabel?.attributedText = NSMutableAttributedString(string: containerTypeData[row], attributes: defaultTextAttributes)
            pickerLabel?.font = UIFont(name: TitleLabel.font.familyName, size: 26)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        else  {
            pickerLabel!.text = containerTypeData[row]
        }
        
        return pickerLabel!;
    }
    
}
