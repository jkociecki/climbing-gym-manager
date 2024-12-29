//
//  TabBar.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 29/12/2024.
//

import SwiftUI


struct CustomTabBar: View {
    @Binding var selectedTab: String
    var onTabSelected: (String) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabBarButton(
                    image: tab,
                    selectedTab: $selectedTab,
                    isSelectedColor: .red,
                    onTap: {
                        onTabSelected(tab)
                    }
                )
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(
            Color.black.opacity(0.8)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        )
        .padding(.horizontal)
        .padding(.bottom, getSafeArea().bottom == 0 ? 20 : getSafeArea().bottom)
    }
    
    var tabs = ["house", "chart.bar", "plus", "person"]
}

struct TabBarButton: View {
    var image: String
    @Binding var selectedTab: String
    var isSelectedColor: Color
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                selectedTab = image
                onTap()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: getIcon())
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == image ? isSelectedColor : .white)
                
                if selectedTab == image {
                    Circle()
                        .fill(isSelectedColor)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private func getIcon() -> String {
        selectedTab == image ? "\(image).fill" : image
    }
}

extension View {
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let safeArea = screen.windows.first?.safeAreaInsets
        else {
            return .zero
        }
        return safeArea
    }
}



#Preview{
    MainView()
}
