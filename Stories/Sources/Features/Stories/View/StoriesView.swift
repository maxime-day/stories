//
//  StoriesView.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import SwiftUI

struct StoriesView: View {
    @ObservedObject var viewModel: StoriesViewModel
    
    init(viewModel: StoriesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            if viewModel.state == .isLoaded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.stories) { story in
                            StoryView(story: story)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear {
            Task {
                try await viewModel.loadStories()
            }
        }
    }
}

#Preview {
    StoriesView(viewModel: {
        let viewModel = StoriesViewModel()
        viewModel.state = .isLoaded
        
        let story1 = StoryViewModel(id: "",
                                    isViewed: false,
                                    image: .dummy,
                                    username: "M_Daymard")
        
        let story2 = StoryViewModel(id: "",
                                    isViewed: true,
                                    image: .dummy,
                                    username: "other_user")
        
        viewModel.stories = [story1, story2]
        return viewModel
    }())
}
