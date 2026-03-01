import SwiftUI

import ProductAbstraction

struct ItemDetailView: View {
    
    @State private var quantity = 1
    
    @ObservedObject var viewModel: ItemDetailViewModel
    
    var body: some View {
        
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                
                Text(viewModel.product.name)
                    .font(.title)
                
                Text(viewModel.product.description)
                    .font(.body)
                
                Text("\(String(format: "%.2f €", viewModel.product.price))")
                    .font(.callout)
                    .bold()
                
                Stepper("Quantity : \(viewModel.quantity)", value: $viewModel.quantity, in: 1...viewModel.product.quantity)
                
            }
            
            Spacer()
            
            Button("Add to Basket") {
                
                viewModel.addProduct()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
