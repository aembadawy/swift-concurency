//
//  ImagesModule.swift
//  SwiftConcurency
//
//  Created by Aya on 02/06/2025.
//

import SwiftUI

class ImageDownloder {
    let url = URL(string: "https://picsum.photos/200")!
    func imageDownloader() async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else { throw URLError(.badURL) }
        return image
    }
}

class ImageViewModel: ObservableObject {
    @Published var image: UIImage?
    
    private let downloader = ImageDownloder()
    
    init() {
        Task { await self.downloadImage() }
    }
    
    func downloadImage() async {
        do {
            self.image = try await downloader.imageDownloader()
        } catch {
            print("Failed to download image: \(error.localizedDescription)")
        }
    }
}

struct ImagesModule: View {
    @StateObject var viewModel = ImageViewModel()
    let url = URL(string: "https://picsum.photos/200")!

    var body: some View {
        VStack(alignment: .center, spacing: 100){
            if let image = viewModel.image {
                let image = Image(uiImage: image)
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .cornerRadius(12)
            } else {
                ProgressView()
            }
            
            // Async image doing the same exact operation
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .cornerRadius(12)
            } placeholder: {
                ProgressView()
            }

        }
    }
}

#Preview {
    ImagesModule()
}
