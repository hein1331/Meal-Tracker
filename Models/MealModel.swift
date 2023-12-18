//
//  MealModel.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/14/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import Foundation
import UIKit

struct Meal: Decodable {
    var id: Int
    var name: String
    var calories: Int
    var date_created: String
    var date_finished: String
    var meal_count: Int
    var created_by: String
}

class MealModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func getMealInContainer(contID : Int) {
        let request = networkModel.request(parameters: ["cont_id" : String(contID)], url: URLServices.GetMealInContainer)
        networkModel.response(request: request) { (data) in
            
            let model = try? JSONDecoder().decode(Meal?.self, from: data) as Meal?
            if(model == nil) {
                self.delegate?.didReceiveData(data: "NoMealInContainer")
            }
            else {
                self.delegate?.didReceiveData(data: model! as Meal)
            }
        }
    }
    
    
    func eatMealInContainer(contID : Int)
    {
        let request = networkModel.request(parameters: ["cont_id" : String(contID)], url: URLServices.EatMeal)
        networkModel.response(request: request) { (data) in
            let respStr = String(bytes: data, encoding: .utf8)
            let succ = respStr?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
    
    
    func addMeal(parameters: [String: Any], image: UIImage?) {
        let request = networkModel.request(parameters: parameters, url: URLServices.AddMeal, image: image)
        networkModel.response(request: request) { (data) in
            let model = try? JSONDecoder().decode(Meal?.self, from: data) as Meal?
            if(model == nil) {
                self.delegate?.didReceiveData(data: false)
            }
            else {
                self.delegate?.didReceiveData(data: (model! as Meal))
            }
        }
    }
    
    
    func editMeal(id: Int, parameters: [String: Any], image: UIImage?) {
        
        
        var paramID = parameters
        paramID["id"] = id
        
        let request = networkModel.request(parameters: paramID, url: URLServices.EditMeal, image: image)
        networkModel.response(request: request) { (data) in
            let model = try? JSONDecoder().decode(Meal?.self, from: data) as Meal?
            if(model == nil) {
                //var respStr = String(bytes: data, encoding: .utf8)
                self.delegate?.didReceiveData(data: false)
            }
            else {
                self.delegate?.didReceiveData(data: (model! as Meal))
            }
        }
    }
    
    
    func getImage(mealID : Int)
    {
        let request = networkModel.request(parameters: ["meal_id" : String(mealID)], url: URLServices.GetMealImage)
        networkModel.response(request: request) { (data) in
            let image = UIImage(data: data)
            self.delegate?.didReceiveData(data: image ?? UIImage(named: "NoImage.png") as Any)
        }
    }

    
    func downloadMeal(parameters: [String: Any], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        networkModel.response(request: request) { (data) in
            let model = try! JSONDecoder().decode(Meal?.self, from: data) as Meal?
            self.delegate?.didReceiveData(data: model! as Meal)
        }
    }
    
    func updateMeal(parameters: [String: Any], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        networkModel.response(request: request) { (data) in
            let respStr = String(bytes: data, encoding: .utf8)
            let succ = respStr?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
        
    func downloadAllMeals() {
        let request = networkModel.request(parameters: [String: String](), url: URLServices.GetMeals)
        networkModel.response(request: request) { (data) in
            let model = try! JSONDecoder().decode([Meal]?.self, from: data) as [Meal]?
            self.delegate?.didReceiveData(data: model! as [Meal])
        }
    }
}
