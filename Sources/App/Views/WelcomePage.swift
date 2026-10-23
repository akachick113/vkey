//
//  WelcomePage.swift
//  VKey
//

import SwiftUI

struct WelcomePage: View {
    @EnvironmentObject private var state: AppState
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            // App icon on the accent circle.
            ZStack {
                Circle()
                    .fill(VKTheme.accent.opacity(0.12))
                    .frame(width: 120, height: 120)
                if let icon = NSApp.applicationIconImage {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 96, height: 96)
                        .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
                } else {
                    Image(systemName: "keyboard")
                        .font(.system(size: 52))
                        .foregroundStyle(VKTheme.accent)
                }
            }

            // Welcome Text
            VStack(spacing: 6) {
                Text("Chào mừng đến với VKey")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(VKTheme.textPrimary)
                Text("Bộ gõ Tiếng Việt hiện đại, an toàn và siêu nhẹ cho macOS.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(VKTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            // Permissions Instruction Card
            VKCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title3)
                            .foregroundStyle(VKTheme.accent)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yêu cầu quyền Trợ năng (Accessibility)")
                                .font(.headline)
                                .foregroundStyle(VKTheme.textPrimary)
                            Text("Để VKey có thể nhận diện phím gõ và chuyển đổi thành chữ Tiếng Việt có dấu trực tiếp trên ứng dụng của bạn, macOS yêu cầu quyền Trợ năng.")
                                .font(.subheadline)
                                .foregroundStyle(VKTheme.textSecondary)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(18)
            }
            .padding(.horizontal, 32)

            // CTA and Status
            VStack(spacing: 14) {
                Button {
                    requestPermission()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                        Text("Mở Cài đặt hệ thống")
                    }
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
                .buttonStyle(VKPrimaryButtonStyle())
                .controlSize(.large)

                // Pulsing Status Indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(state.accessibilityGranted ? VKTheme.ok : VKTheme.warningIcon)
                        .frame(width: 8, height: 8)
                        .opacity(isPulsing ? 0.3 : 1.0)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)

                    Text("Đang chờ bạn bật quyền trong Cài đặt hệ thống...")
                        .font(.footnote)
                        .foregroundStyle(VKTheme.textSecondary)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
            }

            Spacer()
        }
        .frame(width: 480)
        .frame(maxHeight: .infinity)
        .background(VKTheme.windowBackground)
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.hasPrefix("welcome") == true }) {
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility = .hidden
                    window.isMovableByWindowBackground = true
                    window.isOpaque = false
                    window.backgroundColor = .clear
                }
            }
        }
        .onReceive(state.$accessibilityGranted) { granted in
            if granted {
                // close the welcome window
                if let welcomeWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "welcome" }) {
                    welcomeWindow.close()
                }
                // open settings window
                NotificationCenter.default.post(name: .vkOpenSettingsWindow, object: nil)
            }
        }
    }

    private func requestPermission() {
        NotificationCenter.default.post(name: .vkRequestAccessibility, object: nil)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
