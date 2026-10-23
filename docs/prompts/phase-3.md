# Phase 3 — 英数 / かな luôn kết thúc từ + cảnh báo trùng phím tắt macOS

> Codex · **GPT-6 Sol** · effort **Medium** (đường nóng chỉ đổi ~10 dòng đã đặc tả sẵn; phần lớn là Swift thuần + UI theo
> mẫu `HotkeyKeyName` của Phase 2 — WORKFLOW §8) · nhánh `phase-3-hotkey-conflict`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PRODUCT_SPEC.md` (§5, §6.2, §6.3), `docs/PLAN.md` (**Quyết định chung**, Phase 0–2 **Quyết định đã
chốt**, Phase 2 **Còn tồn**, Phase 3), `docs/notes/codebase-map.md` (§5, §6).

Mục tiêu:
1. **Việc 0 — C1:** 英数 / かな luôn là phím kết thúc từ, kể cả khi tắt tuỳ chọn "Dùng phím 英数 / かな…" (người dùng
   chốt 2026-10-19). **C2:** hai lỗi nhỏ có sẵn của `HotkeyEditor` (cộng dồn modifier, ký tự hiển thị khi ghi).
2. `HotkeyEditor` cảnh báo khi phím tắt đã lưu trùng một phím tắt **đang bật** của macOS.

Phase này **không** làm hotkey đi thẳng Nhật / Việt / Anh bằng `TISSelectInputSource` (người dùng bỏ, 2026-10-19).

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; logic thuần C++ ở `Sources/Platform/MKKeyLayout.{h,cpp}`, test
ở `tests/engine/` (mỗi ca một hàm `caseNN_…`, `resetConfiguration()` trước mỗi ca); logic thuần Swift là file chỉ
`import Foundation` ở `Sources/App/`, test bằng `xcrun swiftc` trong `check.sh` như `HotkeyKeyName`; trong
`MKEngineHook.mm` so phím bằng `_physicalKeycode` / `HotkeyKeycode()`; không gọi TIS / AX / IPC đồng bộ mới trong callback
(AGENTS quy tắc 9); chuỗi UI tiếng Việt theo giọng sẵn có; Conventional Commits tiếng Việt; chỉ `git add <file>`;
**mở PR vào `main` của `origin`** và gửi link. Ca test mới đánh số từ **52**.

Hiện trạng đã xem (Claude đo trên máy JIS này, macOS 27.0.1, 2026-10-19):
- **C1 — 英数 / かな khi tắt tuỳ chọn.** `MKLanguageKeyActionFor` (`MKKeyLayout.cpp:6-14`) trả `NotHandled` khi
  `!optionEnabled` → trong `MKEngineCallback` 102 / 104 đi tiếp xuống khối hotkey (`MKEngineHook.mm:1113-1133`) rồi vào
  `vKeyHandleEvent` như ký tự trong từ. Harness + engine thật: `⏎ 英数 ddaay` → `đaay` (đúng như chạy thật ở review
  Phase 2); `tie かな es` → `tie es` không ghép. Khi giữ ⌘ / ⌃ / ⌥ (`OTHER_CONTROL_KEY`) engine đã tự kết thúc từ
  (`Engine.cpp:1473`, `vEnglishMode` `:1438`) nên không cần xử lý thêm.
- Khối 英数 / かな hiện tại (`MKEngineHook.mm:1093-1110`) nằm **trước** khối hotkey: `PassToSystem` = `RequestNewSession()`
  + `return event`; `ToggleLanguage` = `switchLanguage()` + `return NULL`. Khi tắt tuỳ chọn, `HotkeyEditor` cho ghi 英数 /
  かな trơn làm phím tắt (Phase 2) và khối hotkey phải bắt được nó — nên nhánh "chỉ kết thúc từ" phải đặt **sau** khối
  hotkey. `RequestNewSession()` (`:516`) = gửi sự kiện Mouse cho engine (kết thúc từ, xoá bộ đệm gõ tắt ở cả Việt lẫn Anh)
  + xoá `_syncKey` khi VNI + `AXInvalidateFocusCache()`.
- **C2 — HotkeyEditor** (`Sources/App/Views/HotkeyEditor.swift`):
  - `peakModifiers` (`:194`) chỉ được xoá khi bắt đầu ghi (`:204`) và trong nhánh `rejectedKeyInModifierSequence`
    (`:234`). Thả hết modifier mà không ghi gì (nhánh `else` `:252-254`) không xoá → bấm-thả ⌃ rồi bấm-thả ⇧ thì `peak` =
    ⌃⇧ và bị ghi thành phím tắt chỉ-modifier ⌃⇧.
  - Ký tự hiển thị lưu ở byte cao lấy từ `event.characters.utf8.first` (`:308`). Probe `NSEvent(cgEvent:)` (keyboard type
    93, input source ABC):

    | Tổ hợp | `characters` | `charactersIgnoringModifiers` | `characters(byApplyingModifiers: [])` |
    |---|---|---|---|
    | ⌥Z (6) | U+03A9 `Ω` | `z` | `z` |
    | ⌃Z (6) | U+001A | `z` | `z` |
    | ⌃⇧ phím 30 (`[` trên JIS) | U+001D | `{` | `[` |
    | ⌃¥ (93) | `\|` | `¥` | `¥` |
    | ⌃Space (49) | U+0000 | ` ` | ` ` |
    | 英数 (102) | ` ` | ` ` | ` ` |

    ⇒ ghi ⌥Z bằng tay lưu byte 0xCE (đầu UTF-8 của `Ω`) → hiện `⌥Î`; ghi ⌃ + chữ cái lưu ký tự điều khiển → hiện rác.
    Mặc định ⌥Z là `0x7A000206` (byte cao `z`). Engine chỉ dùng byte thấp (keycode) + bit modifier (`Engine.h:25-31`),
    byte cao chỉ để hiển thị.
- **Phím tắt của macOS.** API công khai `CopySymbolicHotKeys` (Carbon / HIToolbox, đã `import Carbon` ở
  `AppState.swift`) trả **giá trị đang hiệu lực, gồm cả mặc định** — khác với file `com.apple.symbolichotkeys.plist`, chỉ
  chứa mục người dùng đã chạm (máy này: 19 mục; Spotlight ⌘Space **không** có trong plist nhưng đang bật; mục 79–82 chỉ có
  `enabled`, không có giá trị). Kết quả trên máy này: 234 mục, mỗi mục là dictionary với `kHISymbolicHotKeyCode` (keycode),
  `kHISymbolicHotKeyModifiers` (modifier kiểu **Carbon**: `cmdKey` 0x100, `shiftKey` 0x200, `optionKey` 0x800,
  `controlKey` 0x1000, `kEventKeyModifierFnMask` 0x20000), `kHISymbolicHotKeyEnabled` (bool). Ví dụ đang bật:
  `49 0x100` (⌘Space), `49 0x1000` (⌃Space), `49 0x1800` (⌃⌥Space), `49 0x1100` (⌃⌘Space), `21 0x300` (⇧⌘4),
  `120 0x21000` (⌃F2, có bit fn), `123 0x21000` (⌃←), `103 0x20000` (F11), `48 0x100` (⌘Tab), `102 0x0` / `104 0x0`
  (英数 / かな trơn). Có cả mục nội bộ (keycode 129–179, mục bit fn trơn như fn Q = `12 0x20000`). App không sandbox
  (`mkey.entitlements` rỗng). Chưa đo: giá trị có cập nhật ngay trong cùng process sau khi người dùng đổi ở Cài đặt hệ thống
  hay không — kịch bản (g) đo.
- macOS tự thêm cờ fn cho F1–F20, mũi tên, Home / End / Page Up / Page Down, Forward Delete, Help — nên mục hệ thống của
  các phím này luôn có bit 0x20000, còn bitfield hotkey của mkey không có bit fn.
- `HotkeyEditor` dùng ở 3 chỗ: `TypingPage.swift:44` (chuyển chế độ, khoá `SwitchKeyStatus`), `ConvertPage.swift:51`
  (chuyển mã, `convertToolHotKey`), `ClipboardPage.swift:35` (clipboard, `clipboardHotKey`, `allowsModifierOnly: false`).
  Bitfield: byte thấp keycode (0xFE = không có phím), ⌃ 0x100, ⌥ 0x200, ⌘ 0x400, ⇧ 0x800, beep 0x8000, byte cao ký tự hiển
  thị; `0xFE0000FE` = chưa đặt. Kiểu cảnh báo sẵn có: `PermissionBanner` (`SettingsRootView.swift:204`) dùng
  `Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)`.
- Kết quả mong đợi của ca 52–54 Claude đã chạy bằng bản cài đặt tham chiếu (ngoài repo) trên engine thật; bảng phím tắt
  ở Việc 3 lấy từ `CopySymbolicHotKeys` + `CGSGetSymbolicHotKeyValue` trên máy này.

## Việc 0 — Còn tồn Phase 2

### C1 — 英数 / かな luôn kết thúc từ
`MKKeyLayout.h` / `.cpp`: thêm giá trị cuối enum `MKLanguageKeyEndWord` (chú thích: "chỉ kết thúc từ, phím đi tiếp như
cũ"). Quy tắc mới của `MKLanguageKeyActionFor`, theo thứ tự:
1. `appExcluded` hoặc `hasCommandControlOption` → `NotHandled`.
2. Phím không phải 102 / 104 → `NotHandled`.
3. `!optionEnabled` → `EndWord`.
4. 104 → `PassToSystem`; 102 → `inputSourceIsLatin ? ToggleLanguage : PassToSystem` (như cũ).

`MKEngineCallback`: giữ nguyên khối 英数 / かな ở `:1093` nhưng lưu kết quả vào biến cục bộ (vd `languageKeyAction`, khởi
tạo `NotHandled` cho mọi loại event). `EndWord` **không** xử lý ở đó mà sau khối hotkey: ngay sau dòng
`_hasJustUsedHotKey = _lastFlag != 0;` (trong nhánh `type == kCGEventKeyDown` của khối hotkey) thêm
```objc
if (languageKeyAction == MKLanguageKeyEndWord) {
    RequestNewSession();
    _lastKeystrokeTime = currentKeystrokeTime;
    return event;
}
```
Tức là: hotkey người dùng lưu bằng 英数 / かな (khi tắt tuỳ chọn) vẫn chạy như cũ; không thì kết thúc từ và trả phím cho
macOS — không vào `vKeyHandleEvent` / `vEnglishMode`, không đổi `vLanguage`, không đổi input source. Nhánh tuỳ chọn bật
không đổi. keyUp không đổi.

Ca 43 (`case43_disabledLanguageKeysUseOldPath`) đổi expectation `NotHandled` → `EndWord` và đổi tên thành
`case43_disabledLanguageKeysEndWord` — **được phép** (quyết định C1); ghi rõ trong PR. Ca 44–46 giữ nguyên.

Harness: thêm vào `EngineHarness.{h,cpp}`
```cpp
// Như typeJIS, input source Latin, không app loại trừ, không ⌘⌃⌥. Phím 102 / 104 không bao giờ chèn chữ:
// hành động lấy từ MKLanguageKeyActionFor(key, optionEnabled, false, false, true);
// EndWord / PassToSystem → kết thúc từ như RequestNewSession (sự kiện Mouse cho engine);
// ToggleLanguage → đảo vLanguage rồi kết thúc từ; NotHandled → vào engine như phím thường.
std::u16string typeJISWithLanguageKeys(const std::vector<Key>& keys, bool optionEnabled);
```
Dùng chung vòng lặp với `typeKeys` (tham số / hàm phụ), không chép lại. `typeJIS` / `type` giữ nguyên hành vi.

### C2 — HotkeyEditor
- Nhánh thả hết modifier mà không ghi (`:252-254`): xoá `peakModifiers = 0` cùng lúc với `activeModifiers = 0`.
- `Sources/App/HotkeyKeyName.swift` thêm hàm thuần
  ```swift
  /// Byte ký tự hiển thị lưu ở byte cao khi ghi phím tắt; nil = không ghi phím này.
  static func recordedCharacter(keyCode: UInt16, baseCharacters: String?) -> UInt8?
  ```
  `keyCode == 49` → 32; `keyCode >= 0xFE` → nil; còn lại `baseCharacters?.utf8.first` (nil nếu chuỗi rỗng / nil).
  Recorder (`:304-312`) gọi hàm này với `event.characters(byApplyingModifiers: []) ?? event.charactersIgnoringModifiers`;
  nil → `return event` như hiện nay. Không đổi định dạng bitfield, không sửa hotkey đã lưu.

## Việc 1 — Đọc phím tắt đang bật của macOS
- File mới `Sources/App/SystemHotkeyConflict.swift`, **chỉ `import Foundation`** (test bằng `swiftc`):
  ```swift
  struct SystemHotkey: Equatable {
      let keyCode: Int
      let carbonModifiers: Int
  }

  enum SystemHotkeyConflict {
      /// Carbon → bit hotkey của mkey: cmdKey 0x100 → ⌘ 0x400, shiftKey 0x200 → ⇧ 0x800,
      /// optionKey 0x800 → ⌥ 0x200, controlKey 0x1000 → ⌃ 0x100. Bỏ mọi bit khác (fn, caps lock, bên phải…).
      static func modifiers(fromCarbon carbon: Int) -> Int32
      /// F1–F20, mũi tên, Home / End / Page Up / Page Down, Forward Delete, Help: macOS tự gắn cờ fn.
      static func carriesImplicitFunction(_ keyCode: Int) -> Bool
      static func matches(status: Int32, _ hotkey: SystemHotkey) -> Bool
      /// Tên mặc định của macOS cho tổ hợp (bảng Việc 3); nil nếu không có trong bảng.
      static func defaultName(status: Int32) -> String?
      /// Chuỗi cảnh báo, nil nếu không trùng.
      static func warning(status: Int32, enabledSystemHotkeys: [SystemHotkey]) -> String?
  }
  ```
  Hằng Carbon viết bằng số kèm chú thích (không `import Carbon` trong file này). Danh sách keycode của
  `carriesImplicitFunction`: F1 122, F2 120, F3 99, F4 118, F5 96, F6 97, F7 98, F8 100, F9 101, F10 109, F11 103, F12 111,
  F13 105, F14 107, F15 113, F16 106, F17 64, F18 79, F19 80, F20 90, Home 115, End 119, Page Up 116, Page Down 121,
  Forward Delete 117, Help 114, ← 123, → 124, ↓ 125, ↑ 126.
- `matches`: hotkey có phím (`(value & ~0x8000) != 0xFE0000FE` và byte thấp ≠ 0xFE) **và** byte thấp == `keyCode`
  **và** `status & 0xF00 == modifiers(fromCarbon:)` **và** `(carbonModifiers & 0x20000 != 0) ==
  carriesImplicitFunction(keyCode)`. Bit beep không tính. Phím tắt chỉ-modifier (⌃⇧…) không bao giờ trùng.
- `warning`: keycode 102 / 104 → nil (英数 / かな đã có chú thích riêng của Phase 2 — tránh hai dòng cùng nói một việc).
  Có ít nhất một `matches` → có `defaultName`:
  `Trùng phím tắt đang bật của macOS (mặc định: “<tên>”). Nên chọn tổ hợp khác, hoặc tắt phím tắt đó trong Cài đặt hệ thống → Bàn phím → Phím tắt bàn phím.`
  không có tên:
  `Trùng một phím tắt đang bật của macOS. Nên chọn tổ hợp khác, hoặc tắt phím tắt đó trong Cài đặt hệ thống → Bàn phím → Phím tắt bàn phím.`
  (dấu ngoặc kép “ ” như trên). Không trùng → nil.
- File mới `Sources/App/SystemHotkeyReader.swift` (`import Carbon`): `enum SystemHotkeyReader { static func
  enabledHotkeys() -> [SystemHotkey] }` — gọi `CopySymbolicHotKeys`, lấy mục có `kHISymbolicHotKeyEnabled == true`,
  keycode / modifier đọc bằng `NSNumber`; lỗi / không đọc được → `[]`. Không cache toàn cục, không gọi từ event tap; không
  dùng API riêng (`CGS…`), không đọc / ghi `com.apple.symbolichotkeys` trực tiếp.

## Việc 2 — Hiện cảnh báo trong `HotkeyEditor`
- `@State private var systemHotkeys: [SystemHotkey] = []`, nạp bằng `SystemHotkeyReader.enabledHotkeys()` ở `.onAppear`
  và `.onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification))` (người dùng đổi ở
  Cài đặt hệ thống rồi quay lại).
- Khi `!isRecording` và `SystemHotkeyConflict.warning(status:enabledSystemHotkeys:)` khác nil: hiện dưới editor (sau các
  dòng chú thích 英数 / かな sẵn có) một `HStack` gồm `Image(systemName: "exclamationmark.triangle.fill")
  .foregroundStyle(.orange)` + `Text(chuỗi cảnh báo)` `.font(.footnote)` `.foregroundStyle(.secondary)`.
- Áp dụng cho cả 3 editor (không thêm tham số). Không chặn ghi, không tự đổi / xoá phím tắt. Không so trùng giữa các phím
  tắt của chính mkey (ngoài phạm vi).

## Việc 3 — Bảng tên mặc định (`defaultName`)
Đo trên máy này (mặc định macOS 27.0.1). Khoá = (keycode, modifier mkey); tên tiếng Việt viết đúng như dưới:

| Tổ hợp | keycode | modifier mkey | Tên |
|---|---|---|---|
| ⌘Space | 49 | 0x400 | Hiện tìm kiếm Spotlight |
| ⌥⌘Space | 49 | 0x600 | Hiện cửa sổ tìm kiếm của Finder |
| ⌃Space | 49 | 0x100 | Chọn nguồn nhập trước đó |
| ⌃⌥Space | 49 | 0x300 | Chọn nguồn tiếp theo trong menu Nhập |
| ⌃⌘Space | 49 | 0x500 | Biểu tượng & ký hiệu |
| ⌘Tab | 48 | 0x400 | Chuyển ứng dụng |
| ⇧⌘Tab | 48 | 0xC00 | Chuyển ứng dụng (ngược) |
| ⌥⌘Esc | 53 | 0x600 | Buộc thoát ứng dụng |
| ⌘\` | 50 | 0x400 | Chuyển tới cửa sổ tiếp theo |
| ⇧⌘3 | 20 | 0xC00 | Lưu ảnh màn hình thành tệp |
| ⌃⇧⌘3 | 20 | 0xD00 | Chép ảnh màn hình vào clipboard |
| ⇧⌘4 | 21 | 0xC00 | Lưu ảnh vùng chọn thành tệp |
| ⌃⇧⌘4 | 21 | 0xD00 | Chép ảnh vùng chọn vào clipboard |
| ⇧⌘5 | 23 | 0xC00 | Tuỳ chọn chụp màn hình |
| ⌥⌘D | 2 | 0x600 | Bật / tắt tự ẩn Dock |
| ⇧⌘/ | 44 | 0xC00 | Hiện menu Trợ giúp |
| ⌃↑ | 126 | 0x100 | Mission Control |
| ⌃↓ | 125 | 0x100 | Cửa sổ của ứng dụng |
| ⌃← | 123 | 0x100 | Sang trái một Space |
| ⌃→ | 124 | 0x100 | Sang phải một Space |
| F11 | 103 | 0 | Hiện màn hình nền |
| ⌃F1 | 122 | 0x100 | Bật / tắt truy cập bàn phím |
| ⌃F2 | 120 | 0x100 | Chuyển tới thanh menu |
| ⌃F3 | 99 | 0x100 | Chuyển tới Dock |
| ⌃F4 | 118 | 0x100 | Chuyển tới cửa sổ đang dùng hoặc cửa sổ kế tiếp |
| ⌃F5 | 96 | 0x100 | Chuyển tới thanh công cụ của cửa sổ |
| ⌃F6 | 97 | 0x100 | Chuyển tới cửa sổ nổi |
| ⌃F7 | 98 | 0x100 | Đổi cách Tab di chuyển tiêu điểm |
| ⌃F8 | 100 | 0x100 | Chuyển tới menu trạng thái |
| ⌘F5 | 96 | 0x400 | Bật / tắt VoiceOver |
| ⌥⌘F5 | 96 | 0x600 | Hiện bảng điều khiển Trợ năng |

Tên là "mặc định của tổ hợp" — người dùng có thể đã gán tổ hợp cho việc khác; chuỗi cảnh báo ghi "mặc định:" vì vậy.
`defaultName` bỏ qua bit beep; trả nil cho phím tắt chỉ-modifier / chưa đặt.

## Việc 4 — Test
Mỗi ca là **một test riêng**, tên có số ca. Kết quả mong đợi của 52–54 Claude đã chạy (bản tham chiếu + engine thật).

`tests/engine/EngineTests.cpp`:
- Ca 43 đổi như Việc 0 (tắt tuỳ chọn: 102 / 104 × Latin / non-Latin → `EndWord`).
52. Tắt tuỳ chọn, các trường hợp vẫn `NotHandled`: app loại trừ (102 / 104 × Latin / non-Latin); có ⌘ / ⌃ / ⌥ (102 / 104 ×
    Latin / non-Latin); phím khác (`KEY_A`, `KEY_RETURN`, `KEY_SPACE`, 93, 94, 95 × Latin / non-Latin).
53. `typeJISWithLanguageKeys(…, false)`, Việt (`vLanguage = 1`), phím 英数 = `{102, 0, u' '}`, かな = `{104, 0, u' '}`,
    Return = `{36, 0, u'\r'}`:
    - `⏎ 英数 ddaay` → `u"\rđây"`
    - `ddaay 英数 ddaay` → `u"đâyđây"`
    - `a 英数 a` → `u"aa"`
    - `tie かな es` → `u"tieé"`
    - `vLanguage = 0`: `⏎ 英数 ddaay` → `u"\rddaay"`, `vLanguage` vẫn 0.
54. `typeJISWithLanguageKeys(…, true)` (tuỳ chọn bật, Latin): Việt, `ddaay 英数 ddaay 英数 ddaay` → `u"đâyddaayđây"`,
    cuối cùng `vLanguage == 1`.

`tests/HotkeyKeyNameTests.swift` (thêm vào mảng `tests`):
55. `recordedCharacter`: (6, `"z"`) → 0x7A và `status(6, 0x200, char: 0x7A) == 0x7A000206` hiện `Z`; (49, nil) → 32;
    (30, `"["`) → 0x5B; (93, `"¥"`) → 0xC2; (6, nil) → nil; (6, `""`) → nil; (0xFE, `"a"`) → nil.

File mới `tests/SystemHotkeyConflictTests.swift` (`@main`, mỗi ca một hàm `caseNN_…`, cuối in
`PASS: <n> system hotkey conflict tests`); `check.sh` thêm bước
`xcrun swiftc Sources/App/SystemHotkeyConflict.swift tests/SystemHotkeyConflictTests.swift -o
build/tests/system-hotkey-conflict-tests`, chạy và đưa kết quả vào phần tóm tắt cuối như các test kia. Trong ca,
`status = keycode | modifiers | (char << 24)`:
56. `modifiers(fromCarbon:)`: 0x100 → 0x400; 0x200 → 0x800; 0x800 → 0x200; 0x1000 → 0x100; 0x1800 → 0x300;
    0x21000 → 0x100; 0x300 → 0xC00; 0x400 (caps lock) → 0.
57. `carriesImplicitFunction`: true với 122, 120, 103, 111, 64, 90, 115, 117, 114, 123, 126; false với 0, 6, 12, 49, 102,
    104, 93.
58. `matches` trùng: ⌘Space (49, 0x400) với `SystemHotkey(49, 0x100)`; ⌃F2 (120, 0x100) với `(120, 0x21000)`; F11 (103, 0)
    với `(103, 0x20000)`; ⌃← (123, 0x100) với `(123, 0x21000)`; ⇧⌘4 (21, 0xC00, char `4`) + beep 0x8000 với `(21, 0x300)`.
59. `matches` không trùng: ⌘Space với `(49, 0x1000)`; ⌥Z `0x7A000206` với `(6, 0x100)`; Q trơn (12, 0) với fn Q
    `(12, 0x20000)`; ⌃F2 với `(120, 0x1000)` (thiếu fn); `0xFE0009FE` (⌃⇧ chỉ modifier) với `(254, 0x1200)`;
    `0xFE0000FE` với mọi mục trên.
60. `defaultName`: ⌘Space → `Hiện tìm kiếm Spotlight`; ⌃Space + beep → `Chọn nguồn nhập trước đó`; ⌃F2 →
    `Chuyển tới thanh menu`; ⌥Z → nil; `0xFE0009FE` → nil.
61. `warning`: ⌘Space với `[SystemHotkey(49, 0x100)]` → đúng chuỗi có tên ở Việc 1 (`“Hiện tìm kiếm Spotlight”`);
    ⌃⌥⌘K (40, 0x700) với `[(40, 0x1900)]` → đúng chuỗi không tên; ⌘Space với `[]` → nil; ⌥Z với danh sách ví dụ ở
    Hiện trạng → nil; 英数 trơn (102, 0) với `[(102, 0)]` → nil.

Ca 1–42, 44–51 giữ nguyên expectation.

## Không được làm
- Không làm hotkey đi thẳng Nhật / Việt / Anh, không gọi `TISSelectInputSource`.
- Không gọi TIS / AX / `NSEvent` / `CopySymbolicHotKeys` / IPC mới trong `MKEngineCallback`.
- Không dùng API riêng (`CGSGetSymbolicHotKeyValue`…), không đọc / ghi `com.apple.symbolichotkeys` trực tiếp, không ghi
  gì vào cài đặt hệ thống.
- Không đổi nhánh tuỳ chọn bật của 英数 / かな (Phase 2), không đổi thứ tự khối app loại trừ → 英数 / かな → hotkey.
- Không chặn ghi / tự xoá / tự đổi phím tắt người dùng đã lưu; không đổi định dạng bitfield; không đổi hotkey mặc định ⌥Z.
- Không sửa `Sources/Engine/`, ánh xạ JIS Phase 1, khối "Tương thích bố cục".
- Không sửa expectation ca 1–42, 44–51 (ca 43 chỉ đổi như Việc 0). Không thêm / nâng dependency; không đổi ký, bundle id,
  Sparkle, version. Không push `main`.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `PASS: 14 update runtime policy checks`, `PASS: 50 engine tests`,
      `PASS: 5 hotkey key name tests`, `PASS: 6 system hotkey conflict tests`. CI xanh.
- [ ] Đủ ca 52–61 + ca 43 đổi, mỗi ca một test.
- [ ] Kịch bản chạy thật — bản Debug, máy JIS này, input source bật ABC + Japanese – Romaji (**không** chọn Input Method
      "MKey"), TextEdit, Telex. Ghi kết quả từng mục:
  - (a) C1, **tắt** tuỳ chọn 英数 / かな, Việt: `⏎ 英数 ddaay␣` → `đây ` (ghi thêm kết quả bản build từ `main` trước khi
    sửa — dự đoán `đaay`); `ddaay 英数 ddaay` → `đâyđây`; `a 英数 a` → `aa`; かな vẫn sang Japanese, `nihongo⏎` →
    `にほんご`, 英数 về ABC, icon vẫn **V**. Chuyển **Anh** (⌥Z): `⏎ 英数 ddaay` → `ddaay`.
  - (b) Tắt tuỳ chọn, ghi **英数** trơn làm phím tắt chuyển chế độ → ở ABC bấm 英数 đổi V / E (phím tắt thắng). Trả về ⌥Z.
  - (c) **Bật** tuỳ chọn: lặp kịch bản (a) của Phase 2 (§4 bước 3–6) → giống Phase 2.
  - (d) C2: ghi ⌥Z bằng tay → hiện `⌥Z`, `defaults read vn.mkey.app SwitchKeyStatus` = 2046820870 (`0x7A000206`); ghi ⌃Z →
    `⌃Z`; ghi ⌃⇧ + phím `[` (keycode 30) → `⌃⇧[`; ghi ⌃¥ → `⌃¥`. Bấm-thả ⌃, rồi bấm-thả ⇧ → vẫn đang ghi (không thành
    `⌃⇧`); giữ ⌃⇧ rồi thả → `⌃⇧`. Trả về ⌥Z.
  - (e) Cảnh báo: lần lượt thử **ghi** ⌘Space, ⌃Space, ⇧⌘4, ⌃F2, ⌃→ ở phím tắt chuyển chế độ — ghi rõ tổ hợp nào ghi
    được, tổ hợp nào macOS bắt mất (editor không nhận); tổ hợp ghi được phải hiện cảnh báo đúng tên. Rồi cách chắc chắn:
    thoát mkey, `defaults write vn.mkey.app SwitchKeyStatus -int 536871985` (⌘Space) → mở lại → Bộ gõ hiện cảnh báo
    `mặc định: “Hiện tìm kiếm Spotlight”`; tương tự `536871217` (⌃Space) → `Chọn nguồn nhập trước đó`. Trả về ⌥Z
    (`2046820870`). Lưu ý: bản Debug và mkey cài sẵn dùng chung domain `vn.mkey.app`.
  - (f) Không cảnh báo: ⌥Z, ⌃⇧ (chỉ modifier), chưa đặt. Phím tắt Chuyển mã và Clipboard: đặt một tổ hợp trùng (ví dụ
    ⌃Space nếu ghi được, không thì một tổ hợp ghi được ở (e)) → cảnh báo hiện ở đó; trả lại giá trị cũ.
  - (g) Nếu người dùng đồng ý: đang có cảnh báo ⌘Space, tắt "Hiện tìm kiếm Spotlight" trong Cài đặt hệ thống → Bàn phím →
    Phím tắt bàn phím → quay lại mkey → cảnh báo mất (không khởi động lại mkey); bật lại → cảnh báo hiện. **Bật lại phím
    tắt Spotlight sau khi thử.** Không làm được → ghi vào "chưa kiểm được".
  - (h) **Bật** tuỳ chọn, phím tắt đã lưu là 英数 → chỉ hiện chú thích 英数 / かな của Phase 2, không có dòng cảnh báo macOS.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo từng bước (Conventional Commits; Việc 0 C1 commit riêng `fix: …`). Push nhánh `phase-3-hotkey-conflict`,
**mở PR vào `main`** và gửi link. Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả từng kịch bản (a)–(h); (a) ghi cả trước và sau khi sửa; (e) ghi tổ hợp nào ghi được / bị macOS bắt.
3. Chỗ nào khác prompt và lý do (gồm đổi ca 43).
4. Những chỗ bạn **chưa chắc** hoặc chưa kiểm được (và vì sao) — đặc biệt: `CopySymbolicHotKeys` có cập nhật ngay sau khi
   đổi ở Cài đặt hệ thống không (g).
