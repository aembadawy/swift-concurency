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
    
    func fetchUsersAsync() async throws -> [User] {
        
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        let users: [User] = [
            User(name: "Alice Smith", email: "alice@example.com"),
            User(name: "Bob Johnson", email: "bob@example.com"),
            User(name: "Charlie Davis", email: "charlie@example.com")
        ]
        let error = Bool.random() // Simulate error in API
        
        if error {
            throw URLError(.badServerResponse)
        } else {
            return users
        }
    }
    
    func fetchUsersCompletion(completion: @escaping(Result<[User], Error>) -> Void) {
        
        let users: [User] = [
            User(name: "Alice Smith", email: "alice@example.com"),
            User(name: "Bob Johnson", email: "bob@example.com"),
            User(name: "Charlie Davis", email: "charlie@example.com")
        ]
        
        let error = Bool.random() // Simulate that an error occured
        if error {
            completion(.failure(URLError(.badServerResponse)))
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion(.success(users))
            }
        }
    }
}

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var users = [User]()
    @Published var isLoading = false
    @Published var isUpdating = false
    
    let service = ConcurrencyService()
    
    init() {
        Task {
            await fetchUsers() // using async
        }
        
        fetchUsersCompletion() // using CH
    }
    
    func fetchUsers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let users = try await service.fetchUsersAsync()
            self.users = users
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func fetchUsersCompletion() {
        self.service.fetchUsersCompletion { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func updateUsersEmails() async {
        var updatedUsers = [User]()
        isUpdating = true
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        for user in users {
            let newEmail = user.email.replacingOccurrences(of: "example",
                                                           with: "gmail")
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
            .frame(width: 310, height: 48)
            .background(.blue)
            .foregroundStyle(.white)
            .cornerRadius(12)
            .padding()
        }
    }
}

#Preview {
    SwiftUIView()
}
