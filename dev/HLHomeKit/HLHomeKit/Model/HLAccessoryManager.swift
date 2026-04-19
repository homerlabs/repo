//
//  HLAccessoryManager.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/3/26.
//

import UIKit
import HomeKit

@Observable class HLAccessoryManager: NSObject {
    static let shared = HLAccessoryManager()
    
    var cameraServices = [HMService]()
//    var cameraProfiles: [HMCameraProfile] = []

    /// The filtered list of services that the app displays.
    var homeAccessories = [HMAccessory]()    // These are called "accessories" in the UI.
 //   var powerSwitches = [HLPowerSwitchModel]()    // These are called "accessories" in the UI.
    var cameras = [HLCameraModel]()    // These are called "accessories" in the UI.
//    let powerSwitchViewModel = HLPowerSwitchViewModel.shared
    var currentAccessory : HMAccessory?


    /// The home whose accessories the app displays.
    var home: HMHome? {
        didSet {
            home?.delegate = HomeStore.shared
            reloadData()
        }
    }
    
    func toggleSwitch(_ accessory: HMAccessory) {
        print("HLAccessoryManager.toggleSwitch-  accessory.name.name: \(accessory.name)")
        let services = accessory.services
        print("currentAccessory?.name: \(currentAccessory?.name ?? "?")   services: \(services)")
    }
    
    /// Resets the list of Kilgo services from the currently set home.
    func reloadData() {
        print("HLAccessoryManager.reloadData")
        
        homeAccessories.removeAll()

        guard let home = home else { return }
        let switchTypeaAccessories = home.accessories.filter({ $0.category.categoryType == HMAccessoryCategoryTypeOutlet })
        //  collect all the HMAccessoryCategoryTypeOutlet accessories
        
//        powerSwitchViewModel.switchAccessories.removeAll()

        for accessory in switchTypeaAccessories {
            accessory.delegate = HomeStore.shared
            homeAccessories.append(accessory)
//            powerSwitchViewModel.switchAccessories.append(accessory)
            print("found accessory.name: \(accessory.name)  accessory.category.categoryType: \(accessory.category.categoryType)  accessory.manufacturer: \(String(describing: accessory.manufacturer))")

/*            print("\taccessory: \(accessory.manufacturer ?? "none") \tname: \(accessory.name)   category: \(accessory.category)")
            print("\tHMServiceTypeSwitch: \(HMServiceTypeSwitch)")
            print("\tHMServiceTypeOutlet: \(HMServiceTypeOutlet)")
            for index in 0..<accessory.services.count {
                print("\tserviceType: \(accessory.services[index].serviceType)")
            }*/
            
            for accessory in home.accessories.filter({ $0.manufacturer == "Logitech" || $0.manufacturer == "Aqara" }) {
                accessory.delegate = HomeStore.shared
                homeAccessories.append(accessory)
                print("found accessory.name: \(accessory.name)  accessory.category.categoryType: \(accessory.category.categoryType)  accessory.manufacturer: \(String(describing: accessory.manufacturer))")

                for service in accessory.services.filter({ $0.isUserInteractive }) {
                    cameraServices.append(service)
           //         print("\tservice.name: \(service.name)  accessory.service.serviceType: \(service.serviceType)  characteristics.count: \(service.characteristics.count)")

                    // Ask for notifications from any characteristics that support them.
                    for characteristic in service.characteristics.filter({
                        $0.properties.contains(HMCharacteristicPropertySupportsEventNotification)
                    }) {
                        characteristic.enableNotification(true) { _ in }
                    }
                }
            }
        }
        
        print("homeAccessories.count: \(homeAccessories.count)")
    }
    
    private override init() {
        super.init()
        print("HLAccessoryManager.init--  Singleton")
        HomeStore.shared.homeManager.delegate = self
        HomeStore.shared.addHomeDelegate(self)
        HomeStore.shared.addAccessoryDelegate(self)
    }

    /// Deregisters this view controller as various kinds of delegate.
    deinit {
        print("HLAccessoryManager.deinit")
        HomeStore.shared.homeManager.delegate = nil
        HomeStore.shared.removeHomeDelegate(self)
        HomeStore.shared.removeAccessoryDelegate(self)
    }
}

/// Handle the home manager delegate callbacks.
extension HLAccessoryManager: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        setOrAddHome(manager: manager)
        
        reloadData()
        
/*        // Find the camera by its service type or accessory name
        print("HLAccessoryManager.homeManagerDidUpdateHomes")
        let cameraProfiles = HomeStore.shared.homeManager.homes
            .flatMap { $0.accessories }
            .flatMap { $0.cameraProfiles ?? [] }
   //         .first { $0.accessory?.name.contains("Circle View") ?? false }
            
        print("cameraProfiles.count: \(cameraProfiles.count)")
        for profile in cameraProfiles {
            let camera = HLCameraModel(profile: profile)
            print("append: \(camera.profile.uniqueIdentifier)")
        }
        
        // Find the switch by its service type or accessory name
        print("HLAccessoryManager.homeManagerDidUpdateHomes")
        let powerSwitches = HomeStore.shared.homeManager.homes
            .flatMap { $0.accessories }
            .flatMap { $0.cameraProfiles ?? [] }
   //         .first { $0.accessory?.name.contains("Circle View") ?? false }*/
     }
    
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        setOrAddHome(manager: manager)
    }
    
    /// Sets the home to either the primary home, or the first home, or a home that the user creates.
    func setOrAddHome(manager: HMHomeManager) {
  //      if manager.primaryHome != nil {
  //          home = manager.primaryHome
  //      } else
        if let firstHome = manager.homes.first {
            home = firstHome
        } else {
            print("setOrAddHome problem!!")
 /*           let alert = UIAlertController(title: "Add a Home",
                                          message: "There aren’t any homes in the database. Create a home to work with.",
                                          preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "Name" }
            alert.addAction(UIAlertAction(title: "Create", style: .default) { _ in
                if let name = alert.textFields?[0].text {
                    manager.addHome(withName: name) { home, error in
                        if let error = error {
                            print("Error adding home: \(error)")
                        } else {
                            self.home = home
                        }
                    }
                }
            })
            present(alert, animated: true)*/
        }
    }
}

extension HLAccessoryManager: HMHomeDelegate {
    func homeDidUpdateName(_ home: HMHome) {
        guard home == self.home else { return }
        
        print("HLAccessoryManager.homeDidUpdateName-  home.name: \(home.name)")
  //      title = home.name
    }

    func home(_ home: HMHome, didAdd accessory: HMAccessory) {
        guard home == self.home else { return }
        
        // Make sure the new accessory generates callbacks to the home store.
        accessory.delegate = HomeStore.shared

        reloadData()
    }
    
    func home(_ home: HMHome, didUpdate room: HMRoom, for accessory: HMAccessory) {
        for service in accessory.services {
            print("HLAccessoryManager.didUpdate start-  service: \(service.serviceType)")
 /*          if let item = cameraServices.firstIndex(of: service) {
                print("HLAccessoryManager.didUpdate")
        //        let cell = collectionView.cellForItem(at: IndexPath(item: item, section: 0)) as? AccessoryCell
        //        cell?.roomLabel.text = room.name
            }*/
        }
    }
    
    func home(_ home: HMHome, didRemove accessory: HMAccessory) {
        guard home == self.home else { return }
        print("HLAccessoryManager.didRemove")
 //       navigationController?.popToRootViewController(animated: true)
        reloadData()
    }
    
    func home(_ home: HMHome, didUpdateNameFor room: HMRoom) {
        print("HLAccessoryManager.didUpdateNameFor")
  //      for cell in collectionView.visibleCells {
  //          (cell as? AccessoryCell)?.roomLabel.text = room.name
   //     }
    }
    
    func home(_ home: HMHome, didEncounterError error: Error, for accessory: HMAccessory) {
        print(error.localizedDescription)
    }
}
