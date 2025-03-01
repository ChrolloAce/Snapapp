import SwiftUI

struct MainTabBar: View {
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    router.navigateToTab(tab)
                } label: {
                    Image(systemName: tab.icon)
                        .font(.system(size: 24))
                        .foregroundColor(router.currentTab == tab ? .white : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(Color.black)
    }
} 