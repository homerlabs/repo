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
    let accessoryManager = HLAccessoryManager.shared

//    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("HomerLabs HomeKit")
            
            VStack(alignment: .leading) {
                ForEach(0..<accessoryManager.cameras.count, id: \.self) {index in
                    let camera = accessoryManager.cameras[index]
                    Text("camera: \(camera.profile.uniqueIdentifier)")
         //           HLCameraView(camera)
                }
            }
            
            HLPowerSwitchView()
        }
        .padding()
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
