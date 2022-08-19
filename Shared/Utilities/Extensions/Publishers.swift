//
//  Publishers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import Foundation
import Combine
import iOS_Common_Libraries

// MARK: - sink

extension Publisher {
    
    func sinkReceivingError(onError errorValue: ((Error) -> Void)? = nil,
                            receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                DispatchQueue.main.async {
                    errorValue?(error)
                }
            default:
                break
            }
        }) { result in
            if let apiResponse = result as? HTTPResponse, !apiResponse.success {
                let errorMessage = apiResponse.error ?? "Server returned 'request was not a success' response."
                errorValue?((ErrorEvent(title: "Error", localizedDescription: errorMessage)))
                return
            }
            receiveValue(result)
        }
    }
    
    func sinkOrRaiseAppEventError(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                DispatchQueue.main.async {
                    AppEvents.shared.error = ErrorEvent(error)
                }
            default:
                break
            }
        }) { result in
            if let apiResponse = result as? HTTPResponse, !apiResponse.success {
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
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .userAuthenticationRequired, .appTransportSecurityRequiresSecureConnection:
                            DispatchQueue.main.async {
                                unauthorisedUserCallback()
                            }
                        default:
                            break
                        }
                    }
                    return Fail<Output, Failure>(error: error).eraseToAnyPublisher()
                }
                .subscribe(subscriber)
        }
    }
}
