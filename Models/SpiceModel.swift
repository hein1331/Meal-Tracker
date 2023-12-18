//
//  MealModel.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 01/18/22.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import Foundation
import UIKit

struct Spice: Decodable {
    var decoded_name: String {
        get {
            return name.replacingOccurrences(of: "\\", with: "");
        }
        set {
            name = newValue.replacingOccurrences(of: "\\", with: "");
        }
    }
    private var name: String
    var date_filled: String
    var status: String
    var leftover: Int
}

class SpiceModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func addSpice(parameters: [String: Any]) {
        let request = networkModel.request(parameters: parameters, url: URLServices.AddSpice)
        networkModel.response(request: request) { (data) in
            let str = String(bytes: data, encoding: .utf8)
            let succ = str?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
    
    
    func editSpice(parameters: [String: Any]) {
        let request = networkModel.request(parameters: parameters, url: URLServices.EditSpice)
        networkModel.response(request: request) { (data) in
            let str = String(bytes: data, encoding: .utf8)
            let succ = str?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
    
    
//    func editMeal(id: Int, parameters: [String: Any], image: UIImage?) {
//
//
//        var paramID = parameters
//        paramID["id"] = id
//
//        let request = networkModel.request(parameters: paramID, url: URLServices.EditMeal, image: image)
//        networkModel.response(request: request) { (data) in
//            let model = try? JSONDecoder().decode(Meal?.self, from: data) as Meal?
//            if(model == nil) {
//                //var respStr = String(bytes: data, encoding: .utf8)
//                self.delegate?.didReceiveData(data: false)
//            }
//            else {
//                self.delegate?.didReceiveData(data: (model! as Meal))
//            }
//        }
//    }
    
        
    func downloadAllSpices() {
        let request = networkModel.request(parameters: [String: String](), url: URLServices.GetSpices)
        networkModel.response(request: request) { (data) in
            let model = try! JSONDecoder().decode([Spice]?.self, from: data) as [Spice]?
            self.delegate?.didReceiveData(data: model! as [Spice])
        }
    }
    
    
    func deleteSpice(parameters: [String: Any]) {
        let request = networkModel.request(parameters: parameters, url: URLServices.DeleteSpice)
        networkModel.response(request: request) { (data) in
            let str = String(bytes: data, encoding: .utf8)
            let succ = str?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
}
