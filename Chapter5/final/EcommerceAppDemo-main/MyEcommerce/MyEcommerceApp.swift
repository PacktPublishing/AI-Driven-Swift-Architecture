import SwiftUI
import Factory

import ProductsFeature
import LoginFeature
import BasketFeature

import UserDomain
import UserData

import ProductDomain
import ProductData

import BasketDomain
import BasketData

import DIAbstraction

import Analytics
import AnalyticsDomain

enum Screen {
    case Products
    
    case Basket
}

final class TabRouter: ObservableObject {
    
    @Published var screen: Screen = .Products
    
    func change(to screen: Screen) {
        self.screen = screen
    }
}

@main
struct MyEcommerceApp: App {

    @StateObject private var tabRouter = TabRouter()

    @StateObject private var loginViewModel: LoginViewModel

    init() {
        // Factory handles dependency registration automatically
        // Dependencies are resolved lazily when first accessed
        // Create LoginViewModel with Factory-resolved dependency
        let loginUseCase = Container.shared.loginUserUseCase()
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(loginUserUseCase: loginUseCase))
    }
    
    var body: some Scene {
        WindowGroup {
            
            LoginView(loginViewModel: loginViewModel)
                .fullScreenCover(isPresented: $loginViewModel.isConnected) {
                    
                    if let userId = loginViewModel.userID {
                        
                        TabView(selection: $tabRouter.screen) {

                            ProductListView(
                                userId: userId,
                                productsListViewModel: ProductsListViewModel(
                                    getProductsUseCase: Container.shared.getProductsUseCase(),
                                    addProductUseCaseFactory: { Container.shared.addProductUseCase() },
                                    sendAnalyticsUseCaseFactory: { Container.shared.sendProductDetailAnalyticsDataUseCase() }
                                )
                            )
                            .tag(Screen.Products)
                            .environmentObject(tabRouter)
                            .tabItem {
                                Label("Products", systemImage: "drop.halffull")
                            }

                            BasketView(
                                userId: userId,
                                viewModel: BasketViewModel(
                                    getBasketUseCase: Container.shared.getBasketUseCase()
                                )
                            )
                            .tag(Screen.Basket)
                            .tabItem {
                                Label("Basket", systemImage: "cart.fill")
                            }
                        }
                        
                         
                        
                    } else {
                        
                        Text("Connexion Error")
                    }
                }
        }
    }
}

