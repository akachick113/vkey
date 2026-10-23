//
//  SettingsRootView.swift
//  VKey
//
//  Settings window: custom sidebar + detail pane. A hand-rolled sidebar avoids
//  NavigationSplitView drawing its selection row into the titlebar on macOS 26.
//

import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            VStack(spacing: 0) {
                if state.selectedPage == .typing {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            header
                            TypingPage()
                        }
                        .padding(.horizontal, 32).padding(.top, 28).padding(.bottom, 28)
                    }
                } else {
                    header.padding(.horizontal, 32).padding(.top, 28).padding(.bottom, 18)
                    Group {
                        switch state.selectedPage {
                        case .typing: EmptyView()
                        case .macro: MacroPage()
                        case .convert: ConvertPage()
                        case .clipboard: ClipboardPage()
                        case .system: SystemPage()
                        case .about: AboutPage()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(VKTheme.windowBackground)
        }
        .frame(minWidth: 860, maxWidth: 860, minHeight: 560, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.hasPrefix("settings") == true }) {
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility = .hidden
                    window.isMovableByWindowBackground = true
                    window.minSize = NSSize(width: 860, height: 560)
                    window.maxSize = NSSize(width: 860, height: CGFloat.greatestFiniteMagnitude)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(state.selectedPage.title).font(.system(size: 24, weight: .bold))
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(VKTheme.textPrimary)
            Spacer(minLength: 0)
            if state.selectedPage == .typing {
                HStack(spacing: 8) {
                    Text("Bàn phím").font(.system(size: 11)).foregroundStyle(VKTheme.textSecondary)
                        .fixedSize(horizontal: true, vertical: false)
                    VKSegmented(title: "Bàn phím", selection: $state.keyboardMode,
                                options: ["Tự động", "JIS (Nhật)", "Tiếng Anh (US)"])
                        .frame(width: 300)
                }
            }
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("VKey").font(.system(size: 20, weight: .bold)).foregroundStyle(VKTheme.textPrimary)
                Text("Việt · 日本語").font(.system(size: 11)).foregroundStyle(VKTheme.textSecondary)
            }
            .padding(.top, 38).padding(.horizontal, 8)
            VStack(spacing: 6) {
                ForEach(SettingsPage.allCases) { page in
                    Button { state.selectedPage = page } label: {
                        HStack(spacing: 10) {
                            Circle().fill(state.selectedPage == page ? VKTheme.accent : .clear)
                                .frame(width: 6, height: 6).accessibilityHidden(true)
                            Text(page.title)
                                .font(.system(size: 13, weight: state.selectedPage == page ? .semibold : .regular))
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(state.selectedPage == page ? VKTheme.accentText : VKTheme.textPrimary)
                        .padding(.vertical, 10).padding(.horizontal, 12)
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .background {
                        if state.selectedPage == page {
                            RoundedRectangle(cornerRadius: 8).fill(VKTheme.card)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(VKTheme.border, lineWidth: 1))
                        }
                    }
                    .accessibilityAddTraits(state.selectedPage == page ? .isSelected : [])
                }
            }
            Spacer()
            HStack(spacing: 8) {
                Circle().fill(state.accessibilityGranted ? VKTheme.ok : VKTheme.warningIcon)
                    .frame(width: 7, height: 7).accessibilityHidden(true)
                Text(state.accessibilityGranted ? "Đã sẵn sàng" : "Cần quyền Trợ năng")
                    .font(.system(size: 11, weight: .medium)).foregroundStyle(VKTheme.textSecondary)
                Spacer(minLength: 0)
            }
            .padding(10)
            .background(VKTheme.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(VKTheme.border, lineWidth: 1))
        }
        .padding(14).frame(width: 200)
        .background(VKTheme.sidebarBackground)
        .overlay(alignment: .trailing) { Rectangle().fill(VKTheme.border).frame(width: 1) }
    }
}
