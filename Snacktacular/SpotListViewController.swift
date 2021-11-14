//
//  SpotListViewController.swift
//  Snacktacular
//
//  Created by Mohsin Braer on 10/31/21.
//

import UIKit
import CoreLocation

class SpotListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    

    
    //var spots = ["Island Creek Oysters" , "El Pelon", "Shake Shack", "Pino's Pizza"]
    var spots: Spots!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spots = Spots()
        tableView.delegate = self
        tableView.dataSource = self
        
        configureSegmentedControl()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLocation()
        spots.loadData {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()

        }
        
    }
    

    
    func configureSegmentedControl(){
        
        let orangeFontColor = [NSAttributedString.Key.foregroundColor : UIColor(named: "PrimaryColor") ?? UIColor.orange]
        let whiteFontColor = [NSAttributedString.Key.foregroundColor : UIColor.white]
        sortSegmentedControl.setTitleTextAttributes(orangeFontColor, for: .selected)
        sortSegmentedControl.setTitleTextAttributes(whiteFontColor, for: .normal)

        
        sortSegmentedControl.layer.borderColor = UIColor.white.cgColor
        sortSegmentedControl.layer.borderWidth = 1.0
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! SpotDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.spot = spots.spotArray[selectedIndexPath.row]
        }
    }
    
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
       sortBasedOnSegmentPressed()
    }
    
    func sortBasedOnSegmentPressed()
    {
        switch sortSegmentedControl.selectedSegmentIndex{
        case 0:
            spots.spotArray.sort(by: {$0.name < $1.name})
            tableView.reloadData()
        case 1:
            spots.spotArray.sort(by: {$0.location.distance(from: currentLocation) < $1.location.distance(from: currentLocation)})
        case 2:
            print("TODO")
        default:
            print("HEY, you shouldn't have gotten here. Check out the segmented control for error")
        }
    }
    
}



extension SpotListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpotTableViewCell
        if let currentLocation = currentLocation {
            cell.currentLocation = currentLocation
        }
        //cell.nameLabel?.text = spots.spotArray[indexPath.row].name
        cell.spot = spots.spotArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension SpotListViewController: CLLocationManagerDelegate{
    
    func getLocation(){
        //Will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthenticationStatus(status: status)
    }
    
    func handleAuthenticationStatus(status: CLAuthorizationStatus){
        switch status{
        
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location services denied", message: "Parental controls may be restricting location use")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select settigns below")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER ALERT: Unknown case of status in handleAuthenticationStatus\(status)")
        }
        
    }
    
    func showAlertToPrivacySettings(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else{
            print("Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last ?? CLLocation()
        print("Current Location: (\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude))")
        sortBasedOnSegmentPressed()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: Could not get location (didFailWithError)")
    }
    
}
