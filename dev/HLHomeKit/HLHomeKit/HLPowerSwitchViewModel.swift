//
//  HLPowerSwitchViewModel.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/16/26.
//

import HomeKit
import Observation

@Observable
class HLPowerSwitchViewModel {
    static let shared = HLPowerSwitchViewModel()
    var switches: [HLPowerSwitchModel] = []
    var switchAccessories: [HMAccessory] = []

    func toggleSwitch(_ powerSwitch: HLPowerSwitchModel) {
        print("HLPowerSwitchViewModel.init--  Singleton")
/*       for (index, element) in switches.enumerated() {
            var theSwitch = switches[index]
            if theSwitch.id == powerSwitch.id {
                theSwitch.isOn.toggle()
            }
        }*/
    }
    
    func getSwitcheAccessories() -> [HMAccessory] {
        return switchAccessories
    }
    
    private init() {
        print("HLPowerSwitchViewModel.init--  Singleton")
    }
}

