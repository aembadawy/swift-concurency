//
//  SwiftUIView.swift
//  SwiftConcurency
//
//  Created by Aya on 27/05/2025.
//

import SwiftUI

struct User: Identifiable {
    let name: String
    var email: String
    var id = UUID().uuidString
}

class ConcurrencyService {
    
    func fetchUsersAsync() async -> [User] {
        let users: [User] = [
            User(name: "Alice Smith", email: "alice@example.com"),
            User(name: "Bob Johnson", email: "bob@example.com"),
            User(name: "Charlie Davis", email: "charlie@example.com")
        ]
        return users
    }
    
    func fetchUsersCompletion(completion: @escaping([User]) -> Void) {
        let users: [User] = [
            User(name: "Alice Smith", email: "alice@example.com"),
            User(name: "Bob Johnson", email: "bob@example.com"),
            User(name: "Charlie Davis", email: "charlie@example.com")
        ]
        completion(users)
    }
}

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var users = [User]()
    @Published var isLoading = false
    @Published var isUpdating = false
    
    let service = ConcurrencyService()
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    func fetchUsers() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        let users = await service.fetchUsersAsync()
        isLoading = false
        self.users = users
    }
    
    func fetchUsersCompletion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.service.fetchUsersCompletion { [weak self] users in
                self?.users = users
            }
        }
    }
    
    func updateUsersEmails() async {
        var updatedUsers = [User]()
        isUpdating = true
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        for user in users {
            let newEmail = user.email.replacingOccurrences(of: "example",
                                                           with: "hey")
            let newUser = User(name: user.name, email: newEmail)
            updatedUsers.append(newUser)
        }
        isUpdating = false
        self.users = updatedUsers
    }
}

struct SwiftUIView: View {
    @StateObject var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading{
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.users) { user in
                        VStack(alignment: .leading) {
                            Text(user.name)
                            if viewModel.isUpdating {
                                ProgressView()
                            } else {
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
            
            Button("Updating Emails") {
                Task {
                    await viewModel.updateUsersEmails()
                }
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
