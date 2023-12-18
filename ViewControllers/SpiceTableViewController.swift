//
//  SpiceTableViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 1/19/22.
//  Copyright © 2022 Heinrich Enslin. All rights reserved.
//

import UIKit

class SpiceTableViewController: UIViewController, Downloadable, UITableViewDelegate,  UITableViewDataSource, UISearchBarDelegate {
    
    //MARK: Properties
    @IBOutlet weak var SpiceTable: UITableView!
    @IBOutlet weak var SpiceSearchBar: UISearchBar!
    

    var spiceModel : SpiceModel = SpiceModel()
    let refreshControl = UIRefreshControl()
    var spices : [Spice] = []
    var allSpices : [Spice] = []
    
    var selectedSpice : Spice!
    
    // Sorting booleans to allow sorting both directions
    var nameSortAcs : Bool = false
    var statusSortAcs : Bool = true


    @objc func refresh_callback(_ sender: AnyObject) {
        refresh()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        spiceModel.delegate = self
        
        SpiceTable.delegate = self
        SpiceTable.dataSource = self
        SpiceSearchBar.delegate = self
        
        refreshControl.addTarget(self, action: #selector(self.refresh_callback(_:)), for: .valueChanged)
        SpiceTable.addSubview(refreshControl) // not required when using UITableViewController
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    func refresh() {
        spiceModel.downloadAllSpices()
    }
    
    
    func didReceiveData(data: Any) {
        let datSpices:[Spice]? = (data as? [Spice])
        let delSucc:Bool? = (data as? Bool)
        
        if(datSpices != nil) {
            DispatchQueue.main.async {
                self.setTable(listOfSpices: datSpices!)
                self.refreshControl.endRefreshing()
            }
        }
        else if(delSucc != nil ) {
            if(delSucc!) {
                refresh()
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Could Not Delete", message: "The spice could not be deleted", preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
    
    
    func setTable(listOfSpices : [Spice])
    {
        allSpices = listOfSpices
        
        var newDict : [String : [Spice]] = [:]
        
        //Get all the distinct meal names
        let spiceNames = Array(Set(listOfSpices.map { $0.decoded_name }))
        for spiceName in spiceNames {
            newDict[spiceName] = listOfSpices.filter{ $0.decoded_name == spiceName }
        }
        
        spices = listOfSpices.sorted {
            return $0.decoded_name < $1.decoded_name
        }
        
        SpiceTable.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedSpice = spices[indexPath.row]
        
        //performSegue(withIdentifier: "MealDetailSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SpiceTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SpiceTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SpiceTableViewCell.")
        }

        // Fetches the appropriate meal for the data source layout.
        let spice = spices[indexPath.row]
        
        cell.SpiceNameLabel.text = spice.decoded_name.replacingOccurrences(of: "_", with: " ")
        cell.SpiceStatusLabel.text = spice.status
        cell.spice = spice
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          let cell = tableView.cellForRow(at: indexPath) as! SpiceTableViewCell
          let param = ["name":cell.spice!.decoded_name] as [String : Any]
          
          // Check to see if refill is present
          let refreshAlert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete " + cell.spice!.decoded_name.replacingOccurrences(of: "_", with: " ") + "?", preferredStyle: UIAlertController.Style.alert)

          refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
              self.spiceModel.deleteSpice(parameters: param as [String : Any])
          }))

          refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
          }))

          present(refreshAlert, animated: true, completion: nil)
          
          
      }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.destination is MealDetailViewController
//        {
//            let mvc = segue.destination as? MealDetailViewController
//            mvc?.MealToShow = selectedMeal
//        }
    }
    
    @IBAction func NameSortButtonPress(_ sender: Any) {
        spices = spices.sorted {
            if(nameSortAcs) {
                return $0.decoded_name < $1.decoded_name
            }
            else {
                return $0.decoded_name > $1.decoded_name
            }
        }
        
        nameSortAcs = !nameSortAcs
        statusSortAcs = true
        
        SpiceTable.reloadData()
    }
    
    @IBAction func StatusSortButtonPress(_ sender: Any) {
        spices = spices.sorted {
            if(statusSortAcs) {
                return $0.status < $1.status
            }
            else {
                return $0.status > $1.status
            }
        }
        
        statusSortAcs = !statusSortAcs
        nameSortAcs = true
        
        SpiceTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        spices = allSpices.sorted {
            return $0.decoded_name < $1.decoded_name
        }
        
        if(searchText != "") {
            spices = spices.filter{ $0.decoded_name.lowercased().contains(searchText.lowercased()) }
        }
        
        SpiceTable.reloadData()
            
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.SpiceSearchBar.endEditing(true)
    }

    
}
