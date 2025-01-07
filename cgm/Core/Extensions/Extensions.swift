//
//  Extensions.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation
import SwiftUI


func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

private let customFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()


func timeAgo(from dateString: String) -> String {
    
    if let createdDate = customFormatter.date(from: dateString) {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: createdDate, to: now)
        
        switch (components.year, components.month, components.day, components.hour, components.minute, components.second) {
        case let (years?, _, _, _, _, _) where years > 0:
            return "\(years) years ago"
        case let (_, months?, _, _, _, _) where months > 0:
            return "\(months) months ago"
        case let (_, _, days?, _, _, _) where days > 0:
            return "\(days) days ago"
        case let (_, _, _, hours?, _, _) where hours > 0:
            return "\(hours) hours ago"
        case let (_, _, _, _, minutes?, _) where minutes > 0:
            return "\(minutes) minutes ago"
        case let (_, _, _, _, _, seconds?) where seconds > 0:
            return "\(seconds) seconds ago"
        default:
            return "Just now"
        }
    }
    print("Failed to parse date: \(dateString)") // Debugowanie błędów parsowania
    return "Unknown"
}

func timeAgo(from date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
    
    switch (components.year, components.month, components.day, components.hour, components.minute, components.second) {
    case let (years?, _, _, _, _, _) where years > 0:
        return "\(years) years ago"
    case let (_, months?, _, _, _, _) where months > 0:
        return "\(months) months ago"
    case let (_, _, days?, _, _, _) where days > 0:
        return "\(days) days ago"
    case let (_, _, _, hours?, _, _) where hours > 0:
        return "\(hours) hours ago"
    case let (_, _, _, _, minutes?, _) where minutes > 0:
        return "\(minutes) minutes ago"
    case let (_, _, _, _, _, seconds?) where seconds > 0:
        return "\(seconds) seconds ago"
    default:
        return "Just now"
    }
}

func formattedDate(_ date: String, dateFormat: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let dateObject = isoFormatter.date(from: date) {
        return formatDateObject(dateObject, dateFormat: dateFormat)
    }
    print("Nie udało się sformatować daty: \(date)")
    return date
}

func formattedDate(_ date: Date, dateFormat: String) -> String {
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = dateFormat
    displayFormatter.locale = Locale(identifier: "en_US_POSIX")
    return displayFormatter.string(from: date)
}


func formatDateObject(_ date: Date, dateFormat: String) -> String {
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = dateFormat
    displayFormatter.locale = Locale(identifier: "en_US_POSIX")
    return displayFormatter.string(from: date)
}

func formatDate(_ date: Date) -> String {
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ssZ"
    displayFormatter.locale = Locale(identifier: "en_US_POSIX")
    return displayFormatter.string(from: date)
}


func formatDate2(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    if let date = dateFormatter.date(from: dateString) {
        // Zwracamy datę w formacie "d MMM yyyy"
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "d MMM yyyy"
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        return displayFormatter.string(from: date)
    } else {
        print("Nie udało się sformatować daty: \(dateString)")
        return dateString
    }
}



extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    func toHex() -> String {
        // Pobierz składniki koloru w przestrzeni RGB
        guard let components = UIColor(self).cgColor.components else {
            return "000000" // Domyślny kolor w przypadku błędu
        }
        
        let r = Int((components[0] * 255).rounded())
        let g = Int((components[1] * 255).rounded())
        let b = Int((components[2] * 255).rounded())
        
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
