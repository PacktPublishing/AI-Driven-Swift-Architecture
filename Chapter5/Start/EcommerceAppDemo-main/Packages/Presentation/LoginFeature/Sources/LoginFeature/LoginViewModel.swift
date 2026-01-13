import Foundation
import Combine
import RxSwift

import UserAbstraction
import DIAbstraction

import Utils

@MainActor
public final class LoginViewModel: ObservableObject {
    
    @Published public var userID: UUID?
    
    @Published public var isConnected: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private let loginUserUseCase: LoginUserUseCaseProtocol
    
    public init() {
        
        self.loginUserUseCase = DIContainer.shared.resolve(LoginUserUseCaseProtocol.self)!
        
    }
    
    func login(username: String) {
        
        let observable = loginUserUseCase.start(username: username)
            .share()
        
        observable
            .asPublisher()
            .map { $0.id }
            .receive(on: DispatchQueue.main)
            .assign(to: \.userID, on: self)
            .store(in: &cancellables)
        
        observable
            .asPublisher()
            .map { !$0.id.uuidString.isEmpty }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
                    
    }
    
}
