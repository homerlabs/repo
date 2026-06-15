//
//  HomeStore.swift
//  MyHomeKit
//
//  Created by Matthew Homer on 6/9/26.
//

import Foundation
import HomeKit
import Combine

class HomeStore: NSObject, ObservableObject, HMHomeManagerDelegate {
    
    
    @Published var homes: [HMHome] = []
    @Published var accessories: [HMAccessory] = []
    @Published var services: [HMService] = []
    @Published var characteristics: [HMCharacteristic] = []
    private var manager: HMHomeManager!

    @Published var readingData: Bool = false
    
    @Published var hueValue: Int?
    @Published var brightnessValue: Int?
    
    @Published var powerState: Bool?
    @Published var model: String?
    @Published var name: String?
    
    @Published var outletAccessories: [HMAccessory] = []
    @Published var cameraAccessories: [HMAccessory] = []


    func findAccessories(homeId: UUID) {
        guard let devices = homes.first(where: {$0.uniqueIdentifier == homeId})?.accessories else {
            print("ERROR: No Accessory not found!")
            return
        }
        accessories = devices
        
        outletAccessories = []
        cameraAccessories = []

        for accessory in devices {
            if accessory.category.categoryType == HMAccessoryCategoryTypeOutlet {
                outletAccessories.append(accessory)
            }
            
            else if accessory.category.categoryType == HMAccessoryCategoryTypeIPCamera {
                cameraAccessories.append(accessory)
            }
        }

        print("outletAccessories.count: \(outletAccessories.count)    cameraAccessories.count: \(cameraAccessories.count)")
    }

    func findServices(accessoryId: UUID, homeId: UUID){
        guard let accessoryServices = homes.first(where: {$0.uniqueIdentifier == homeId})?.accessories.first(where: {$0.uniqueIdentifier == accessoryId})?.services else {
            print("ERROR: No Services found!")
            return
        }
        services = accessoryServices
    }

    func findCharacteristics(serviceId: UUID, accessoryId: UUID, homeId: UUID){
        guard let serviceCharacteristics = homes.first(where: {$0.uniqueIdentifier == homeId})?.accessories.first(where: {$0.uniqueIdentifier == accessoryId})?.services.first(where: {$0.uniqueIdentifier == serviceId})?.characteristics else {
            print("ERROR: No Services found!")
            return
        }
        characteristics = serviceCharacteristics
    }

    func readCharacteristicValues(serviceId: UUID){
        guard let characteristicsToRead = services.first(where: {$0.uniqueIdentifier == serviceId})?.characteristics else {
            print("ERROR: Characteristic not found!")
            return
        }
       readingData = true
        for characteristic in characteristicsToRead {
            characteristic.readValue(completionHandler: {_ in
                print("DEBUG: reading localizedDescription: \(characteristic.localizedDescription)")
                if characteristic.localizedDescription == "Power State" {
                    self.powerState = characteristic.value as? Bool
                }
                if characteristic.localizedDescription == "Model" {
                    self.model = characteristic.value as? String
                }
                if characteristic.localizedDescription == "Name" {
                    self.name = characteristic.value as? String
                }
                self.readingData = false
            })
        }
    }

    func setCharacteristicValue(characteristicID: UUID?, value: Any) {
        guard let characteristicToWrite = characteristics.first(where: {$0.uniqueIdentifier == characteristicID}) else {
            print("ERROR: Characteristic not found!")
            return
        }
        characteristicToWrite.writeValue(value, completionHandler: {_ in
            self.readCharacteristicValue(characteristicID: characteristicToWrite.uniqueIdentifier)
        })
    }
    
    func readCharacteristicValue(characteristicID: UUID?){
        guard let characteristicToRead = characteristics.first(where: {$0.uniqueIdentifier == characteristicID}) else {
            print("ERROR: Characteristic not found!")
            return
        }
        readingData = true
        characteristicToRead.readValue(completionHandler: {_ in
            if characteristicToRead.localizedDescription == "Power State" {
                self.powerState = characteristicToRead.value as? Bool
            }
            if characteristicToRead.localizedDescription == "Model" {
                self.model = characteristicToRead.value as? String
            }
            if characteristicToRead.localizedDescription == "Name" {
                self.name = characteristicToRead.value as? String
            }
            self.readingData = false
        })
    }

    override init(){
        super.init()
        load()
    }
    
    func load() {
        if manager == nil {
            manager = .init()
            manager.delegate = self
        }
    }
    

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("DEBUG: Updated Homes!")
        self.homes = self.manager.homes
    }
}
