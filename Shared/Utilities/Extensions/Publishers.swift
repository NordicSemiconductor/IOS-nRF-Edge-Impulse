//
//  Publishers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import Foundation
import Combine

// MARK: - SinkToKeyPath

extension Publisher {
    
    func sink<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, in root: Root, assigningInCaseOfError errorValue: Output) -> AnyCancellable {
        self.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(_):
                root[keyPath: keyPath] = errorValue
            default:
                break
            }
        }) { result in
            root[keyPath: keyPath] = result
        }
    }
    
    func sinkOrRaiseAppEventError(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                AppEvents.shared.error = ErrorEvent(error)
            default:
                break
            }
        }) { result in
            if let apiResponse = result as? APIResponse, !apiResponse.success {
                let errorMessage = apiResponse.error ?? "Server returned 'request was not a success' response."
                AppEvents.shared.error = ErrorEvent(title: "Error", localizedDescription: errorMessage)
                return
            }
            receiveValue(result)
        }
    }
}

// MARK: - OnUnauthorisedUserError

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
                        DispatchQueue.main.async {
                            unauthorisedUserCallback()
                        }
                    }
                    return Fail<Output, Failure>(error: error).eraseToAnyPublisher()
                }
                .subscribe(subscriber)
        }
    }
}
