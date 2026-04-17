//
//  HLPowerSwitchView.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/14/26.
//

import SwiftUI

struct HLPowerSwitchView: View {
    @State private var viewModel = HLPowerSwitchViewModel.shared

    var body: some View {
        Text("HLPowerSwitchView")
        List(viewModel.switches) { powerSwitch in
            HStack(alignment: .center) {
                Text(powerSwitch.name)
               Text(powerSwitch.isOn ? "On" : "Off")
                Button(powerSwitch.name) {
             //       viewModel.toggle(powerSwitch)
                }
            }
        }
    }
}

#Preview {
    HLPowerSwitchView()
}
