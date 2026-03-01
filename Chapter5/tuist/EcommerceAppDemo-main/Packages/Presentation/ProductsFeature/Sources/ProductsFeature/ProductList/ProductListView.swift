import SwiftUI

public struct ProductListView: View {

    @StateObject var productsListViewModel: ProductsListViewModel

    var userId: UUID

    public init(userId: UUID, productsListViewModel: ProductsListViewModel) {
        _productsListViewModel = StateObject(wrappedValue: productsListViewModel)
        self.userId = userId
    }
    
    public var body: some View {

        NavigationView {
            List(
                productsListViewModel.products,
                id: \.id
            ) { product in
                NavigationLink(
                    destination: ItemDetailView(viewModel: ItemDetailViewModel(
                        product: product,
                        userId: userId,
                        addProductUseCase: productsListViewModel.addProductUseCaseFactory(),
                        sendProductDetailAnalyticsDataUseCase: productsListViewModel.sendAnalyticsUseCaseFactory()
                    ))
                ) {
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text(String(format: "%.2f €", product.price))
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Products")
        }
    }
}
