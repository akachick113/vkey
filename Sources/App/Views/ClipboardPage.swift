//
//  ClipboardPage.swift
//  VKey
//
//  Settings for the clipboard history feature.
//

import SwiftUI

struct ClipboardPage: View {
    @ObservedObject var manager = ClipboardManager.shared
    @ObservedObject var state = AppState.shared

    var body: some View {
        VKPageContent {
            VKCard {
                VKSwitchRow("Bật lịch sử Clipboard", isOn: $manager.enabled)
                if manager.enabled {
                    VKDivider()
                    VKSwitchRow("Ghim trên cùng", isOn: $manager.pinOnTop)
                    VKDivider()
                    VKSwitchRow("Tự động ẩn", isOn: $manager.autoHide)
                    VKDivider()
                    VKRow(title: "Kích thước và vị trí cửa sổ") {
                        Button("Đặt lại") { manager.resetPickerLayout() }
                            .disabled(!manager.hasCustomLayout)
                    }
                }
            }

            if manager.enabled {
                VKSectionLabel("PHÍM TẮT")
                VKCard {
                    HotkeyEditor(status: $manager.hotKey, allowsModifierOnly: false, blocksLanguageKeys: state.useJISLanguageKeys)
                        .padding(.vertical, 11).padding(.horizontal, 16)
                }
                Text("Mặc định: ⌃V. Cần ít nhất một phím chức năng kèm một phím chữ.")
                    .font(.footnote)
                    .foregroundStyle(VKTheme.textSecondary)

                VKSectionLabel("LỊCH SỬ")
                VKCard {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Số mục tối đa")
                            Spacer()
                            Text("\(manager.maxItems)")
                                .foregroundStyle(VKTheme.textPrimary)
                                .font(.body.weight(.semibold))
                                .monospacedDigit()
                        }
                        // Label + .labelsHidden() stops Form from reserving a
                        // left label column (which pushed the track to the
                        // right half). No value labels → avoids the render glitch.
                        Slider(
                            value: Binding(
                                get: { Double(manager.maxItems) },
                                set: { manager.maxItems = Int($0.rounded()) }
                            ),
                            in: 10...100
                        ) {
                            Text("Số mục tối đa")
                        }
                        .labelsHidden().tint(VKTheme.accent)
                        HStack {
                            Text("10")
                            Spacer()
                            Text("100")
                        }
                        .font(.caption)
                        .foregroundStyle(VKTheme.textSecondary)
                    }
                    .padding(.vertical, 11).padding(.horizontal, 16)
                }
                Text("Clipboard từ trình quản lý mật khẩu và ứng dụng nhạy cảm sẽ không được lưu vào lịch sử.")
                    .font(.footnote)
                    .foregroundStyle(VKTheme.textSecondary)

                VKCard {
                    HStack {
                        Text("Đang lưu \(manager.items.count) mục")
                            .foregroundStyle(VKTheme.textSecondary)
                        Spacer()
                        Button("Xoá lịch sử", role: .destructive) { manager.clear() }
                            .buttonStyle(.bordered)
                            .disabled(manager.items.isEmpty)
                    }
                    .padding(.vertical, 11).padding(.horizontal, 16)
                }
                Text(
                    "Mục đã ghim (biểu tượng ghim trong bảng lịch sử, phím tắt ⌘P) luôn nằm trên cùng, không bị trôi khi vượt số mục tối đa và được giữ lại khi xoá lịch sử. Di chuột lên mục hình ảnh để xem trước phóng to."
                )
                .font(.footnote)
                .foregroundStyle(VKTheme.textSecondary)
            }
        }
    }
}
