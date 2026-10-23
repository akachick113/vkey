//
//  SystemPage.swift
//  VKey
//
//  System integration: login item, dock/menu-bar icon, smart switching.
//

import SwiftUI

struct SystemPage: View {
    @EnvironmentObject private var state: AppState
    @ObservedObject private var updater = UpdateChecker.shared
    @State private var confirmReset = false

    var body: some View {
        VKPageContent {
            VKSectionLabel("KHỞI ĐỘNG")
            VKCard {
                VKSwitchRow("Khởi động cùng macOS", isOn: $state.runOnStartup)
                VKDivider()
                VKSwitchRow("Hiện bảng điều khiển khi khởi động", isOn: $state.showUIOnStartup)
            }

            VKSectionLabel("CẬP NHẬT")
            VKCard {
                VKSwitchRow(
                    "Tự động kiểm tra cập nhật",
                    isOn: Binding(get: { updater.autoCheckEnabled },
                                  set: { updater.autoCheckEnabled = $0 })
                )
                VKDivider()
                VKSwitchRow(
                    "Tự động tải và cài đặt khi thoát",
                    isOn: Binding(get: { updater.autoDownloadEnabled },
                                  set: { updater.autoDownloadEnabled = $0 })
                )
                .disabled(!updater.autoCheckEnabled)
                VKDivider()
                HStack(spacing: 8) {
                    Image(systemName: updateIcon)
                        .foregroundStyle(updateIconColor)
                    Text(updateStatusText)
                        .foregroundStyle(VKTheme.textSecondary)
                        .lineLimit(2)
                    Spacer()
                    if case .checking = updater.status {
                        ProgressView().controlSize(.small)
                    } else {
                        Button("Kiểm tra ngay") { updater.checkForUpdates() }
                            .disabled(!updater.canCheckForUpdates)
                    }
                }
                .padding(.vertical, 11).padding(.horizontal, 16)
                if case .available(let info) = updater.status {
                    VKDivider()
                    HStack {
                        Text("Phiên bản \(info) đã sẵn sàng.")
                        Spacer()
                        Button("Cập nhật…") { updater.checkForUpdates() }
                            .disabled(!updater.canCheckForUpdates)
                            .buttonStyle(VKPrimaryButtonStyle())
                    }
                    .padding(.vertical, 11).padding(.horizontal, 16)
                }
                if let lastCheck = updater.lastCheckDate {
                    VKDivider()
                    Text("Kiểm tra lần cuối: \(lastCheck.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundStyle(VKTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 11).padding(.horizontal, 16)
                }
                if let notice = updater.availabilityNotice {
                    VKDivider()
                    Text(notice)
                        .font(.footnote)
                        .foregroundStyle(VKTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 11).padding(.horizontal, 16)
                }
            }

            VKSectionLabel("BIỂU TƯỢNG")
            VKCard {
                VKSwitchRow("Biểu tượng đơn sắc trên thanh menu", isOn: $state.grayIcon)
                VKDivider()
                VKSwitchRow("Hiện biểu tượng ở Dock", isOn: $state.showIconOnDock)
            }

            VKSectionLabel("CHUYỂN CHẾ ĐỘ THÔNG MINH")
            VKCard {
                VKSwitchRow("Tự nhớ chế độ gõ theo từng ứng dụng", isOn: $state.useSmartSwitchKey)
                VKDivider()
                VKSwitchRow("Tự nhớ bảng mã theo từng ứng dụng", isOn: $state.rememberCode)
            }

            VKSectionLabel("ỨNG DỤNG LOẠI TRỪ")
            AppBundleListEditor(
                apps: $state.excludedApps,
                emptyHint: "Chưa có ứng dụng nào. Kéo thả ứng dụng vào đây, nhấn +, hoặc dùng menu \u{201C}Tắt VKey cho…\u{201D} trên thanh menu.",
                panelMessage: "Chọn ứng dụng để loại trừ (VKey sẽ không xử lý phím trong ứng dụng đó)"
            )
            Text("Trong các ứng dụng này, VKey bỏ qua hoàn toàn — gõ như khi chưa cài (phù hợp terminal, IDE, game…). Khác với \u{201C}nhớ chế độ theo app\u{201D}: loại trừ là tắt cứng, luôn ưu tiên.")
                .font(.footnote)
                .foregroundStyle(VKTheme.textSecondary)

            VKSectionLabel("TƯƠNG THÍCH NÂNG CAO")
            VKCard {
                VKSwitchRow("Gửi phím từng bước (chậm nhưng tương thích cao)", isOn: $state.sendKeyStepByStep)
                VKDivider()
                VKSwitchRow("Tương thích bố cục bàn phím khác QWERTY", isOn: $state.performLayoutCompat)
            }
            Text("Khi trang Bộ gõ đang gõ kiểu JIS (Tự động với bàn phím JIS, hoặc chọn JIS), tuỳ chọn này không có tác dụng.")
                .font(.footnote)
                .foregroundStyle(VKTheme.textSecondary)

            VKCard {
                HStack {
                    Text("Khôi phục toàn bộ cài đặt về mặc định.")
                        .foregroundStyle(VKTheme.textSecondary)
                    Spacer()
                    Button("Cài đặt mặc định", role: .destructive) { confirmReset = true }
                        .buttonStyle(.bordered)
                }
                .padding(.vertical, 11).padding(.horizontal, 16)
            }
        }
        .confirmationDialog("Bạn có chắc chắn muốn thiết lập lại cấu hình mặc định?",
                            isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Khôi phục mặc định", role: .destructive) {
                state.resetToDefaults()
            }
            Button("Huỷ", role: .cancel) {}
        }
    }

    private var updateStatusText: String {
        switch updater.status {
        case .idle:        return "Phiên bản hiện tại \(updater.currentVersion)."
        case .checking:    return "Đang kiểm tra cập nhật…"
        case .upToDate:    return "Bạn đang dùng bản mới nhất (\(updater.currentVersion))."
        case .available(let info): return "Đã có bản \(info)."
        case .failed(let msg):     return msg
        }
    }

    private var updateIcon: String {
        switch updater.status {
        case .available: return "arrow.down.circle.fill"
        case .failed:    return "exclamationmark.triangle"
        case .upToDate:  return "checkmark.circle"
        default:         return "arrow.triangle.2.circlepath"
        }
    }

    private var updateIconColor: Color {
        switch updater.status {
        case .available, .upToDate: return VKTheme.ok
        case .failed:               return VKTheme.warningIcon
        default:                    return VKTheme.textSecondary
        }
    }
}
