//
//  TwoPaneLayoutView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 17/3/21.
//

import SwiftUI

struct TwoPaneLayoutView: View {
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        HStack {
            NavigationView {
                List {
                    Section(header: Text("Menu")) {
                        ForEach(Tabs.availableCases) { tab in
                            HorizontalTabView(tab: tab)
                                .withoutListRowInsets()
                        }
                    }
                    .accentColor(Assets.blue.color)
                    .padding(.top)
                }
                .listStyle(SidebarListStyle())
                .toolbarPrincipalImage(Image("Nordic"))
                .setTitle("nRF Edge Impulse")
            }
            .setBackgroundColor(.blue)
            .setSingleColumnNavigationViewStyle()
            .frame(width: 215, alignment: .leading)
            
            // Don't use appData.selectedTab?.view because SwiftUI will not switch well within them
            // if there's a DetailView pushed into the embedded NavigationView.
            VStack {
                switch appData.selectedTab {
                case .Devices?:
                    DeviceList()
                        .setAsDetailView(title: appData.selectedTab?.description)
                case .DataAcquisition?:
                    DataSamplesView()
                        .setAsDetailView(title: appData.selectedTab?.description)
                case .Deployment?:
                    DeploymentView()
                        .setAsDetailView(title: appData.selectedTab?.description)
                case .Inferencing?:
                    InferencingView()
                        .setAsDetailView(title: appData.selectedTab?.description)
                case .Settings?:
                    SettingsContentView()
                        .setAsDetailView(title: appData.selectedTab?.description)
                default:
                    AppHeaderView(.template)
                        .setAsDetailView(title: nil)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Detail View Configuration

private extension View {
    
    func setAsDetailView(title: String?) -> some View {
        self
            .setTitle(title ?? Constant.appName)
            .toolbar {
                ProjectSelectionView()
                    .toolbarItem()
            }
            .wrapInNavigationViewForiOS()
    }
}

// MARK: - Preview

#if DEBUG
struct TwoPaneLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(OSX)
        TwoPaneLayoutView()
            .environmentObject(Preview.mockScannerData)
            .environmentObject(Preview.projectsPreviewAppData)
        #elseif os(iOS)
        TwoPaneLayoutView()
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .environmentObject(Preview.mockScannerData)
            .environmentObject(Preview.projectsPreviewAppData)
        #endif
    }
}
#endif
