////
////  SelectGymView.swift
////  cgm
////
////  Created by Jędrzej Kocięcki on 15/12/2024.
////
//
import SwiftUI
import Macaw

struct SelectGymView: View {
    @State private var searchText: String = ""
    @State private var favoriteGyms: Set<Int> = []
    @StateObject private var selectGymModel: SelectGymModel = SelectGymModel()

    var filteredGyms: [GymD] {
        let gyms = selectGymModel.climbingGyms
        return searchText.isEmpty
            ? gyms
        : gyms.filter { $0.name.lowercased().contains(searchText.lowercased())
            || $0.address.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        ScrollView{
            NavigationView {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding()
                        
                        TextField("Search...", text: $searchText)
                            
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 30)
                
            

                    List(filteredGyms) { gym in
                        HStack {

                            SVGView(svgString: gym.logoSVG)
                                .frame(width: 40, height: 40)
                                .scaledToFit()
                                .clipShape(Circle())

                            
                            VStack(alignment: .leading) {
                                Text(gym.name)
                                    .font(.headline)
                                Text(gym.address)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()

                            Button(action: {
                                selectGymModel.selectedGym = gym.id
                                selectGymModel.storeSelectedGymIntoUserData(gymID: gym.id)
                            }) {
                                Image(systemName: selectGymModel.selectedGym == gym.id ? "circle.inset.filled" : "circle")
                                    .foregroundColor(.fioletowy)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }.padding(0)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.top, 140)
        }
        .frame(maxHeight: .infinity)
    }

    private func toggleFavorite(gym: GymD) {
        if favoriteGyms.contains(gym.id) {
            favoriteGyms.remove(gym.id)
        } else {
            favoriteGyms.insert(gym.id)
        }
    }
}

struct SelectGymView_Preview: PreviewProvider {
    static var previews: some View {
        SelectGymView()
    }
}

struct SVGView: UIViewRepresentable {
    let svgString: String
    
    func makeUIView(context: Context) -> MacawView {
        let svgView: MacawView
        do {
            let node = try SVGParser.parse(text: svgString) // Parsowanie SVG
            
            // Obliczanie skali
            let scaleX = 40 / node.bounds!.x
            let scaleY = 40 / node.bounds!.y
            let scale = min(scaleX, scaleY) // Zachowaj proporcje
                       
            node.place =  .scale(scaleX, scaleY)
            
            // Tworzenie widoku Macaw
            svgView = MacawView(node: node, frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            
        } catch {
            print("Error parsing SVG: \(error)")
            svgView = MacawView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) // Pusty widok w przypadku błędu
        }
        return svgView
    }
    
    func updateUIView(_ uiView: MacawView, context: Context) {
        // Można dodać kod do odświeżenia widoku SVG, jeśli dane się zmieniają
    }
}
