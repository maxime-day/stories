//
//  StoriesView.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import SwiftUI

struct StoriesView: View {
    let viewModel = StoriesViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                let image = try await viewModel.fetchStories()
                print("got image !")
            }
            catch {
                print("error : \(error)")
            }
        }
    }
}

#Preview {
    StoriesView()
}
