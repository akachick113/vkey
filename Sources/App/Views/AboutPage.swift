//
//  AboutPage.swift
//  VKey
//

import SwiftUI

struct AboutPage: View {
    @ObservedObject private var updater = UpdateChecker.shared
    private var versionShort: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    private var versionBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 8)

                    if let icon = NSApp.applicationIconImage {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 96, height: 96)
                            .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
                    }

                    Text("VKey")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 6)

                    Text("Bộ gõ Tiếng Việt hiện đại cho macOS")
                        .font(.callout)
                        .foregroundStyle(VKTheme.textSecondary)
                        .padding(.top, 2)

                    Text("Phiên bản \(versionShort) (\(versionBuild))")
                        .font(.system(size: 11))
                        .foregroundStyle(VKTheme.textSecondary)
                    .padding(.top, 6)

                    Button("Kiểm tra cập nhật") {
                        updater.checkForUpdates()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!updater.canCheckForUpdates)
                    .controlSize(.small)
                    .padding(.top, 8)

                    VStack(spacing: 6) {
                        InfoRow(icon: "keyboard",
                                title: "Bộ gõ",
                                caption: "Telex, VNI, bảng mã phổ biến và các tuỳ chọn chính tả.")
                        InfoRow(icon: "app.badge",
                                title: "Tương thích ứng dụng",
                                caption: "Hỗ trợ Spotlight, Raycast, Alfred và cấu hình riêng từng ứng dụng.")
                        InfoRow(icon: "doc.on.clipboard",
                                title: "Tiện ích hằng ngày",
                                caption: "Chuyển mã nhanh, gõ tắt, lịch sử clipboard và đồng bộ iCloud Drive.")
                        InfoRow(icon: "speedometer",
                                title: "Hiệu năng",
                                caption: "Event hook và engine C++ được tối ưu cho độ trễ thấp khi gõ.")
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 34)
                    .frame(maxWidth: 620)

                    Spacer(minLength: 8)

                    Text("Phát triển bởi **Trung Đức** (akachick113) · © 2026")
                        .font(.system(size: 11))
                        .foregroundStyle(VKTheme.textSecondary)

                    VStack(spacing: 5) {
                        HStack(spacing: 16) {
                            Link("Mã nguồn", destination: URL(string: "https://github.com/akachick113/vkey")!)
                            Link("Ghi công", destination: URL(string: "https://github.com/akachick113/vkey/blob/main/NOTICE.md")!)
                            Link("Giấy phép GPL v3", destination: URL(string: "https://www.gnu.org/licenses/gpl-3.0.html")!)
                        }
                        .foregroundStyle(VKTheme.accentText)
                        .tint(VKTheme.accentText)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(VKTheme.textSecondary)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(VKTheme.textPrimary).tint(VKTheme.accent)
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let caption: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VKTheme.accent)
                .frame(width: 32, height: 32)
                .background(VKTheme.segmentTrack, in: RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.semibold))
                Text(caption)
                    .font(.system(size: 11))
                    .foregroundStyle(VKTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(VKTheme.card, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(VKTheme.border, lineWidth: 1)
        )
    }
}
