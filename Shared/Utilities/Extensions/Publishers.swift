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
            if let apiResponse = result as? APIResponse, !apiResponse.success {
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

// MARK: - OnlyDecode

extension Publisher {
    
    func onlyDecode<T: Codable>(type: T.Type) -> Publishers.OnlyDecode<Self, T> {
        return .init(upstream: self)
    }
}

extension Publishers {
    
    struct OnlyDecode<Upstream: Publisher, DecodedOutput: Codable>: Publisher where Upstream.Output == Data {
        
        typealias Output = DecodedOutput
        typealias Failure = Upstream.Failure
        
        private let upstream: Upstream
        private let decoder: JSONDecoder
        
        init(upstream: Upstream) {
            self.upstream = upstream
            self.decoder = JSONDecoder()
        }
        
        func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, DecodedOutput == S.Input {
            self.upstream
                .compactMap { try? decoder.decode(DecodedOutput.self, from: $0) }
                .subscribe(subscriber)
        }
    }
}

// MARK: - GatherData

extension Publisher {
    
    func gatherData<T: Codable>(ofType type: T.Type) -> Publishers.GatherData<Self, T> {
        return .init(upstream: self)
    }
}

extension Publishers {
    
    struct GatherData<Upstream: Publisher, DecodedOutput: Codable>: Publisher where Upstream.Output == Data {
        
        typealias Output = DecodedOutput
        typealias Failure = Upstream.Failure
        
        private let upstream: Upstream
        private let decoder: JSONDecoder
        
        init(upstream: Upstream) {
            self.upstream = upstream
            self.decoder = JSONDecoder()
        }
        
        func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, DecodedOutput == S.Input {
            self.upstream
                .scan(Data(), { $0 + $1 })
                .compactMap { try? decoder.decode(DecodedOutput.self, from: $0) }
                .subscribe(subscriber)
        }
    }
}

extension Publisher {
    func justDoIt(_ action: @escaping (Self.Output) -> Void) -> Publishers.JustDoIt<Self> {
        return .init(action: action, upstream: self)
    }
}

extension Publishers {
    struct JustDoIt<Upstream: Publisher>: Publisher {
        let action: (Output) -> Void
        let upstream: Upstream
        
        func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            upstream
                .map { output in
                    action(output)
                    return output
                }
                .subscribe(subscriber)
        }
        
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
    }
}

extension Publisher {
    func eraseToAnyVoidPublisher() -> AnyPublisher<Void, Self.Failure> {
        self
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
}
