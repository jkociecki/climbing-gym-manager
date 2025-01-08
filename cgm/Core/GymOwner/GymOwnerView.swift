import SwiftUI

struct GymOwnerView: View {
    @State private var isAddBouldersPresented = false
    @State private var isEditBouldersPresented = false
    @Binding var isLoading: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    isAddBouldersPresented = true
                }) {
                    Label("Add Boulders", systemImage: "plus.circle")
                }
                
                Button(action: {
                    isEditBouldersPresented = true
                }) {
                    Label("Edit Boulders", systemImage: "pencil.circle")
                }
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 60)
            }
            .fullScreenCover(isPresented: $isAddBouldersPresented) {
                AddBouldersView(isPresented: $isAddBouldersPresented,
                                isLoading: $isLoading)
            }
            .fullScreenCover(isPresented: $isEditBouldersPresented) {
                selectBoulder(isPresented: $isEditBouldersPresented,
                              isLoading: $isLoading)
            }
        }
    }
}
