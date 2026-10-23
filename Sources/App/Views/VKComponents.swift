//
//  VKComponents.swift
//  VKey
//
//  Thành phần giao diện dùng chung theo thiết kế VKey.
//

import SwiftUI

struct VKCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .frame(maxWidth: .infinity)
            .background(VKTheme.card, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(VKTheme.border, lineWidth: 1))
    }
}

struct VKRow<Control: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var control: Control

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 13)).foregroundStyle(VKTheme.textPrimary)
                if let subtitle {
                    Text(subtitle).font(.system(size: 11)).foregroundStyle(VKTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 4)
            control
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 16)
    }
}

struct VKDivider: View {
    var body: some View {
        Rectangle().fill(VKTheme.divider).frame(height: 1).padding(.horizontal, 16)
            .accessibilityHidden(true)
    }
}

struct VKSectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title).font(.system(size: 11, weight: .semibold)).tracking(0.44)
            .foregroundStyle(VKTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct VKSegmented: View {
    let title: String
    @Binding var selection: Int
    let options: [String]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options.indices, id: \.self) { index in
                Button { selection = index } label: {
                    Text(options[index])
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(size: 11, weight: selection == index ? .semibold : .regular))
                        .foregroundStyle(selection == index ? VKTheme.textPrimary : VKTheme.textSecondary)
                        .padding(.horizontal, 8).padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selection == index {
                                RoundedRectangle(cornerRadius: 6).fill(VKTheme.segmentThumb)
                                    .shadow(color: VKTheme.textPrimary.opacity(0.10), radius: 1, y: 1)
                            }
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(title), \(options[index])")
                .accessibilityAddTraits(selection == index ? .isSelected : [])
            }
        }
        .padding(3)
        .background(VKTheme.segmentTrack, in: RoundedRectangle(cornerRadius: 9))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(VKTheme.border, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}

struct VKKeycap: View {
    let title: String
    var highlighted = false
    init(_ title: String, highlighted: Bool = false) {
        self.title = title
        self.highlighted = highlighted
    }
    var body: some View {
        Text(title).font(.system(size: 12, weight: highlighted ? .bold : .regular))
            .padding(.vertical, 1).padding(.horizontal, 6)
            .overlay(RoundedRectangle(cornerRadius: 4)
                .stroke(highlighted ? VKTheme.onAccent.opacity(0.6) : VKTheme.keycapBorder, lineWidth: 1))
    }
}

struct VKKeycapRow: View {
    let keys: [String]
    var highlighted = false
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                if index > 0 { Text("hoặc").font(.system(size: 11)) }
                VKKeycap(key, highlighted: highlighted)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct VKBanner: View {
    let message: String
    let actionTitle: String
    let action: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle").foregroundStyle(VKTheme.warningIcon)
                .accessibilityHidden(true)
            Text(message).font(.system(size: 12)).foregroundStyle(VKTheme.warningText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(actionTitle, action: action).buttonStyle(.bordered)
        }
        .padding(12)
        .background(VKTheme.warningBackground, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(VKTheme.warningBorder, lineWidth: 1))
    }
}

/// Cuộn và áp nền chữ chung cho thân các trang cài đặt.
struct VKPageContent<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) { content }
                .padding(.horizontal, 32).padding(.bottom, 28)
        }
        .foregroundStyle(VKTheme.textPrimary)
        .tint(VKTheme.accent)
    }
}

/// Hàng nhãn và công tắc theo lề chuẩn của thẻ.
struct VKSwitchRow: View {
    let title: String
    @Binding var isOn: Bool
    init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
    var body: some View {
        VKRow(title: title) {
            Toggle(title, isOn: $isOn).labelsHidden().toggleStyle(.switch).tint(VKTheme.accent)
        }
    }
}

/// Nút chính theo màu nhấn, giữ độ mờ khi bị vô hiệu hoá.
struct VKPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 13, weight: .semibold))
            .foregroundStyle(VKTheme.onAccent)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(
                VKTheme.accent.opacity(!isEnabled ? 0.45 : configuration.isPressed ? 0.8 : 1),
                in: RoundedRectangle(cornerRadius: 7))
    }
}
