//
//  HLPowerSwitchView.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/14/26.
//

import HomeKit
import SwiftUI
import Foundation

struct HLPowerSwitchView: View {
    let accessory: HMAccessory?
    var accessoryManager = HLAccessoryManager.shared
    
  //  @EnvironmentObject var viewModel: HLHomeViewModel
    func toggle() {
        if let accessory = self.accessory {
            accessoryManager.toggleSwitch(accessory)
        }
    }
    
    var body: some View {
        Text("HLPowerSwitchView")
        if let accessory = self.accessory {
            HStack(alignment: .center) {
                Text(accessory.name)
        //       Text(accessory.isOn ? "On" : "Off")
                Button(accessory.name) {
                    toggle()
                }
            }
        }
    }
}

#Preview {
    HLPowerSwitchView(accessory: nil)
}
