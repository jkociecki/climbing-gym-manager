//
//  LoginView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 14/12/2024.
//

import SwiftUI

struct LoginView: View {
    @State var signInViewModel: EmailAuthModel = EmailAuthModel()
    @State private var email = ""
    @State private var password = ""
    @State private var appUser: AppUser?
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Fioletowy")
                    .ignoresSafeArea()
                

                VStack()
                {
                    Image("logoRed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 440, height: 280)
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
                    .padding(.bottom, 30)
                    
                
                    Button {
                        Task{
                            do{
                                let appUser = try await signInViewModel.signInWithEmail(email: email, password: password)
                                self.appUser = appUser
                                print(appUser.uid)
                                self.isLoggedIn = true
                            } catch{
                                print(error)
                            }
                        }
                        
                    } label: {
                        Text("Login")
                            .bold()
                            .font(.system(size: 25))
                            .frame(width: 350, height: 75)
                            .background(
                                RoundedRectangle(cornerRadius: 40, style: .continuous)
                                    .fill(Color("Czerwony"))
                            )
                            .foregroundColor(.white)
                    }
                    

                    Spacer()
                    
                    
                    NavigationLink(destination: RegisterView()
                        .navigationBarBackButtonHidden()
                    ) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            Text("Sign up")
                                .foregroundColor(Color("Czerwony"))
                                .fontWeight(.bold)
                                .underline(true, color: Color("Czerwony"))
                                .font(.system(size: 20))
                        }
                        .font(.system(size: 14))
                    }
                }
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                MainView().navigationBarBackButtonHidden(true)
                
            }
        }
//        .onTapGesture {
//            hideKeyboard()
//        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
