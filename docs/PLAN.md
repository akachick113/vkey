# mkey (bản JIS) — Kế hoạch xây dựng (giao cho Codex)

Đọc trước: [`PRODUCT_SPEC.md`](./PRODUCT_SPEC.md) (nghiệp vụ), [`../AGENTS.md`](../AGENTS.md) (quy tắc code),
[`notes/codebase-map.md`](./notes/codebase-map.md) (hiện trạng tại `b3c6f61`).

Làm **từng Phase một**, mỗi Phase một nhánh + PR. Xong Phase phải đạt "Done khi" rồi mới sang Phase sau.

---

## Stack (giữ nguyên hiện trạng)

| Phần | Chọn |
|---|---|
| Repo | single, XcodeGen (`project.yml`), không commit `mkey.xcodeproj` |
| Engine | C++17 OpenKey (`Sources/Engine`) — không sửa trừ khi phase giao |
| Platform | ObjC++ CGEventTap (`Sources/Platform/MKEngineHook.mm`) — nơi làm phần lớn việc JIS |
| UI | SwiftUI (`Sources/App`) |
| Test | chương trình test biên dịch bằng `xcrun swiftc` / `xcrun clang++` trong `tests/` (không XCTest) |
| CI | GitHub Actions macOS: `scripts/check.sh` trên mỗi PR + push `main` |

`CHECK_CMD` = `scripts/check.sh` (Phase 0 tạo).

## Quyết định chung (đã chốt 2026-10-19)
- Kiến trúc: **giữ event tap**, không chuyển sang InputMethodKit. Tiếng Nhật do Kotoeri của macOS xử lý.
- Phím: **かな = Nhật, 英数 = về Latin / đổi Việt ⇄ Anh** (PRODUCT_SPEC §6.2). ⌥Z giữ nguyên.
- Git: clone làm dự án riêng. `upstream` = `maclifevn/mkey` (chỉ fetch), `origin` = repo GitHub của chủ dự án.
- Quy ước: Conventional Commits, mô tả tiếng Việt; nhánh `phase-N-<tên>`; merge **squash**; tài liệu tiếng Việt; không
  thêm formatter.
- Codex chạy **local** trên máy có bàn phím JIS (cùng thư mục `/Users/duc/Developer/mkey`).

---

## Phase 0 — Đưa repo về trạng thái xanh + có chỗ test
Hiện trạng: baseline build Debug ✅, policy test 14/14 ✅, **chưa có CI, chưa có test engine**.
- `scripts/check.sh`: xcodegen → build Debug → policy test → test engine.
- Harness test engine (C++/ObjC++, không cần event tap) + bộ test "đặc tả hiện trạng" Telex/VNI trên keycode ANSI.
- CI GitHub Actions macOS chạy `scripts/check.sh`.
- Không: tính năng, sửa engine, sửa `MKEngineHook.mm`, nâng dependency, đổi ký / bundle id.

Prompt chi tiết: [`prompts/phase-0.md`](./prompts/phase-0.md).

**Done khi:** clone sạch → `brew install xcodegen` → `scripts/check.sh` pass trên máy và CI.

Review: [`reviews/phase-0.md`](./reviews/phase-0.md).

**✅ Xong (PR #1, merge commit `67d98ab` — merge thường, không squash; nội dung = `1e00aac` đã review).** Quyết định đã chốt (Phase sau phải theo):
- `CHECK_CMD` = `scripts/check.sh` (xcodegen → build Debug `-quiet` → policy test → engine test). CI: GitHub Actions
  `macos-15`, `brew install xcodegen`, không secret.
- Test engine: `tests/engine/EngineHarness.{h,cpp}` (global cấu hình = mặc định app, `resetConfiguration()` trước mỗi ca,
  `type(keys)` mô phỏng ô text; `vLanguage = 0` thì không gọi engine) + `tests/engine/EngineTests.cpp` (mỗi ca một hàm
  `caseNN_…`, framework tự viết, in `PASS: N engine tests`). Ca mới thêm cùng kiểu, biên dịch trong `check.sh`.
- Harness thêm **ký tự thô** của phím vừa gõ khi restore; hook thật dùng `keyCodeToCharacter(keycode logic)`. Trên ANSI
  hai cách trùng nhau; trên JIS thì không (Phase 1 sửa hook).
- Còn tồn, làm đầu Phase 1: C1 — `check.sh` biên dịch test với `-Wall` làm cảnh báo `-Wmissing-braces` của
  `Sources/Engine/Vietnamese.cpp:811` hiện mỗi lần → thêm `-Wno-missing-braces`.

## Phase 1 — Gõ đúng trên bàn phím JIS
Đo bằng harness + engine thật (2026-10-19): mặc định trên JIS gõ `@` ra `ơ`, `[` ra `ư`, `]` không ra gì; bật "Tương
thích bố cục" thì Telex đúng nhưng VNI `a^` → `â`, `a@` → `à`; `¥` / `_` không ngắt từ (`tooi¥as` → `tôi¥as`).
- Loại bàn phím theo từng phím (`kCGKeyboardEventKeyboardType` → `KBGetLayoutType`), cache theo giá trị keyboard type.
- Hàm thuần ánh xạ keycode vật lý JIS → keycode logic (30→33, 42→30, 33→42, 93→42, 94→27+Shift, 95→43) và chiều
  ngược cho ký tự trong từ; trên JIS bỏ qua "Tương thích bố cục".
- Trên JIS, ký tự của phím vừa gõ (khi restore / gửi lại) lấy từ chính event, không từ bảng ANSI; hotkey so bằng
  keycode vật lý.
- Test: hàm ánh xạ, các ca gõ JIS qua harness, ANSI giữ nguyên.

Prompt chi tiết: [`prompts/phase-1.md`](./prompts/phase-1.md).

**Done khi:** ví dụ chuẩn PRODUCT_SPEC §4 bước 1, 2, 7 đúng trên máy JIS thật; test Phase 0 vẫn xanh.

Review: [`reviews/phase-1.md`](./reviews/phase-1.md) (2 vòng; vòng 1 có 2 lỗi do prompt).

**✅ Xong (PR #2, squash `2a57674`).** Quyết định đã chốt (Phase sau phải theo):
- Hàm thuần về bố cục phím nằm ở `Sources/Platform/MKKeyLayout.{h,cpp}` (C++ thuần, không Carbon / ObjC), được
  `check.sh` biên dịch cùng test: `MKJISToLogicalKey`, `MKLogicalToJISKeycode`, `MKCurrentKeyCharacter` (trả 0 cho phím
  điều khiển → hook gửi phím thật), `MKJISWordCharacter`. Logic thuần mới của phase sau đặt ở đây hoặc file cùng kiểu.
- Trạng thái trong `MKEngineHook.mm`: `_currentKeyboardIsJIS` (tính mỗi keyDown, chỉ gọi `KBGetLayoutType` khi
  `_lastKeyboardType` đổi), `_physicalKeycode`, `_currentEventCharacter` (chỉ đọc khi JIS). So hotkey qua
  `HotkeyKeycode()` (keycode vật lý trên JIS). Mọi chỗ gửi lại phím đi qua `SendLayoutKey(data, currentKey)`.
- Trên JIS, "Tương thích bố cục" bị bỏ qua; ở chế độ "Gửi phím từng bước", ký tự ASCII trong từ / gõ tắt gửi bằng
  Unicode (`SendPureCharacter`).
- Phím 102 (英数) / 104 (かな) hiện đi thẳng qua engine, keycode không đổi (ca 19). Phase 2 bắt chúng **trước**
  `vKeyHandleEvent`.
- Harness: `jisKeys(u"…")` + `typeJIS(keys)`; có 39 ca, ca mới đánh số từ 40.
- Còn tồn: không có. Theo dõi khi dùng thật: app nào chỉ nhận keycode thật ở chế độ "Gửi phím từng bước" trên JIS.

## Phase 2 — かな / 英数 điều phối Nhật ⇄ Việt ⇄ Anh
Đo trên máy JIS (2026-10-19): keyDown / keyUp của 102 / 104 tới event tap **trước** khi input source đổi; notification
`kTISNotifySelectedKeyboardInputSourceChanged` tới 10–45 ms sau, và chỉ trên **Distributed** center — mkey đang đăng ký
trên Darwin center nên cache input source không bao giờ được làm mới bằng notification (chỉ lúc khởi động / đổi app).
- Sửa đăng ký notification sang Distributed center (sửa lỗi có sẵn, mọi bàn phím).
- Bắt keyDown 104 (かな) / 102 (英数) trong `MKEngineCallback`, theo PRODUCT_SPEC §6.2 (dựa vào input source **trước**
  khi phím đổi nó = cache lúc keyDown).
- Tuỳ chọn trong Bảng điều khiển → Bộ gõ, lưu UserDefaults, có trong "Cài đặt mặc định" (iCloud chỉ đồng bộ danh sách gõ
  tắt, không đồng bộ cài đặt → không thêm).
- `HotkeyEditor` hiển thị tên phím 英数 / かな / ¥ / _ ; không cho gán 英数 / かな khi tuỳ chọn bật.
- Test: hàm quyết định thuần (input source hiện tại, phím, tuỳ chọn, app loại trừ → hành động); tên phím của HotkeyEditor
  (test Swift mới).

Prompt chi tiết: [`prompts/phase-2.md`](./prompts/phase-2.md).

**Done khi:** ví dụ chuẩn §4 bước 3–6 đúng trên máy JIS thật; tắt tuỳ chọn → 英数 / かな đi đường cũ như 1.6.1 (khác 1.6.1
duy nhất ở chỗ cache input source nay được làm mới đúng).

Review: [`reviews/phase-2.md`](./reviews/phase-2.md) (2 vòng; vòng 1 thiếu chạy thật + 1 lỗi UI nhỏ; kịch bản (h) của
prompt có một bước không làm được — ⌃英数).

**✅ Xong (PR #3, squash `38acd60` = nội dung `5748c46` đã review).** Quyết định đã chốt (Phase sau phải theo):
- Cache input source (`_cachedIsEnglishLayout`) làm mới bằng `kTISNotifySelectedKeyboardInputSourceChanged` trên
  **Distributed** center. Ở keyDown của 英数 / かな cache là nguồn **trước** khi đổi (notification tới 10–45 ms sau keyUp).
  Không gọi TIS trong `MKEngineCallback`.
- Hàm thuần `MKLanguageKeyActionFor(physicalKeycode, optionEnabled, appExcluded, hasCommandControlOption,
  inputSourceIsLatin)` trong `MKKeyLayout` → `NotHandled` / `PassToSystem` / `ToggleLanguage`. Gọi ở keyDown, sau khối app
  loại trừ, **trước** khối hotkey (英数 / かな ưu tiên hơn hotkey đã lưu bằng 102 / 104). `PassToSystem` =
  `RequestNewSession()` + trả event; `ToggleLanguage` = `switchLanguage()` + nuốt keyDown (keyUp không nuốt). ⌘ / ⌃ / ⌥ đang
  giữ → đường cũ. Không xét loại bàn phím trong hàm.
- Khoá UserDefaults / global `vUseJISLanguageKeys`; mặc định = `AppState.isJISKeyboard`
  (`KBGetLayoutType(LMGetKbdType()) == kKeyboardJIS`), không ghi xuống khi chưa bấm.
- `HotkeyKeyName` (Swift thuần, `Sources/App/HotkeyKeyName.swift`): tên phím theo keycode trước (102 `英数`, 104 `かな`,
  93 `¥`, 94 `_`), còn lại theo ký tự lưu ở byte cao như cũ. `HotkeyEditor(blocksLanguageKeys:)` ở cả 3 chỗ dùng.
- `check.sh` có thêm bước test Swift `tests/HotkeyKeyNameTests.swift` (`PASS: 4 hotkey key name tests`); engine có 47 ca,
  ca mới đánh số từ 52.
- macOS không giao ⌃英数 / ⌃かな cho NSEvent local monitor → không ghi được làm phím tắt; chỉ 英数 / かな trơn.
- Review chạy thật được bằng `CGEventPost` (keyboard type 93) + Accessibility vào bản Debug **đã cấp quyền Trợ năng**
  (bản ad-hoc build lại thì mất quyền).

Còn tồn (người dùng chốt 2026-10-19, làm ở `Việc 0` của phase sau):
- C1 — **Luôn coi 英数 / かな là phím kết thúc từ, kể cả khi tắt tuỳ chọn.** Hiện khi tắt, keycode 102 / 104 đi vào bộ đệm
  engine như ký tự trong từ nên từ gõ ngay sau bị hỏng (chạy thật: `⏎ 英数 ddaay␣` → `đaay`). Cách làm gợi ý: tuỳ chọn tắt
  thì 102 / 104 vẫn `RequestNewSession()` rồi đi tiếp như cũ (không đổi input source, không đổi V / E). Cần ca test hàm
  thuần mới (tắt tuỳ chọn → hành động "chỉ kết thúc từ") và chạy thật lại ví dụ trên.
- C2 (nhỏ, chỉ làm nếu phase sau đụng `HotkeyEditor`) — `peakModifiers` không xoá khi thả một modifier đơn lẻ; ghi ⌥Z bằng
  tay lưu ký tự `Ω`, hiện `⌥Î` (cả hai có sẵn từ 1.6.1).

## Phase 3 — 英数 / かな luôn kết thúc từ + cảnh báo trùng phím tắt macOS
Người dùng chốt 2026-10-19: chỉ làm phần cảnh báo; **bỏ** hotkey đi thẳng Nhật / Việt / Anh (`TISSelectInputSource`).
- Việc 0: C1 (英数 / かな luôn kết thúc từ, kể cả khi tắt tuỳ chọn — `MKLanguageKeyEndWord`, xử lý **sau** khối hotkey để
  phím tắt lưu bằng 英数 / かな vẫn chạy) + C2 (`peakModifiers`; ký tự hiển thị khi ghi lấy
  `characters(byApplyingModifiers: [])`).
- Đọc phím tắt đang bật của macOS bằng API công khai `CopySymbolicHotKeys` (giá trị hiệu lực, gồm mặc định — plist
  `com.apple.symbolichotkeys` chỉ có mục người dùng đã chạm, không đủ). Logic so trùng Swift thuần
  (`SystemHotkeyConflict`), cảnh báo trong `HotkeyEditor` ở cả 3 chỗ, có tên mặc định cho các tổ hợp hay gặp.
- Test: ca 43 đổi (`EndWord`), ca 52–54 engine / harness, 55 ký tự ghi phím tắt, 56–61 so trùng.

Prompt chi tiết: [`prompts/phase-3.md`](./prompts/phase-3.md).

**Done khi:** `⏎ 英数 ddaay` → `đây` khi tắt tuỳ chọn trên máy JIS thật; phím tắt trùng phím tắt đang bật của macOS hiện
cảnh báo, ⌥Z không; test Phase 0–2 vẫn xanh.

Review: [`reviews/phase-3.md`](./reviews/phase-3.md) (1 vòng, Approved; Claude tự chạy thật (a)–(h) trừ (g)).

**✅ Xong (PR #4, squash `b98dca1` = nội dung `8d18c6c` đã review).** Quyết định đã chốt (Phase sau phải theo):
- `MKLanguageKeyActionFor` thêm `MKLanguageKeyEndWord`: tắt tuỳ chọn → 102 / 104 (không ⌘⌃⌥, không app loại trừ) chỉ kết
  thúc từ. `EndWord` xử lý **sau** khối hotkey (`RequestNewSession()` + `return event`) để phím tắt lưu bằng 英数 / かな
  vẫn chạy; nhánh bật tuỳ chọn giữ nguyên trước khối hotkey. Phím tắt 英数 trơn thì nuốt 英数 nên macOS không đổi input
  source bằng phím đó (hệ quả chấp nhận).
- Harness có `typeJISWithLanguageKeys(keys, optionEnabled)` (input source Latin; 102 / 104 không chèn chữ). Engine 50 ca,
  Swift `HotkeyKeyName` 5 ca, `SystemHotkeyConflict` 6 ca; ca mới đánh số từ **62**.
- Ghi phím tắt: modifier lấy từ flagsChanged (`activeModifiers`), `peakModifiers` xoá khi thả hết mà không ghi; byte ký tự
  hiển thị = `HotkeyKeyName.recordedCharacter(keyCode:baseCharacters:)` với `characters(byApplyingModifiers: [])`
  (ghi ⌥Z tay = `0x7A000206`, giống mặc định).
- Phím tắt đang bật của macOS đọc bằng `CopySymbolicHotKeys` (`SystemHotkeyReader`, chỉ ở UI: `.onAppear` +
  `didBecomeActiveNotification`), so trùng bằng `SystemHotkeyConflict` (Swift thuần; modifier Carbon → bit mkey; cờ fn
  ngầm cho F1–F20 / mũi tên / Home / End / PgUp / PgDn / Forward Delete / Help). Chỉ cảnh báo, không chặn ghi; 英数 /
  かな trơn không cảnh báo (dùng chú thích Phase 2). Tên mặc định 31 tổ hợp đo trên macOS 27.0.1.
- macOS bắt ⌘Space / ⌃Space trước app → recorder không ghi được các tổ hợp này; cảnh báo có ích cho phím tắt đã lưu và tổ
  hợp app vẫn nhận (⌃F-key, ⌃ mũi tên…).
- Chạy thật bản Debug: mục Trợ năng "mkey" có thể thuộc bản phát hành `~/Downloads/mkey.app` (cùng bundle id, ký khác) →
  gỡ mục cũ, thêm lại bản Debug bằng +.

Còn tồn (người dùng chốt 2026-10-22, làm ở `Việc 0` của phase sau):
- C1 — **Keycap F1–F20 và mũi tên trống / rác trong `HotkeyEditor`** (có sẵn từ 1.6.1; ghi ⌃F2 lưu byte cao 0x10 → keycap
  trống). Làm: `HotkeyKeyName.name` trả tên theo keycode cho F1–F20 (122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103,
  111, 105, 107, 113, 106, 64, 79, 80, 90 → `F1`…`F20`) và 123–126 (`←` `→` `↓` `↑`), kèm ca test Swift.
- Chưa kiểm (không chặn): kịch bản (g) — tắt / bật phím tắt Spotlight ở Cài đặt hệ thống rồi quay lại mkey, cảnh báo mất /
  hiện mà không khởi động lại.

## Phase 4 — Phát hành dự án riêng
Người dùng chốt 2026-10-22:
- Bundle id `io.github.akachick113.mkeyjis` (Debug: `….debug`, Claude chọn để tách quyền Trợ năng / UserDefaults khỏi
  Release). Tên hiển thị `MKey JIS` (Debug `MKey JIS Debug`), file `mkey-jis.app`; target / scheme giữ `mkey`.
- **Không mua Developer ID → không notarize.** Release ký bằng chứng chỉ **Apple Development** team `8C4YAMZSGP` (có sẵn
  trên máy) để quyền Trợ năng giữ qua các bản cập nhật (ad-hoc thì mỗi bản phải cấp lại). Chứng chỉ hết hạn mỗi năm →
  gia hạn trước khi phát hành bản kế. Người cài phải "Vẫn mở" / xoá quarantine ở lần đầu.
- Appcast trên GitHub Releases `akachick113/mkey-jis` (`…/releases/latest/download/appcast.xml`) → repo phải public khi
  phát hành (cũng là nghĩa vụ GPL-3.0). Khoá Ed25519 mới, tài khoản Keychain `io.github.akachick113.mkeyjis`, người dùng tự
  tạo + sao lưu.

- 4a: Việc 0 C1 (keycap F1–F20 / mũi tên) + định danh trên (`project.yml`, `Info.plist`, script feed, chuỗi UI), README
  phần cài đặt (gỡ mkey gốc + prototype IMK "MKey"), `UPDATES.md` mục Cấu hình. Không phát hành, không bump version.
- 4b: build Release ký Apple Development (ký lại helper Sparkle nếu 4a đo thấy còn ad-hoc — thay cho `notarize.sh`), chọn
  version / build đầu tiên, kiểm cập nhật thật (bản cũ → mới, relaunch, quyền Trợ năng giữ nguyên). GitHub Release tách
  sang 4c (người dùng chốt 2026-10-22, xem dưới).
- 4c: phát hành công khai — public repo, tag, GitHub Release, kiểm feed thật.

Prompt chi tiết: [`prompts/phase-4a.md`](./prompts/phase-4a.md).

**Done khi (4a):** bản Debug / Release mang định danh mới, Release ký team `8C4YAMZSGP`, feed thử dựng cục bộ trỏ
`akachick113/mkey-jis`; không còn `maclifevn/mkey/releases`, `vn.mkey.app`, `CF5PGH3KGK` ngoài `notarize.sh`.

Review: [`reviews/phase-4a.md`](./reviews/phase-4a.md) (2 vòng; vòng 1 sót 6 chuỗi UI `mkey` thường — lỗi do prompt).

**✅ 4a xong (PR #5, squash `127fc59` = nội dung `89915ba` đã review).** Quyết định đã chốt (Phase sau phải theo):
- Định danh: Release `io.github.akachick113.mkeyjis` / `MKey JIS`; Debug `io.github.akachick113.mkeyjis.debug` /
  `MKey JIS Debug` (build setting `MKEY_APP_DISPLAY_NAME`, `Info.plist` dùng `$(MKEY_APP_DISPLAY_NAME)`). File
  `mkey-jis.app`, executable `mkey-jis`; target / scheme / project / `PRODUCT_MODULE_NAME` giữ `mkey`. Chuỗi UI gọi app là
  `MKey JIS` (không viết `mkey` thường).
- UserDefaults Debug ở domain `io.github.akachick113.mkeyjis.debug` (kịch bản chạy thật phase sau dùng domain này, không
  còn `vn.mkey.app`). Không chuyển cài đặt từ mkey gốc. Đường dẫn dữ liệu giữ `Application Support/MKey`,
  `iCloud Drive/mkey`.
- Release ký `Apple Development` team `8C4YAMZSGP`, hardened runtime + `--timestamp`, không cần provisioning profile; Debug /
  CI ad-hoc (base settings). Không notarize → `spctl` từ chối là đúng; README hướng dẫn "Vẫn mở" / `xattr`.
- Sparkle: `SUFeedURL` = `https://github.com/akachick113/mkey-jis/releases/latest/download/appcast.xml`, `SUPublicEDKey` =
  `t1bjqHBGylWvh0cWk9EAwWC28rEJgmA0pYPb/+TBtjc=` (private key trong Keychain account `io.github.akachick113.mkeyjis`, người
  dùng giữ bản sao lưu). `build-update-feed.sh` / `verify-update-feed.py` / smoke test đã trỏ repo mới, asset
  `mkey-jis-<version>.{zip,md}`; dựng feed thử + smoke 4/4 PASS ở review.
- `HotkeyKeyName.keyName(keyCode:)` đặt tên theo keycode cho 英数 / かな / ¥ / _ / F1–F20 / mũi tên; F1–F20 ghi byte cao 0x10.
  Swift `HotkeyKeyName` 8 ca; ca mới đánh số từ **65**.

Còn tồn (đưa vào 4b):
- C1 — **4 helper Sparkle vẫn ad-hoc** trong bản Release (`Autoupdate`, `Updater.app`, `Downloader.xpc`, `Installer.xpc`,
  `flags=adhoc,runtime`); `Sparkle.framework` đã ký team. Ký lại từ trong ra ngoài bằng Apple Development (thay
  `scripts/notarize.sh`, script đó còn identity / profile của chủ repo gốc), rồi kiểm cập nhật thật bản cũ → mới.
- `docs/UPDATES.md` mục "Tạo bản phát hành" còn quy trình notarize của mkey gốc (có ghi chú "bỏ bước này") → 4b viết lại.
- Nhỏ, không chặn: keycap Tab / Delete / Esc / Home / End / PgUp / PgDn / Forward Delete / Help vẫn trống trong
  `HotkeyEditor`.

### Phase 4b — Ký đủ bản Release, quy trình phát hành, kiểm cập nhật cục bộ
Người dùng chốt 2026-10-22: bản đầu tiên **1.7.0 build 14** (origin có sẵn tag `v1.0.0`…`v1.6.1` của mkey gốc); repo
**vẫn private** trong 4b — không tag, không Release, không upload; kiểm cập nhật bằng **feed cục bộ** `http://127.0.0.1`
ký khoá thật; về sau người dùng tự tạo Release + upload qua web (máy không có `gh`).
- Việc 0 C1: `scripts/verify-release-signature.py` (hàm thuần `signature_problems` + CLI: 6 thành phần team `8C4YAMZSGP`,
  không ad-hoc, runtime, Timestamp, app universal); `notarize.sh` → `scripts/sign-release.sh` (copy + ký từ trong ra ngoài,
  `--preserve-metadata=identifier,entitlements`); `build-update-feed.sh` từ chối app còn ad-hoc; viết lại `UPDATES.md` mục
  "Tạo bản phát hành".
- Version 1.7.0 / 14 + `docs/releases/1.7.0.md`; `scripts/prepare-local-update-test.sh` (feed cục bộ + bản "old" build 13
  trỏ feed cục bộ, ký lại cùng chứng chỉ); bước test Python mới trong `check.sh`, ca 65–70.
- Claude đo trước (2026-10-22): ký lại helper như trên → `--verify --deep --strict` pass, DR app không đổi, `Autoupdate`
  giữ entitlement `com.apple.application-identifier` vẫn chạy; Keychain chỉ cho công cụ Sparkle ở
  `build/DerivedData/…/Sparkle/bin` **của checkout chính** đọc khoá (đường dẫn khác → hộp thoại hỏi, lệnh treo).

Prompt chi tiết: [`prompts/phase-4b.md`](./prompts/phase-4b.md).

**Done khi (4b):** bản Release ký lại không còn thành phần ad-hoc; feed dựng từ bản đã ký; bản cũ (build 13) cập nhật lên
1.7.0 qua feed cục bộ, tự mở lại, quyền Trợ năng giữ nguyên; `notarize.sh` không còn.

Review: [`reviews/phase-4b.md`](./reviews/phase-4b.md) (2 vòng; vòng 1 sai tên mục Trợ năng trong hướng dẫn — lỗi do prompt).

**✅ 4b xong (PR #6, squash `ac6eb54` = nội dung `ef79062` đã review).** Quyết định đã chốt (Phase sau phải theo):
- Version hiện tại **1.7.0 / build 14** (chưa phát hành). Ghi chú phát hành ở `docs/releases/<version>.md`; tag
  `v<version>`; mỗi bản tăng `CFBundleVersion`.
- Quy trình phát hành = `docs/UPDATES.md` "Tạo bản phát hành" (7 bước): build Release universal trong **worktree riêng**
  (`../mkey-release-<version>`, không đổi nhánh checkout chính) → `scripts/sign-release.sh` (copy + ký 6 thành phần từ trong
  ra ngoài, `--preserve-metadata=identifier,entitlements`, identity mặc định `Apple Development: akachick113@gmail.com
  (BCHZ2Y26CN)`, đổi bằng `MKEY_SIGNING_IDENTITY`) → `scripts/prepare-local-update-test.sh` (feed `http://127.0.0.1:8765`
  + bản `old` build − 1; **không bao giờ phát hành** bản old) → `scripts/build-update-feed.sh` → người dùng tag + tạo Release
  + upload qua web → kiểm sau phát hành. `scripts/notarize.sh` đã bỏ.
- `scripts/verify-release-signature.py` (hàm thuần `signature_problems` + CLI) là cổng chữ ký: 6 thành phần team
  `8C4YAMZSGP`, không ad-hoc, runtime, Timestamp, app universal; `build-update-feed.sh` và `prepare-local-update-test.sh`
  gọi nó → app Release thô (helper Sparkle ad-hoc) không dựng feed được. Test Python `tests/release-signature-tests.py`
  trong `check.sh` (`PASS: 6 release signature tests`); ca mới đánh số từ **71**.
- Công cụ Sparkle phải chạy từ `/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin`
  (checkout chính) — Keychain chỉ cho đường dẫn này đọc khoá không hỏi.
- Đã chạy thật (Codex, 2026-10-22): bản old build 13 cập nhật lên 1.7.0 qua feed cục bộ, tự mở lại, gõ được ngay, quyền
  Trợ năng giữ nguyên (DR giống nhau). Sparkle chỉ dùng `Autoupdate` (app không sandbox), XPC services không chạy nhưng vẫn
  ký team.
- Mục Trợ năng của macOS hiện **tên file app** (`mkey-jis`, cả Debug lẫn Release), không phải tên hiển thị → mọi hướng dẫn
  ghi "bật **mkey-jis**".

Còn tồn (đưa vào 4c):
- C1 — **Bản phát hành thật dựng lại từ commit squash** theo `UPDATES.md`; không dùng `build/release-1.7.0` /
  `build/update-1.7.0` của Codex (build từ nhánh, ghi chú phát hành cũ).
- C2 — **Đường Gatekeeper chưa kiểm**: quarantine giả (`0081;…;Safari;` bằng `xattr`) không làm hiện hộp thoại chặn trên
  máy này. Kiểm bằng zip tải thật bằng trình duyệt từ Release, mở bằng Finder; README bước 4 sửa theo kết quả.
- Nhỏ, không chặn: keycap Tab / Delete / Esc / Home / End / PgUp / PgDn / Forward Delete / Help vẫn trống trong
  `HotkeyEditor`; chứng chỉ Apple Development hết hạn 2027-08-11 (DR cùng CN khi gia hạn — chưa kiểm).

### Phase 4c — Phát hành công khai (**thay bằng Phase 6** — người dùng chốt đổi thành VKey trước khi public, 2026-10-22)
Người dùng public repo `akachick113/mkey-jis` khi sẵn sàng; build + ký + feed 1.7.0 từ commit squash của 4b theo
`UPDATES.md`; tag `v1.7.0`, người dùng tạo Release + upload 3 file qua web; kiểm feed thật (tải appcast, chữ ký, cài từ zip
tải về có quarantine, "Kiểm tra cập nhật…" báo đã mới nhất). Cập nhật thật qua GitHub (bản cũ → mới) kiểm ở bản phát hành
kế tiếp.

## Phase 5 — VKey: sản phẩm riêng (đổi tên + giao diện mới)
Người dùng chốt 2026-10-22, **trước khi public**:
- Tên **VKey** (viết hoa K). Bundle id `io.github.akachick113.vkey` (Debug `….vkey.debug`), file `VKey.app`, project /
  target / scheme / module `VKey`, tiền tố code `VK` / `VKEY_`, repo `akachick113/vkey`, khoá Sparkle mới (Keychain account
  `io.github.akachick113.vkey`, người dùng tạo). Lưu ý tên gần giống: Vietkey, VNKey (cũng dựa trên OpenKey), EVKey.
- **Bản quyền:** đổi thương hiệu, **giữ ghi công** GPL-3.0 — `LICENSE`, header © Tuyen Mai trong `Sources/Engine/`, `NOTICE.md`,
  một dòng ghi công trong trang Giới thiệu, `NSHumanReadableCopyright`, mục "Nguồn gốc & giấy phép" của README. Không viết lại
  engine. Biến gốc OpenKey (`vTempOffOpenKey`, `v…`) giữ nguyên.
- **Lịch sử git:** repo public mới `akachick113/vkey`, lịch sử bắt đầu từ một commit đầu = mã VKey (giữ NOTICE); repo
  `mkey-jis` giữ private làm lưu trữ. Tài liệu quy trình nào (prompts, reviews, notes, workflow-kit, PLAN) theo sang repo mới:
  chốt ở bước chuyển repo.
- **Phạm vi:** giữ engine + phần JIS đã test; **giữ đủ** gõ tắt (iCloud), quản lý clipboard, chuyển mã, loại trừ / nhớ theo
  app; thiết kế lại toàn bộ giao diện (cửa sổ cài đặt, menu bar, chào mừng, giới thiệu) và icon (icon hiện tại là logo
  "ngọn núi" của tác giả mkey). Giao diện **tiếng Việt**. Thiết kế: Claude đề xuất 2–3 hướng (trang xem được), người dùng chọn.
- **Thiết kế (5b):** người dùng chọn **hướng B — Song ngữ Việt–Nhật** (2026-10-23; giấy kem, đỏ son, Be Vietnam Pro + Noto
  Sans JP, dải 3 ô Việt · Anh · 日本語 kèm phím chuyển). Bản vẽ: canvas "VKey — 3 hướng thiết kế"
  (https://claude.ai/artifact/3n4aSe5KNjboWuSSKfMs6h, khung B và "B · khi chọn bàn phím Tiếng Anh"). Chi tiết chốt ở
  `docs/DESIGN.md`.
- **Chọn bàn phím** (tính năng mới, người dùng chốt 2026-10-23): nút **Tự động / JIS (Nhật) / Tiếng Anh (US)** ở đầu trang
  Bộ gõ và mục "Bàn phím" trong menu thanh menu. Tự động (mặc định) = như hiện tại, nhận JIS theo từng phím
  (`kCGKeyboardEventKeyboardType`). JIS = luôn xử lý kiểu JIS (ánh xạ keycode, ký tự từ event, 英数 / かな theo tuỳ chọn).
  Tiếng Anh = tắt toàn bộ phần JIS, gõ **y như mkey gốc** (kể cả 英数 / かな không được xử lý, "Tương thích bố cục" như
  cũ). Chọn Tiếng Anh mà phím gõ đến từ bàn phím JIS → hiện cảnh báo trong cài đặt kèm nút "Về Tự động", không tự đổi.
  Khoá UserDefaults mới (có trong "Cài đặt mặc định"); quyết định thuần đặt ở `Sources/Platform/` có test; không thêm truy
  vấn mới trên đường nóng.
- Chưa có người dùng → không chuyển cài đặt / dữ liệu từ tên cũ. Thư mục làm việc trên máy giữ `/Users/duc/Developer/mkey`
  (Keychain tin công cụ Sparkle ở đường dẫn đó).

Các bước:
- **5a** (Codex, Sol High) — đổi tên toàn bộ sang VKey, không đổi hành vi / giao diện / icon. Prompt:
  [`prompts/phase-5a.md`](./prompts/phase-5a.md). **Done khi:** `check.sh` xanh như 4b; ngoài tài liệu quy trình và các dòng
  ghi công, không còn `mkey` / `MKey` / tiền tố `MK`; Debug / Release mang định danh VKey, feed thử trỏ `akachick113/vkey`.
- **5b** (Claude + người dùng, có thể song song 5a) — 2–3 hướng thiết kế (cửa sổ cài đặt, menu bar, icon) dạng trang xem
  được → người dùng chọn / chỉnh → `docs/DESIGN.md` (đặc tả cho Codex).
- **5c** (Codex, Sol High) — nền giao diện hướng B (`VKTheme`, khung cửa sổ, sidebar), trang **Bộ gõ**, **chọn bàn phím**
  Tự động / JIS / Tiếng Anh (logic + test), menu thanh menu, icon thanh menu (VI / EN / あ), icon app mới. Prompt:
  [`prompts/phase-5c.md`](./prompts/phase-5c.md).
- **5d** (Codex) — các trang còn lại (Gõ tắt, Chuyển mã, Clipboard, Hệ thống, Giới thiệu), cửa sổ Chào mừng, bảng lịch sử
  clipboard theo `DESIGN.md`; đổi khoá `mkLoginItemInitialized`.
  Prompt: [`prompts/phase-5d.md`](./prompts/phase-5d.md).
Review 5a: [`reviews/phase-5a.md`](./reviews/phase-5a.md) (1 vòng, Approved; người dùng gõ tay 4 bước trên Debug — đạt).

**✅ 5a xong (PR #7, squash `3e0931b` = nội dung `a3579f4` đã review).** Quyết định đã chốt (Phase sau phải theo):
- Định danh: Release `io.github.akachick113.vkey` / `VKey`; Debug `io.github.akachick113.vkey.debug` / `VKey Debug`;
  file `VKey.app`, executable `VKey`; project / target / scheme / module `VKey` (`VKey.xcodeproj`, build setting
  `VKEY_APP_DISPLAY_NAME`). Tiền tố code `VK…` (`VKBridge`, `VKEngineHook.mm`, `VKKeyLayout`, `VKGlobals.h`,
  `VKEngineCallback`, `VKUpdateInputSourceCache`…), macro / env `VKEY_…`, notification Swift `.vk…` (chuỗi `VK…`).
- Dữ liệu: `Application Support/VKey/clipboard`, `iCloud Drive/VKey/VKeyMacroData.bin`, file xuất `VKeyMacro`. Không chuyển
  dữ liệu từ tên cũ. Biến / khoá gốc OpenKey (`vTempOffOpenKey`, `v…`) giữ nguyên.
- Sparkle: feed `https://github.com/akachick113/vkey/releases/latest/download/appcast.xml`, `SUPublicEDKey`
  `fcqb3GZ6HvWXoXM+WpYSukjXRGF0mI0pYmJZTR7WTAE=` (Keychain account `io.github.akachick113.vkey`, người dùng đã sao lưu);
  asset `VKey-<version>.{zip,md}`. Version vẫn 1.7.0 / 14 (chọn ở Phase 6).
- Ghi công: `NOTICE.md`, mục "Nguồn gốc & giấy phép" của README, một dòng trang Giới thiệu, `NSHumanReadableCopyright`,
  header © Tuyen Mai trong `Sources/Engine/`. Mục Trợ năng hiện tên file: **VKey**.
- Ca test mới đánh số từ **71**. Lệnh grep tên cũ ở prompt sau dùng `(?<![a-z])mkey` (tránh khớp `fromkeys`).

Còn tồn: khoá UserDefaults `mkLoginItemInitialized` (`AppState.swift:248-249`) → đổi ở 5d.

**✅ 5b xong (Claude + người dùng, 2026-10-23).** Hướng B, màu giữ nguyên bản vẽ; đặc tả [`DESIGN.md`](./DESIGN.md).

Review 5c: [`reviews/phase-5c.md`](./reviews/phase-5c.md) (1 vòng, Approved; Claude tự gõ `CGEventPost` 3 chế độ — đạt).

**✅ 5c xong (PR #8, squash `43c2d38` = nội dung `c5a8df1` đã review).** Quyết định đã chốt (Phase sau phải theo):
- Màu chỉ khai báo ở `Sources/App/Views/VKTheme.swift` (18 token sáng / tối, `NSColor` động); thành phần dùng chung ở
  `VKComponents.swift` (`VKCard`, `VKRow`, `VKDivider`, `VKSectionLabel`, `VKSegmented`, `VKKeycap(Row)`, `VKBanner`). Switch
  = `Toggle(.switch).tint(VKTheme.accent)`.
- Khung cửa sổ 860 × 600 (tối thiểu 860 × 560), sidebar chữ + chấm, tiêu đề trang chung trong `SettingsRootView` (trang Bộ gõ
  thêm chọn bàn phím). `SettingsPage.icon` đã bỏ.
- Chọn bàn phím: khoá / global `vKeyboardMode` (0 Tự động, 1 JIS, 2 Tiếng Anh; giá trị lạ = Tự động), `VKTreatAsJIS`,
  `VKLanguageKeyActionForMode` (`VKKeyLayout`); hook tách `_hardwareKeyboardIsJIS` / `_currentKeyboardIsJIS`; notification
  `VKHardwareKeyboardDidChange` (chỉ khi bàn phím vật lý đổi), `VKInputSourceDidChange`; `AppState.keyboardMode`,
  `hardwareKeyboardIsJIS`, `inputSourceIsLatin`; chữ trạng thái ở `KeyboardModeStatus` (Swift thuần), `LanguageIndicator`
  (`VI` / `EN` / `あ`). Engine 53 ca, Swift `keyboard mode` 5 ca; ca mới đánh số từ **79**.
- Menu thanh menu là menu gốc macOS (có submenu `Bàn phím`, `Cài đặt VKey…`); icon thanh menu `VI` / `EN` / `あ`; icon app
  đỏ son (V + dấu sắc + con dấu あ; 16 / 32 px không con dấu) sinh bằng `scripts/make_icon.swift`.
- Chạy thật trên máy: gõ bằng `CGEventPost` (JIS keyboard type 93, ANSI 40); phím do AppleScript / System Events gửi mang
  keyboard type JIS — tránh dùng khi đo trạng thái "bàn phím vừa gõ".

Còn tồn (đưa vào 5d): `PermissionBanner` (không dùng) + cảnh báo trùng phím tắt `HotkeyEditor.swift:145` còn `.orange`; header
file thiếu ở file mới / viết lại (mất chú thích lý do sidebar tự dựng); submenu `Bàn phím` lặp tiêu đề; khoá
`mkLoginItemInitialized`.

Review 5d: [`reviews/phase-5d.md`](./reviews/phase-5d.md) (3 vòng: vòng 1 formatter thụt lề lẫn lộn + hàng trong thẻ đệm hai
lần + icon bảng clipboard cùng màu nền; vòng 2 còn khoảng trắng — một phần do tiêu chí kiểm của review; người dùng chuyển
sang **Luna · High, session mới** với hướng dẫn từng bước Claude chạy thử trước; vòng 3 Approved, Claude đọc Accessibility).

**✅ 5d xong (PR #9, squash `abab86b` = nội dung `90a3e14` đã review).** Quyết định đã chốt (Phase sau phải theo):
- Mọi trang cài đặt: `VKPageContent` (cuộn, đệm 32 ngang / 28 dưới, `tint` accent) + `VKCard` chứa trực tiếp
  `VKSwitchRow` / `VKRow` / `VKDivider`; hàng không phải `VKRow` đệm 11 × 16. Thành phần mới trong `VKComponents`:
  `VKPageContent`, `VKSwitchRow`, `VKPrimaryButtonStyle` (nền `accent`, chữ `onAccent` semibold, bo 7). Nút phụ `.bordered`.
- Đã xoá `AppStyle` / `settingsFormStyle`, `VisualEffectBlur`, `PermissionBanner`. Màu chỉ qua `VKTheme`; ngoại lệ:
  `StatusIcon` vẽ icon template bằng `NSColor.black/white`, và `.shadow(color: .black…)`. DESIGN §10 cập nhật (bảng gõ tắt
  nền phẳng, chữ hoa / thường là popup, bố cục chung).
- Bảng lịch sử clipboard: nền `card` + viền `border`; hàng chọn `accent`, chữ / icon `onAccent`, ô loại mục
  `onAccent.opacity(0.16)` viền `0.4`; hover `segmentTrack`; ghim `accent`; chữ hàng chọn semibold.
- Khoá `vkLoginItemInitialized` (không chuyển giá trị cũ).
- Quy trình: **cấm chạy formatter** (`swift-format` / `swiftformat`); kiểm thay đổi khoảng trắng bằng `git diff --numstat`
  có / không `-w`. Hạ Sol → Luna = **session Codex mới** + mục "Hướng dẫn sửa (cho Luna)" Claude chạy thử trước (WORKFLOW
  §8). Đọc menu thanh menu qua `AXExtrasMenuBar`, chuyển trang bằng AXPress — không cần gửi phím.
- Ca mới vẫn đánh số từ **79**.

Còn tồn (đưa vào Phase 6, Việc 0):
- C1 — submenu `Bàn phím` có 2 dải phân cách rỗng (`Menu { Picker.inline }` — lỗi của prompt 5d) → `Picker` thẳng như
  `Kiểu gõ` / `Bảng mã` (`VKeyApp.swift` ~114).
- C2 — `SystemPage`: dòng `availabilityNotice` / `Kiểm tra lần cuối` căn giữa → căn trái.
- C3 — `ConvertPage`: popup `Chuyển đổi` lệch mép phải so với 2 popup bảng mã.
- C4 — 2 ô nhập trang Gõ tắt thiếu nhãn Accessibility (có từ trước).
- Chưa kiểm (gộp vào kiểm trước phát hành): cửa sổ Chào mừng nền sáng; bảng clipboard có mục HTML / ảnh / hover; Tab bằng
  phím thật + nghe VoiceOver.

## Phase 6 — Repo `akachick113/vkey` + phát hành VKey 1.0.0
Thay 4c; Còn tồn C1 / C2 của 4b chuyển sang đây. Người dùng chốt 2026-10-24:
- Version đầu **1.0.0, build 2** (sản phẩm mới; build ≥ 2 vì kiểm cập nhật cục bộ cần bản `old` = build − 1).
- Repo mới `akachick113/vkey`, **lịch sử mới** (một commit đầu = cây `main` sau 6a), **mang theo toàn bộ tài liệu quy trình**
  (PLAN, prompts, reviews, notes, workflow-kit, AGENTS, CLAUDE). `mkey-jis` giữ private làm lưu trữ.
- Repo vkey tạo **private**, chỉ **public ngay trước khi tag** (sau CI xanh + kiểm cập nhật cục bộ).
- Phase 6 gồm cả chuyển repo lẫn phát hành.

Các bước:
- **6a** (Codex, Luna · High) — Việc 0 = Còn tồn C1–C4 của 5d; version 1.0.0 / 2; `docs/releases/1.0.0.md`; README thêm
  tính năng chọn bàn phím. PR vào `mkey-jis` như cũ. Prompt: [`prompts/phase-6a.md`](./prompts/phase-6a.md).
- **6b** (Claude + người dùng, không có Codex chạy) — người dùng tạo repo **private** trống `akachick113/vkey` qua web;
  Claude ở checkout chính: `origin` → `archive` (mkey-jis), thêm `origin` = vkey, nhánh orphan một commit từ cây `main` sau
  6a, push; sửa tài liệu nhắc `mkey-jis` (AGENTS, CLAUDE, codebase-map, workflow) trong commit docs tiếp theo; CI xanh trên
  repo mới. Số PR bắt đầu lại từ #1 (review cũ nhắc PR của `mkey-jis`).
- **6c** (Codex + người dùng + Claude) — phát hành theo `UPDATES.md` từ commit đầu của repo mới: build Release universal
  trong worktree, `sign-release.sh`, kiểm cập nhật cục bộ (`old` build 1 → 1.0.0 build 2), dựng feed; Claude kiểm giao diện
  trước phát hành (Chào mừng nền sáng, bảng clipboard HTML / ảnh / hover, Tab + VoiceOver); người dùng public repo, tag
  `v1.0.0`, tạo Release, upload 3 file; kiểm sau phát hành gồm **Gatekeeper thật** (zip tải bằng trình duyệt, mở bằng
  Finder — 4b C2) và sửa README bước 3 theo kết quả.

Review 6a: [`reviews/phase-6a.md`](./reviews/phase-6a.md) (1 vòng, Approved; Claude đọc Accessibility trên bản Debug sau khi
người dùng cấp lại quyền Trợ năng).

**✅ 6a xong (PR #10, squash `1bdc5ba` = nội dung `608e45c` đã review).** Quyết định đã chốt (Phase sau phải theo):
- `Info.plist`: `1.0.0` / build `2`. Ghi chú phát hành ở `docs/releases/1.0.0.md` (hứa: Apple Silicon + Intel, macOS 14+, app
  tự nhận quyền Trợ năng không cần mở lại — đã thấy đúng trên bản Debug).
- Submenu `Bàn phím` là `Picker` thẳng (như `Kiểu gõ` / `Bảng mã`); C2–C4 của 5d xong.
- Quy trình: Luna · High làm đúng 1 vòng khi prompt ghi sẵn từng đoạn mã + bảng `numstat` mong đợi Claude đã đo trước.
- Ca mới vẫn đánh số từ **79**.

Còn tồn (đưa vào 6c):
- C1 — bản Release phải universal: kiểm `lipo -archs` = `x86_64 arm64` trước khi upload (Debug chỉ `arm64`).
- C2 — danh sách Trợ năng hiện icon `mkey` cũ cạnh mục VKey Debug (cache icon của macOS; `AppIcon.icns` trong bản build là icon
  VKey) → kiểm lại với bản cài ở `/Applications`.
- C3 — chưa kiểm từ 5d: Chào mừng nền sáng; bảng clipboard HTML / ảnh / hover; Tab bằng phím thật + VoiceOver.

**Done khi (Phase 6):** repo `akachick113/vkey` public, CI xanh; Release `v1.0.0` là latest với `appcast.xml`,
`VKey-1.0.0.zip`, `VKey-1.0.0.md`; chữ ký feed hợp lệ; cài từ zip tải bằng trình duyệt chạy được theo README; "Kiểm tra
cập nhật…" báo đã mới nhất.

## Ngoài phạm vi (ghi lại để không tự làm)
- Target InputMethodKit (prototype ở `~/Desktop/ki12026/…/MKeyInputMethod`, không có git). Xem lại sau Phase 4 nếu cần.
- Sửa cảnh báo deprecated `activateIgnoringOtherApps`.
- Hotkey đi thẳng Nhật / Việt / Anh bằng `TISSelectInputSource` (người dùng bỏ khỏi Phase 3, 2026-10-19).
- Đóng góp ngược Phase 1 cho `maclifevn/mkey` (bản sửa JIS dùng được cho mọi người) — cân nhắc sau khi Phase 1 merge.
