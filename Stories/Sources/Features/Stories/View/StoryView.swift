//
//  StoryView.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import SwiftUI

struct StoryView: View {
    private enum Constants {
        static let size: CGFloat = 65
    }
    
    let story: StoryViewModel
    
    var gradientColors: [Color] {
        story.isViewed ? [.gray, .black] : [.newStoryGradientStart, .newStoryGradientEnd]
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                    .frame(width: 70, height: 70)
                
                Image(uiImage: story.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Constants.size, height: Constants.size)
                    .clipShape(Circle())
            }
            Text(story.username)
                .font(.caption2)
                .foregroundColor(.primary)
                .frame(width: Constants.size)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(5)
    }
}

#Preview {
    StoryView(story: {
        let viewModel = StoryViewModel(id: "",
                                       isViewed: false,
                                       image: .dummy,
                                       username: "M_Daymard")
        return viewModel
    }())
}
