//
//  LocationSearchResultsTable.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-13.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    
    var chooseLocationVC: ChooseLocationViewController?
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.tableFooterView = UIView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.locationSearchResultCellIdentifier)!
        
        let selectedItem = matchingItems[indexPath.row].placemark
        
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = Helpers.parseAddress(for: selectedItem)
        
        cell.textLabel?.textColor = K.Colors.goldenThemeColorLight
        cell.detailTextLabel?.textColor = K.Colors.goldenThemeColorDark
        
        return cell
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        chooseLocationVC?.resultSearchController?.isActive = false
        
        let location = matchingItems[indexPath.row]
        
        // if all the attributes of the location are present
        if location.placemark.subThoroughfare != nil && location.placemark.thoroughfare != nil && location.placemark.locality != nil && location.placemark.administrativeArea != nil && location.placemark.postalCode != nil {
            
			chooseLocationVC?.setLocation(location: location)
			chooseLocationVC?.doneButton.isHidden = false
			
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.chooseLocationVC?.navigationController?.popViewController(animated: true)
//				self.chooseLocationVC?.businessRegisterVC?.setLocation(location: self.matchingItems[indexPath.row])
//				self.chooseLocationVC?.businessRegisterVC?.isNewLocation = true
//            }
            
        } else {
            Alerts.showNoOptionAlert(title: "An error occurred when selecting this location", message: "Try typing in the full address instead of the location name", sender: chooseLocationVC!)
        }
        
    }
}


extension LocationSearchTable : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
