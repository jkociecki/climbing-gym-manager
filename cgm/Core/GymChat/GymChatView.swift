//
//  GymChatView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 18/12/2024.
//

import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    let userName: String
    let userImage: String
    let date: String
    let content: String
}

struct ContentView: View {
    @State private var posts: [Post] = [
        Post(userName: "Wade Warren",
             userImage: "person1", // Placeholder name for system image
             date: "8 lis 2024",
             content: "Cześć, szukam kogoś do wspólnego wspinania w weekend – ścianka \"Vertical Dream\", poziom 5c-6a. Ktoś chętny? ✨ Zapraszam na dobrą zabawę i może kawę po treningu ☕!"),
        
        Post(userName: "Jane Cooper",
             userImage: "person2",
             date: "8 lis 2024",
             content: "Dziś znowu przegrałem z \"Kobaltową Ścianą\" 😅 Ale kto się nie poddaje, ten kiedyś zawisnąć na topie musi! 💪😂"),
        
        Post(userName: "Leise Alexander",
             userImage: "person3",
             date: "8 lis 2024",
             content: "Nowa trasa w \"Gravity Spot\" – Zielona Grota 6b+. 💣 Kto pierwszy w tym tygodniu wchodzi na top, wygrywa pizzę na mój koszt! 🍕🔥 Czas start!")
    ]
    
    var body: some View {
        NavigationView {
            ZStack{
                Color(hex: "F7F7F7").ignoresSafeArea()
                PostView(post: posts[1])

            }
        }.background(Color(hex: "#F7F7F7"))
    }
}

struct PostView: View {
    let post: Post
    
    init(post :Post) {
        self.post = post
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle.fill") // Domyślna ikona użytkownika
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text(post.userName)
                        .font(.custom("Inter18pt-Light", size: 33))
                    Text(post.date)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Text("5 min ago")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            Text(post.content)
                .font(.body)
                .lineLimit(nil)
                .padding(.top, 4)
            
            Divider()
                .padding(.top, 20)
            
            HStack {
                Button(action: {
                    // Akcja odpowiedzi
                }) {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("Odpowiedz")
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
                Text("+7 Komentarze")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .background(Rectangle()
            .foregroundStyle(Color(.white))
            .cornerRadius(15)
        )
        .padding()
    }
}

// Podgląd w Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

