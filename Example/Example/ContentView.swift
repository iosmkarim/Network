//
//  ContentView.swift
//  Example
//
//  Created by Md Rezaul Karim on 12/27/24.
//

import SwiftUI
import Network
import Combine

struct ContentView: View {
    @State private var cancellables = Set<AnyCancellable>()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear {
            makeRequest()
        }
        .padding()
    }
    
    func makeRequest() {
        //https://jsonplaceholder.typicode.com/posts
        guard let url = URL(string: "https://jsonplaceholder.typicode.com") else { return }
        let builder = RequestBuilder(baseURL: url, path: "/posts")
        builder.set(method: .get)
        
        let network = NetworkManager()
        do {
            let response = try network.makeRequest(with: builder, type: [WelcomeElement].self)
            response.sink { completion in
                switch completion {
                case .finished:
                    print("******* finished")
                case .failure(let error):
                    print("******** \(error)")
                }
                
            } receiveValue: { value in
                print("********* \(value)")
            }
            .store(in: &cancellables)

        }catch let error {
            print("********* \(error)")
        }
        
    }
}

struct WelcomeElement: Codable {
    var userID, id: Int?
    var title, body: String?
}

#Preview {
    ContentView()
}
