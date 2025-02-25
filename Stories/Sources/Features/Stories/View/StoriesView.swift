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
            switch viewModel.state {
            case .idle:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .isLoading, .isLoaded:
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ForEach(viewModel.stories) { story in
                            StoryView(story: story)
                                .onAppear {
                                    if story.id == viewModel.stories.last?.id {
                                        Task {
                                            try await viewModel.loadMore()
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            case .requiresNetwork:
                Text("No internet connection, please try again")
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
