# Review Phase 5c — PR #8, nhánh `phase-5c-design-typing` (vòng 1 `c5a8df1`)

## Review lần 1 — `c5a8df1`

**Kết luận: Approved.** Không có mục Phải sửa. Ba điểm nhỏ về kiểu code / giao diện chuyển vào Còn tồn để làm cùng 5d.

Kiểm tra trên worktree sạch (`git worktree add --detach ../mkey-review c5a8df1`, DerivedData mới):
`scripts/check.sh` ✅ — `PASS: 14 update runtime policy checks` · `PASS: 53 engine tests` · `PASS: 8 hotkey key name tests` ·
`PASS: 6 system hotkey conflict tests` · `PASS: 6 release signature tests` · `PASS: 5 keyboard mode tests`. 5 commit Conventional
Commits tiếng Việt ✅. Không đụng `Sources/Engine/`, `.github/`, `project.yml`, cấu hình ký, version, tài liệu ✅; không nhúng
font, không thêm dependency ✅; trang Gõ tắt / Chuyển mã / Clipboard / Hệ thống / Giới thiệu / Chào mừng giữ nội dung cũ ✅.
Mô tả PR #8 (kết quả chạy của Codex) Claude không đọc được (repo private) — Claude tự chạy lại phần chính (dưới).

Đối chiếu prompt:
- Việc 1 ✅ — `VKTreatAsJIS`, `VKLanguageKeyActionForMode` (ANSI → `NotHandled`, còn lại gọi nguyên `VKLanguageKeyActionFor`);
  `vKeyboardMode` + `LOAD_DATA`; hook tách `_hardwareKeyboardIsJIS` (chỉ tính khi keyboard type đổi) và
  `_currentKeyboardIsJIS = VKTreatAsJIS(…)` mỗi keyDown (một phép so sánh); notification `VKHardwareKeyboardDidChange` chỉ post
  khi bàn phím vật lý đổi, `VKInputSourceDidChange` post trong `VKUpdateInputSourceCache` (ngoài callback phím) ✅ quy tắc 9.
  `VKBridge` 3 hàm; `AppState.keyboardMode` có trong `registerDefaultSettings` + `resetToDefaults`. `KeyboardModeStatus` chữ đúng
  từng ký tự DESIGN §6.1; `LanguageIndicator` đúng.
- Việc 2–4 ✅ — `VKTheme` đủ 18 token đúng mã màu sáng / tối; `VKComponents` đủ thành phần; khung cửa sổ 860 × 600, sidebar chữ +
  chấm, tiêu đề trang chung, chọn bàn phím cạnh tiêu đề Bộ gõ; trang Bộ gõ đủ mọi tuỳ chọn cũ, dải 3 ô (Việt / Anh là nút, 日本語
  không bấm), switch 英数 / かな disabled ở chế độ Tiếng Anh. `HotkeyEditor` không chặn 英数 / かな khi ở chế độ Tiếng Anh — hợp lý
  (phím đó không còn được xử lý riêng).
- Việc 5 ✅ — menu đúng thứ tự DESIGN §7; icon `VI` (đặc) / `EN` / `あ` (viền), template khi đơn sắc, đỏ son khi tắt đơn sắc, mờ
  khi loại trừ (ảnh `build/phase-5c-evidence/status-icons.png`).
- Việc 6 ✅ — icon nền đỏ son phẳng, V + dấu sắc + con dấu あ; cỡ 16 / 32 bỏ con dấu (đã xem `icon-1024.png`, `icon-32.png`).
- Ca 71–78 ✅ — mỗi ca một hàm; ca 72 quét đủ 32 tổ hợp × các mode; ca 73 đúng bảng Claude đo trước.
- `git grep -n -E 'Color\(red|srgbRed|#[0-9A-Fa-f]{6}' -- Sources/App` → chỉ `VKTheme.swift:7` ✅.

## Chạy thật (Claude, bản Debug `c5a8df1` ở checkout chính, đã có quyền Trợ năng; người dùng cho phép, không dùng máy lúc chạy)
Gõ bằng `CGEventPost` vào TextEdit (công cụ của Codex `build/phase-5c-type.swift`, keyboard type JIS = 93, ANSI = 40 —
`KBGetLayoutType(40) == kKeyboardANSI`), đổi chế độ bằng `defaults write … vKeyboardMode` + mở lại app, đọc chữ bằng AppleScript.

| Chế độ | Gõ | Kết quả |
|---|---|---|
| Tự động | JIS `tieengs vieetj` / `@` / `[` | `tiếng việt` / `@` / `ơ` ✅ |
| Tự động | ANSI `ddaay` | `đây` ✅ |
| Tự động | JIS かな `nihongo⏎`, rồi 英数, `ddaay` | `日本語`, về ABC, `đây` ✅ |
| Tiếng Anh (US) | JIS `@` / `[` / `tieengs vieetj`; ANSI `ddaay` | `ơ` / `ư` (như mkey gốc) / `tiếng việt`; `đây` ✅ |
| JIS (Nhật) | JIS `@` / `tieengs vieetj` | `@` / `tiếng việt` ✅ |

- Menu (Accessibility): `Tiếng Việt`, `Tắt VKey cho TextEdit`, ─, `Kiểu gõ`, `Bảng mã`, `Bàn phím`, ─, `Chuyển mã nhanh`, `Công cụ
  chuyển mã…`, `Gõ tắt…`, `Lịch sử Clipboard`, ─, `Cài đặt VKey…`, `Giới thiệu VKey`, `Kiểm tra cập nhật…`, ─, `Thoát VKey` ✅;
  submenu `Bàn phím` có dấu ✓ đúng ở `JIS (Nhật)` ✅. `Cài đặt VKey…` mở cửa sổ ✅.
- Cửa sổ (chụp, tối): chế độ JIS + gõ JIS → `● Luôn gõ kiểu JIS`; gõ ANSI → cảnh báo `Bạn đang gõ trên bàn phím không phải JIS…`
  + nút `Về Tự động` ✅. (Lưu ý đo: phím Esc do AppleScript gửi mang keyboard type JIS nên làm trạng thái đổi về JIS — đúng hành
  vi, không phải lỗi.) Ảnh sáng / tối của Codex khớp DESIGN §5–§6; nhãn segmented không xuống dòng ở bản cuối.
- Đã trả về chế độ Tự động (`vKeyboardMode = 0`), mở lại VKey Debug như trước khi chạy, đóng tài liệu thử.

## Còn tồn (đề xuất — làm cùng 5d)
1. `SettingsRootView.swift`: `PermissionBanner` (không còn được dùng) vẫn tô `.orange` — xoá hoặc chuyển sang token cảnh báo;
   cảnh báo trùng phím tắt trong `HotkeyEditor.swift:145` (`.orange`) đổi sang `VKTheme.warningIcon` / `warningText`.
2. Header file theo quy ước repo (`//\n//  Tên.swift\n//  VKey\n//` + 1–2 dòng mô tả) cho file mới / viết lại: `VKTheme.swift`,
   `VKComponents.swift`, `KeyboardModeStatus.swift`, `LanguageIndicator.swift`, `StatusIcon.swift`, `SettingsRootView.swift` —
   khôi phục chú thích "hand-rolled sidebar thay NavigationSplitView vì lỗi vẽ trên macOS 26" đã bị xoá.
3. Submenu `Bàn phím` hiện thêm một dòng tiêu đề `Bàn phím` (nhãn của `Picker` inline) — ẩn nhãn (`.labelsHidden()`).
4. Khoá `mkLoginItemInitialized` (từ 5a).
