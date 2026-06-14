//
//  MyHomeKitApp.swift
//  MyHomeKit
//
//  Created by Matthew Homer on 6/9/26.
//

import SwiftUI

@main
struct MyHomeKitApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(model: HomeStore())
        }
    }
}
