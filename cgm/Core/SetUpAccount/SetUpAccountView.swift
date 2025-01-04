//
//  SetUpAccountView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import SwiftUI

enum Gender {
    case female, male
}

struct SetUpAccountView: View {
    @StateObject var setUpAccountModel: SetUpAccountModel = SetUpAccountModel()
    @State var name: String = ""
    @State var surname: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var selectedGender: Gender? = nil
    @State private var showConfirmationAlert: Bool = false
        
    var body: some View {
        ScrollView{
                ZStack{

                    ScrollView{
                        VStack{
                            // PHOTO AND PLUS ICON
                            VStack{
                                if setUpAccountModel.imageData == nil {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                        .foregroundColor(Color(.systemGray))
                                        .background(Circle().foregroundColor(.white).frame(width: 160, height: 160))
                                } else {
                                    Image(uiImage: UIImage(data: setUpAccountModel.imageData!)!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                        .background(Circle().foregroundColor(.white).frame(width: 160, height: 160))
                                }
                                Button(action:
                                        {
                                    
                                    setUpAccountModel.showImagePicker = true
                                    
                                } ){
                                    Image(systemName: "plus.circle")
                                        .resizable()
                                        .foregroundColor(Color(.white))
                                        .background(Circle().fill(Color("Fioletowy")))
                                        .frame(width: 50, height: 50)
                                }
                                .offset(x: 40, y: -40)
                                .sheet(isPresented: $setUpAccountModel.showImagePicker) {
                                    PhotoPicker(imageData: $setUpAccountModel.imageData)
                                }
                                .padding(.bottom, -10)
                                .padding(.top)
                                
                                // Personal Information
                                VStack(alignment: .leading) {
                                    Text("Personal information")
                                        .font(.headline)
                                        .padding(.horizontal)
                                        .foregroundColor(.black)
                                    
                                    
                                    InfoRow(icon: "person",
                                            title: "Full name",
                                            text: $name,
                                            placeholder: setUpAccountModel.userData?.name ?? "Enter your full name")
                                    
                                    InfoRow(icon: "person.crop.square",
                                            title: "Nickname",
                                            text: $surname,
                                            placeholder: setUpAccountModel.userData?.surname ?? "Enter your nickname")
                                    
                                    SelectGender(selectedGender: $selectedGender)
      
                                    Text("Account")
                                        .font(.headline)
                                        .padding(.horizontal)
                                        .foregroundColor(.black)
                                        .padding(.top, 20)
                                    InfoRow(icon: "envelope",
                                            title: "Email",
                                            text: $email,
                                            placeholder: setUpAccountModel.userData?.email ?? "john.doe@gmail.com")
                                    
                                    InfoRow(icon: "lock.fill",
                                            title: "Password",
                                            text: $password,
                                            placeholder: "*************",
                                            isSecure: true)
                                }
                                .padding()
                                
                                Button {
                                    Task{
                                        do{
                                            try await StorageManager.shared.uploadFileForCurrentUser(photoData: setUpAccountModel.imageData!)
                                            try await setUpAccountModel.saveUserData(name: name, surname: surname, gender: selectedGender)
                                            await setUpAccountModel.fetchUserData()
                                            try await setUpAccountModel.fetchProfilePicture()
                                            showConfirmationAlert = true
                                        }catch{
                                            print(error)
                                        }
                                    }
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
                .padding(.vertical, 140)
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            Task {
                await setUpAccountModel.fetchUserData()
                // Przenieś przypisanie wartości tutaj, po pobraniu danych
                if let userData = setUpAccountModel.userData {
                    await MainActor.run {
                        name = userData.name ?? ""
                        surname = userData.surname ?? ""
                        email = userData.email
                        if let isFemale = userData.gender {
                            selectedGender = isFemale ? .female : .male
                        } else {
                            selectedGender = nil
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Changes Saved"),
                message: Text("Your account information has been successfully updated."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    
    struct InfoRow: View {
        var icon: String
        var title: String
        @Binding var text: String
        var placeholder: String
        var isSecure: Bool = false
        var isList: Bool = false
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.fioletowy)
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
                
            }.background(Rectangle()
                .cornerRadius(15)
                .foregroundColor(.background))
            .padding(.vertical, -1)
        }
    }
}



struct SelectGender: View {
    @Binding var selectedGender: Gender?
    @State private var isRotating = false
    
    init(selectedGender: Binding<Gender?>) {
        self._selectedGender = selectedGender
        if let initialGender = selectedGender.wrappedValue {
            _isRotating = State(initialValue: initialGender != nil)
        }
    }

    private func getIconName(for gender: Gender?) -> String {
        switch gender {
        case .female:
            return "male-svgrepo-com"
        case .male:
            return "female-svgrepo-com"
        case nil:
            return "transgender-svgrepo-com"
        }
    }
    
    var body: some View {
        HStack {
            Image(getIconName(for: selectedGender))
                .resizable()
                .frame(width: 50, height: 50)
                .rotation3DEffect(
                    .degrees(isRotating ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .padding(.horizontal, 6)
            
            Spacer()
            
            HStack {
                GenderButton(
                    title: "Female",
                    isSelected: selectedGender == .female,
                    action: {
                        withAnimation(.spring(duration: 0.5)) {
                            isRotating.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            selectedGender = selectedGender == .female ? nil : .female
                        }
                    }
                )
                
                GenderButton(
                    title: "Male",
                    isSelected: selectedGender == .male,
                    action: {
                        withAnimation(.spring(duration: 0.8)) {
                            isRotating.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            selectedGender = selectedGender == .male ? nil : .male
                        }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .cornerRadius(15)
                .foregroundColor(.background)
        )
    }
}

struct GenderButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var animationAmount = 1.0
    
    var body: some View {
        Text(title)
            .frame(width: 80, height: 20)
            .font(.custom("Inter18pt-SemiBold", size: 15))
            .foregroundStyle(isSelected ? .white : .black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? .fioletowy : Color(.systemGray5))
                        .frame(width: 100, height: 35)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.fioletowy.opacity(isSelected ? 1 : 0),
                                                                  Color(.systemGray5).opacity(isSelected ? 0 : 1)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 100, height: 35)
                        )
                }
            )
            .scaleEffect(animationAmount)
            .onTapGesture {
                withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                    animationAmount = 0.9
                    action()
                }
                
                withAnimation(.spring(duration: 0.4).delay(0.1)) {
                    animationAmount = 1.0
                }
            }
            .animation(.spring(duration: 0.8), value: isSelected)
    }
}
#Preview{
    //SelectGender()
    SetUpAccountView()
}
