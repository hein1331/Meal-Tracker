//
//  AddMealViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/15/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit

class AddMealViewController: UIViewController, Downloadable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // MARK: Properties
    @IBOutlet weak var MealNameField: UITextField!
    @IBOutlet weak var CaloriesField: UITextField!
    @IBOutlet weak var DateCreatedPicker: UIDatePicker!
    @IBOutlet weak var AddContainersButton: UIButton!
    @IBOutlet weak var MealImage: UIImageView!
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var TitleField: UILabel!
    @IBOutlet weak var MealImageButton: UIButton!
    @IBOutlet weak var CreatedByPicker: UIPickerView!
    
    let containerModel = ContainerModel()
    let mealModel = MealModel()
    var existingContainers : [Container] = [Container]()
    var addedMeal : Meal? = nil
    var mealMakers: [String] = ["Caitlyn", "Heinrich"]
    
    var mealToEdit : Meal? = nil
    var mealToEditImage: UIImage? = nil
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealModel.delegate = self
        containerModel.delegate = self

        // Get all the current containers
        containerModel.downloadContainers(parameters: [String: String](), url: URLServices.GetContainers)
        
        //Set maximum date to today
        DateCreatedPicker.maximumDate = Date()
        
        
        
        //Add tap recognizer to close keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        //Load meal to edit if required
        if(mealToEdit != nil) {
            TitleField.text = "Edit Meal"
            MealNameField.text = mealToEdit!.name
            CaloriesField.text = String(mealToEdit!.calories)
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd"
            DateCreatedPicker.date = dateFormatter.date(from:mealToEdit!.date_created)!

            MealImage.image = mealToEditImage;
            if(MealImage.image != nil)
            {
                MealImageButton.setTitle("", for: UIControl.State.normal)
            }
            
            AddContainersButton.setTitle("Edit Containers", for: UIControl.State.normal)
        }
        else  {
            MealImageButton.setTitle("Add Image", for: UIControl.State.normal)
            AddContainersButton.setTitle("Add Containers", for: UIControl.State.normal)
        }
        
        CreatedByPicker.delegate = self
        CreatedByPicker.dataSource = self
        
        //Init the button
        SetButton()
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        MealImage.image = info[.originalImage] as? UIImage
        
        if(MealImage.image != nil)
        {
            MealImage.image = resizeImage(image: MealImage.image!, withPercentage: 0.2)
            MealImageButton.setTitle("", for: UIControl.State.normal)
        }
    }
    
    func resizeImage(image:UIImage, withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage {
        let canvas = CGSize(width: image.size.width * percentage, height: image.size.height * percentage)
        let format = image.imageRendererFormat
            format.opaque = isOpaque
            return UIGraphicsImageRenderer(size: canvas, format: format).image {
                _ in image.draw(in: CGRect(origin: .zero, size: canvas))
            }
        }
    
    @IBAction func AddImageButton(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func MealNameChanged(_ sender: Any) {
        SetButton()
    }
    
    @IBAction func CaloriesChanged(_ sender: Any) {
        SetButton()
    }
    
    func SetButton() {
        if MealNameField.text == "" {
            AddContainersButton.setTitle("Meal name required", for: UIControl.State.disabled)
            AddContainersButton.isEnabled = false;
            AddContainersButton.backgroundColor = UIColor.red
        }
        else if CaloriesField.text == "" {
            AddContainersButton.setTitle("Calories required", for: UIControl.State.disabled)
            AddContainersButton.isEnabled = false;
            AddContainersButton.backgroundColor = UIColor.red
        }
        else {
            AddContainersButton.isEnabled = true;
            AddContainersButton.backgroundColor = UIColor.green
        }
    }
    
    
    @IBAction func AddContainerPressed(_ sender: Any) {
        //Set loading screen
        setLoading(visible: true)

        //Convert date to string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: DateCreatedPicker.date)

        let createdBy = mealMakers[CreatedByPicker.selectedRow(inComponent: 0)]

        let param = ["name":MealNameField.text!, "calories":CaloriesField.text!, "date":dateStr, "created_by":createdBy]


        if(mealToEdit == nil) {
            mealModel.addMeal(parameters: param, image: MealImage.image)
        }
        else {
            mealModel.editMeal(id: mealToEdit!.id, parameters: param, image: MealImage.image)
        }
    }
    
    func setLoading(visible: Bool, callback_on_dismiss: (() -> Void)? = nil) {
        if(visible) {
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating();

            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
        }
        else {
            if let vc = self.presentedViewController, vc is UIAlertController {
                dismiss(animated: true, completion: callback_on_dismiss)
            }
        }
    }
    
    // Hide alert callbacks
    func couldNotAddMeal() {
        let alert = UIAlertController(title: "Could Not Add", message: "The meal could not be added", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func segueToAddContainers() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SequeToAddContainers", sender: nil)
        }
    }
    
    func mealIsCorrupted() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Meal is Corrupted", message: "The meal is not valid", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
           }
    }
    
    func didReceiveData(data: Any) {
        let datCont:[Container]? = (data as? [Container])
        let datMeal:Meal? = (data as? Meal)
        let addSucc:Bool? = (data as? Bool)
        
        if(datCont != nil) {
            existingContainers = datCont!
        }
        else if(addSucc != nil) {
            DispatchQueue.main.async {
                //Hide loading screen and present error
                self.setLoading(visible: false, callback_on_dismiss: self.couldNotAddMeal)
            }
        }
        else if(datMeal != nil) {
            addedMeal = datMeal!
            if(addedMeal!.id > 0)
            {
                //Hide loading screen and segue to add containers
                DispatchQueue.main.async { [unowned self] in
                    self.setLoading(visible:false, callback_on_dismiss: self.segueToAddContainers)
                }
            }
            else 
            {
                //Hide loading screen and segue to meal is corrupted alert
                DispatchQueue.main.async { [unowned self] in
                    self.setLoading(visible:false, callback_on_dismiss: self.mealIsCorrupted)
                }
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddMealContainersViewController
        {
            let vc = segue.destination as? AddMealContainersViewController
            vc?.selectedMeal = addedMeal!
            vc?.editMeal = mealToEdit != nil
        }
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)  {
            pickerLabel = UILabel()

            pickerLabel?.text = mealMakers[row]
            //pickerLabel?.font = UIFont(name: TitleLabel.font.familyName, size: 26)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        else  {
            pickerLabel!.text = mealMakers[row]
        }
        
        return pickerLabel!;
    }

}
