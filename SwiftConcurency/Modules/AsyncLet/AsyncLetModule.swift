//
//  AsyncLetModule.swift
//  SwiftConcurency
//
//  Created by Aya on 02/06/2025.
//

import SwiftUI

struct UserStates {
    let posts: Int
    let followers: Int
    let following: Int
}

class UserStatesViewModel: ObservableObject {
    @Published var userStates: UserStates?
    
    func getUserStates() async {
        async let posts = getUserPosts()
        async let followers = getUserFollowers()
        async let following = getUserFollowing()
        
        self.userStates = await UserStates(
            posts: posts,
            followers: followers,
            following: following
        )
    }
    
    private func getUserPosts() async -> Int {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        return 9
    }
    
    private func getUserFollowing() async -> Int {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return 20
    }
    
    private func getUserFollowers() async -> Int {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return 1
    }
}
struct AsyncLetModule: View {
    @StateObject var viewModel = UserStatesViewModel()
    
    var body: some View {
        HStack (spacing: 20){
            VStack {
                if let posts = viewModel.userStates?.posts {
                    Text("\(posts)")
                        .fontWeight(.bold)
                } else {
                    ProgressView()
                }
                Text("Posts")
            }
            VStack {
                if let followers = viewModel.userStates?.followers {
                    Text("\(followers)")
                        .fontWeight(.bold)
                } else {
                    ProgressView()
                }
                Text("Followers")
            }
            VStack {
                if let following = viewModel.userStates?.following {
                    Text("\(following)")
                        .fontWeight(.bold)
                } else {
                    ProgressView()
                }
                Text("Following")
            }
        }
        .task {
            await viewModel.getUserStates()
        }
    }
}

#Preview {
    AsyncLetModule()
}
