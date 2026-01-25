import SwiftUI

public struct BasketView: View {

    @StateObject var viewModel: BasketViewModel

    let userId: UUID

    public init(userId: UUID, viewModel: BasketViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.userId = userId
    }
    
    public var body: some View {
        VStack {
            
            if viewModel.baskets.isEmpty {
                Text ("Your cart is empty").padding()
            } else {
                List {
                    ForEach(viewModel.baskets, id: \.id) { basket in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(basket.productName)
                                    .font(.headline)
                                Text("price: \(String(format:"%.2f", basket.price))")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Text("Quantity: \(basket.quantity)")
                            Spacer()
                            Text(String(format:"%.2f", basket.price * Double(basket.quantity)))
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                HStack {
                    Spacer()
                    Text("Total: \(String(format:"%.2f", viewModel.calculateTotalPrice()))")
                        .font(.title2)
                        .padding()
                }
            }
        }
        .task {
            await viewModel.getBasket(userId: userId)
        }
    }
}
