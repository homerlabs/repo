//
//  AccessoriesView.swift
//  MyHomeKit
//
//  Created by Matthew Homer on 6/9/26.
//

import SwiftUI
import HomeKit

struct AccessoriesView: View {
    
    var homeId: UUID
    @State private var path = NavigationPath()
    @ObservedObject var model: HomeStore

    var body: some View {
        List {
            Section(header: HStack {
                Text("My Accessories")
            })
            {
                ForEach(model.accessories, id: \.uniqueIdentifier) { accessory in
                    NavigationLink(value: accessory){
                        Text("\(accessory.category.localizedDescription) \t \(accessory.name) ")
                    }
                }
            }
        }.navigationDestination(for: HMAccessory.self) {
                ServicesView(accessoryId: $0.uniqueIdentifier, homeId: homeId, model: model)
        }.onAppear(){
            model.findAccessories(homeId: homeId)
        }
        
        AccessoryOutletsView(homeId: homeId, model: model)
        AccessoryCamerasView(homeId: homeId, model: model)
    }
}
    
#Preview {
    AccessoriesView(homeId: UUID(), model: HomeStore())
}
