//
//  ContentView.swift
//  HLHomeKit
//
//  Created by Matthew Homer on 4/2/26.
//

import SwiftUI

var stringArray: [String] = ["1", "2"]

struct ContentView: View {
    let accessoryManager = HLAccessoryManager()
//    let homeStore = HomeStore.shared
    //let cameraManager = CameraManager()

 //   let accessoryList = AccessoryList()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("HLHomeKit App")
            
//            List(cameraManager.cameraProfiles){ cameraProfile in
//                Text("cameraProfile: \(cameraProfile.id)")
                            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
