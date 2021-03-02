//
//  Publishers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import Foundation
import Combine

extension Publisher {
    
    func onUnauthorisedUserError(_ unauthorisedUserCallback: @escaping () -> Void) -> Publishers.OnUnauthorisedUserError<Self> {
        return .init(upstream: self, unauthorisedUserCallback: unauthorisedUserCallback)
    }
}

extension Publishers {
    
    struct OnUnauthorisedUserError<Upstream: Publisher>: Publisher {
        
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        let upstream: Upstream
        let unauthorisedUserCallback: () -> Void
        
        init(upstream: Upstream, unauthorisedUserCallback: @escaping () -> Void) {
            self.upstream = upstream
            self.unauthorisedUserCallback = unauthorisedUserCallback
        }
        
        func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .catch { error -> AnyPublisher<Output, Failure> in
                    if let urlError = error as? URLError, urlError.code == .userAuthenticationRequired {
                        unauthorisedUserCallback()
                    }
                    return Fail<Output, Failure>(error: error).eraseToAnyPublisher()
                }
                .subscribe(subscriber)
        }
    }
}
