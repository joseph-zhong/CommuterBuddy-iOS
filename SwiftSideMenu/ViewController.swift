//
//  ViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 03.08.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
//import XCGLogger

class ViewController: UIViewController, ENSideMenuDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var unitLabel: UILabel!
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    var geocoder: CLGeocoder!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ENSideMenu Delegate
        self.sideMenuController()?.sideMenu?.delegate = self
        
        // searchBarButton gestures
        self.searchBarButtonItem.action = #selector(self.toggleDestinationTextField)
        self.searchBarButtonItem.target = self
        
        // distanceSlider gestures
//        self.distanceSlider.addTarget(self, action: #selector(self.changeLabelValue), for: UIControlEvents.valueChanged)
        
        // alarmSwitch gesture
        self.alarmSwitch.addTarget(self, action: #selector(self.toggleAlarm), for: UIControlEvents.valueChanged)
        
        // hide keyboard
        self.hideKeyboardWhenTappedAround()

        // locationManager
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()          
        }
        else {
            // TODO: do something here
        }
        
        // geocoder
        self.geocoder = CLGeocoder()        
        
        // map
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.showsPointsOfInterest = true
        self.mapView.mapType = MKMapType.standard
        self.mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func toggleSideMenu(_ sender: AnyObject) {
        self.toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("ViewController: sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("ViewController: sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("ViewController: sideMenuShouldOpenSideMenu")
        return true
    }
    
    func sideMenuDidClose() {
        print("ViewController: sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("ViewController: sideMenuDidOpen")
    }
    
    // MARK: - CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        // first time retrieving location
        if userLocation.coordinate.latitude == 47.606200001 
                && userLocation.coordinate.longitude == 122.332100001 {
            self.setMapRegion(location: location)
        }
        
        userLocation = location
        print("locationManager: didUpdateLocations \(locations)")
        
        if destination != nil {
            distanceFromDest = Float(userLocation.distance(from: destination!))
            self.changeLabelValue(distance: metersToMiles(meters: distanceFromDest!))
        }
        
        if UIApplication.shared.applicationState == .background {
            print("locationManager: didUpdateLocations background userLocation \(userLocation)")
            //  check distance and region entering
            //  draw overlay
            // end loop sound alarm
            if self.alarmSwitch.isOn && distanceFromDest! <= thresholdDist! {
                //  check distance and region entering
                
            }
            
        }
        else if UIApplication.shared.applicationState == .active {
            print("locationManager: didUpdateLocations active userLocation \(userLocation)")
        }
    }
    
    func fireNotification() -> Void { 
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Destination Reached!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "", arguments: nil)
        content.sound = UNNotificationSound.default()
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
//        
//        
//        let notificationContent = UNNotificationContent()
////        notificationContent.title = "Destination Reached"
////        notificationContent.sound = 
//        let notificationRequest = UNNotificationRequest(identifier: "Notification", 
//                                                        content: notificationContent, 
//                                                        trigger: UNNotificationTrigger?)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        print("locationManager: didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, 
                         didUpdateHeading newHeading: CLHeading) {
        print("locationManager: didUpdateHeading \(newHeading)")
    }
    
    func locationManager(_ manager: CLLocationManager, 
                         didStartMonitoringFor region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("locationManager: didEnterRegion \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, 
                         monitoringDidFailFor region: CLRegion?, 
                         withError error: Error){
        
    }
    
    func locationManager(_ manager: CLLocationManager, 
                         didDetermineState state: CLRegionState, 
                         for region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, 
                         didExitRegion region: CLRegion) {
        
    }
    
    // MARK: - MKMap Delegate
    
    func mapView(_ mapView: MKMapView, 
                 regionWillChangeAnimated animated: Bool) {
        print("mapView: regionWillChangeAnimated \(animated)")
    }
    
    func mapView(_ mapView: MKMapView, 
                 regionDidChangeAnimated animated: Bool) {
        print("mapView: regionDidChangeAnimated \(animated)")
        
        // update destination
        destination = CLLocation(latitude: self.mapView.centerCoordinate.latitude, 
                                      longitude: self.mapView.centerCoordinate.longitude)
        distanceFromDest = Float(userLocation.distance(from: destination!))
        print("mapView: destination \(destination)")
        self.setDestinationTextField(location: destination!)
        self.changeLabelValue(distance: metersToMiles(meters: distanceFromDest!))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.blue
            pr.lineWidth = 3
            return pr
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        
    }
    
    // MARK: - Map Functionality
    func setMapRegion(location: CLLocation) {
        // set region 
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Geocoding functionality
    func setDestinationTextField(location: CLLocation) {
        self.geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: Error?) in
            if error == nil && placemarks != nil && (placemarks?.count)! > 0 {
                print("setDestinationTextField placemarks: \(placemarks)")
                let placemark = placemarks![0]
                if placemark.thoroughfare != nil {
                    self.destinationTextField.text = placemark.thoroughfare!
                }
                else if placemark.subThoroughfare != nil {
                    self.destinationTextField.text = placemark.subThoroughfare!
                }
                else {
                    self.destinationTextField.text = ""
                }
                print("destinationTextField text: \(self.destinationTextField.text)")
                self.changeLabelValue(distance: metersToMiles(meters: Float(userLocation.distance(from: location)))) 
            }
            else {
                print("setDestinationTextField error: \(error)")
            }
        }
    }
    
    // MARK: - Gesture Targets
    func toggleDestinationTextField(){
        self.destinationTextField.becomeFirstResponder()
        print("toggleDestinationTextField: focus \(self.destinationTextField.isFocused)")
    }
    
    func toggleAlarm() {
        print("toggleAlarm: isOn \(self.alarmSwitch.isOn)")
        
        if self.alarmSwitch.isOn {
            self.distanceLabel.textColor = UIColor.blue
        }
        else {
            self.distanceLabel.textColor = UIColor.black
        }
    }
    
    func changeLabelValue(distance: Float) {
        // update value 
        self.distanceLabel.text = String(format: "%.2f", distance)
        print("changeLabelValue: text \(self.distanceLabel.text)")
        
        
    }
}

