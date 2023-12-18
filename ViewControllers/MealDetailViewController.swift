//
//  MealDetailViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 4/9/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit

class MealDetailViewController: UIViewController, Downloadable {
    
    

    
    
    var MealToShow: Meal!
    var meal:MealModel = MealModel()
    
    @IBOutlet weak var MealLabel: UILabel!
    
    @IBOutlet weak var MealImage: UIImageView!
    @IBOutlet weak var CountLabel: UILabel!
    @IBOutlet weak var CalorieLabel: UILabel!
    @IBOutlet weak var DateCreatedLabel: UILabel!
    @IBOutlet weak var CreatedByLabel: UILabel!
    @IBOutlet weak var ImageLoadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meal.delegate = self
        
        meal.getImage(mealID: MealToShow.id)
        
        MealImage.isHidden = true
        MealImage.image = UIImage(named: "NoImage.png")
        ImageLoadingIndicator.startAnimating()
        ImageLoadingIndicator.hidesWhenStopped = true
        
        MealLabel.text = MealToShow.name

        if MealToShow.meal_count > 1 {
            CountLabel.text = "Meal Count: " + String(MealToShow.meal_count) + " Meals"
        }
        else {
            CountLabel.text = "Meal Count: " + String(MealToShow.meal_count) + " Meal"
        }
        CalorieLabel.text = "Calories: " + String(MealToShow.calories) + " Calories"
        
        //Convert to date and change format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: MealToShow.date_created)
        dateFormatter.dateFormat = "MMMM d, yyyy"
        DateCreatedLabel.text = "Date Created: " + dateFormatter.string(from: date!)
        
        CreatedByLabel.text = "Created By: " + MealToShow.created_by
    }
    
    
    func didReceiveData(data: Any) {
        //Convert data to a string if possible
        let recImage:UIImage? = (data as? UIImage)
        
        let imageFailed:Bool? = data as? Bool
        
        if recImage != nil {
            DispatchQueue.main.async {
                self.MealImage.image = recImage
                self.ImageLoadingIndicator.stopAnimating()
                self.MealImage.isHidden = false
            }
        }
        else if imageFailed != nil {
            DispatchQueue.main.async {
                self.ImageLoadingIndicator.stopAnimating()
                self.MealImage.isHidden = false
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddMealViewController
        {
            let vc = segue.destination as? AddMealViewController
            vc?.mealToEdit = MealToShow
            vc?.mealToEditImage = MealImage.image
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
