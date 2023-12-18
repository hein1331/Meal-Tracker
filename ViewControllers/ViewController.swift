//
//  ViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/13/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ViewController: UIViewController, Downloadable, UITableViewDelegate,  UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var TimeToEatButton: UIButton!
    @IBOutlet weak var MealTableView: UITableView!
    @IBOutlet weak var MealCountLabel: UILabel!
    @IBOutlet weak var MealsPerDayLabel: UILabel!
    @IBOutlet weak var RunOutDateLabel: UILabel!
    @IBOutlet weak var AverageAgeLabel: UILabel!
    @IBOutlet weak var OldestMealLabel: UILabel!
    @IBOutlet weak var MostPopularMeal: UILabel!

    var statModel : MealStatModel = MealStatModel()
    var mealsModel : MealModel = MealModel()
    let refreshControl = UIRefreshControl()
    var meals : [Meal] = []
    var allMeals : [Meal] = []
    
    var selectedMeal : Meal!
    
    var getStats : Bool = false
    var firstLoad : Bool = true
    

    @objc func refresh_callback(_ sender: AnyObject) {
        refresh()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mealsModel.delegate = self
        statModel.delegate = self
        
        MealTableView.delegate = self
        MealTableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(self.refresh_callback(_:)), for: .valueChanged)
        MealTableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    func refresh() {
        getStats = true
        mealsModel.downloadAllMeals()
        
        if(firstLoad) {
            getStats = false
            firstLoad = false
            do {
                usleep(500000)
            }
            statModel.getStats()
        }
    }
    
    
    func didReceiveData(data: Any) {
        let datMeal:[Meal]? = (data as? [Meal])
        let mealStat:MealStat? = (data as? MealStat)
        
        if(datMeal != nil) {
            DispatchQueue.main.async {
                self.setTable(listOfMeals: datMeal!)
                
                if(self.getStats)
                {
                    self.statModel.getStats()
                }
            }
        }
        else if(mealStat != nil) {
            let percent = String(Int(( Double(mealStat!.meal_count)/Double(mealStat!.container_count))*100.0))
            
            DispatchQueue.main.async {
                self.MealCountLabel.text = String(mealStat!.meal_count) + "/" + String(mealStat!.container_count) + " (" + percent + "%) Meals Left"
                self.MealsPerDayLabel.text = String(mealStat!.per_day) + " Meals Eaten Per Day"
                self.RunOutDateLabel.text = "Meals Will Run Out On: " + mealStat!.run_out_date
                self.AverageAgeLabel.text = "Average Meal Age: " + String(mealStat!.average_meal_age) + " days"
                
                let oldestMeal = self.allMeals.first(where: {$0.id == mealStat?.oldest_meal})
                if(oldestMeal != nil)
                {
                    self.OldestMealLabel.text = "Oldest: " + oldestMeal!.name
                }
                else
                {
                    self.OldestMealLabel.text = "Could not find oldest meal"
                }
                
                let mostPopulareMeal = self.allMeals.first(where: {$0.id == mealStat?.popular_meal})
                
                if(mostPopulareMeal != nil)
                {
                    self.MostPopularMeal.text = "Most Popular: " + mostPopulareMeal!.name
                }
                else
                {
                    self.MostPopularMeal.text = "Could not find most popular meal"
                }
                self.getStats = false
                self.refreshControl.endRefreshing()
            }
        }
        
    }
    
    
    func setTable(listOfMeals : [Meal])
    {
        allMeals = listOfMeals
        
        var newDict : [String : [Meal]] = [:]
        
        //Get all the distinct meal names
        let mealNames = Array(Set(listOfMeals.map { $0.name }))
        for mealName in mealNames {
            newDict[mealName] = listOfMeals.filter{ $0.name == mealName }
        }
        
        meals = listOfMeals.filter {$0.meal_count > 0}
        
        meals = meals.sorted {
            return $0.meal_count > $1.meal_count
        }
        
        MealTableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedMeal = meals[indexPath.row]
        
        performSegue(withIdentifier: "MealDetailSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        if meals.count == 0 {
            return cell
        }

        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.NameLabel.text = meal.name
        if meal.meal_count > 1 {
            cell.CountLabel.text = String(meal.meal_count) + " Meals"
        }
        else {
            cell.CountLabel.text = String(meal.meal_count) + " Meal"
        }
        cell.CalorieLabel.text = String(meal.calories) + " Calories"
        
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MealDetailViewController
        {
            let mvc = segue.destination as? MealDetailViewController
            mvc?.MealToShow = selectedMeal
        }
    }
    
    @IBAction func NameSortButtonPress(_ sender: Any) {
        meals = meals.sorted {
            return $0.name < $1.name
        }
        
        MealTableView.reloadData()
    }
    
    @IBAction func CountSortButtonPress(_ sender: Any) {
        meals = meals.sorted {
            return $0.meal_count > $1.meal_count
        }
        
        MealTableView.reloadData()
    }
    
    @IBAction func CalorieSortButtonPress(_ sender: Any) {
        meals = meals.sorted {
            return $0.calories < $1.calories
        }
        
        MealTableView.reloadData()
    }
    
}

