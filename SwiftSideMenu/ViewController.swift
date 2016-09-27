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
//import XCGLogger

class ViewController: UIViewController, ENSideMenuDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var geocoder: CLGeocoder!
    
    var destination: CLLocationCoordinate2D?
    var userLocation: CLLocation?
    
    var destinationAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ENSideMenu Delegate
        self.sideMenuController()?.sideMenu?.delegate = self
        
        // searchBarButton Delegate
        self.searchBarButtonItem.action = #selector(self.toggleDestinationTextField)
        self.searchBarButtonItem.target = self
        
        // hide keyboard
        self.hideKeyboardWhenTappedAround()

        // locationManager
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
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
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
    
    // MARK: - CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        print("locationManager: didUpdateLocations \(locations)")
        
        if self.userLocation == nil {
            self.userLocation = location
            self.setMapRegion(location: location)
        }
        
        // ???
//        var coordinates = [CLLocationCoordinate2D]()
//        for l in locations {
//            coordinates.append(l.coordinate)
//        }
//        
//        let polyline = MKPolyline(coordinates: coordinates, count: locations.count)
//        self.mapView.add(polyline)
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
        self.destination = self.mapView.centerCoordinate
        print("mapView: destination \(self.mapView.centerCoordinate)")
        self.setDestinationTextField(location: CLLocation(latitude: self.destination!.latitude, 
                                                          longitude: self.destination!.longitude))
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
                if placemark.subAdministrativeArea != nil {
                    self.destinationTextField.text = placemark.thoroughfare!
                    print("destinationTextField text: \(self.destinationTextField.text)")
                }
            }
            else {
                print("setDestinationTextField error: \(error)")
            }
        }
    }
    
    // MARK: - Tap Gestures
    func toggleDestinationTextField(){
        self.destinationTextField.isHidden = !self.destinationTextField.isHidden
        print("toggleDestinationTextField: isHidden \(self.destinationTextField.isHidden)")
    }
}

