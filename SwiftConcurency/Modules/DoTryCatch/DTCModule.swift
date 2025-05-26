//
//  DTCModule.swift
//  SwiftConcurency
//
//  Created by Aya on 26/05/2025.
//

import SwiftUI

enum EncryptionError: Error {
    case weak
    case empty
}

struct Encryptor {
    func encrypt(_ message: String,
                 password: String) throws -> String {
        guard !password.isEmpty else { throw EncryptionError.empty}
        guard password.count < 6 else { throw EncryptionError.weak}
        let encrypted = password + message + password
        return String (encrypted.reversed())
    }
}

struct DTCModule: View {
    let encryptor = Encryptor()
    let message = "Hello, World!"
    var encryptedMassage: String {
        do {
            return try encryptor.encrypt(message, password: "X1W3E4T6")
        } catch let error as EncryptionError {
            return "Encryption Error \(error)"
        } catch {
            return "Unknown Error: \(error.localizedDescription)"
        }
    }
    var body: some View {
        Text("Message: \(message)")
        Text("Encrypted: \(message)")
    }
}

#Preview {
    DTCModule()
}
