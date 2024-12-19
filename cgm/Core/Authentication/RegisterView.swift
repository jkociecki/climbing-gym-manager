//
//  RegisterView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 14/12/2024.
//

import SwiftUI

struct RegisterView: View {
   @State private var email = ""
   @State private var password = ""
   @State private var password_repeat = ""
   @State var emailAuthModel: EmailAuthModel = EmailAuthModel()
   @State private var appUser: AppUser?
   @State private var isLoggedIn: Bool = false

   var body: some View {
       NavigationStack{
           ZStack {
               Color("Czerwony")
                   .ignoresSafeArea()
               
               VStack()
               {
                   
                   Image("logoPurple")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 440, height: 245)
                       .padding(.bottom, 40)
                   
                   VStack {
                       HStack {
                           Image(systemName: "envelope.fill")
                               .foregroundColor(.white)
                               .font(.system(size: 20))
                           
                           TextField("", text: $email)
                               .textInputAutocapitalization(.never)
                               .disableAutocorrection(true)
                               .foregroundColor(.white)
                               .font(.system(size: 23))
                               .placeholder(when: email.isEmpty) {
                                   Text("Email")
                                       .foregroundColor(.white)
                                       .font(.system(size: 23))
                                       .bold()
                               }
                       }
                       
                       Rectangle()
                           .fill(Color.white)
                           .frame(height: 2)
                   }
                   .padding(.horizontal, 40)
                   .padding(.vertical, 10)
                   
                   VStack {
                       HStack {
                           Image(systemName: "lock.open.fill")
                               .foregroundColor(.white)
                               .font(.system(size: 20))
                           
                           SecureField("", text: $password)
                               .foregroundColor(.white)
                               .font(.system(size: 23))
                               .placeholder(when: password.isEmpty) {
                                   Text("Password")
                                       .foregroundColor(.white)
                                       .font(.system(size: 23))
                                       .bold()
                               }
                       }
                       
                       Rectangle()
                           .fill(Color.white)
                           .frame(height: 2)
                   }
                   .padding(.horizontal, 40)
                   .padding(.vertical, 10)
                   
                   VStack {
                       HStack {
                           Image(systemName: "lock.open.fill")
                               .foregroundColor(.white)
                               .font(.system(size: 20))
                           
                           SecureField("", text: $password_repeat)
                               .foregroundColor(.white)
                               .font(.system(size: 23))
                               .placeholder(when: password_repeat.isEmpty) {
                                   Text("Password")
                                       .foregroundColor(.white)
                                       .font(.system(size: 23))
                                       .bold()
                               }
                       }
                       
                       Rectangle()
                           .fill(Color.white)
                           .frame(height: 2)
                   }
                   .padding(.horizontal, 40)
                   .padding(.vertical, 10)
                   .padding(.bottom, 30)
                   
                   
                   
                   Button {
                       if password == password_repeat {
                           print(password)
                           print(email)
                           Task{
                               do{
                                   let appUser = try await emailAuthModel.registerNewUserWithEmail(email: email, password: password)
                                   try await emailAuthModel.storeUser()
                                   self.appUser = appUser
                                   self.isLoggedIn = true
                                   
                               }catch{
                                   print(error)
                               }
                           }
                           
                       } else {
                           print("Passwords do not match")
                       }
                   } label: {
                       Text("Sign up")
                           .bold()
                           .font(.system(size: 25))
                           .frame(width: 350, height: 60)
                           .background(
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .fill(Color("Fioletowy"))
                           )
                           .foregroundColor(.white)
                   }
                   
                
                   
                   Spacer()
                   
                   NavigationLink(destination: LoginView()
                    .navigationBarBackButtonHidden()
                   ) {
                       HStack {
                           Text("Already have an account?")
                               .foregroundColor(.white)
                               .font(.system(size: 20))
                           Text("Sign in")
                               .foregroundColor(Color("Fioletowy"))
                               .fontWeight(.bold)
                               .underline(true, color: Color("Fioletowy"))
                               .font(.system(size: 20))
                       }
                       .font(.system(size: 14))
                   }
                   
               }
               .padding(.horizontal, 30)
           }
           .navigationDestination(isPresented: $isLoggedIn) {
               SetUpAccountView().navigationBarBackButtonHidden(true)}
       }
   }
}


struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
