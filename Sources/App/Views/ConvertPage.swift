//
//  ConvertPage.swift
//  VKey
//
//  Clipboard encoding converter (Unicode ⇄ TCVN3 ⇄ VNI …).
//

import SwiftUI

struct ConvertPage: View {
    @EnvironmentObject private var state: AppState
    @State private var resultMessage: String?

    var body: some View {
        VKPageContent {
            VKSectionLabel("BẢNG MÃ")
            VKCard {
                VKRow(title: "Từ bảng mã") {
                    Picker("Từ bảng mã", selection: $state.convertFromCode) {
                        ForEach(AppState.codeTableNames.indices, id: \.self) { i in
                            Text(AppState.codeTableNames[i]).tag(i)
                        }
                    }
                    .labelsHidden().pickerStyle(.menu).frame(width: 215, alignment: .trailing)
                }
                VKDivider()
                VKRow(title: "Sang bảng mã") {
                    Picker("Sang bảng mã", selection: $state.convertToCode) {
                        ForEach(AppState.codeTableNames.indices, id: \.self) { i in
                            Text(AppState.codeTableNames[i]).tag(i)
                        }
                    }
                    .labelsHidden().pickerStyle(.menu).frame(width: 215, alignment: .trailing)
                    Button {
                        let from = state.convertFromCode
                        state.convertFromCode = state.convertToCode
                        state.convertToCode = from
                    } label: {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                    .accessibilityLabel("Đảo chiều")
                }
            }

            VKSectionLabel("CHỮ HOA / CHỮ THƯỜNG")
            VKCard {
                VKRow(title: "Chuyển đổi") {
                    Picker("Chuyển đổi", selection: $state.convertCaseMode) {
                        Text("Giữ nguyên").tag(0)
                        Text("IN HOA TOÀN BỘ").tag(1)
                        Text("in thường toàn bộ").tag(2)
                        Text("Hoa chữ cái đầu câu").tag(3)
                        Text("Hoa Mỗi Đầu Từ").tag(4)
                    }
                    .labelsHidden().pickerStyle(.menu).frame(width: 215, alignment: .trailing)
                }
                VKDivider()
                VKSwitchRow("Loại bỏ dấu thanh (tiếng Việt → khong dau)", isOn: $state.convertRemoveMark)
            }

            VKSectionLabel("PHÍM TẮT CHUYỂN NHANH")
            VKCard {
                HotkeyEditor(status: $state.convertHotKey, blocksLanguageKeys: state.useJISLanguageKeys)
                    .padding(.vertical, 11).padding(.horizontal, 16)
                VKDivider()
                VKSwitchRow("Thông báo khi chuyển mã xong", isOn: $state.convertAlert)
            }

            VKCard {
                HStack(alignment: .center) {
                    Text("Sao chép văn bản cần chuyển vào clipboard rồi bấm Chuyển mã.")
                        .font(.callout)
                        .foregroundStyle(VKTheme.textSecondary)
                    Spacer()
                    Button("Chuyển mã clipboard") {
                        let ok = VKBridge.quickConvertClipboard()
                        resultMessage = ok
                            ? "Chuyển mã thành công! Kết quả đã được lưu trong clipboard."
                            : "Không có dữ liệu trong clipboard. Hãy sao chép một đoạn văn bản trước."
                    }
                    .buttonStyle(VKPrimaryButtonStyle())
                }
                .padding(.vertical, 11).padding(.horizontal, 16)
            }
        }
        .alert("Công cụ chuyển mã", isPresented: .init(get: { resultMessage != nil }, set: { if !$0 { resultMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resultMessage ?? "")
        }
    }
}
