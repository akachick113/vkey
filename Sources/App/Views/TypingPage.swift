//
//  TypingPage.swift
//  VKey
//
//  Core typing configuration: language, input type, code table,
//  switch hotkey and engine behaviour toggles.
//

import SwiftUI
import UniformTypeIdentifiers

struct TypingPage: View {
    @EnvironmentObject private var state: AppState
    @State private var selectedAXApp: String?
    @State private var isAXAppDropTargeted = false

    private var beepBinding: Binding<Bool> {
        Binding {
            state.switchKeyStatus & 0x8000 != 0
        } set: { on in
            if on { state.switchKeyStatus |= 0x8000 } else { state.switchKeyStatus &= ~0x8000 }
        }
    }

    private var keyboardStatus: KeyboardModeStatus.Result {
        KeyboardModeStatus.result(mode: state.keyboardMode, hardwareIsJIS: state.hardwareKeyboardIsJIS)
    }
    private var language: LanguageIndicator {
        .current(isVietnamese: state.isVietnamese, inputSourceIsLatin: state.inputSourceIsLatin)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if keyboardStatus.isWarning {
                VKBanner(message: keyboardStatus.message, actionTitle: "Về Tự động") { state.keyboardMode = 0 }
            } else {
                HStack(spacing: 7) {
                    Circle().fill(VKTheme.ok).frame(width: 6, height: 6).accessibilityHidden(true)
                    Text(keyboardStatus.message).font(.system(size: 12)).foregroundStyle(VKTheme.textSecondary)
                }
            }
            HStack(spacing: 10) {
                languageTile(.vietnamese, title: "Việt", subtitle: "\(AppState.inputTypeNames[state.inputType]) · \(state.codeTable == 0 ? "Unicode" : AppState.codeTableNames[state.codeTable])")
                languageTile(.english, title: "Anh", subtitle: "Chữ Latin, không dấu")
                languageTile(.japanese, title: "日本語", subtitle: keyboardStatus.treatsAsJIS ? "Bộ gõ Nhật của macOS" : "Chọn trong menu Nguồn nhập của macOS")
            }
            VKCard {
                VKRow(title: "Kiểu gõ") {
                    VKSegmented(title: "Kiểu gõ", selection: $state.inputType, options: AppState.inputTypeNames)
                        .frame(width: 370)
                }
                VKDivider()
                VKRow(title: "Bảng mã") {
                    Picker("Bảng mã", selection: $state.codeTable) {
                        ForEach(AppState.codeTableNames.indices, id: \.self) { Text(AppState.codeTableNames[$0]).tag($0) }
                    }.labelsHidden().pickerStyle(.menu).frame(width: 215)
                }
                VKDivider()
                VKRow(title: "Phím chuyển Việt ⇄ Anh") {
                    VStack(alignment: .leading, spacing: 6) {
                        HotkeyEditor(status: $state.switchKeyStatus,
                                     blocksLanguageKeys: state.useJISLanguageKeys && state.keyboardMode != 2)
                        Text("Có thể dùng riêng tổ hợp phím chức năng, ví dụ ⌃⇧ (Control+Shift): bấm giữ rồi thả ra để ghi.")
                            .font(.system(size: 11)).foregroundStyle(VKTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: 330)
                }
                VKDivider()
                switchRow("Kêu beep khi chuyển chế độ", beepBinding)
                VKDivider()
                switchRow("Dùng 英数 / かな để chuyển ngôn ngữ", $state.useJISLanguageKeys,
                          subtitle: state.keyboardMode == 2 ? "Không dùng khi chọn bàn phím Tiếng Anh" : "かな: sang tiếng Nhật · 英数: về chữ Latin, bấm lần nữa để đổi Việt ⇄ Anh",
                          disabled: state.keyboardMode == 2)
            }
            VKSectionLabel("CHÍNH TẢ")
            VKCard {
                switchRow("Kiểm tra chính tả", $state.checkSpelling)
                VKDivider()
                switchRow("Khôi phục phím nếu từ sai chính tả", $state.restoreIfWrongSpelling, disabled: !state.checkSpelling)
                VKDivider()
                switchRow("Tạm tắt kiểm tra chính tả bằng phím ⌃", $state.tempOffSpelling, disabled: !state.checkSpelling)
                VKDivider()
                switchRow("Cho phép phụ âm Z, F, W, J đầu từ", $state.allowZFWJ, disabled: !state.checkSpelling)
                VKDivider()
                switchRow("Dấu thanh kiểu mới (oà, uý)", $state.modernOrthography)
                VKDivider()
                switchRow("Bỏ dấu tự do", $state.freeMark)
            }
            VKSectionLabel("GÕ NHANH")
            VKCard {
                switchRow("Gõ nhanh Telex (cc→ch, gg→gi, …)", $state.quickTelex)
                VKDivider()
                switchRow("Phụ âm đầu nhanh (f→ph, j→gi, w→qu)", $state.quickStartConsonant)
                VKDivider()
                switchRow("Phụ âm cuối nhanh (g→ng, h→nh, k→ch)", $state.quickEndConsonant)
                VKDivider()
                switchRow("Tự viết hoa chữ đầu câu", $state.upperCaseFirstChar)
            }
            VKSectionLabel("TƯƠNG THÍCH")
            VKCard {
                switchRow("Sửa lỗi gợi ý của trình duyệt và Excel", $state.fixRecommendBrowser,
                          subtitle: "Tự bỏ qua trong Adobe/Affinity để không hiện ký tự lỗi (ô vuông ✕).")
                VKDivider()
                switchRow("Sửa lỗi nhân Chromium (thử nghiệm)", $state.fixChromiumBrowser, disabled: !state.fixRecommendBrowser)
                VKDivider()
                switchRow("Tạm tắt VKey bằng phím ⌘", $state.tempOffByCommand)
                VKDivider()
                switchRow("Tắt Tiếng Việt khi dùng bàn phím ngôn ngữ khác", $state.otherLanguage)
            }
            VKSectionLabel("HỖ TRỢ TRỢ NĂNG")
            VKCard {
                switchRow("Bật Trợ năng cho Spotlight, Raycast, Alfred", $state.fixSpotlight)
                VKDivider()
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        if state.axIncludeApps.isEmpty {
                            Text("Chưa có ứng dụng nào, kéo thả ứng dụng vào đây hoặc nhấn nút + để thêm.")
                                .font(.footnote)
                                .foregroundStyle(VKTheme.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(state.axIncludeApps, id: \.self) { bundleID in
                                AXSupportAppRow(
                                    app: AXSupportApp(bundleID: bundleID),
                                    isSelected: selectedAXApp == bundleID,
                                    isEnabled: Binding {
                                        state.axIncludeApps.contains(bundleID)
                                    } set: { enabled in
                                        if !enabled {
                                            removeAXApp(bundleID)
                                        }
                                    }
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedAXApp = bundleID
                                }

                                if bundleID != state.axIncludeApps.last {
                                    VKDivider()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 116, alignment: .top)
                    .background(VKTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isAXAppDropTargeted ? VKTheme.accent : VKTheme.border, lineWidth: 1)
                    )
                    .onDrop(of: [UTType.fileURL], isTargeted: $isAXAppDropTargeted) { providers in
                        addAppsFromDrop(providers)
                    }

                    HStack(spacing: 0) {
                        Button {
                            addAppFromFinder()
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.borderless)
                        .help("Thêm ứng dụng").accessibilityLabel("Thêm ứng dụng")

                        Divider()
                            .frame(height: 18)

                        Button {
                            if let selectedAXApp {
                                removeAXApp(selectedAXApp)
                            }
                        } label: {
                            Image(systemName: "minus")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.borderless)
                        .disabled(selectedAXApp == nil)
                        .help("Xóa ứng dụng").accessibilityLabel("Xóa ứng dụng")
                    }
                    .padding(.top, 6)
                }
                    .padding(16)
            }
        }
        .tint(VKTheme.accent)
        .foregroundStyle(VKTheme.textPrimary)
    }

    private func switchRow(_ title: String, _ binding: Binding<Bool>, subtitle: String? = nil, disabled: Bool = false) -> some View {
        VKRow(title: title, subtitle: subtitle) {
            Toggle(title, isOn: binding).labelsHidden().toggleStyle(.switch).controlSize(.small).tint(VKTheme.accent)
                .disabled(disabled)
        }
        .opacity(disabled ? 0.5 : 1)
    }

    private func languageTile(_ indicator: LanguageIndicator, title: String, subtitle: String) -> some View {
        let active = language == indicator
        let languageKeys = keyboardStatus.treatsAsJIS && state.useJISLanguageKeys
        let keys = indicator == .japanese ? (languageKeys ? ["かな"] : []) :
            [AppState.hotkeyDescription(state.switchKeyStatus)] + (languageKeys ? ["英数"] : [])
        let label = indicator == .vietnamese ? "Tiếng Việt" : indicator == .english ? "Tiếng Anh" : "Tiếng Nhật, bấm かな để chuyển"
        let tile = VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer(minLength: 0)
                Text(active ? "ĐANG GÕ" : " ")
                    .font(.system(size: 11, weight: .semibold)).padding(.horizontal, 5).padding(.vertical, 2)
                    .background(active ? VKTheme.onAccent.opacity(0.2) : .clear, in: RoundedRectangle(cornerRadius: 4))
                    .accessibilityHidden(true)
            }
            Text(title).font(.system(size: 26, weight: .bold))
            Text(subtitle).font(.system(size: 11, weight: active ? .bold : .regular))
                .foregroundStyle(active ? VKTheme.onAccent : VKTheme.textSecondary)
                .frame(height: 30, alignment: .topLeading).fixedSize(horizontal: false, vertical: true)
            VKKeycapRow(keys: keys, highlighted: active).frame(height: 22, alignment: .leading)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(active ? VKTheme.onAccent : VKTheme.textPrimary)
        .background(active ? VKTheme.accent : VKTheme.card, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(active ? VKTheme.accent : VKTheme.border, lineWidth: 1))
        if indicator == .japanese {
            return AnyView(tile.accessibilityElement(children: .ignore)
                .accessibilityLabel(label + (active ? ", đang gõ" : "")))
        }
        return AnyView(Button { state.isVietnamese = indicator == .vietnamese } label: { tile }
            .buttonStyle(.plain).accessibilityLabel(label + (active ? ", đang gõ" : ""))
            .accessibilityAddTraits(active ? .isSelected : []))
    }

    private func removeAXApp(_ bundleID: String) {
        state.axIncludeApps.removeAll { $0 == bundleID }
        if selectedAXApp == bundleID {
            selectedAXApp = nil
        }
    }

    private func addAppFromFinder() {
        let panel = NSOpenPanel()
        panel.message = "Chọn ứng dụng để bật hỗ trợ Trợ năng (Accessibility)"
        panel.allowedContentTypes = [.application, .bundle]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK, let url = panel.url {
            addApp(at: url)
        }
    }

    private func addAppsFromDrop(_ providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            handled = true
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let url = fileURL(from: item) else { return }
                Task { @MainActor in
                    addApp(at: url)
                }
            }
        }
        return handled
    }

    private func addApp(at url: URL) {
        guard let bundleID = bundleID(for: url) else { return }
        if !state.axIncludeApps.contains(bundleID) {
            state.axIncludeApps.append(bundleID)
        }
        selectedAXApp = bundleID
    }

    private func bundleID(for url: URL) -> String? {
        if let bundleID = Bundle(url: url)?.bundleIdentifier {
            return bundleID
        }
        if let infoDict = NSDictionary(contentsOf: url.appendingPathComponent("Contents/Info.plist")),
           let bundleID = infoDict["CFBundleIdentifier"] as? String {
            return bundleID
        }
        return nil
    }

    private func fileURL(from item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        }
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }
        if let string = item as? String {
            return URL(string: string)
        }
        return nil
    }
}

private struct AXSupportApp {
    let bundleID: String

    var appURL: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
    }

    var name: String {
        if let appURL,
           let bundle = Bundle(url: appURL),
           let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        }
        if let appURL,
           let bundleName = Bundle(url: appURL)?.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return bundleID
    }

    var icon: NSImage {
        guard let appURL else {
            return NSWorkspace.shared.icon(for: .application)
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
}

private struct AXSupportAppRow: View {
    let app: AXSupportApp
    let isSelected: Bool
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.footnote)
                    .lineLimit(1)
                Text(app.bundleID)
                    .font(.caption2)
                    .foregroundStyle(VKTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .toggleStyle(.switch)
                .controlSize(.small)
                .labelsHidden()
                .accessibilityLabel("Hỗ trợ Trợ năng cho \(app.name)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? VKTheme.segmentTrack : Color.clear)
    }
}
