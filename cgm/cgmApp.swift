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
    @StateObject private var authManager = AuthManager.shared
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    AnimatedLoader(size: 60)
                        
                } else {
                    Group {
                        if authManager.isAuthenticated {
                            MainView()
                        } else {
                            RegisterView()
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    async let authCheck = authManager.checkAuth()
                    async let artificialDelay = Task.sleep(for: .seconds(2))
                    
                    await (_, _) = (authCheck, try artificialDelay)
                    
                    await MainActor.run {
                        withAnimation {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
}
