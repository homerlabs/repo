//
//  HLAccessoryManager.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/3/26.
//

import UIKit
import HomeKit

class HLAccessoryManager: NSObject {
    /// The filtered list of services that the app displays.
    var cameraServices = [HMService]()    // These are called "accessories" in the UI.

    /// The home whose accessories the app displays.
    var home: HMHome? {
        didSet {
            home?.delegate = HomeStore.shared
            reloadData()
        }
    }
    
    /// Resets the list of Kilgo services from the currently set home.
    func reloadData() {
        cameraServices = []

        guard let home = home else { return }

/*        for accessory in home.accessories {
            accessory.delegate = HomeStore.shared
            print("\nreloadData-  accessory.name: \(accessory.name)  accessory.category: \(accessory.category)  accessory.manufacturer: \(String(describing: accessory.manufacturer))")
            print("\tservices.count: \(accessory.services.count)  accessory.services[0]: \(accessory.services[0])")

            for service in accessory.services.filter({ $0.isUserInteractive }) {
                cameraServices.append(service)
                print("-------reloadData-  service: \(service)")

                // Ask for notifications from any characteristics that support them.
                for characteristic in service.characteristics.filter({
                    $0.properties.contains(HMCharacteristicPropertySupportsEventNotification)
                }) {
                    characteristic.enableNotification(true) { _ in }
                }
            }
        }*/

        for accessory in home.accessories.filter({ $0.manufacturer == "Logitech" || $0.manufacturer == "Aqara" }) {
            accessory.delegate = HomeStore.shared
            print("\nreloadData-  accessory.name: \(accessory.name)  accessory.category: \(accessory.category)  accessory.manufacturer: \(String(describing: accessory.manufacturer))")

            for service in accessory.services.filter({ $0.isUserInteractive }) {
                cameraServices.append(service)
                print("\tservices.count: \(accessory.services.count)  accessory.services[0]: \(accessory.services[0])")

                // Ask for notifications from any characteristics that support them.
                for characteristic in service.characteristics.filter({
                    $0.properties.contains(HMCharacteristicPropertySupportsEventNotification)
                }) {
                    characteristic.enableNotification(true) { _ in }
                }
            }
        }
    }
    
    override init() {
        super.init()
        print("HLAccessoryManager.init")
        HomeStore.shared.homeManager.delegate = self
        HomeStore.shared.addHomeDelegate(self)
        HomeStore.shared.addAccessoryDelegate(self)
    //    homeManager = HMHomeManager()
   //     homeManager?.delegate = self
    }

    /*    /// Registers this view controller to receive various delegate callbacks.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeStore.shared.homeManager.delegate = self
        HomeStore.shared.addHomeDelegate(self)
        HomeStore.shared.addAccessoryDelegate(self)
    }*/
    
    /// Deregisters this view controller as various kinds of delegate.
    deinit {
        HomeStore.shared.homeManager.delegate = nil
        HomeStore.shared.removeHomeDelegate(self)
        HomeStore.shared.removeAccessoryDelegate(self)
    }
}
