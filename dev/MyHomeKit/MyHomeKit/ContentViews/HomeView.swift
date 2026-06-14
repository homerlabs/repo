//
//  ContentView.swift
//  MyHomeKit
//
//  Created by Matthew Homer on 6/9/26.
//

import SwiftUI
import HomeKit
//https://www.createwithswift.com/creating-a-homekit-enabled-app-with-swiftui/

struct HomeView: View {
    
    @State private var path = NavigationPath()
    @ObservedObject var model: HomeStore
    
    var body: some View {
        NavigationStack(path: $path) {
            Text("My Homes")
            List {
                    ForEach(model.homes, id: \.uniqueIdentifier) { home in
                        NavigationLink(value: home){
                            Text("\(home.name)")
                        }
                    }
                }.navigationDestination(for: HMHome.self){
                    AccessoriesView(homeId: $0.uniqueIdentifier, model: model)
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView(model: HomeStore())
}
