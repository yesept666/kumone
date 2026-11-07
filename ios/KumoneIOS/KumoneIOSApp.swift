import SwiftUI
import KumoneIOSFeature

@main
struct KumoneIOSApp: App {
    @UIApplicationDelegateAdaptor(DownloadAppDelegate.self) private var downloadDelegate
    @State private var showSplash = true
    @State private var splashOpacity = 0.0
    @State private var splashOffset: CGFloat = 0

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack {
                    IOSMainWindow()
                    if showSplash {
                        SplashView()
                            .opacity(splashOpacity)
                            .offset(y: splashOffset)
                            .zIndex(1)
                    }
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) {
                        splashOpacity = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            splashOpacity = 0.0
                            splashOffset = -geometry.size.height
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

/// Launch splash: "欢迎回来，Hailie。" fades in, holds, then fades out
/// to reveal the main interface. Shown once per launch.
private struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            Text("欢迎回来，Hailie。")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(splashTextColor)
        }
    }

    /// Klein Blue (#002FA7) in light mode; a lighter blue in dark mode
    /// so it stays readable.
    private var splashTextColor: Color {
        colorScheme == .dark
            ? Color(red: 0.45, green: 0.6, blue: 1.0)
            : Color(red: 0.0, green: 0.184, blue: 0.655)
    }
}

final class DownloadAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        OfflineDownloadEvents.handleBackgroundSession(identifier: identifier, completion: completionHandler)
    }
}

// MARK: - CarPlay

import CarPlay
import UIKit

/// CarPlay template scene delegate — instantiated automatically by UIApplicationSceneManifest in Info.plist.
/// It just forwards the connect/disconnect callbacks into `CarPlayConnector` inside KumoneCore;
/// the app target itself stays as a thin bridge and owns no CarPlay logic of its own.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {}

extension CarPlaySceneDelegate {
    func templateApplicationScene(
        _ scene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        CarPlayConnector.shared.didConnect(
            interfaceController: interfaceController,
            window: scene.carWindow
        )
    }

    func templateApplicationScene(
        _ scene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        CarPlayConnector.shared.didDisconnect()
    }
}
