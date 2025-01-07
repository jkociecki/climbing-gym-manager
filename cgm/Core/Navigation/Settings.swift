//
//  SettingsView.swift
//  temp
//
//  Created by Malwina Juchiewicz on 04/01/2025.
//



import UIKit
import SwiftUI
import MessageUI
import SwiftUI
import AVKit


// MARK: - Constants
struct GymConstants {
    struct Settings {
        static let supportEmail = "juchiewicz.malwina@gmail.com"
        static let appVersion = "1.0.0"
        static let buildNumber = "1"
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showingPrivacyPolicy = false
    @State private var showingFeedbackForm = false
    @State private var showingTerms = false
    @State private var showingDeleteConfirmation = false
    @State private var showingNoMailAlert = false

    
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Appearance Section
                Section(header: Text("Appearance")) {
                                    Toggle(isOn: $isDarkMode) {
                                        SettingsRow(
                                            icon: "moon.fill",
                                            iconColor: .fioletowy,
                                            title: "Dark Mode",
                                            showArrow: false
                                        )
                                    }
                                    .onChange(of: isDarkMode) { newValue in
                                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                            windowScene.windows.forEach { window in
                                                window.overrideUserInterfaceStyle = newValue ? .dark : .light
                                            }
                                        }
                                    }
                                }
                
                // MARK: - Notifications Section
                Section(header: Text("Others")) {
                    NavigationLink {
                        NotificationPreferencesView()
                    } label: {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .fioletowy,
                            title: "Notification Preferences",
                            showArrow: false
                        )
                    }
                    
                    Button(action: sendFeedbackEmail) {
                        SettingsRow(
                            icon: "exclamationmark.bubble.fill",
                            iconColor: .fioletowy,
                            title: "Report an Issue"
                        )
                    }
                    NavigationLink {
                        MapGuideView()
                    } label: {
                        SettingsRow(
                            icon: "map.fill",
                            iconColor: .fioletowy,
                            title: "Map Guide",
                            showArrow: false
                        )
                    }
                    
                    
                }

                
                // MARK: - Legal Section
                Section(header: Text("Legal")) {
                    Button {
                        showingPrivacyPolicy.toggle()
                    } label: {
                        SettingsRow(
                            icon: "lock.fill",
                            iconColor: .secondary,
                            title: "Privacy Policy",
                            textColor: .secondary
                        )
                    }
                    
                    Button {
                        showingTerms.toggle()
                    } label: {
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .secondary,
                            title: "Terms of Service",
                            textColor: .secondary
                        )
                    }
                }
                
                // MARK: - Account Section
                Section(header: Text("Account")) {
                    Button {
                        showingDeleteConfirmation.toggle()
                    } label: {
                        SettingsRow(
                            icon: "trash.fill",
                            iconColor: .czerwony,
                            title: "Delete Account",
                            showArrow: false,
                            textColor: .czerwony
                        )
                        .foregroundColor(.red)
                    }
                }
                
                // MARK: - App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(GymConstants.Settings.appVersion) (\(GymConstants.Settings.buildNumber))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacyPolicy) {
                LegalDocumentView(title: "Privacy Policy", content: privacyPolicy, headers: privacyHeaders)
                
            }
            .sheet(isPresented: $showingTerms) {
                LegalDocumentView(title: "Terms of Service", content: termsOfService, headers: termsHeaders)
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .alert("No Mail App Configured", isPresented: $showingNoMailAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Please configure a mail account in your Mail app to send feedback.")
                    }
        }
        .accentColor(.czerwony)
    }
    
    private func sendFeedbackEmail() {
        let email = GymConstants.Settings.supportEmail
        let subject = "App Feedback"
        let body = """
        App Version: \(GymConstants.Settings.appVersion)
        Build Number: \(GymConstants.Settings.buildNumber)
        
        Description:
        
        """
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let emailURL = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"),
           UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL)
        } else {
            showingNoMailAlert = true
        }
    }
}


// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var showArrow: Bool = true
    var textColor: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(title)
                .foregroundColor(textColor)
            if showArrow {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
}

    
    // MARK: - Notification Preferences
    struct NotificationPreferencesView: View {
        @State private var chatAlerts = true
        
        var body: some View {
            Form {
                Section(header: Text("Current chat notifications")) {
                    Toggle("Notifications", isOn: $chatAlerts)
                }
            }
            .navigationTitle("Notifications")
        }
    }


// MARK: - Map guide
struct MapGuideView: View {
    private var player: AVPlayer? = {
        if let url = Bundle.main.url(forResource: "mapGuideVid", withExtension: "mp4") {
            return AVPlayer(url: url)
        }
        return nil
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Watch this video guide to learn how to effectively use the map features in our app.")
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Video player taking remaining space
            GeometryReader { geometry in
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .cornerRadius(12)
                        .onAppear() {
                            player.play()
                        }
                        .onDisappear() {
                            player.pause()
                            player.seek(to: .zero)
                        }
                } else {
                    Text("Video not available")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        

                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Map guide")
    }
}
    
// MARK: - Legal Document View
struct LegalDocumentView: View {
    let title: String
    let content: String
    let headers: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(formatAttributedString(content, headers: headers))
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.czerwony)
            )
        }
    }
}
    
    
    
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
    


func formatAttributedString(_ text: String, headers: [String]) -> AttributedString {
        var attributedString = AttributedString(text)
        
        for header in headers {
            if let range = attributedString.range(of: header) {
                attributedString[range].font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
            }
        }
        
        return attributedString
    }
    
    var privacyPolicy = """
    
    1. Information We Collect
    - Personal Information: We may collect personal data such as your email address when you create an account.
    - Usage Data: We collect information on how you interact with the app, including logs of your activities and preferences.
    - Device Information: We gather details about your device, including the operating system and device model.
    
    2. How We Use Your Information
    - To provide and maintain our services.
    - To improve user experience and app functionality.
    - To send you notifications, if you opt-in.
    
    3. Sharing Your Information
    We do not share your personal data with third parties except as necessary to comply with legal obligations.
    
    4. Your Rights
    You have the right to access, modify, or delete your personal information. Contact us at [Insert Contact Email] for any requests.
    
    5. Data Security
    We implement industry-standard security measures to protect your data. However, no method of transmission over the Internet is 100% secure.
    
    6. Changes to This Policy
    We may update this Privacy Policy from time to time. Changes will be effective when posted in the app.
    
    For questions or concerns about our Privacy Policy, contact us at [Insert Contact Email].
    """
    
    var privacyHeaders = [
        "1. Information We Collect",
        "2. How We Use Your Information",
        "3. Sharing Your Information",
        "4. Your Rights",
        "5. Data Security",
        "6. Changes to This Policy"
    ]
    
    var termsOfService = """
        
    Welcome to WallUp! By using our app, you agree to these Terms of Service. Please read them carefully.
    
    1. Use of the App
    - Eligibility: You must be at least 13 years old to use WallUp.
    - Account: You are responsible for keeping your login credentials secure.
    - License: We grant you a non-exclusive, non-transferable license to use WallUp for personal purposes.
    
    2. User Conduct
    - Do not use WallUp for illegal activities or to harm other users.
    - Respect intellectual property rights when uploading or sharing content.
    
    3. Termination
    We reserve the right to suspend or terminate your access to WallUp if you violate these terms.
    
    4. Limitation of Liability
    WallUp is provided "as is". We are not liable for any damages resulting from your use of the app.
    
    5. Changes to Terms
    We may revise these Terms of Service from time to time. The latest version will always be available in the app.
    
    For questions regarding these Terms of Service, please contact us at [Insert Contact Email].
    """
    
    var termsHeaders = [
        "1. Use of the App",
        "2. User Conduct",
        "3. Termination",
        "4. Limitation of Liability",
        "5. Changes to Terms"
    ]

