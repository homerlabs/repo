//
//  ServicesView.swift
//  MyHomeKit
//
//  Created by Matthew Homer on 6/9/26.
//

import SwiftUI
import HomeKit

struct ServicesView: View {
    
    var accessoryId: UUID
    var homeId: UUID
    @ObservedObject var model: HomeStore
    
    var body: some View {
        
        List {
            Section(header: HStack {
                Text("\(model.accessories.first(where: {$0.uniqueIdentifier == accessoryId})?.name ?? "No Accessory Name Found") Services")
            })
            {
                ForEach(model.services, id: \.uniqueIdentifier) { service in
                    NavigationLink(value: service){
                        Text("\(service.localizedDescription)")
                    }
                }
            }
        }.navigationDestination(for: HMService.self) {
            CharacteristicsView(serviceId: $0.uniqueIdentifier, accessoryId: accessoryId, homeId: homeId, model: model)
        }.onAppear(){
            model.findServices(accessoryId: accessoryId, homeId: homeId)
        }
    }
}

#Preview {
    ServicesView(accessoryId: UUID(), homeId: UUID(), model: HomeStore())
}
