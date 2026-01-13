import Foundation

import RxSwift

public extension ObservableType where Element == APIResponse {
    
    func map<T: Decodable>(_ type: T.Type) -> Observable<T> {
        
        flatMap {
            Observable.just(
                try $0.parse(type)
            )
        }
    }
}
