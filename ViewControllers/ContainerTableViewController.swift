//
//  ContainerTableViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/14/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit

class ContainerTableViewController: UITableViewController, Downloadable {

    var model: ContainerModel = ContainerModel()
    var existingContainers: [Container] = [Container]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
        model.delegate = self;
        
        reloadTableView()
        
    }
    
    func reloadTableView() {
        model.downloadContainers(parameters: [String: String](), url: URLServices.GetContainers)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return existingContainers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ContainerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContainerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ContainerTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let cont = existingContainers[indexPath.row]
        
        cell.IDLabel.text = String(cont.id)
        cell.TypeLabel.text = cont.type
        
        if(cont.filled) {
            cell.FilledLabel.text = "Filled"
        }
        else {
            cell.FilledLabel.text = "Empty"
        }

        return cell
    }
    
    func didReceiveData(data: Any) {
        let datCont:[Container]? = (data as? [Container])
        if(datCont != nil) {
            existingContainers = datCont!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
