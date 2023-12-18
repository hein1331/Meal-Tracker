//
//  MealStatModel.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 4/12/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import Foundation

struct MealStat: Decodable {
    var per_day: Float
    var run_out_date: String
    var meal_count: Int
    var oldest_meal: Int
    var average_meal_age: Int
    var popular_meal: Int
    var container_count: Int
}

class MealStatModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func getStats() {
        let request = networkModel.request(parameters: [String: String](), url: URLServices.GetStats)
        networkModel.response(request: request) { (data) in
            
            let model = try? JSONDecoder().decode(MealStat?.self, from: data) as MealStat?
            if(model == nil) {
                self.delegate?.didReceiveData(data: "MealStat Error")
            }
            else {
                self.delegate?.didReceiveData(data: model! as MealStat)
            }
        }
    }
}
