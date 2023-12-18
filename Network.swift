//
//  Network.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/14/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import Foundation
import UIKit

protocol Downloadable: AnyObject {
    func didReceiveData(data: Any)
}

enum URLServices {
    static let serverIP = "http://caven.us/"; 
    // change to your PHP script in your own server.
    static let GetMeal: String = serverIP + "meals/GetMeal.php"
    static let GetMeals: String = serverIP + "meals/GetMeals.php"
    static let GetMealInContainer: String = serverIP + "meals/GetMealInContainer.php"
    static let OverwriteMealInContainer: String = serverIP + "mealcontainers/OverwriteMealInContainer.php"
    static let ClearMealInContainer: String = serverIP + "mealcontainers/ClearMealInContainer.php"
    static let EatMeal: String = serverIP + "mealcontainers/EatMeal.php"
    static let AddMeal: String = serverIP + "meals/AddMeal.php"
    static let EditMeal: String = serverIP + "meals/EditMeal.php"
    static let AddMealToContainer: String = serverIP + "mealcontainers/AddMealToContainer.php"
    static let AddContainer: String = serverIP + "containers/AddContainer.php"
    static let GetContainers: String = serverIP + "containers/GetContainers.php"
    static let GetStats: String = serverIP + "meals/GetMealStats.php"
    static let GetMealImage: String = serverIP + "meals/GetMealImage.php"
    static let GetSpices: String = serverIP + "spices/GetSpices.php"
    static let AddSpice: String = serverIP + "spices/AddSpice.php"
    static let DeleteSpice: String = serverIP + "spices/DeleteSpice.php"
    static let EditSpice: String = serverIP + "spices/EditSpice.php"
}

class Network{
    func request(parameters: [String: Any], url: String, image: UIImage? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        
        if(image == nil)
        {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = parameters.percentEscaped().data(using: .utf8)
        }
        else
        {
            let boundary = generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let imageData = image!.jpegData(compressionQuality: 1)
            request.httpBody = imageBody(parameters: parameters, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        }
        return request
    }
    
    func response(request: URLRequest, completionBlock: @escaping (Data) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {   // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            guard (200 ... 299) ~= response.statusCode else { //check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            // data will be available for other models that implements the block
            completionBlock(data);
        }
        task.resume()
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func imageBody(parameters: [String: Any]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
       
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString(string: "\r\n")
        
    
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body as Data
    }

    
    
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension NSMutableData {

     func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
         append(data!)
     }
}
