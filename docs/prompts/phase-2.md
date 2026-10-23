# Phase 2 — かな / 英数 điều phối Nhật ⇄ Việt ⇄ Anh

> Codex · **GPT-6 Sol** · effort **High** (đụng đường nóng của event tap, notification input source, cài đặt + UI
> HotkeyEditor; lỗi thứ tự sự kiện chỉ lộ khi bấm phím thật — WORKFLOW §8) · nhánh `phase-2-kana-eisu`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PRODUCT_SPEC.md` (§3, §4 bước 3–6, §5, §6.2, §6.3), `docs/PLAN.md` (**Quyết định chung**, Phase 0 +
Phase 1 **Quyết định đã chốt**, Phase 2), `docs/notes/codebase-map.md` (§5, §5a).

Mục tiêu: trên bàn phím JIS, phím **かな** (keycode 104) luôn sang tiếng Nhật, phím **英数** (keycode 102) về Latin; khi đã
ở Latin thì 英数 đổi Việt ⇄ Anh như ⌥Z. Có tuỳ chọn bật / tắt ở Bảng điều khiển → Bộ gõ; tắt thì 英数 / かな đi đường cũ
như 1.6.1. `HotkeyEditor` hiện đúng tên phím 英数 / かな / ¥ / _ và không cho gán 英数 / かな khi tuỳ chọn bật.
Phase này **không** làm: cảnh báo trùng `com.apple.symbolichotkeys`, hotkey đi thẳng Nhật / Việt / Anh bằng
`TISSelectInputSource` (Phase 3), không sửa `Sources/Engine/`, không đổi hotkey mặc định ⌥Z.

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; logic thuần ở `Sources/Platform/MKKeyLayout.{h,cpp}` (C++
thuần, không Carbon / ObjC) và test qua `tests/engine/` (mỗi ca một hàm `caseNN_…`, `resetConfiguration()` trước mỗi ca,
ca mới đánh số từ 40); trong `MKEngineHook.mm` so phím bằng `_physicalKeycode` / `HotkeyKeycode()`, mọi chỗ gửi lại phím
đi qua `SendLayoutKey`; không gọi TIS / AX / IPC đồng bộ mới trong callback (AGENTS quy tắc 9); khoá UserDefaults mới có
trong `registerDefaultSettings` + `resetToDefaults` (AGENTS quy tắc 10); chuỗi UI tiếng Việt theo giọng sẵn có;
Conventional Commits tiếng Việt; chỉ `git add <file>`; **mở PR vào `main` của `origin`** và gửi link.

Hiện trạng đã xem (Claude đo trên máy JIS này, 2026-10-19 — input source bật: ABC, Japanese – Romaji, và prototype IMK
"MKey" (`vi`); probe là chương trình riêng ngoài repo dùng session event tap listen-only + `CGEventPost` keycode
102 / 104 với keyboard type 93):
- **Thứ tự sự kiện.** keyDown và keyUp của 102 / 104 tới session tap **trước** khi input source đổi:
  - đang ABC, keyDown かな → `TISCopyCurrentKeyboardInputSource` vẫn là ABC; đang Japanese, keyDown 英数 → vẫn Japanese.
  - `kTISNotifySelectedKeyboardInputSourceChanged` tới **10–45 ms sau keyUp**, mỗi lần đổi 2–5 notification.
  - đang ABC bấm 英数 → macOS không đổi gì, không có notification; đang Japanese bấm かな → cũng vậy.
  - ⇒ ở keyDown của 英数 / かな, cache input source (nếu được làm mới đúng) là nguồn **trước** khi phím đổi nó.
- **Cache input source đang không bao giờ được làm mới bằng notification.** `MKEngineInit` (`MKEngineHook.mm:502-512`)
  đăng ký `kTISNotifySelectedKeyboardInputSourceChanged` trên `CFNotificationCenterGetDarwinNotifyCenter()`. Đây là
  *distributed notification*: probe đăng ký cả hai trung tâm, Darwin không nhận lần nào (thử trong chương trình CLI và
  trong `NSApplication`, đổi bằng phím かな / 英数 lẫn bằng `TISSelectInputSource`), `CFNotificationCenterGetDistributedCenter()`
  nhận đủ. Hiện `_cachedIsEnglishLayout` (`:76`, tính ở `MKUpdateInputSourceCache` `:116`) chỉ được làm mới ở
  `MKEngineInit` và `OnActiveAppChanged` (`:590`, chỉ chạy khi bật "Tự nhớ chế độ gõ theo từng ứng dụng" và đổi app).
  Suy ra (Claude **chưa** chạy được trên mkey thật vì bản Debug build mới chưa có quyền Trợ năng): đổi sang Japanese trong
  cùng một app thì mkey vẫn tưởng là Latin, nhánh `vOtherLanguage` (`:1175`) không cho qua và Telex chạy chồng lên Kotoeri.
  Kịch bản (a0) bên dưới xác nhận điều này trên bản build từ `main` trước khi sửa.
- **Ký tự của event.** 102 / 104: `CGEventKeyboardGetUnicodeString` = U+0020, `NSEvent.characters` = `" "`. Phím 93: `¥`
  (Shift: `|`), phím 94: `_`. `keyCodeToCharacter(102 / 104) = 0` → trên JIS `MKCurrentKeyCharacter` trả 0 cho hai phím này.
- **HotkeyEditor** (`HotkeyEditor.swift:27-42` hiển thị, `:274-289` ghi): lưu keycode vật lý ở byte thấp, ký tự hiển thị
  = `event.characters.utf8.first` ở byte cao. NSEvent local monitor của app nhận được keyDown 102 / 104 (input source vẫn
  đổi sau đó). Kết quả hiện tại: 英数 / かな ghi được và hiện là **"Space"** (ký tự 0x20); `¥` hiện **"Â"** (0xC2 = byte đầu
  UTF-8 của ¥); `_` hiện `_`. `AppState.hotkeyDescription` (`AppState.swift:407`) cùng logic nhưng không ai gọi.
  `HotkeyEditor` dùng ở 3 chỗ: `TypingPage.swift:44` (chuyển chế độ), `ConvertPage.swift:51` (chuyển mã),
  `ClipboardPage.swift:34` (clipboard, hotkey Carbon, `allowsModifierOnly: false`).
- **Engine với 102 / 104** (harness `typeJIS`, engine thật): không có trong `isWordBreak`, nhưng chen giữa từ làm từ không
  ghép tiếp — `tie` + かな + `es` → `tie` rồi `es` (không ra `tiés`); `a` + かな + `a` → không ra `â`. Đây là đường cũ, giữ
  nguyên khi tuỳ chọn tắt.
- **`MKEngineCallback`** (`MKEngineHook.mm`): `:1041-1064` đọc `_flag`, `_keycode`, `_physicalKeycode`, keyboard type,
  ký tự event; `:1071` app loại trừ → `return event`; `:1075-1079` ánh xạ JIS; `:1092-1145` hotkey (keyDown: so
  `HotkeyKeycode()`, gọi `switchLanguage()`, `_lastFlag = 0`, `_hasJustUsedHotKey = true`, `return NULL`; phím khác:
  `_lastFlag = 0`); `:1149` `vLanguage == 0` (gõ tắt khi ở Anh qua `vEnglishMode`); `:1175` `vOtherLanguage` +
  `!_cachedIsEnglishLayout` → cho qua; `:1196` `vKeyHandleEvent`.
- `switchLanguage()` (`:906`): đảo `vLanguage`, beep nếu `HAS_BEEP(vSwitchKeyStatus)`, `[MKBridge engineDidSwitchLanguage]`
  (lưu `InputMethod`, `OnInputMethodChanged` → nhớ theo app nếu bật smart switch, `postStateChanged` → icon V/E), rồi
  `startNewSession()`. `RequestNewSession()` (`:515`): gửi sự kiện Mouse cho engine (kết thúc từ + xoá bộ đệm gõ tắt
  `hMacroKey` ở cả chế độ Việt lẫn Anh), xoá `_syncKey` khi VNI, `AXInvalidateFocusCache()` — giống bấm chuột.
- Cài đặt: `AppState.registerDefaultSettings()` (`:276`, gọi ở `MkeyApp.swift:166` **trước** `startEventTap`),
  `resetToDefaults()` (`:316`, danh sách khoá + gán lại `@Published` + gán global C). Toggle bool kiểu
  `@Published var otherLanguage: Bool { didSet { set("vOtherLanguage", &vOtherLanguage, otherLanguage) } }`, global khai
  báo ở `MKGlobals.h`, định nghĩa ở `MKBridge.mm:18-43`, đọc lại bằng `LOAD_DATA` trong `MKEngineInit`.
  **Không có đồng bộ iCloud cho cài đặt**: iCloud chỉ đồng bộ file danh sách gõ tắt (`MacroCloudSync`, `MacroPage.swift`)
  → khoá mới **không** thêm vào iCloud.
- Swift đọc được loại bàn phím: `import Carbon` + `KBGetLayoutType(Int16(LMGetKbdType())) == kKeyboardJIS` → `true` trên
  máy này (`LMGetKbdType() = 93`).
- Kết quả mong đợi của ca 40–51 Claude đã chạy bằng một bản cài đặt tham chiếu (ngoài repo) trên engine thật.

## Việc 0 — Còn tồn
Không có (Phase 1 không để lại mục nào).

## Việc 1 — Làm mới cache input source bằng đúng trung tâm notification
`MKEngineHook.mm:502-512`: đổi `CFNotificationCenterGetDarwinNotifyCenter()` → `CFNotificationCenterGetDistributedCenter()`
(giữ `CFNotificationSuspensionBehaviorDeliverImmediately`, callback `MKInputSourceChangedCallback` giữ nguyên — nó chạy
trên main run loop, cùng luồng với event tap). Không thêm lời gọi TIS nào trong `MKEngineCallback`: ở keyDown của 英数 /
かな, `_cachedIsEnglishLayout` chính là nguồn trước khi đổi (notification tới sau keyUp).

Đây là sửa lỗi có sẵn, áp dụng cho mọi bàn phím (ANSI cũng hưởng: đổi sang input source không phải `en` bằng ⌃Space trong
cùng app giờ được cho qua đúng như tuỳ chọn "Tắt Tiếng Việt khi dùng bàn phím ngôn ngữ khác" mô tả; cache "Tương thích bố
cục" cũng được xoá khi đổi input source). Ghi rõ trong PR. Commit riêng (`fix: …`).

## Việc 2 — Hàm quyết định thuần
Thêm vào `Sources/Platform/MKKeyLayout.h` / `.cpp`:

```cpp
enum MKLanguageKeyAction {
    MKLanguageKeyNotHandled = 0,   // đường cũ (1.6.1): phím đi tiếp như hiện nay
    MKLanguageKeyPassToSystem,     // kết thúc từ, trả event cho macOS đổi input source
    MKLanguageKeyToggleLanguage,   // đổi Việt ⇄ Anh như hotkey, nuốt keyDown
};
MKLanguageKeyAction MKLanguageKeyActionFor(Uint16 physicalKeycode, bool optionEnabled, bool appExcluded,
                                           bool hasCommandControlOption, bool inputSourceIsLatin);
```
Quy tắc (PRODUCT_SPEC §6.2), theo thứ tự:
1. `!optionEnabled` hoặc `appExcluded` hoặc `hasCommandControlOption` (⌘ / ⌃ / ⌥ đang giữ) → `NotHandled`.
2. `physicalKeycode == 104` (かな) → `PassToSystem` (bất kể input source).
3. `physicalKeycode == 102` (英数): `inputSourceIsLatin` → `ToggleLanguage`; ngược lại → `PassToSystem`.
4. Phím khác → `NotHandled`.
Shift / Caps Lock không ảnh hưởng. Hàm **không** xét loại bàn phím: keycode 102 / 104 chỉ đến từ phím 英数 / かな (bàn
phím JIS, hoặc phím đã remap thành 英数 / かな) — mặc định của tuỳ chọn (Việc 4) mới phụ thuộc bàn phím JIS. Trên ANSI /
ISO không có phím nào sinh 102 / 104 nên hành vi không đổi.

## Việc 3 — Nối vào `MKEngineCallback`
Chỉ ở `type == kCGEventKeyDown`, đặt **sau** khối app loại trừ (`:1071`) và **trước** khối hotkey (`:1092`) — tức 英数 /
かな được ưu tiên hơn hotkey người dùng đã lưu trước đó bằng 102 / 104:
- Gọi `MKLanguageKeyActionFor(_physicalKeycode, vUseJISLanguageKeys != 0, _frontMostIsExcluded,
  (_flag & (kCGEventFlagMaskCommand | kCGEventFlagMaskControl | kCGEventFlagMaskAlternate)) != 0,
  _cachedIsEnglishLayout)`. (`_frontMostIsExcluded` lúc này luôn false vì đã `return` ở trên — vẫn truyền vào để hàm
  thuần đúng nghĩa; không dùng `OTHER_CONTROL_KEY` vì macro đó gồm cả Fn / NumericPad.)
- `PassToSystem`: `RequestNewSession()`; `_lastFlag = 0`; `_lastKeystrokeTime = currentKeystrokeTime`; `return event`.
  **Không** gọi `vKeyHandleEvent` / `vEnglishMode` cho phím này, không đổi `vLanguage`.
- `ToggleLanguage`: `switchLanguage()`; `_lastFlag = 0`; `_hasJustUsedHotKey = true`;
  `_lastKeystrokeTime = currentKeystrokeTime`; `return NULL` (giống nhánh hotkey keyDown). keyUp của 102 không nuốt (giống
  hotkey).
- `NotHandled`: không đổi gì so với hiện tại.
- keyUp / flagsChanged / chuột: không đổi.
- Không gọi TIS / AX / `NSEvent` mới ở đây. `vUseJISLanguageKeys` chỉ là đọc một biến int.

Global mới `int vUseJISLanguageKeys` — khai báo `extern` trong `MKGlobals.h` (cạnh `vOtherLanguage`, kèm chú thích 1 dòng),
định nghĩa trong `MKBridge.mm` (giá trị khởi đầu 0, giá trị thật nạp từ UserDefaults), `LOAD_DATA(vUseJISLanguageKeys,
vUseJISLanguageKeys);` trong `MKEngineInit`. Nếu harness cần định nghĩa để link thì thêm vào `EngineHarness.cpp` và
`resetConfiguration()` (giá trị 1).

## Việc 4 — Tuỳ chọn trong Bảng điều khiển → Bộ gõ
- Khoá UserDefaults `vUseJISLanguageKeys` (int 0 / 1, như các khoá `v…` khác).
- `AppState`: `@Published var useJISLanguageKeys: Bool { didSet { set("vUseJISLanguageKeys", &vUseJISLanguageKeys,
  useJISLanguageKeys) } }`, đọc trong `init` như `otherLanguage`.
- Mặc định = **bật khi bàn phím hiện tại là JIS** (PRODUCT_SPEC §5): thêm `static var isJISKeyboard: Bool` dùng
  `KBGetLayoutType(Int16(LMGetKbdType())) == kKeyboardJIS` (`import Carbon` trong `AppState.swift`), và
  `"vUseJISLanguageKeys": isJISKeyboard ? 1 : 0` trong `registerDefaultSettings()`. Không ghi giá trị xuống UserDefaults
  lúc khởi động (người dùng chưa bấm thì mặc định theo bàn phím).
- `resetToDefaults()`: thêm `"vUseJISLanguageKeys"` vào danh sách khoá xoá, gán `useJISLanguageKeys = AppState.isJISKeyboard`
  trong khối `suppressCallbacks`, và gán `vUseJISLanguageKeys` ở khối "push everything into the engine globals".
- Không thêm vào iCloud (không có danh sách đồng bộ cài đặt — xem Hiện trạng).
- `TypingPage.swift`, section "Phím chuyển chế độ" (`:43-52`): thêm sau toggle beep
  `Toggle("Dùng phím 英数 / かな để chuyển ngôn ngữ (bàn phím JIS)", isOn: $state.useJISLanguageKeys)` và một dòng chú
  thích (`.font(.footnote)`, `.foregroundStyle(.secondary)` như dòng chú thích ở section "Tương thích"):
  `かな: sang tiếng Nhật. 英数: về chữ Latin; bấm lần nữa để đổi Việt ⇄ Anh.` Footer hiện có của section giữ nguyên.

## Việc 5 — HotkeyEditor
- File mới `Sources/App/HotkeyKeyName.swift`, Swift thuần (chỉ `import Foundation`), để test bằng `xcrun swiftc` như
  `UpdateRuntimePolicy`:
  ```swift
  enum HotkeyKeyName {
      static func isLanguageKey(_ keycode: UInt16) -> Bool          // 102 hoặc 104
      static func name(status: Int32) -> String?                    // tên phím thường; nil = không có phím (chỉ modifier / chưa đặt)
      static func usesLanguageKey(status: Int32) -> Bool            // hotkey đã đặt và phím là 102 / 104
  }
  ```
  `name`: theo **keycode** (byte thấp) trước — 102 → `英数`, 104 → `かな`, 93 → `¥`, 94 → `_` (bất kể ký tự hiển thị đã
  lưu); keycode khác → giữ đúng logic hiện tại theo byte cao (0xFE → nil; `char == 49 || " "` → `Space`; còn lại
  `String(UnicodeScalar(char)).uppercased()`). Không sửa điều kiện `char == 49` (lỗi nhỏ có sẵn: ký tự `1` hiện là
  "Space") — chỉ ghi vào PR. `usesLanguageKey`: `(value & ~0x8000) != 0xFE0000FE` và keycode là 102 / 104.
- `HotkeyEditor.hotkeyParts` dùng `HotkeyKeyName.name(status:)` thay cho đoạn tự dựng ký tự; `AppState.hotkeyDescription`
  cũng dùng hàm này (không xoá hàm).
- Thêm tham số `var blocksLanguageKeys: Bool = false` cho `HotkeyEditor`; cả **3** chỗ dùng truyền
  `AppState.shared.useJISLanguageKeys` (hoặc `state.useJISLanguageKeys` nếu view có `AppState` — sao cho bật / tắt tuỳ
  chọn thì editor cập nhật ngay). Khi `blocksLanguageKeys`:
  - Đang ghi mà bấm 102 / 104 (có hay không modifier): **không ghi**, `return nil`, vẫn ở trạng thái ghi, và hiện dòng chú
    thích dưới editor: `英数 / かな đang dùng để chuyển ngôn ngữ (Bộ gõ → Phím chuyển chế độ).`
  - Hotkey đang lưu dùng 102 / 104 (`usesLanguageKey`): hiện dòng chú thích
    `Phím tắt này trùng 英数 / かな nên sẽ không chạy khi đang dùng 英数 / かな để chuyển ngôn ngữ.`
  Không tự đổi / xoá hotkey đã lưu.
- Khi `blocksLanguageKeys == false`: ghi 102 / 104 như cũ (giá trị lưu không đổi định dạng), chỉ khác là hiện `英数` /
  `かな`.

## Việc 6 — Test
Mỗi ca là **một test riêng**, tên có số ca. Kết quả mong đợi Claude đã chạy (bản tham chiếu + engine thật).

`tests/engine/EngineTests.cpp` (hàm `caseNN_…`, `resetConfiguration()` trước mỗi ca):
40. `MKLanguageKeyActionFor(104, enabled, không loại trừ, không ⌘⌃⌥, Latin)` → `PassToSystem`; cùng vậy với non-Latin →
    `PassToSystem`.
41. 102, bật, non-Latin → `PassToSystem`.
42. 102, bật, Latin → `ToggleLanguage`.
43. Tuỳ chọn tắt: 102 / 104 × Latin / non-Latin → `NotHandled` (4 tổ hợp).
44. App loại trừ: 102 / 104 × Latin / non-Latin → `NotHandled`.
45. Có ⌘ / ⌃ / ⌥: 102 / 104 × Latin / non-Latin → `NotHandled`.
46. Phím khác khi bật, cả Latin / non-Latin → `NotHandled`: `KEY_A` (0), `KEY_Z` (6), `KEY_RETURN` (36), `KEY_SPACE`
    (49), `KEY_ESC` (53), 93, 94, 95.
47. Ví dụ chuẩn §4 bước 3–6 (mô phỏng trong test: biến `latin`; `PassToSystem` của 104 → `latin = false`, của 102 →
    `latin = true`, cả hai gọi `startNewSession()`; `ToggleLanguage` → đảo `vLanguage`). Bắt đầu `latin = true`,
    `vLanguage = 1`: かな → `PassToSystem`, `latin = false`, `vLanguage = 1`; 英数 → `PassToSystem`, `vLanguage = 1`,
    `typeJIS(jisKeys(u"ddaay"))` → `đây`; 英数 → `ToggleLanguage`, `vLanguage = 0`, `ddaay` → `ddaay`; 英数 →
    `ToggleLanguage`, `vLanguage = 1`, `ddaay` → `đây`. Thêm: bắt đầu `vLanguage = 0`, かな rồi 英数 → `vLanguage` vẫn 0,
    `ddaay` → `ddaay`.

File mới `tests/HotkeyKeyNameTests.swift` (`@main`, mỗi ca một hàm `caseNN_…`, cuối in
`PASS: <n> hotkey key name tests`), `check.sh` biên dịch bằng `xcrun swiftc Sources/App/HotkeyKeyName.swift
tests/HotkeyKeyNameTests.swift -o build/tests/hotkey-key-name-tests`, chạy và đưa kết quả vào phần tóm tắt cuối như hai
test kia. Trong ca, `status = keycode | modifiers | (char << 24)`:
48. `name`: (102, ⌃, char 0x20) → `英数`; (104, không modifier, char 0x20) → `かな`.
49. `name`: (93, char 0xC2) → `¥`; (93, ⇧, char 0x7C) → `¥`; (94, char 0x5F) → `_`.
50. `name` giữ hành vi cũ: `0x7A000206` (⌥Z mặc định) → `Z`; (49, ⌃, char 0x20) → `Space`; (30, ⌃⇧, char 0x5B) → `[`;
    `0xFE0009FE` (⌃⇧ chỉ modifier) → nil; `0xFE0000FE` → nil.
51. `usesLanguageKey`: (102, ⌃ + beep 0x8000) → true; (104) → true; `0x7A000206` → false;
    `0xFE0000FE | 0x8000` → false; (93, char 0xC2) → false.

Ca 1–39 giữ nguyên expectation.

## Không được làm
- Không làm Phase 3 (đọc `com.apple.symbolichotkeys`, hotkey đi thẳng bằng `TISSelectInputSource`). Không gọi
  `TISSelectInputSource`.
- Không gọi TIS / AX / `NSEvent` / IPC mới trong `MKEngineCallback`; trạng thái input source chỉ lấy từ
  `_cachedIsEnglishLayout`.
- Không nuốt phím かな, không nuốt 英数 khi input source không phải Latin. Không xử lý 英数 / かな khi đang giữ ⌘ / ⌃ / ⌥.
- Không sửa `Sources/Engine/`, `ConvertKeyStringToKeyCode`, khối "Tương thích bố cục", hàm ánh xạ JIS của Phase 1.
- Không đổi hotkey mặc định ⌥Z, không tự xoá / đổi hotkey người dùng đã lưu, không đổi định dạng bitfield hotkey.
- Không thêm khoá vào iCloud / không tạo cơ chế đồng bộ cài đặt mới.
- Không sửa expectation ca 1–39. Không thêm / nâng dependency; không đổi ký, bundle id, Sparkle, version. Không push `main`.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `PASS: 14 update runtime policy checks`, `PASS: 47 engine tests`,
      `PASS: 4 hotkey key name tests`. CI xanh.
- [ ] Đủ ca 40–51, mỗi ca một test.
- [ ] Kịch bản chạy thật — bản Debug, máy JIS này, input source bật ABC + Japanese – Romaji (**không** chọn Input Method
      "MKey"), TextEdit, Telex, smart switch bật (mặc định). Ghi kết quả từng mục:
  - (a0) **Trước khi sửa** — build từ `main`: ABC + Việt, bấm かな, gõ `aa` → ghi kết quả thật (dự đoán: mkey chồng Telex
    lên Kotoeri, không ra `ああ`). Lặp lại sau Việc 1 → `ああ`.
  - (a) §4 bước 3–6: Việt; かな → `nihongo` + Return → `にほんご`; 英数 → ABC, icon **V**, `ddaay ` → `đây`; 英数 → icon
    **E**, `ddaay` → `ddaay`; 英数 → **V**, `ddaay` → `đây`.
  - (b) Bắt đầu ở **Anh**: かな → 英数 → vẫn **E**; ⌥Z → **V**.
  - (c) Đổi sang Japanese bằng menu input source (không dùng phím) rồi gõ `aa` → `ああ`; về ABC bằng menu → Việt gõ đúng.
  - (d) Bật "Kêu beep khi chuyển chế độ": 英数 ở ABC kêu; かな và 英数 từ Japanese không kêu.
  - (e) Nhớ theo app: ở TextEdit dùng 英数 sang **E**, chuyển sang Notes (đang **V**), quay lại TextEdit → **E**.
  - (f) Thêm TextEdit vào "Ứng dụng loại trừ": 英数 ở ABC không đổi V / E; かな / 英数 vẫn đổi input source. Gỡ ra.
  - (g) Tắt tuỳ chọn: 英数 ở ABC không đổi V / E; かな / 英数 vẫn đổi input source (macOS); ⌥Z vẫn đổi; (a) bước gõ
    `nihongo` vẫn ra `にほんご` (nhờ Việc 1).
  - (h) HotkeyEditor (tuỳ chọn bật): ghi phím tắt chuyển chế độ, bấm 英数 → không nhận, hiện chú thích, Esc huỷ. Tắt tuỳ
    chọn → ghi ⌃英数 → hiện `⌃英数`, bấm ⌃英数 ở ABC → đổi V / E. Bật lại tuỳ chọn → hiện chú thích trùng. Ghi ⌃¥ → hiện
    `⌃¥` (không phải `Â`). Trả về ⌥Z. Làm tương tự một lần ở phím tắt Chuyển mã.
  - (i) "Cài đặt mặc định" (Hệ thống) → tuỳ chọn về **bật** trên máy JIS.
  - (j) Bật "Gửi phím từng bước" → lặp (a) → giống hệt. Tắt lại.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo từng bước (Conventional Commits; Việc 1 commit riêng). Push nhánh `phase-2-kana-eisu`, **mở PR vào `main`**
và gửi link. Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả từng kịch bản (a0)–(j), (a0) ghi cả trước và sau Việc 1.
3. Chỗ nào khác prompt và lý do.
4. Những chỗ bạn **chưa chắc** hoặc chưa kiểm được (và vì sao) — đặc biệt: bấm かな rồi gõ ngay (< 50 ms) trước khi
   notification tới.
