//
//  SetUpAccountView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import SwiftUI

struct SetUpAccountView: View {
    @StateObject var setUpAccountModel: SetUpAccountModel = SetUpAccountModel()
        
    
    
    var body: some View {
        NavigationView{
            ZStack{
                Color("Background").ignoresSafeArea()
                    ScrollView{
                    VStack{
                        // PHOTO AND PLUS ICON
                        VStack{
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .foregroundColor(Color(.systemGray))
                                .background(Circle().foregroundColor(.white).frame(width: 160, height: 160))
                            Button(action:
                                    {
                                
                                // WYBOR ZDJECIA PROFILOWEGO
                                
                            } ){
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .foregroundColor(Color(.white))
                                    .background(Circle().fill(Color("Fioletowy")))
                                    .frame(width: 50, height: 50)
                            }.offset(x: 40, y: -40)
                            
                        }.padding(.bottom)
                            .padding(.top)
                        
                        // Personal Information
                        VStack(alignment: .leading) {
                            Text("Personal information")
                                .font(.headline)
                                .padding(.horizontal)
                                .foregroundColor(.black)
                            
                            
                            InfoRow(icon: "person",
                                    title: "Full name",
                                    placeholder: setUpAccountModel.userData?.name ?? "Enter your full name")
                            
                            InfoRow(icon: "person.crop.square",
                                    title: "Nickname",
                                    placeholder: setUpAccountModel.userData?.surname ?? "Enter your nickname")
                            
                            InfoRow(icon: "envelope",
                                    title: "Email",
                                    placeholder: setUpAccountModel.userData?.email ?? "john.doe@gmail.com")
                            
                            InfoRow(
                                icon: "figure.stand.dress.line.vertical.figure",
                                title: "Gender",
                                placeholder: {
                                    if let gender = setUpAccountModel.userData?.gender {
                                        return gender ? "Male" : "Female"
                                    } else {
                                        return "Select gender"
                                    }
                                }(),
                                isList: true
                            )
                            
                            
                            InfoRow(icon: "lock.fill",
                                    title: "Password",
                                    placeholder: "*************",
                                    isSecure: true)
                        }
                        .padding()
                        
                        Button {
                            
                            
                        } label: {
                            Text("Save Changes")
                                .bold()
                                .font(.system(size: 20))
                                .frame(width: 360, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color("Fioletowy"))
                                )
                                .foregroundColor(.white)
                        }.padding()
                        
                    }
                }
            }
        }
    }
}


struct InfoRow: View {
    var icon: String
    var title: String
    @State private var text: String = ""
    var placeholder: String
    var isSecure: Bool = false
    var isList: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(.purple)
                .frame(width: 25, height: 25)
                .padding()

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)

                ZStack(alignment: .leading) {
                    // Wyświetlanie placeholdera jako Text
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.black) // Kolor placeholdera
                            .font(.body)
                    }
                    // TextField lub SecureField
                    if isSecure {
                        SecureField("", text: $text)
                            .foregroundColor(.black)
                            .font(.body)
                    } else {
                        TextField("", text: $text)
                            .foregroundColor(.black)
                            .font(.body)
                    }
                }
            }

            if !isList {
                Button(action: {

                }) {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 25, height: 25)
                        .padding()
                        
                }
            }
            
        }.background(Rectangle()
            .cornerRadius(15)
            .foregroundColor(.white))
        .padding(.vertical, -1)
    }
}


#Preview {
   SetUpAccountView()
    //InfoRow(icon: "person", title: "Full name", placeholder: "Enter your full name", isList: false)

}
