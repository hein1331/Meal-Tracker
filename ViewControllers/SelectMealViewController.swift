//
//  SelectMealViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/15/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit
import AVFoundation

class SelectMealViewController: QRScanViewController, Downloadable {

    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var FoodLabel: UILabel!
    @IBOutlet weak var EatMe: UIButton!
    @IBOutlet weak var MealImage: UIImageView!
    
    let model = MealModel()
    
    var contID: Int? = -1
    var selectedMeal: Meal? = nil
    var closing = false;
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        model.delegate = self
        
        self.view.bringSubviewToFront(TitleLabel)
        self.view.bringSubviewToFront(FoodLabel)
        self.view.bringSubviewToFront(EatMe)
        self.view.sendSubviewToBack(MealImage)
        
        TitleLabel.attributedText = NSMutableAttributedString(string: "Scan a Container", attributes: self.defaultTextAttributes)
        
        found(code: "0")
    }

    override func found(code: String?) {
        if(closing)
        {
            return
        }
        
        //Convert to ID
        let newCode = Int(code!)
        
        //Check to make sure it is a new code
        if(contID != newCode)
        {
            contID = newCode;
            //Send image to back
            self.view.sendSubviewToBack(MealImage)
            
            if(contID == nil)
            {
                FoodLabel.attributedText = NSMutableAttributedString(string: "Not a Valid QR Code",
                attributes: errorTextAttributes)
                EatMe.isHidden = true
            }
            else if(contID == 0) {
                FoodLabel.attributedText = NSMutableAttributedString(string: "Please scan a QR Code",
                attributes: defaultTextAttributes)
                EatMe.isHidden = true
            }
                //Ensure the ID is within range
            else if (contID! > 0 && contID! < 200)
            {
                //Check if there is a meal in the container
                model.getMealInContainer(contID: contID!)
            }
            else
            {
                FoodLabel.attributedText = NSMutableAttributedString(string: "Not a Valid Container",
                attributes: errorTextAttributes)
                EatMe.isHidden = true
            }
            
            setFoodLabelSize()
        }
    }
    
    @IBAction func EatMePressed(_ sender: Any) {
        EatMe.isHidden = true
        closing = true
        self.playSound()
        model.eatMealInContainer(contID: contID!)
    }
    
    func didReceiveData(data: Any) {
        
        //Convert data to a meal list if possible
        let datMeal:Meal? = (data as? Meal)
        
        //Convert data to a bool if possible
        let datBool:Bool? = (data as? Bool)
        
        //Convert data to a string if possible
        let datString:String? = (data as? String)
        
        //Convert data to image if possible
        let recImage:UIImage? = (data as? UIImage)

        //If the it is a list of meals it means that it is from the init and that it contains all the existing meals
        if(datMeal != nil) {
            self.selectedMeal = datMeal!
            model.getImage(mealID: selectedMeal!.id)
            DispatchQueue.main.async {
                //Convert to date and change format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: self.selectedMeal!.date_created)
                dateFormatter.dateFormat = "MMMM d, yyyy"
                let dateStr = dateFormatter.string(from: date!)
                let calStr = String(self.selectedMeal!.calories)
                let mealName = self.selectedMeal!.name
                
                let str = mealName + "\nCalories: " + calStr + "\nCooked: " + dateStr
                     
                self.FoodLabel.attributedText = NSMutableAttributedString(string: str, attributes: self.goodTextAttributes)
                
                self.EatMe.isHidden = false
 
                self.setFoodLabelSize()
            }
        }
        else if recImage != nil {
            DispatchQueue.main.async {
                self.MealImage.image = recImage
                self.view.bringSubviewToFront(self.MealImage)
            }
        }
        //If it is a string.It contains a message
        else if(datString != nil) {
            //We tried to add a meal. A request for the meal in the container was sent. No meal existed. Can add
            if(datString == "NoMealInContainer") {
                DispatchQueue.main.async {
                    self.FoodLabel.attributedText = NSMutableAttributedString(string: "Empty Container", attributes: self.errorTextAttributes)
                    
                    self.EatMe.isHidden = true
                }
            }
        }
            
        //If it is a bool it means that the container add request has returned
        else if (datBool != nil) {
            DispatchQueue.main.async {
                if(datBool!) {
                    self.FoodLabel.attributedText = NSMutableAttributedString(string: "Eaten!", attributes: self.goodTextAttributes)
                    self.delayedClose()
                }
                else {
                    let alert = UIAlertController(title: "Could Not Eat", message: "The container could not be eaten", preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.delayedClose()
                }
            }
        }
        
    }
    
    func delayedClose() {
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    func setFoodLabelSize() {
        FoodLabel.sizeToFit()
        var myFrame = FoodLabel.frame
        myFrame = CGRect(x: myFrame.minX, y: myFrame.minY, width: 343, height: myFrame.height)
        FoodLabel.frame = myFrame
    }
    
    
    

    func playSound() {
        guard let url = Bundle.main.url(forResource: "mealEaten", withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

}
