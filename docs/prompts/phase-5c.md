# Phase 5c — Giao diện hướng B: nền, trang Bộ gõ, chọn bàn phím, menu, icon

> Codex · **GPT-6 Sol** · effort **High** (logic mới trên đường event tap + giao diện SwiftUI nhiều file + icon; phải chạy
> thật cả sáng / tối và 3 chế độ bàn phím — WORKFLOW §8) · nhánh `phase-5c-design-typing`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Quyết định chung**, mọi **Quyết định đã chốt**, **Phase 5** gồm "✅ 5a xong", "✅ 5b
xong"), **`docs/DESIGN.md`** (đặc tả giao diện — làm đúng từng mục được giao dưới đây), `docs/PRODUCT_SPEC.md` §6.1–6.4.

Mục tiêu: VKey có giao diện mới theo hướng B cho **khung cửa sổ cài đặt + trang Bộ gõ + menu thanh menu + icon thanh menu +
icon app**, và tính năng mới **chọn bàn phím Tự động / JIS (Nhật) / Tiếng Anh (US)** (SPEC §6.4). Các trang khác (Gõ tắt,
Chuyển mã, Clipboard, Hệ thống, Giới thiệu, Chào mừng) **giữ nguyên nội dung và kiểu cũ** trong khung mới — làm ở 5d.

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; logic thuần C++ ở `Sources/Platform/VKKeyLayout.{h,cpp}` (test
trong `tests/engine/EngineTests.cpp`, mỗi ca một hàm `caseNN_…`); logic thuần Swift là file chỉ `import Foundation` ở
`Sources/App/`, test bằng `xcrun swiftc` trong `check.sh`; khoá UserDefaults mới có trong `registerDefaultSettings` và
`resetToDefaults`; không thêm IPC / TIS / AX đồng bộ trên đường nóng (AGENTS quy tắc 9); Conventional Commits tiếng Việt; chỉ
`git add <file>`; **mở PR vào `main` của `origin`** và gửi link. Ca test mới đánh số từ **71**.

### Hiện trạng đã xem (Claude, `origin/main` @ `3e0931b` + tài liệu, 2026-10-23)
- **Loại bàn phím trong hook** (`Sources/Platform/VKEngineHook.mm`): biến `_currentKeyboardIsJIS` (`:255`),
  `_lastKeyboardType` (`:257`). Mỗi keyDown (`:1047-1059`): đọc `kCGKeyboardEventKeyboardType`; chỉ khi đổi mới gọi
  `KBGetLayoutType` → `_currentKeyboardIsJIS`; nếu JIS thì đọc `_currentEventCharacter`. Sau khối loại trừ app:
  `if (keyDown && _currentKeyboardIsJIS)` → `VKJISToLogicalKey` (`:1076`); `if (keyDown && !_currentKeyboardIsJIS &&
  vPerformLayoutCompat)` → tương thích bố cục (`:1081`). Phím 英数 / かな: `VKLanguageKeyActionFor(_physicalKeycode,
  vUseJISLanguageKeys != 0, _frontMostIsExcluded, ⌘⌃⌥, _cachedIsEnglishLayout)` (`:1096`) — hàm không xét loại bàn phím.
  `_currentKeyboardIsJIS` còn dùng ở `:393-395`, `:779`, `:794`, `:859-862`, `:1181`, `:1227`.
- **Cài đặt nạp vào global** bằng `LOAD_DATA(var, key)` (`VKEngineHook.mm:434-460`, vd `LOAD_DATA(vUseJISLanguageKeys,
  vUseJISLanguageKeys)`); global khai báo ở `VKBridge.mm:39-43`, `extern` ở `VKGlobals.h:43-48`.
- **Nguồn nhập:** `VKUpdateInputSourceCache()` (`VKEngineHook.mm:116`) cập nhật `_cachedIsEnglishLayout` (`:124`) khi có
  `kTISNotifySelectedKeyboardInputSourceChanged` (đăng ký Distributed, `:508`) và lúc khởi động / đổi app. Phía Swift chưa
  biết nguồn nhập hiện tại.
- **AppState** (`Sources/App/AppState.swift`): `static var isJISKeyboard` (`:47`, `LMGetKbdType`); `useJISLanguageKeys`
  (`:109`, khoá `vUseJISLanguageKeys`, mặc định `isJISKeyboard`); `registerDefaultSettings` (`:283`); `resetToDefaults`
  (`:323`, danh sách khoá `:325-332`). Có sẵn: `isVietnamese`, `inputType`, `codeTable`, `switchKeyStatus`, `grayIcon`,
  `currentAppExcluded`, `selectedPage`, `accessibilityGranted`.
- **Khung cửa sổ** `Sources/App/Views/SettingsRootView.swift`: sidebar tự dựng rộng 192 (icon app 64, nhãn `CÀI ĐẶT`, 6
  `SidebarRow` có SF Symbol, `StatusBadge`), vùng nội dung có `PageHeader` (SF Symbol + tiêu đề) + mask gradient + blur
  (`VisualEffectBlur`); cửa sổ cố định rộng 820, cao tối thiểu 560 (`:51`, `:61-63`). `VKeyApp.swift:26-33` khai báo cửa sổ
  `settings` `defaultSize(820, 560)`.
- **Trang Bộ gõ** `Sources/App/Views/TypingPage.swift`: `Form` kiểu grouped (`settingsFormStyle` ở `AppStyle.swift`) với các
  Section `Chế độ gõ` (Toggle "Bật Tiếng Việt", Picker Kiểu gõ, Picker Bảng mã), `Phím chuyển chế độ` (HotkeyEditor, beep,
  toggle 英数 / かな + chú thích, footer ⌃⇧), `Chính tả` (6), `Gõ nhanh` (4), `Tương thích` (5 + chú thích), `Hỗ trợ Trợ năng`
  (toggle + danh sách app kéo thả `AXSupportAppRow`).
- **Menu** `VKeyApp.swift` `MenuContent` (`:~75-150`): Toggle Tiếng Việt (dynamicShortcut), `Tắt VKey cho …`, Picker Kiểu gõ,
  Picker Bảng mã, Chuyển mã nhanh, Công cụ chuyển mã…, Gõ tắt…, Lịch sử Clipboard, `Bảng điều khiển…`, Giới thiệu VKey, Kiểm
  tra cập nhật…, Thoát VKey; bản rút gọn khi chưa có quyền.
- **Icon thanh menu** `Sources/App/StatusIcon.swift`: 18 × 18, khối bo 2 màu `srgbRed 0x0066AB` hoặc template (`gray`), chữ
  `V` / `E` 14 pt, loại trừ = alpha 0.35; dùng ở `MenuBarLabel` (`VKeyApp.swift`).
- **Icon app** `scripts/make_icon.swift`: nền gradient xanh + logo "ngọn núi" (polygons) → `Assets.xcassets/AppIcon.appiconset`
  (10 PNG + `Contents.json`).
- **Harness** `tests/engine/EngineHarness.h`: `jisKeys(u"…")`, `type(keys)` (đường ANSI — keycode giữ nguyên),
  `typeJIS(keys)` (đường JIS). Claude đo 2026-10-23 bằng chính harness:

  | Chuỗi gõ trên bàn phím JIS | `type(jisKeys(…))` (= Tiếng Anh, như mkey gốc) | `typeJIS(jisKeys(…))` (= JIS) |
  |---|---|---|
  | `@` | `ơ` | `@` |
  | `[` | `ư` | `ơ` |
  | `]` | `]` | `ư` |
  | `tooi@as` | `tôi@as` | `tôi@á` |
  | `ddaay` | `đây` | `đây` |

## Việc 0 — Còn tồn
Không có cho 5c (khoá `mkLoginItemInitialized` để 5d).

## Việc 1 — Chọn bàn phím: logic (SPEC §6.4)
- `VKKeyLayout.h/.cpp` (C++ thuần):
  ```cpp
  enum VKKeyboardMode { VKKeyboardModeAuto = 0, VKKeyboardModeJIS = 1, VKKeyboardModeANSI = 2 };
  // Giá trị lạ → coi như Auto.
  bool VKTreatAsJIS(int keyboardMode, bool hardwareIsJIS);
  // ANSI → VKLanguageKeyNotHandled; Auto / JIS / giá trị lạ → đúng kết quả VKLanguageKeyActionFor(...).
  VKLanguageKeyAction VKLanguageKeyActionForMode(int keyboardMode, Uint16 physicalKeycode, bool optionEnabled,
                                                bool appExcluded, bool hasCommandControlOption, bool inputSourceIsLatin);
  ```
  Không đổi chữ ký / hành vi `VKLanguageKeyActionFor` (ca 40–47, 52–54 giữ nguyên).
- Global `int vKeyboardMode = 0;` (`VKBridge.mm` cạnh `vUseJISLanguageKeys`, `extern` trong `VKGlobals.h`);
  `LOAD_DATA(vKeyboardMode, vKeyboardMode);`.
- `VKEngineHook.mm`:
  - Đổi tên `_currentKeyboardIsJIS` thành hai biến: `_hardwareKeyboardIsJIS` (tính như cũ, chỉ khi keyboard type đổi) và
    `_currentKeyboardIsJIS = VKTreatAsJIS(vKeyboardMode, _hardwareKeyboardIsJIS)` tính **mỗi keyDown** ngay sau đó (một phép so
    sánh, không gọi hệ thống). Mọi chỗ dùng `_currentKeyboardIsJIS` hiện có giữ nguyên ý nghĩa "xử lý kiểu JIS". Đọc
    `_currentEventCharacter` khi `_currentKeyboardIsJIS`.
  - Thay lời gọi `VKLanguageKeyActionFor(…)` (`:1096`) bằng `VKLanguageKeyActionForMode(vKeyboardMode, …)`.
  - Báo UI khi bàn phím vật lý đổi: trong nhánh "keyboard type đổi", nếu `_hardwareKeyboardIsJIS` đổi giá trị → ghi một
    `std::atomic<bool>` toàn cục và `dispatch_async(dispatch_get_main_queue(), …)` post notification
    `VKHardwareKeyboardDidChange`. Không làm gì khác trên đường nóng.
  - `VKUpdateInputSourceCache()`: sau khi cập nhật cache, post notification `VKInputSourceDidChange` (hàm này không chạy trong
    callback phím).
- `VKBridge`: `+ (BOOL)lastHardwareKeyboardIsJIS` (đọc atomic; trước phím đầu tiên trả `KBGetLayoutType(LMGetKbdType()) ==
  kKeyboardJIS`), `+ (BOOL)inputSourceIsLatin` (đọc `_cachedIsEnglishLayout`), `+ (void)setKeyboardMode:(int)mode` (ghi
  global). Đặt tên notification ở phía Swift như các `.vk…` hiện có.
- `AppState`: `@Published var keyboardMode: Int` (khoá `vKeyboardMode`, mặc định 0, ghi xuống + `VKBridge.setKeyboardMode`),
  có trong `registerDefaultSettings` và `resetToDefaults`; `@Published private(set) var hardwareKeyboardIsJIS: Bool` và
  `inputSourceIsLatin: Bool`, khởi tạo từ `VKBridge`, cập nhật khi nhận hai notification trên (main thread).
- Swift thuần `Sources/App/KeyboardModeStatus.swift` (chỉ `import Foundation`):
  ```swift
  enum KeyboardModeStatus {
      struct Result: Equatable { let message: String; let isWarning: Bool; let treatsAsJIS: Bool }
      static func result(mode: Int, hardwareIsJIS: Bool) -> Result   // chữ đúng từng ký tự theo DESIGN §6.1
  }
  ```
  Giá trị `mode` lạ → như Tự động.
- Swift thuần `Sources/App/LanguageIndicator.swift`:
  ```swift
  enum LanguageIndicator: Equatable {
      case vietnamese, english, japanese
      static func current(isVietnamese: Bool, inputSourceIsLatin: Bool) -> LanguageIndicator
      var menuBarText: String   // "VI" / "EN" / "あ"
  }
  ```

## Việc 2 — Nền giao diện (DESIGN §1–§4)
- `Sources/App/Views/VKTheme.swift`: đủ token DESIGN §2 (sáng / tối), dạng `static let` `Color` dựng từ `NSColor` động.
  Không khai báo màu ở chỗ khác.
- `Sources/App/Views/VKComponents.swift`: `VKCard`, `VKRow`, `VKDivider`, `VKSectionLabel`, `VKSegmented`, `VKKeycap`,
  `VKKeycapRow`, `VKBanner` đúng DESIGN §3–§4 (kèm accessibility như §4).
- `AppStyle.swift` / `settingsFormStyle` **giữ** cho các trang chưa làm (5d).

## Việc 3 — Khung cửa sổ (DESIGN §5)
- `SettingsRootView`: sidebar mới (rộng 200, chữ VKey + `Việt · 日本語`, 6 mục chữ, mục chọn kiểu §5, `StatusBadge` đổi màu
  theo token); bỏ `PageHeader` có SF Symbol, mask gradient, `VisualEffectBlur`; vùng nội dung nền `windowBackground`; tiêu đề
  trang (24 bold) ở đầu vùng nội dung cho **mọi** trang (các trang 5d hiển thị tiêu đề này + nội dung cũ bên dưới); trang Bộ
  gõ thêm chọn bàn phím bên phải tiêu đề. Kích thước 860 × 600, tối thiểu 860 × 560 (`SettingsRootView`, `VKeyApp`
  `defaultSize`).
- Bỏ `icon` (SF Symbol) của `SettingsPage` nếu không còn dùng.

## Việc 4 — Trang Bộ gõ (DESIGN §6)
Viết lại `TypingPage` bằng `VKCard` / `VKRow`…: chọn bàn phím + dòng trạng thái / cảnh báo (`KeyboardModeStatus`; nút `Về
Tự động` đặt `keyboardMode = 0`), dải 3 ô ngôn ngữ (ô đang dùng theo `LanguageIndicator`; ô Việt / Anh là nút; ô 日本語 không
bấm được), rồi các thẻ §6.3 với **đủ** tuỳ chọn hiện có (không bỏ, không thêm tuỳ chọn nào ngoài chọn bàn phím). Toggle "Bật
Tiếng Việt" được thay bằng ô Việt / Anh. Ở chế độ Tiếng Anh: switch 英数 / かな disabled + chú thích như DESIGN.

## Việc 5 — Menu + icon thanh menu (DESIGN §7–§8)
- `MenuContent`: thêm submenu `Bàn phím` (Picker inline / radio 3 lựa chọn, ràng buộc `state.keyboardMode`); dòng mờ `Đang gõ
  tiếng Nhật — bấm 英数 để về` khi `!inputSourceIsLatin`; đổi `Bảng điều khiển…` → `Cài đặt VKey…`; thứ tự theo §7. Bản rút
  gọn khi chưa có quyền giữ nguyên.
- `StatusIcon`: vẽ theo §8 (`VI` / `EN` / `あ`, đặc / viền, template khi `grayIcon`, màu `accent` khi không, mờ 35 % khi loại
  trừ); `MenuBarLabel` truyền `LanguageIndicator.current(…)`.

## Việc 6 — Icon app (DESIGN §9)
Viết lại `scripts/make_icon.swift` theo §9 (bỏ hình ngọn núi, gradient, viền sáng; 16 / 32 px bỏ con dấu), chạy để sinh lại
`AppIcon.appiconset` (đủ 10 PNG + `Contents.json`, commit các PNG). Chữ `あ` vẽ bằng font hệ thống (`NSFont.systemFont`
bold — macOS tự lấy Hiragino cho chữ Nhật).

## Ca test bắt buộc (mỗi ca một hàm riêng, tên có số ca)
C++ trong `tests/engine/EngineTests.cpp` (harness thêm `std::u16string typeWithKeyboardMode(int mode, bool hardwareIsJIS,
const std::vector<Key>& keys)`: `VKTreatAsJIS(mode, hardwareIsJIS) ? typeJIS(keys) : type(keys)`):

71. `case71_treatAsJISByMode`: Auto + JIS → true; Auto + không JIS → false; JIS + JIS → true; JIS + không JIS → true;
    ANSI + JIS → false; ANSI + không JIS → false; mode 7 / -1 + JIS → true, + không JIS → false.
72. `case72_languageKeysByMode`: ANSI → `NotHandled` cho 102 và 104 với mọi tổ hợp (option bật / tắt, input source Latin /
    không) — kiểm ít nhất 8 tổ hợp; Auto và JIS → bằng đúng `VKLanguageKeyActionFor` trên cùng 8 tổ hợp (gồm `PassToSystem`,
    `ToggleLanguage`, `EndWord`).
73. `case73_typingByKeyboardMode` (bàn phím vật lý JIS, `jisKeys`): Auto → `@`→`@`, `[`→`ơ`, `]`→`ư`, `tooi@as`→`tôi@á`;
    JIS → giống Auto; ANSI → `@`→`ơ`, `[`→`ư`, `]`→`]`, `tooi@as`→`tôi@as`; cả ba mode `ddaay`→`đây`. Bàn phím vật lý không
    JIS (`ansiKeys("ddaay")`): Auto và ANSI → `đây`.

Swift `tests/KeyboardModeStatusTests.swift` (biên dịch cùng `KeyboardModeStatus.swift` + `LanguageIndicator.swift`, bước mới
trong `check.sh`, in `PASS: 5 keyboard mode tests`):

74. `case74_autoModeStatus`: (0, JIS) và (0, không JIS) → đúng chữ DESIGN §6.1, `isWarning == false`, `treatsAsJIS` true /
    false.
75. `case75_forcedModeMatchingKeyboard`: (1, JIS) → `Luôn gõ kiểu JIS`; (2, không JIS) → `Luôn gõ như bàn phím tiếng Anh
    (US)`; không cảnh báo.
76. `case76_forcedModeMismatchWarns`: (1, không JIS) và (2, JIS) → `isWarning == true`, chữ đúng DESIGN (cảnh báo Tiếng Anh có
    `vd @ ra ơ` và `英数 / かな`).
77. `case77_invalidModeFallsBackToAuto`: mode 3 và -1 → bằng kết quả mode 0 với cùng `hardwareIsJIS`.
78. `case78_languageIndicator`: (Việt, Latin) → `.vietnamese` `VI`; (Anh, Latin) → `.english` `EN`; (Việt, không Latin) và
    (Anh, không Latin) → `.japanese` `あ`.

Ca 1–70 giữ nguyên expectation.

## Không được làm
- Không đổi giao diện / nội dung trang Gõ tắt, Chuyển mã, Clipboard, Hệ thống, Giới thiệu, cửa sổ Chào mừng, bảng lịch sử
  clipboard (5d) — chỉ được hiện trong khung mới. Không đổi khoá `mkLoginItemInitialized`.
- Không bỏ / thêm tuỳ chọn nào ngoài chọn bàn phím; không đổi khoá UserDefaults hiện có; không đổi hành vi Auto so với hiện
  tại (mọi ca 1–70 xanh).
- Không gọi `TISSelectInputSource` / không tự đổi nguồn nhập (ô 日本語 không bấm được). Không gọi TIS / AX / IPC mới trong
  `VKEngineCallback`; notification chỉ post khi loại bàn phím đổi.
- Không nhúng font, không thêm dependency / Swift package, không thêm file nhị phân ngoài PNG icon. Không sửa
  `Sources/Engine/`, `.github/`, `project.yml` (trừ khi cần thêm file nguồn mới — XcodeGen tự nhận theo thư mục, thường không
  cần), cấu hình ký, version, `SU*`.
- Không sửa `AGENTS.md`, `CLAUDE.md`, `docs/` (Claude cập nhật). Không push `main`.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `PASS: 14 update runtime policy checks`, `PASS: 53 engine tests`,
      `PASS: 8 hotkey key name tests`, `PASS: 6 system hotkey conflict tests`, `PASS: 6 release signature tests`,
      `PASS: 5 keyboard mode tests`. CI xanh.
- [ ] Đủ ca 71–78, mỗi ca một hàm.
- [ ] `git grep -n -E 'Color\(red|srgbRed|#[0-9A-Fa-f]{6}' -- Sources/App` chỉ còn trong `VKTheme.swift` (dán kết quả).
- [ ] Kịch bản chạy thật — máy JIS này, ABC + Japanese – Romaji, không bộ gõ tiếng Việt khác chạy. **Gõ bằng `CGEventPost`
      (đặt `kCGKeyboardEventKeyboardType`: JIS = 93; ANSI = một giá trị mà `KBGetLayoutType` trả `kKeyboardANSI`, ghi giá trị
      đã dùng) như Phase 4b — không dùng công cụ chèn chữ thẳng vào ô (5a đã cho thấy nó không đi qua event tap)**. Đọc chữ
      bằng AppleScript / Accessibility. Ghi kết quả:
  - (a) Tự động: gõ JIS `tieengs vieetj` → `tiếng việt`; `@` → `@`; かな → `nihongo⏎` ra chữ Nhật, icon thanh menu `あ`, ô 日本語
    sáng; 英数 → ABC, icon `VI`; gõ ANSI `ddaay` → `đây`, dòng trạng thái đổi sang `Đang nhận: bàn phím US / ISO…`, gõ JIS lại →
    đổi về.
  - (b) Tiếng Anh (US) (chọn trong menu `Bàn phím`): gõ JIS `@` → `ơ`, `[` → `ư`; cảnh báo hiện; bấm `Về Tự động` → về Tự
    động, cảnh báo mất; switch 英数 / かな disabled khi ở Tiếng Anh.
  - (c) JIS (Nhật): gõ ANSI → cảnh báo không phải JIS; gõ JIS → `Luôn gõ kiểu JIS`.
  - (d) Giao diện: chụp cửa sổ cài đặt trang Bộ gõ ở **sáng và tối** (Cài đặt hệ thống → Giao diện, hoặc
    `NSApp.appearance` tạm trong Debug), so với DESIGN §5–§6 và khung B của canvas; đính kèm ảnh **vào PR** (không commit);
    chuyển qua 5 trang còn lại → tiêu đề mới + nội dung cũ, không vỡ bố cục. Tab đi qua segmented, ô Việt / Anh, các switch.
  - (e) Menu thanh menu (đọc qua Accessibility): đúng thứ tự §7, submenu `Bàn phím` có dấu chọn đúng, `Cài đặt VKey…` mở cửa
    sổ; icon `VI` / `EN` / `あ`, mờ khi app bị loại trừ; tắt "Biểu tượng đơn sắc" → icon màu đỏ son.
  - (f) Icon app: ảnh `icon_512x512@2x.png` và `icon_16x16@2x.png` đính kèm PR; Finder / Dock hiện icon mới (có thể phải
    `killall Dock` / đổi tên tạm bản build).
  - (g) `defaults read io.github.akachick113.vkey.debug vKeyboardMode` đổi theo lựa chọn; "Khôi phục mặc định" (trang Hệ thống)
    → về 0.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo việc (Conventional Commits tiếng Việt, vd `feat: chọn bàn phím Tự động / JIS / Tiếng Anh`, `feat: nền giao diện
VKTheme và khung cửa sổ mới`, `feat: trang Bộ gõ theo thiết kế mới`, `feat: menu và icon thanh menu VI / EN / あ`, `feat: icon
app VKey`, `test: …`). Push nhánh `phase-5c-design-typing`, **mở PR vào `main`** và gửi link. Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả (a)–(g) (keyboard type ANSI đã dùng; link ảnh trong PR).
3. Kết quả lệnh `git grep` màu.
4. Chỗ khác DESIGN / prompt và lý do; chỗ **chưa chắc** / chưa kiểm được (đặc biệt: tương phản chế độ tối, VoiceOver).
