//
//  AsyncStream.swift
//  SwiftConcurency
//
//  Created by Aya on 03/06/2025.
//

import SwiftUI

class AsyncStreamDataProvider {
    let prices = [105264, 105891, 106809, 109876, 110876]
    
    func getPrices(completion: @escaping(Int) -> Void ) {
        for i in 0..<prices.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                completion(self.prices[i])
            }
        }
    }
    
    func getAsyncStream() -> AsyncStream<Int> {
        return AsyncStream { continuation in
            self.getPrices { price in
                continuation.yield(price)
            }
        }
    }
}

class AsyncStreamViewModel: ObservableObject {
    @Published var currentPrice: Int = 0
    private let dataProvider = AsyncStreamDataProvider()
    
    init() {
        getDataWithCompeletionHandler()
    }
    
    func getDataWithCompeletionHandler() {
        dataProvider.getPrices { [weak self] price in
            self?.currentPrice = price
        }
    }
    
    func getDataWithStream() async {
        for await price in dataProvider.getAsyncStream() {
            self.currentPrice = price
        }
    }
}

struct AsyncStreamUIView: View {
    @StateObject var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        
        HStack {
            Text("BTC")
                .fontWeight(.bold)
            Spacer()
            
            Text("$\(viewModel.currentPrice)")
        }
        .padding()
        .task {
            await viewModel.getDataWithStream()
        }
    }
}

#Preview {
    AsyncStreamUIView()
}
