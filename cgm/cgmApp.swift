//
//  cgmApp.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 14/12/2024.
//

import SwiftUI
import Supabase

@main
struct cgmApp: App {
    @StateObject private var authmanager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group{
                if authmanager.isAuthenticated {
                    MainView()
                }else{
                    RegisterView()
                }
            }.onAppear{
                Task {
                                    await authmanager.checkAuth()
                                }
            }
        }
    }
}
