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
    @State private var isLoading = true

    
    var body: some Scene {
        WindowGroup {
            Group{
                if authmanager.isAuthenticated {
                    MainView()
                }else{
                    RegisterView()
                }
            }
            .onAppear {
                           Task {
                               async let authCheck = authmanager.checkAuth()
                               async let artificialDelay = Task.sleep(for: .seconds(1.5))
                               
                               await (_, _) = (authCheck, try artificialDelay)
                               
                               await MainActor.run {
                                   withAnimation {
                                       isLoading = false
                                   }
                               }
                               UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                           }
                       }

                   }
               }
        }
