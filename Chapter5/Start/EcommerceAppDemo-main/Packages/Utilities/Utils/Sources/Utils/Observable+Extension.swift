import RxSwift
import Combine

public extension Observable {
    
    func asPublisher() -> AnyPublisher<Element, Never> {
        let subject = PassthroughSubject<Element, Error>()
        
        let disposable = self.subscribe(
            onNext: { element in
                subject.send(element)
            },
            onError: { error in
                subject.send(completion: .failure(error))
            },
            onCompleted: {
                subject.send(completion: .finished)
            },
            onDisposed: {
                // Do any cleanup if necessary when the subscription is disposed of
            }
        )
        
        return subject
            .handleEvents(receiveCancel: {
                disposable.dispose()
            })
            .catch { _ in Empty<Element, Never>() }
            .eraseToAnyPublisher()
    }
}
