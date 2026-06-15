//
//  AccessoryCamerasView.swift
//  MyHomeKit
//
//  Created by Matthew Homer on 6/15/26.
//

import HomeKit
import SwiftUI

struct AccessoryCamerasView: View {
    var homeId: UUID
    @ObservedObject var model: HomeStore

    var body: some View {
        Text("My Cameras")
        List {
            ForEach(model.cameraAccessories, id: \.uniqueIdentifier) { camera in
        //        NavigationLink(value: home){
                Text("\(camera.model ?? "nil")")
            }
        }
    }
}

#Preview {
    AccessoryCamerasView(homeId: UUID(), model: HomeStore())
}
