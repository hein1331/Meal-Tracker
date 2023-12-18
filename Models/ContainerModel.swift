//
//  ContainerModel.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/14/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import Foundation

struct Container: Decodable {
    var id: Int
    var type: String
    var filled: Bool
}

class ContainerModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    
    func overwriteMealInContainer(parameters: [String: Any]) {
        let request = networkModel.request(parameters: parameters, url: URLServices.OverwriteMealInContainer)
        networkModel.response(request: request) { (data) in
            let succ = String(bytes: data, encoding: .utf8)?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
    
    
    func clearMealInContainer(parameters: [String: Any]) {
        let request = networkModel.request(parameters: parameters, url: URLServices.ClearMealInContainer)
        networkModel.response(request: request) { (data) in
            let respStr = String(bytes: data, encoding: .utf8)
            let succ = respStr?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
    
    
    func addMealToContainer(parameters: [String: Any]) {
        let request = networkModel.request(parameters: parameters, url: URLServices.AddMealToContainer)
        networkModel.response(request: request) { (data) in
            let succ = String(bytes: data, encoding: .utf8)?.contains("Success")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
    
    
    func addContainer(parameters: [String: Any]) {
        let request = networkModel.request(parameters: parameters, url: URLServices.AddContainer)
        networkModel.response(request: request) { (data) in
            let succ = String(bytes: data, encoding: .utf8)?.contains("Succesfully Added")
            self.delegate?.didReceiveData(data: succ ?? false)
        }
    }
    
    func downloadContainers(parameters: [String: Any], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        networkModel.response(request: request) { (data) in
            let model = try! JSONDecoder().decode([Container]?.self, from: data) as [Container]?
            if(model != nil) {
                self.delegate?.didReceiveData(data: model! as [Container])
            }
            
        }
    }
}
