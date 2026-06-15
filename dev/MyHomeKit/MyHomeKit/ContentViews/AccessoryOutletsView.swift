//
//  AccessoryOutletsView.swift
//  MyHomeKit
//
//  Created by Matthew Homer on 6/14/26.
//

import HomeKit
import SwiftUI

struct AccessoryOutletsView: View {
    var homeId: UUID
    @ObservedObject var model: HomeStore

    var body: some View {
        Text("My Outlets")
        List {
            ForEach(model.outletAccessories, id: \.uniqueIdentifier) { outlet in
        //        NavigationLink(value: home){
                Text("\(outlet.model ?? "nil")")
            }
        }
    }
}

#Preview {
    AccessoryOutletsView(homeId: UUID(), model: HomeStore())
}
