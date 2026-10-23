# Review Phase 3 — PR #4, nhánh `phase-3-hotkey-conflict` (commit `8d18c6c`)

**Kết luận: Approved.** Không có mục Phải sửa. Một mục nhỏ có sẵn từ trước ghi vào Còn tồn (C1 bên dưới).

Kiểm tra trên worktree sạch (`git worktree add ../mkey-review 8d18c6c`, DerivedData mới):
`scripts/check.sh` ✅ (build Debug ✅ · `PASS: 14 update runtime policy checks` · `PASS: 50 engine tests` ·
`PASS: 5 hotkey key name tests` · `PASS: 6 system hotkey conflict tests`) · không đụng `Sources/Engine/`, `project.yml`,
`docs/` ✅ · không thêm dependency ✅ · ca 1–42, 44–51 không đổi expectation ✅, ca 43 đổi đúng như prompt cho phép ✅ ·
ca 52–61 đủ, mỗi ca một hàm có số ca ✅ · 3 commit Conventional Commits tiếng Việt, C1 commit riêng (`fix:`) ✅.
CI: Claude không xem được (repo private, trình duyệt trong app chưa đăng nhập GitHub) — người dùng kiểm trước khi merge.

Đối chiếu prompt từng việc:
- Việc 0 C1 ✅ — `MKLanguageKeyEndWord` thêm cuối enum; thứ tự quy tắc đúng (loại trừ / ⌘⌃⌥ → phím khác → tắt tuỳ chọn →
  như cũ). Trong `MKEngineCallback`: `languageKeyAction` khởi tạo `NotHandled`, nhánh bật tuỳ chọn giữ nguyên, `EndWord`
  xử lý ngay sau `_hasJustUsedHotKey = _lastFlag != 0;` (sau khối hotkey) với `RequestNewSession()` +
  `_lastKeystrokeTime` + `return event`. Không thêm lời gọi TIS / AX / NSEvent trong callback. Harness
  `typeJISWithLanguageKeys` dùng chung vòng lặp `typeKeys`, `typeJIS` / `type` không đổi.
- Việc 0 C2 ✅ — xoá `peakModifiers` ở nhánh thả hết modifier mà không ghi; `HotkeyKeyName.recordedCharacter` đúng đặc tả,
  recorder gọi với `characters(byApplyingModifiers: []) ?? charactersIgnoringModifiers`.
- Việc 1 ✅ — `SystemHotkeyConflict` chỉ `import Foundation`, hằng Carbon viết bằng số kèm chú thích; `matches` xét đủ
  keycode + 4 modifier + cờ fn ngầm; `warning` bỏ qua 102 / 104, đúng hai chuỗi. `SystemHotkeyReader` dùng
  `CopySymbolicHotKeys`, không API riêng, không đọc plist.
- Việc 2 ✅ — đọc lại ở `.onAppear` + `didBecomeActiveNotification`; cảnh báo chỉ hiện khi không ghi; cả 3 editor.
- Việc 3 ✅ — bảng tên khớp prompt (31 tổ hợp).

Test bắt lỗi tốt — làm hỏng tạm `MKLanguageKeyActionFor` 2 kiểu: trả về quy tắc cũ (tắt tuỳ chọn → `NotHandled`) → đỏ ca
43 + 53 (`actual: [ đaay]`); `EndWord` không xét app loại trừ / ⌘⌃⌥ → đỏ ca 52.

## Chạy thật
Bản Debug của Codex (`build/DerivedData/…/Debug/mkey.app`, build 16:37, không file nguồn nào mới hơn bản build → đúng nội
dung `8d18c6c`). Lúc đầu bản này mất quyền Trợ năng: mục "mkey" trong danh sách Trợ năng là của bản phát hành
`~/Downloads/mkey.app` (cùng bundle id `vn.mkey.app`, ký team `CF5PGH3KGK`), không khớp bản ad-hoc → người dùng gỡ mục cũ,
thêm lại bản Debug. Claude chạy bằng `CGEventPost` (keyboard type 93, gửi cả flagsChanged cho modifier) vào TextEdit, đọc
lại bằng AppleScript; UI đọc bằng Accessibility + chụp cửa sổ. Input source ABC + Japanese – Romaji, không chọn Input Method
"MKey", Telex. Mỗi ca bắt đầu bằng → để kết thúc từ của ca trước.

- (a) ✅ Tắt tuỳ chọn, Việt: `⏎ 英数 ddaay␣` → `⏎đây␣`; `ddaay 英数 ddaay` → `đâyđây`; `a 英数 a` → `aa` (đối chứng
  `a a` → `â`); `tie 英数 es` → `tieé`; かな → Japanese, `nihongo⏎` → `日本語` (Kotoeri chuyển đổi trực tiếp đang bật —
  mkey không can thiệp), 英数 → ABC, `ddaay␣` → `đây␣`, vẫn **V**. Anh: `⏎ 英数 ddaay␣` → `⏎ddaay␣`.
  Không chạy lại bản build từ `main` (không có bản có quyền); trạng thái trước khi sửa đã có ở review Phase 2
  (`⏎ 英数 ddaay` → `đaay`) và ở ca 53 khi làm hỏng tạm (mục trên).
- (b) ✅ Tắt tuỳ chọn, ghi 英数 trơn bằng recorder → lưu `0x20000066`, không hiện cảnh báo macOS; ở ABC bấm 英数 → V ⇄ E
  (phím tắt thắng). Hệ quả đã biết từ Phase 2: phím tắt nuốt 英数 nên macOS không nhận 英数 nữa (đang Japanese thì không về
  ABC bằng 英数).
- (c) ✅ Bật tuỳ chọn: かな → `日本語`; 英数 ×3 → `đây` / `ddaay` / `đây`, `InputMethod` 1 → 0 → 1.
- (d) ✅ Ghi bằng recorder: ⌥Z → `0x7A000206` (giống hệt mặc định); ⌃Z → `0x7A000106`; ⌃⇧ + phím 30 → `0x5B00091E`;
  ⌃¥ → `0xC200015D`. Bấm-thả ⌃ rồi bấm-thả ⇧ → không ghi gì (giá trị giữ nguyên); giữ ⌃⇧ rồi thả → `0xFE0009FE`.
- (e) ✅ Thử ghi: ⌘Space và ⌃Space **bị macOS bắt mất** (recorder không nhận; ⌃Space đổi input source); ⌃F2 ghi được →
  cảnh báo `mặc định: “Chuyển tới thanh menu”`. Cách chắc chắn (`defaults write` khi mkey đã thoát): ⌘Space →
  `“Hiện tìm kiếm Spotlight”`, ⌃Space → `“Chọn nguồn nhập trước đó”`. Chuỗi, biểu tượng ⚠️ cam, vị trí đúng prompt.
- (f) ✅ Không cảnh báo với ⌥Z, ⌃⇧, chưa đặt. Chuyển mã và Clipboard đặt ⌃F2 → cảnh báo hiện ở cả hai trang.
- (g) ⚠️ **Chưa kiểm được**: phải tắt / bật phím tắt Spotlight trong Cài đặt hệ thống — Claude không tự đổi cài đặt hệ
  thống. Rủi ro thấp: danh sách đọc lại khi app được kích hoạt và mỗi lần editor xuất hiện (đổi trang). Người dùng có thể
  tự thử khi tiện.
- (h) ✅ Bật tuỳ chọn, phím tắt đã lưu là 英数 → chỉ hiện chú thích Phase 2, không có dòng cảnh báo macOS.

Đã trả cài đặt `vn.mkey.app` về đúng bản sao lưu trước khi chạy, thoát bản Debug, input source về ABC.

Ghi nhận: các tổ hợp hệ thống bắt trước app (⌘Space, ⌃Space…) không ghi được bằng recorder, nên cảnh báo chủ yếu có ích
cho phím tắt đã lưu từ trước / được bật sau, và các tổ hợp app vẫn nhận (⌃F-key, ⌃ mũi tên…). Đúng phạm vi PRODUCT_SPEC
§6.3 (chỉ cảnh báo).

## Phải sửa
Không có.

## Nên sửa
Không có trong PR này.

## Còn tồn (đề xuất — người dùng chốt khi merge)
- C1 (nhỏ, có sẵn từ 1.6.1) — **Phím F1–F20 và mũi tên hiện keycap trống / rác trong `HotkeyEditor`.** Ghi ⌃F2 lưu byte
  cao 0x10 (`characters(byApplyingModifiers: [])` của F2 = U+0010; trước PR là U+F705 → byte 0xEF → hiện `Ï`). Nay bảng
  cảnh báo nêu tên nhiều tổ hợp ⌃F-key / ⌃ mũi tên nên dễ gặp hơn. Cách làm gợi ý: `HotkeyKeyName.name` trả tên theo
  keycode cho F1–F20 (122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111, 105, 107, 113, 106, 64, 79, 80, 90) và
  ← → ↓ ↑ (123–126), kèm ca test Swift.
