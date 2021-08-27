//
//  LoggedInRootView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine
import os

struct LoggedInRootView: View {
    
    private let logger = Logger(category: "LoggedInRootView")
    
    enum Error: Swift.Error {
        case anyError(Swift.Error)
        case describedError(String)
    }
    
    // MARK: Properties
    
    @EnvironmentObject var appData: AppData
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @State private var hasMadeUserRequest = false
    @State private var userCancellable: Cancellable? = nil
    @ObservedObject private var appEvents = AppEvents.shared
    
    // MARK: View
    
    var body: some View {
        layout.view()
            .onAppear() {
                guard !hasMadeUserRequest, !Constant.isRunningInPreviewMode else { return }
                requestUser()
            }
            .onDisappear() {
                userCancellable?.cancel()
            }
            .alert(item: $appEvents.error) { error in
                Alert(title: Text(error.title),
                      message: Text(error.localizedDescription))
            }.onAppear {
                appEvents.error = nil
            }
    }
}

// MARK: - Logic

extension LoggedInRootView {
    
    func requestUser() {
        guard let token = appData.apiToken,
              let httpRequest = HTTPRequest.getUser(using: token) else { return }
        appData.loginState = .loading
        userCancellable = Network.shared.perform(httpRequest, responseType: GetUserResponse.self)
            .compactMap { response -> Project? in
                hasMadeUserRequest = true
                appData.loginState = .complete(response.user, response.projects)
                return response.projects.first
            }
            .onUnauthorisedUserError(appData.logout)
            .sink(receiveCompletion: { completion in
                guard !Constant.isRunningInPreviewMode else { return }
                switch completion {
                case .failure(let error):
                    logger.error("Error: \(error.localizedDescription)")
                    appData.loginState = .error(error)
                case .finished:
                    break
                }
            },
            receiveValue: { project in
                appData.selectedProject = project
            })
    }
}

// MARK: - Layout

extension LoggedInRootView {
    
    var layout: LoggedInLayout {
        #if os(OSX)
        return .threePane
        #else
        if horizontalSizeClass == .compact {
            return .tabs
        }
        return .dualPane
        #endif
    }
    
    enum LoggedInLayout {
        case tabs
        case dualPane
        case threePane
        
        @ViewBuilder
        func view() -> some View {
            switch self {
            case .tabs:
                TabBarLayoutView()
            case .dualPane:
                TwoPaneLayoutView()
            case .threePane:
                ThreePaneLayoutView()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LoggedInRootView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(OSX)
        LoggedInRootView()
            .environmentObject(Preview.projectsPreviewAppData)
        #elseif os(iOS)
        Group {
            LoggedInRootView()
                .previewDevice("iPhone 11")
                .preferredColorScheme(.light)
                .environmentObject(Preview.projectsPreviewAppData)
        }
        Group {
            Landscape {
                LoggedInRootView()
                    .preferredColorScheme(.light)
                    .environmentObject(Preview.projectsPreviewAppData)
            }
        }
        Group {
            LoggedInRootView()
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
                .preferredColorScheme(.dark)
                .environmentObject(Preview.projectsPreviewAppData)
        }
        #endif
    }
}
#endif
