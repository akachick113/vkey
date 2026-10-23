# Phase 5d — Giao diện hướng B cho các màn còn lại

> Codex · **GPT-6 Sol** · effort **Medium** (đổi kiểu giao diện theo đặc tả + thành phần đã có từ 5c, không logic mới; nhiều
> file nhưng mỗi chỗ đã chỉ rõ — WORKFLOW §8) · nhánh `phase-5d-design-pages`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Phase 5**: "✅ 5c xong" — Quyết định đã chốt + Còn tồn), **`docs/DESIGN.md`** (§1–§4, §10,
§11). Xem cách 5c dựng trang Bộ gõ (`Sources/App/Views/TypingPage.swift`) làm mẫu.

Mục tiêu: các màn còn lại theo hướng B, dùng `VKTheme` + `VKComponents` — **giữ nguyên nội dung, tuỳ chọn, hành vi**, chỉ đổi
kiểu; dọn Còn tồn của 5c. Sau phase này không còn màn nào dùng kiểu `Form` grouped / màu hệ thống cũ.

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; chuỗi tiếng Việt giữ nguyên câu chữ hiện có (trừ chỗ prompt ghi);
header file theo quy ước repo (`//\n//  Tên.swift\n//  VKey\n//\n//  1–2 dòng mô tả.\n//`); Conventional Commits tiếng Việt;
chỉ `git add <file>`; **mở PR vào `main` của `origin`** và gửi link. Không có ca test mới (ca mới vẫn đánh số từ **79**).

### Hiện trạng đã xem (Claude, `origin/main` @ `43c2d38`, 2026-10-23)
- Các trang dưới đây vẫn là `Form { Section … }.settingsFormStyle()` (kiểu cũ) hiển thị dưới tiêu đề chung của khung 5c:
  - `MacroPage.swift` (389 dòng): Section `Tuỳ chọn` (3 toggle), `Đồng bộ` (toggle iCloud + trạng thái icon
    `checkmark.icloud` / `icloud.slash` tô `Color.accentColor` + nút `Đồng bộ ngay`), `Thêm / sửa gõ tắt` (2 `TextField` + nút
    Thêm / Sửa, Xoá), Section header `Danh sách gõ tắt` chứa `Table` 2 cột + `Nhập từ file…`, `Xuất ra file…`, `N mục`.
  - `ConvertPage.swift` (78): `Bảng mã` (2 Picker + nút đảo chiều trong `LabeledContent("")`), `Chữ hoa / chữ thường` (Picker 5
    lựa chọn + toggle bỏ dấu), `Phím tắt chuyển nhanh` (HotkeyEditor + toggle thông báo), Section cuối (chú thích + nút
    `Chuyển mã clipboard`), alert `OK`.
  - `ClipboardPage.swift` (100): toggle bật; khi bật: `Ghim trên cùng`, `Tự động ẩn`, `Kích thước và vị trí cửa sổ` + `Đặt lại`;
    Section `Phím tắt` (HotkeyEditor + chú thích ⌃V); Section số mục tối đa (Slider 10–100, số hiện bằng `Color.accentColor`)
    + chú thích bảo mật; Section `Đang lưu N mục` + `Xoá lịch sử` + chú thích ghim (có ký tự 📌).
  - `SystemPage.swift` (148): `Khởi động` (2), `Cập nhật` (2 toggle + trạng thái + `Kiểm tra ngay` / `Cập nhật…` + lần cuối;
    màu trạng thái `.orange` khi lỗi `:144`), `Biểu tượng` (2), `Chuyển chế độ thông minh` (2), `Ứng dụng loại trừ`
    (`AppBundleListEditor` + chú thích), `Tương thích nâng cao` (2 toggle + chú thích `:98` "Bàn phím JIS được VKey tự nhận và
    xử lý riêng, không cần bật tuỳ chọn này."), `Cài đặt mặc định` + alert xác nhận.
  - `AboutPage.swift` (144): icon app, `VKey`, mô tả, nút `Kiểm tra cập nhật`, hàng `InfoRow` (SF Symbol tô
    `Color.accentColor` `:120`), `Phát triển bởi akachick113 · © 2026`, dòng ghi công, 3 `Link`.
- `WelcomePage.swift` (146): nền `VisualEffectBlur(.sidebar)` (`:115`), vòng tròn `Color.accentColor.opacity(0.12)` quanh icon,
  SF Symbol tô `Color.accentColor`, chấm chờ `Color.orange` (`:95`), nút `Mở Cài đặt hệ thống`.
- `AppBundleListEditor.swift`: viền thả `Color.accentColor` / `separatorColor` (`:53`), hàng chọn `Color.accentColor.opacity(0.16)`
  (`:188`). `HotkeyEditor.swift`: ô ghi `Color.accentColor` (`:93`, `:97`), cảnh báo trùng phím tắt `.orange` (`:145`).
- `Clipboard/ClipboardPicker.swift` (887): nền `VisualEffectBlur(.popover)` (`:484`, `:614`); hàng chọn nền `Color.accentColor`
  + chữ `Color.white.opacity(…)` (`:648-848`); ghim / dấu `Color.orange` (`:732`, `:806`, `:822`, `:831`); gradient xanh-tím
  (`:760-769`); nhãn HTML `Color.blue.opacity(0.2)` (`:791`); nút ghim / tự ẩn tô `Color.accentColor` (`:388-418`).
- `SettingsRootView.swift`: `PermissionBanner` (`:119`, không còn được dùng, tô `.orange`), `VisualEffectBlur` (`:145`, còn
  dùng ở ClipboardPicker / WelcomePage). File mới / viết lại ở 5c **thiếu header**: `VKTheme.swift`, `VKComponents.swift`,
  `KeyboardModeStatus.swift`, `LanguageIndicator.swift`, `StatusIcon.swift`, `SettingsRootView.swift` (bản cũ có chú thích:
  "Settings window: custom sidebar + detail pane. A hand-rolled sidebar is used instead of NavigationSplitView, which mis-renders
  its selection row into the titlebar area on macOS 26.").
- `VKeyApp.swift` submenu `Bàn phím`: `Picker("Bàn phím", …).pickerStyle(.inline)` → menu hiện thêm một dòng tiêu đề `Bàn phím`.
- `AppState.swift:250-251` khoá `mkLoginItemInitialized`.
- `AppStyle.swift` (`settingsFormStyle`) chỉ còn các trang trên dùng.

## Việc 0 — Còn tồn 5c
- Xoá `PermissionBanner` (không dùng). Cảnh báo trùng phím tắt trong `HotkeyEditor` dùng `VKTheme.warningIcon` (icon) /
  `warningText` (chữ); ô ghi phím: `VKTheme.accent` thay `Color.accentColor`, nền / viền ô theo `card` / `border`.
- Header file cho 6 file nêu trên; `SettingsRootView` khôi phục ý chú thích về sidebar tự dựng.
- Submenu `Bàn phím`: ẩn nhãn Picker (`.labelsHidden()` hoặc tiêu đề rỗng) — menu chỉ còn 3 mục radio.
- `mkLoginItemInitialized` → `vkLoginItemInitialized` (đổi cả hai chỗ; chưa có người dùng nên không chuyển giá trị cũ).

## Việc 1 — Các trang cài đặt (DESIGN §10)
Viết lại phần thân 5 trang bằng `VKSectionLabel` + `VKCard` / `VKRow` / `VKDivider` / switch tint `accent`, như `TypingPage`.
Thứ tự nhóm, câu chữ, quan hệ disabled / hiện-ẩn, alert, `onChange` giữ y như cũ.
- **Gõ tắt:** `TUỲ CHỌN` · `ĐỒNG BỘ` (icon trạng thái `accent` / `textSecondary`) · `THÊM / SỬA GÕ TẮT` (2 ô nhập cùng hàng + nút;
  nút chính Thêm / Sửa nền `accent`, Xoá kiểu viền) · `DANH SÁCH GÕ TẮT`: `Table` giữ nguyên chức năng (chọn, sửa, sắp xếp nếu
  có) đặt trong `VKCard` (`.scrollContentBackground(.hidden)`; cột "Từ tắt" font monospaced), dưới thẻ: `Nhập từ file…`,
  `Xuất ra file…` trái, `N mục` phải. Bảng cao tối thiểu đủ ~8 hàng.
- **Chuyển mã:** `BẢNG MÃ` (Từ / Sang popup + nút đảo chiều icon `arrow.left.arrow.right`, có `accessibilityLabel`) ·
  `CHỮ HOA / CHỮ THƯỜNG` (`VKSegmented` 5 lựa chọn; nếu không vừa một hàng thì dùng popup — ghi lại lựa chọn) + toggle bỏ dấu ·
  `PHÍM TẮT CHUYỂN NHANH` · cuối trang: chú thích + nút chính `Chuyển mã clipboard` nền `accent`, chữ `onAccent`.
- **Clipboard:** thẻ bật + 3 hàng con khi bật · `PHÍM TẮT` · `LỊCH SỬ` (số mục tối đa: slider tint `accent`, số hiện
  `textPrimary` semibold; chú thích bảo mật) · `Đang lưu N mục` + `Xoá lịch sử` (nút viền, `role: .destructive`) + chú thích
  ghim — **bỏ ký tự 📌**, viết "biểu tượng ghim".
- **Hệ thống:** `KHỞI ĐỘNG` · `CẬP NHẬT` (màu trạng thái: ok → `ok`, lỗi → `warningIcon`, đang kiểm → `textSecondary`) ·
  `BIỂU TƯỢNG` · `CHUYỂN CHẾ ĐỘ THÔNG MINH` · `ỨNG DỤNG LOẠI TRỪ` (`AppBundleListEditor` trong thẻ; viền thả / hàng chọn dùng
  `accent`) · `TƯƠNG THÍCH NÂNG CAO` — chú thích `:98` đổi thành `Khi trang Bộ gõ đang gõ kiểu JIS (Tự động với bàn phím JIS,
  hoặc chọn JIS), tuỳ chọn này không có tác dụng.` · cuối trang: chú thích + nút viền `Cài đặt mặc định` (giữ alert).
- **Giới thiệu:** căn giữa: icon app 96 pt, `VKey` 28 bold, mô tả, `Phiên bản x (build)` (giữ cách lấy version hiện có), nút
  `Kiểm tra cập nhật` (viền); các `InfoRow` giữ nội dung, icon tô `accent`; `Phát triển bởi akachick113 · © 2026`; dòng ghi công
  11 pt `textSecondary`; 3 link `accentText`. Vừa cửa sổ mặc định không cần cuộn.
- Sau khi 5 trang không còn dùng: xoá `SettingsFormStyle` / `settingsFormStyle()` và `AppStyle` nếu không còn tham chiếu.

## Việc 2 — Cửa sổ Chào mừng (DESIGN §10)
Nền `windowBackground` (bỏ `VisualEffectBlur`), icon app 96 pt (vòng nền `accent` 12 %), tiêu đề 24 bold, mô tả, thẻ `VKCard`
hướng dẫn quyền Trợ năng (icon `accent`), nút chính `Mở Cài đặt hệ thống` nền `accent` chữ `onAccent`, chấm chờ
`warningIcon`, trạng thái đã cấp `ok`. Giữ kích thước cửa sổ và logic hiện có.

## Việc 3 — Bảng lịch sử clipboard (DESIGN §10)
`ClipboardPicker` theo mapping (giữ bố cục, phím tắt, điều hướng bàn phím, xem trước ảnh): nền panel `card` + viền `border`, bo
như hiện tại (bỏ `VisualEffectBlur`); hàng đang chọn nền `accent`, mọi chữ / icon trên hàng chọn `onAccent` (thay
`Color.white.opacity`); hàng rê chuột `segmentTrack`; ghim / dấu ghim `accent` (thay `.orange`); nhãn HTML / ảnh: viền
`keycapBorder`, chữ `textSecondary` (thay `Color.blue.opacity`); nút ghim / tự ẩn bật = `accent`, tắt = `textSecondary`; bỏ
`LinearGradient` (dùng màu đặc tương ứng); chữ phụ `textSecondary`. Sau đó xoá `VisualEffectBlur` nếu không còn dùng.

## Không được làm
- Không đổi nội dung / câu chữ / thứ tự tuỳ chọn ngoài các chỗ prompt ghi; không thêm / bỏ tính năng; không đổi khoá
  UserDefaults ngoài `mkLoginItemInitialized`; không đổi logic gõ tắt, đồng bộ iCloud, clipboard, chuyển mã, cập nhật.
- Không đổi `TypingPage`, `VKTheme` (giá trị màu), `VKComponents` (trừ thêm thành phần nhỏ dùng chung nếu cần — ghi vào báo cáo),
  icon, menu (ngoài nhãn submenu), `Sources/Platform/`, `Sources/Engine/`, `.github/`, `project.yml`, version, ký.
- Không nhúng font, không thêm dependency. Không sửa `AGENTS.md`, `CLAUDE.md`, `docs/`. Không push `main`.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `14 / 53 / 8 / 6 / 6 / 5` (policy / engine / hotkey name / hotkey conflict /
      release signature / keyboard mode). CI xanh.
- [ ] `git grep -n -E 'Color\(red|srgbRed|#[0-9A-Fa-f]{6}|\.orange|Color\.(blue|purple|indigo|orange|red|green)|accentColor|LinearGradient|VisualEffectBlur|settingsFormStyle|mkLoginItemInitialized|📌' -- Sources/App`
      chỉ còn `VKTheme.swift:7` (dán kết quả). `Color.white` / `Color.black` chỉ còn trong `.shadow(...)` (dán
      `git grep -n -E 'Color\.(white|black)|\.white\b|\.black\b' -- Sources/App`).
- [ ] Kịch bản chạy thật (bản Debug, máy này) — ghi kết quả, ảnh đính kèm **PR** (không commit):
  - (a) Chụp **sáng và tối**: Gõ tắt, Chuyển mã, Clipboard, Hệ thống, Giới thiệu, cửa sổ Chào mừng (mở bằng cách tạm gỡ quyền
    hoặc gọi `vkOpenWelcomeWindow` trong Debug — ghi cách dùng), bảng lịch sử clipboard (có ít nhất 1 mục chữ, 1 ảnh, 1 mục ghim;
    một hàng đang chọn). So DESIGN §10; chữ không cắt; trang Giới thiệu không cần cuộn ở cửa sổ mặc định.
  - (b) Chức năng vẫn chạy: thêm / sửa / xoá một gõ tắt và gõ thử nó (gõ bằng `CGEventPost` keyboard type 93 như 5c, không dùng
    công cụ chèn chữ); `Chuyển mã clipboard` một đoạn TCVN3 → Unicode; mở bảng clipboard bằng ⌃V, ↑ / ↓ chọn, Enter dán, ⌘P ghim;
    `Kiểm tra ngay` ở Hệ thống; thêm / bỏ một app loại trừ bằng kéo thả hoặc +; `Cài đặt mặc định` → huỷ.
  - (c) Menu thanh menu: submenu `Bàn phím` chỉ còn 3 mục (đọc qua Accessibility).
  - (d) Tab / Shift-Tab đi qua control của từng trang; VoiceOver đọc được nút đảo chiều (Chuyển mã) và nút ghim (bảng clipboard).
  - (e) `defaults read io.github.akachick113.vkey.debug vkLoginItemInitialized` = 1 sau lần chạy đầu.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo việc (vd `chore: dọn còn tồn giao diện 5c`, `feat: trang Gõ tắt, Chuyển mã, Clipboard theo thiết kế mới`, `feat:
trang Hệ thống, Giới thiệu và Chào mừng theo thiết kế mới`, `feat: bảng lịch sử clipboard theo thiết kế mới`). Push nhánh
`phase-5d-design-pages`, **mở PR vào `main`** và gửi link. Trả lời bằng tiếng Việt, và **ghi toàn văn báo cáo vào
`build/phase-5d-report.md`** (không commit — Claude đọc file này khi review vì không xem được mô tả PR của repo private), gồm:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả (a)–(e); danh sách ảnh đã đính kèm PR (và bản sao trong `build/phase-5d-evidence/` để Claude xem).
3. Kết quả 2 lệnh `git grep`.
4. Chỗ khác DESIGN / prompt và lý do; chỗ **chưa chắc** / chưa kiểm được.
