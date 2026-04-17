//
//  HLPowerSwitchModel.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/14/26.
//

import Foundation

struct HLPowerSwitchModel: Identifiable {
    let id = UUID()
    var name: String
    var isOn: Bool
}
