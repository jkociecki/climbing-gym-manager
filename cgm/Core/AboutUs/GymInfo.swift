import SwiftUI
import MapKit

// MARK: - Data Models
struct GymModel {
    let name:                   String
    let description:            String
    let address:                Address
    let avatarImageName:        String
    let backgroundImageName:    String
    let rating:                 Double
    let totalBoulders:          Int
    let openingHours:           [String: (start: String, end: String)]
    
    static let sample = GymModel(
        name:                   "Groto Bulderownia",
        description:            "Climbing & Coffee",
        address:                Address(
                                    street: "Międzyleska 4",
                                    city: "Wrocław",
                                    postalCode: "50-514",
                                    coordinates: CLLocationCoordinate2D(latitude: 51.0897, longitude: 17.0538)
                                ),
        avatarImageName:        "default_avatar",
        backgroundImageName:    "gym_background",
        rating:                 4.8,
        totalBoulders:          162,
        openingHours: [
            "Monday": ("08:00", "22:00"),
            "Tuesday": ("08:00", "22:00"),
            "Wednesday": ("08:00", "22:00"),
            "Thursday": ("08:00", "22:00"),
            "Friday": ("08:00", "22:00"),
            "Saturday": ("09:00", "20:00"),
            "Sunday": ("10:00", "20:00")
        ]
    )
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct GymInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isOpeningHoursExpanded = false
    @State private var isBouldersExpanded = false
    @StateObject private var model: GymInfoModel = GymInfoModel()
    @Binding var isLoading: Bool
    let gym: GymModel
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 51.0897, longitude: 17.0538), // Wartość domyślna
           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
       )
    
    init(gym: GymModel = GymModel.sample, isLoading: Binding<Bool>) {
            self.gym = gym
            _isLoading = isLoading
    }
    

    
    var body: some View {
//        if model.isLoading {
//            ProgressView("Loading...")
//                .onAppear {
//                    Task {
//                        await model.loadData()
//                        await model.loadBoulders()
//                        await model.loadImagaes()
//                        region = MKCoordinateRegion(
//                            center: model.address.coordinates,
//                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                        )
//                        model.isLoading = false
//                    }
//                }
//            
//        }else{
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        HeroSection(gym: gym, model: model, background: model.background, logo: model.logo)
                            .id("hero")
                            .frame(height: 200)
                        
                        VStack(spacing: 16) {
                            QuickInfoSection(
                                gym: gym,
                                totalBoulders: model.totalBoulders,
                                isOpenNow: isOpenNow,
                                closingTime: nextClosingTime
                            )
                            .id("quickInfo")
                            
                            LocationCard(address: model.address, region: $region)
                                .id("location")
                            
                            ExpandableSection(
                                isExpanded: $isOpeningHoursExpanded,
                                title: "Opening hours",
                                icon: "calendar.badge.clock"
                            ) {
                                HoursCard(
                                    openingHours: model.openingHours,
                                    currentDay: currentDay,
                                    isOpenNow: isOpenNow
                                )
                            }
                            .id("openingHours")
                            
                            ExpandableSection(
                                isExpanded: $isBouldersExpanded,
                                title: "Boulders",
                                icon: "figure.climbing"
                            ) {
                                BoulderGradeChart(gradeData: model.boulderData)
                            }
                            .id("boulders")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 120)
                }
                .frame(maxHeight: .infinity)
                .background(Color(.systemGray6).opacity(0.5))
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: isBouldersExpanded) { newValue in
                    if newValue {
                        withAnimation {
                            proxy.scrollTo("boulders", anchor: .top)
                        }
                    }
                }
                .onChange(of: isOpeningHoursExpanded) { newValue in
                    if newValue {
                        withAnimation {
                            proxy.scrollTo("openingHours", anchor: .top)
                        }
                    }
                }
            }
            .onAppear{
                    Task {
                        isLoading = true
                        await model.loadData()
                        await model.loadBoulders()
                        await model.loadImagaes()
                        region = MKCoordinateRegion(
                            center: model.address.coordinates,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        isLoading = false
                    }
            }
    }
    
    private var currentDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    private var isOpenNow: Bool {
        guard let hours = model.openingHours[currentDay] else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let now = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        
        guard let currentTime = formatter.date(from: String(format: "%02d:%02d", currentComponents.hour ?? 0, currentComponents.minute ?? 0)),
              let openTime = formatter.date(from: hours.start),
              let closeTime = formatter.date(from: hours.end) else {
            return false
        }
        
        return currentTime >= openTime && currentTime <= closeTime
    }
    
    private var nextClosingTime: String {
        guard let hours = model.openingHours[currentDay] else { return "" }
        return "Until \(hours.end)"
    }
}


// MARK: - Hero Section
struct HeroSection: View {
    let gym: GymModel
    let model: GymInfoModel
    let background: Data
    let logo:       Data
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let uiImage = UIImage(data: background) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
                    .frame(height: 200)
                    .clipped()
            } else {
                Color.gray
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 200)
            }

            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    CircularProfileImage(imageName: gym.avatarImageName, logo: logo)
                        .frame(width: 70, height: 70)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.address.street)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(model.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
    }
}

struct CircularProfileImage: View {
    let imageName: String
    let logo:       Data
    
    var body: some View {

        if let uiImage = UIImage(data: logo) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
        } else {
            Circle()
                .foregroundStyle(.czerwony)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
        }
        
    }
}

// MARK: - Quick Info Section
struct QuickInfoSection: View {
    let gym:            GymModel
    let totalBoulders:  Int
    let isOpenNow:      Bool
    let closingTime:    String
    
    var body: some View {
        HStack(spacing: 16) {
            InfoCard(
                icon: "clock",
                title: isOpenNow ? "Open Now" : "Closed",
                subtitle: isOpenNow ? closingTime : "Check hours"
            )
            
            InfoCard(
                icon: "figure.climbing",
                title: "\(totalBoulders)",
                subtitle: "Boulders"
            )
            
            InfoCard(
                icon: "star",
                title: String(format: "%.1f", gym.rating),
                subtitle: "Rating"
            )
        }
    }
}

struct InfoCard: View {
    @Environment(\.colorScheme) var colorScheme

    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.primary)
                .font(.system(size: 20))
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Location Card
struct LocationCard: View {
    @Environment(\.colorScheme) var colorScheme
    let address: Address
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "mappin.circle")
                    .foregroundColor(.czerwony)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(address.street)
                        .font(.headline)
                    Text("\(address.postalCode) \(address.city)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Map(coordinateRegion: $region,
                annotationItems: [Location(name: "Gym", coordinate: address.coordinates)]) { location in
                MapMarker(coordinate: location.coordinate, tint: .czerwony)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button(action: openDirections) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Get Directions")
                }
                .frame(maxWidth: .infinity)
                .padding()
                //.background(Color.czerwony)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func openDirections() {
        let addressString = "\(address.street)+\(address.city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://maps.apple.com/?address=\(addressString)") {
            UIApplication.shared.open(url)
        }
    }
}

struct HoursCard: View {
    @Environment(\.colorScheme) var colorScheme
        let openingHours: [String: (start: String, end: String)]
        let currentDay: String
        let isOpenNow: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(openingHours.keys.sorted(), id: \.self) { day in
                    VStack(spacing: 8) {
                        HStack {
                            Text(day)
                                .font(.system(size: 16))
                                .foregroundColor(day == currentDay ? .primary : .secondary)

                            Spacer()

                            Text("\(openingHours[day]!.start) - \(openingHours[day]!.end)")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(day == currentDay ? 8 : 0)

                        .background(
                            day == currentDay ? Color.czerwony .opacity(colorScheme == .dark ? 0.2 : 0.1) : Color.clear
                        )
                        .cornerRadius(12)

                        if day != openingHours.keys.sorted().last {
                            Divider()
                                .foregroundColor(Color(.systemGray5))
                        }
                    }
                }

                StatusBadge(isOpen: isOpenNow)
                    .padding(.top, 8)
            }
            .padding(16)
        }
    }




private struct ExpandableSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isExpanded: Bool
    let title: String
    let icon: String
    let content: Content
    
    init(
        isExpanded: Binding<Bool>,
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = isExpanded
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    HStack {
                        Image(systemName: icon)
                            .foregroundColor(Color.czerwony)
                            .font(.system(size: 20))

                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                content
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}


private struct StatusBadge: View {
    @Environment(\.colorScheme) var colorScheme
    let isOpen: Bool
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 6) {
                Circle()
                    .fill(isOpen ? Color.green : Color.czerwony)
                    .frame(width: 6, height: 6)
                
                Text(isOpen ? "Currently Open" : "Currently Closed")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isOpen ? .green : .czerwony)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isOpen
                        ? Color.green.opacity(colorScheme == .dark ? 0.3 : 0.1)
                        : Color.czerwony.opacity(colorScheme == .dark ? 0.2 : 0.1))
            )
        }
        
    }
}

// MARK: - Helper Extensions
extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: self)
    }
}



struct GymDetailsView_Previews: PreviewProvider {
    static var previews: some View {
            MainView()
    }
}


