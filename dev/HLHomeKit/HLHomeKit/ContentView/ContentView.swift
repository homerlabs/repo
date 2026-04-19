//
//  ContentView.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/14/26.
//

import SwiftUI
import HomeKit
//swift mvvm example
//http://dummy.restapiexample.com/api/v1/employees

struct ContentView: View {
    @State private var homeAccessories = HLAccessoryManager.shared.homeAccessories
 //   @Binding var currentHome: HMHome?
    private var currentAccessory: HMAccessory?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("HomerLabs HomeKit")

            let cameraAccessories = HLAccessoryManager.shared.homeAccessories.filter({ $0.category.categoryType == HMAccessoryCategoryTypeIPCamera })
            Text("cameraAccessories: \(cameraAccessories.count)")
            VStack(alignment: .leading) {
                ForEach(0..<cameraAccessories.count, id: \.self) {index in
                    let cameraAccessory = cameraAccessories[index]
                    Text("cameraAccessory: \(cameraAccessory.uniqueIdentifier)   name:  \(cameraAccessory.name)")
         //           HLCameraView(camera)
                }
            }
            
            let switchTypeAccessories = HLAccessoryManager.shared.homeAccessories.filter({ $0.category.categoryType == HMAccessoryCategoryTypeOutlet })
            Text("switchTypeAccessories: \(switchTypeAccessories.count)")
     //       Text("switchTypeAccessories: \(switchTypeAccessories)")
            VStack(alignment: .leading) {
                ForEach(0..<switchTypeAccessories.count, id: \.self) {index in
                    
                    let powerSwitchAccessory = switchTypeAccessories[index]
                    HLPowerSwitchView(accessory: powerSwitchAccessory)
                    
           //         HLAccessoryManager.shared.currentAccessory = powerSwitchAccessory
            /*        HStack(alignment: .center) {
                        Text("powerSwitch: \(powerSwitchAccessory.name)")
                        Button(action: HLAccessoryManager.shared.toggleSwitch) {
                            Text("Toggle Switch")
                        }
                    }*/
                }
            }
        }
        .padding()
    }
    
    func toggleSwitch() {
 //       print("HLAccessoryManager.shared.currentAccessory.isOn: \(HLAccessoryManager.shared.currentAccessory?.name ?? "?")")
    }
}

#Preview {
    ContentView()
}

/*extension ContentView {
    @Observable
    class ViewModel {
        var name: String = "HomerLabs"
    }
}*/
