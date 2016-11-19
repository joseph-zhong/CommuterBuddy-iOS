//
//  ViewController2.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 01.02.15.
//  Copyright (c) 2015 Evgeny Nazarov. All rights reserved.
//

import UIKit

class ViewController2: UIViewController, ENSideMenuDelegate {

    @IBOutlet weak var thresholdDistanceSlider: UISlider!
    @IBOutlet weak var thresholdDistanceLabel: UILabel!
    @IBOutlet weak var thresholdDistanceUnitLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Move next line to viewWillAppear functon if you store your view controllers
        self.sideMenuController()?.sideMenu?.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("ViewController2: sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("ViewController2: sideMenuWillClose")
    }
    
    func sideMenuDidClose() {
        print("ViewController2: sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("ViewController2: sideMenuDidOpen")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("ViewController2: sideMenuShouldOpenSideMenu")
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
