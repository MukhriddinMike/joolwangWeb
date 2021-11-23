//
//  wkweebviewApp.swift
//  wkweebview
//
//  Created by Mike on 2021/10/18.
//

import SwiftUI

@main
struct wkweebviewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate  
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
