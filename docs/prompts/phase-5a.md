# Phase 5a — Đổi tên toàn bộ thành VKey

> Codex · **GPT-6 Sol** · effort **High** (refactor đổi tên ~45 file: project / target / module, bridging header ObjC++,
> hàm C++ dùng chung với test, đường dẫn dữ liệu, script phát hành; sót một chỗ là gãy build hoặc lộ tên cũ — WORKFLOW
> §8 "refactor nhiều file") · nhánh `phase-5a-rename-vkey`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Quyết định chung**, Phase 4 **Quyết định đã chốt** của 4a và 4b, **Phase 5**),
`docs/UPDATES.md`.

Người dùng chốt 2026-10-22: trước khi public, app thành sản phẩm riêng tên **VKey**. Bỏ mọi tên của bản cũ (mkey, MKey,
MKey JIS, tiền tố `MK`, `mkey-jis`, `mkeyjis`), **chỉ giữ ghi công bắt buộc theo GPL-3.0**: header bản quyền trong file
engine, tên biến gốc OpenKey, một file `NOTICE.md`, một dòng ghi công trong trang Giới thiệu, chuỗi bản quyền trong
`Info.plist`, mục "Nguồn gốc & giấy phép" trong README. Phase này **chỉ đổi tên**, không đổi hành vi, không đổi giao diện
(giao diện mới làm ở 5c sau khi người dùng chọn thiết kế ở 5b).

Định danh mới:

| Mục | Cũ | Mới |
|---|---|---|
| Tên hiển thị Release / Debug | `MKey JIS` / `MKey JIS Debug` | `VKey` / `VKey Debug` |
| Bundle id Release / Debug | `io.github.akachick113.mkeyjis` / `….debug` | `io.github.akachick113.vkey` / `io.github.akachick113.vkey.debug` |
| File app / executable | `mkey-jis.app` / `mkey-jis` | `VKey.app` / `VKey` |
| Project / target / scheme / module | `mkey` (`mkey.xcodeproj`) | `VKey` (`VKey.xcodeproj`) |
| Tiền tố code ObjC / C++ / macro | `MK…`, `MKEY_…` | `VK…`, `VKEY_…` |
| Repo / feed Sparkle | `akachick113/mkey-jis` | `akachick113/vkey` → `https://github.com/akachick113/vkey/releases/latest/download/appcast.xml` (repo tạo ở phase sau; feed chưa dùng tới) |
| Khoá Sparkle (Keychain account) | `io.github.akachick113.mkeyjis` | `io.github.akachick113.vkey` (người dùng tạo, xem dưới) |
| Asset phát hành | `mkey-jis-<version>.{zip,md}` | `VKey-<version>.{zip,md}` |
| Dữ liệu | `Application Support/MKey`, `iCloud Drive/mkey/mkeyMacroData.bin`, file xuất `mkeyMacro` | `Application Support/VKey`, `iCloud Drive/VKey/VKeyMacroData.bin`, `VKeyMacro` |

Chưa có người dùng nào (chưa phát hành) → **không** viết code chuyển cài đặt / dữ liệu từ tên cũ.

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; Conventional Commits tiếng Việt; chỉ `git add <file>` (đổi tên
file dùng `git mv`); **mở PR vào `main` của `origin`** và gửi link. Không có ca test mới (ca mới vẫn đánh số từ **71**);
test cũ chỉ được sửa ở chỗ chứa tên / đường dẫn / bundle id cũ — liệt kê từng chỗ trong PR (AGENTS quy tắc 3).

### Trước khi giao (người dùng làm, Codex chỉ kiểm)
Tạo khoá Sparkle mới bằng công cụ ở **checkout chính** (Keychain chỉ tin đường dẫn này):
```bash
BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin
"$BIN/generate_keys" --account io.github.akachick113.vkey
"$BIN/generate_keys" --account io.github.akachick113.vkey -x <đường dẫn ngoài repo>   # sao lưu, rồi cất kỹ / xoá file tạm
```
Codex lấy public key bằng `"$BIN/generate_keys" --account io.github.akachick113.vkey -p` (chỉ đọc). Báo không có khoá →
**dừng, hỏi người dùng**; không tự tạo, không `-x` / `-f`. Khoá cũ `io.github.akachick113.mkeyjis` để nguyên trong Keychain.

### Hiện trạng đã xem (Claude, `origin/main` @ `43e657c`, 2026-10-22)
- **Tên file chứa tên cũ:** `Sources/App/MkeyApp.swift`; `Sources/Platform/MKBridge.{h,mm}`, `MKEngineHook.mm`,
  `MKGlobals.h`, `MKKeyLayout.{h,cpp}`; `Sources/Support/mkey-Bridging-Header.h`, `mkey.entitlements`. `.gitignore:7`
  `mkey.xcodeproj/`.
- **Định danh tiền tố `MK` / `MKEY_`** (`git grep -c -P '(?<![A-Za-z])MK[A-Z]|MKEY_' -- Sources tests scripts project.yml`
  → 26 file): kiểu / hàm / notification `MKBridge` (59 lần), `MKCurrentKeyCharacter`, `MKLanguageKey{Action,ActionFor,
  NotHandled,PassToSystem,ToggleLanguage,EndWord}`, `MKJISWordCharacter`, `MKJISToLogicalKey`, `MKLogicalToJISKeycode`,
  `MKMacroItem`, `MKKey`, `MKStateDidChange[Notification]`, `MKQuickConvertDidRun[Notification]`,
  `MKMacroCloudSyncDidImport`, `MKUpdateInputSourceCache`, `MKReloadExcludedApps`, `MKEngineInit`, `MKEngineCallback`,
  `MKSetEngineSuspended`, `MKReEnableEventTap`, `MKGetBundleIdentifierForPid`, `MKFrontMostAppChanged`,
  `MKInputSourceChangedCallback`, `MKRequestAccessibility`, `MKOpenWelcomeWindow`, `MKOpenSettingsWindow`, include guard
  `MKGlobals_h`; macro / biến môi trường / build setting `MKEY_DEFAULT_SWITCH_STATUS`, `MKEY_EMPTY_HOTKEY`,
  `MKEY_ENABLE_UPDATES`, `MKEY_SPARKLE_ACCOUNT`, `MKEY_SMOKE_RESULT`, `MKEY_SMOKE_EXPECTED`, `MKEY_SIGNING_IDENTITY`,
  `MKEY_APP_DISPLAY_NAME`. Dùng ở cả `tests/engine/EngineHarness.cpp` (13), `EngineTests.cpp` (43), test Swift, script.
- **Chữ `mkey` / `MKey` (không phân biệt hoa thường)** ngoài tài liệu quy trình: 43 file — header `//  mkey` ở mọi file
  `Sources/App`; `struct MkeyApp`, `MkeyAppDelegate`; chuỗi UI `MKey JIS` (`MkeyApp.swift:26,35,77,91,129,135`,
  `UpdateChecker.swift:56,112`, `AboutPage.swift:30,84`, `SettingsRootView.swift:206`, `SystemPage.swift:81-98`,
  `TypingPage.swift:84`, `WelcomePage.swift:37,60`); `NSLog("mkey: …")`; domain lỗi
  `io.github.akachick113.mkeyjis.updates` (`UpdateChecker.swift:127`); đường dẫn dữ liệu (`ClipboardManager.swift:154`,
  `MacroPage.swift:199,252,256`); chú thích nhắc "MKey"; `project.yml`; `Info.plist:32,34`; mọi script trong `scripts/`
  (bundle id, feed, `NAME="mkey-jis-…"`, `mktemp … mkey-…`, `APP="$OUTPUT/mkey-jis.app"`); test (`UpdateRuntimePolicyTests.swift:22-29`
  dùng `mkey.app` làm đường dẫn mẫu, `release-signature-tests.py:14`, `run-update-smoke.py:19,36,45,46,53`);
  `README.md`, `CONTRIBUTING.md`, `docs/UPDATES.md`, `docs/releases/1.6.1.md` (ghi chú của mkey gốc),
  `docs/releases/1.7.0.md` (bản MKey JIS chưa phát hành). `scripts/make_icon.swift:1` "Renders the mkey app icon".
- **Ghi công hiện có:** header `Copyright © 2019 Tuyen Mai. All rights reserved.` ở 12 file `Sources/Engine/`;
  `MKEngineHook.mm:5-6` "Adapted from OpenKey's macOS glue (OpenKey.mm, GPLv3, © Tuyen Mai)"; `AboutPage.swift:73`
  `Phát triển bởi **Anh Tuấn** · © 2026` (tác giả mkey), `:74` dòng bản JIS, `:82` dòng engine OpenKey, `:84-87` bốn link;
  `Info.plist:32` `Engine © Tuyen Mai (OpenKey, GPL v3). UI mkey 2026. Bản JIS: akachick113.`; `LICENSE` = GPL-3.0;
  `Vendor/Licenses/Sparkle/LICENSE.txt`.
- **Giữ nguyên (không phải tên thương hiệu):** biến / khoá gốc OpenKey `vTempOffOpenKey` (khai báo ở
  `Sources/Engine/Engine.h:183`, dùng ở Platform, `AppState`, harness, khoá UserDefaults) và mọi biến `v…` khác; nội dung
  `Sources/Engine/`.
- **Icon** (`scripts/make_icon.swift`, `Assets.xcassets/AppIcon`) là logo "ngọn núi" của tác giả mkey — **không** đổi ở
  5a (icon mới thiết kế ở 5b, làm ở 5c); chỉ đổi chú thích dòng 1 của script.
- **Không đổi tên thư mục** `/Users/duc/Developer/mkey` (Keychain chỉ cho công cụ Sparkle ở
  `…/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin` đọc khoá) — đây là đường dẫn máy, không nằm trong
  repo.

## Việc 1 — Project, target, file
- `project.yml`: `name: VKey`; target `VKey`; `PRODUCT_NAME: VKey`; `PRODUCT_MODULE_NAME: VKey`;
  `PRODUCT_BUNDLE_IDENTIFIER` base `io.github.akachick113.vkey`, Debug `io.github.akachick113.vkey.debug`; build setting
  `MKEY_APP_DISPLAY_NAME` → `VKEY_APP_DISPLAY_NAME` (base `VKey`, Debug `VKey Debug`); `CODE_SIGN_ENTITLEMENTS:
  Sources/Support/VKey.entitlements`; `SWIFT_OBJC_BRIDGING_HEADER: Sources/Support/VKey-Bridging-Header.h`. Cấu hình ký,
  Sparkle `exactVersion`, mọi dòng khác giữ nguyên.
- `git mv`: `MkeyApp.swift` → `VKeyApp.swift`; `MKBridge.{h,mm}` → `VKBridge.{h,mm}`; `MKEngineHook.mm` →
  `VKEngineHook.mm`; `MKGlobals.h` → `VKGlobals.h`; `MKKeyLayout.{h,cpp}` → `VKKeyLayout.{h,cpp}`;
  `mkey-Bridging-Header.h` → `VKey-Bridging-Header.h`; `mkey.entitlements` → `VKey.entitlements`. Sửa mọi `#import` /
  `#include` theo.
- `.gitignore`: `mkey.xcodeproj/` → `VKey.xcodeproj/`. Xoá thư mục sinh `mkey.xcodeproj` cục bộ (không tracked).
- `scripts/check.sh`: `-project VKey.xcodeproj -scheme VKey`; đường dẫn `Sources/Platform/VKKeyLayout.cpp`. Không đổi
  bước, không đổi thứ tự.

## Việc 2 — Đổi định danh trong code
- Mọi định danh `MK…` → `VK…`, `MKEY_…` → `VKEY_…` (danh sách ở Hiện trạng; giữ phần sau tiền tố, vd
  `MKLanguageKeyActionFor` → `VKLanguageKeyActionFor`, `MKGlobals_h` → `VKGlobals_h`). Tên notification là chuỗi → đổi cả
  giá trị chuỗi. Biến môi trường mới: `VKEY_ENABLE_UPDATES`, `VKEY_SPARKLE_ACCOUNT`, `VKEY_SIGNING_IDENTITY`,
  `VKEY_SMOKE_RESULT`, `VKEY_SMOKE_EXPECTED`.
- `struct MkeyApp` → `VKeyApp`, `MkeyAppDelegate` → `VKeyAppDelegate`.
- Header file `//  mkey` → `//  VKey`; `//  MkeyApp.swift` → `//  VKeyApp.swift`, `//  mkey-Bridging-Header.h` →
  `//  VKey-Bridging-Header.h`. Chú thích nhắc "MKey" / "mkey" (vd `AppState.swift:119,130,393,406`,
  `ClipboardManager.swift:74`, `StatusIcon.swift:22`, `SettingsRootView.swift:210`, `VKeyApp.swift:285`) → "VKey".
  **Giữ** chú thích ghi nguồn OpenKey (`VKEngineHook.mm:5-6`, `VKeyApp.swift:5` "built on the OpenKey…", `AppState.swift:282`).
- `NSLog("mkey: …")` → `NSLog("VKey: …")`. Domain lỗi `io.github.akachick113.vkey.updates`.
- Không đổi `Sources/Engine/`, `vTempOffOpenKey` và các biến `v…`, khoá UserDefaults hiện có.

## Việc 3 — Chuỗi giao diện, dữ liệu, Info.plist
- Mọi chuỗi UI `MKey JIS` → `VKey` (giữ phần còn lại của câu; vd `Tắt VKey cho \(excludeTargetName)`,
  `VKey — Bộ gõ Tiếng Việt`, `Chào mừng đến với VKey`, `Tạm tắt VKey bằng phím ⌘`).
- `AboutPage.swift` (tạm, 5c thiết kế lại): tên `VKey`; dòng tác giả `Phát triển bởi **akachick113** · © 2026`; **bỏ**
  dòng `Bản cho bàn phím JIS…`; dòng engine thay bằng một dòng ghi công `Dựa trên mã nguồn mở OpenKey (© Tuyen Mai) và mkey
  (© Anh Tuấn), giấy phép GPL v3.`; hàng link còn 3: `Mã nguồn` → `https://github.com/akachick113/vkey`, `Ghi công` →
  `https://github.com/akachick113/vkey/blob/main/NOTICE.md`, `Giấy phép GPL v3` (giữ URL hiện có). Bỏ link `MKey gốc`,
  `Mã nguồn OpenKey` (đã nằm trong NOTICE).
- `ClipboardManager.swift:154` → `"VKey/clipboard"`; `MacroPage.swift:199` → `"VKeyMacro"`, `:252` → `"VKey"`, `:256` →
  `"VKeyMacroData.bin"`.
- `Info.plist`: `CFBundleDisplayName` / `CFBundleName` = `$(VKEY_APP_DISPLAY_NAME)`; `NSHumanReadableCopyright` =
  `VKey © 2026 akachick113. Dựa trên OpenKey (© Tuyen Mai) và mkey (© Anh Tuấn), GPL v3.`; `SUFeedURL` feed mới;
  `SUPublicEDKey` = `generate_keys --account io.github.akachick113.vkey -p`. Version / build và khoá `SU*` khác giữ nguyên.

## Việc 4 — Script phát hành + test
- `build-update-feed.sh`: `ACCOUNT` mặc định `io.github.akachick113.vkey` (biến `VKEY_SPARKLE_ACCOUNT`); kiểm bundle id /
  feed mới; `mktemp … vkey-release.XXXXXX`; `NAME="VKey-${VERSION}"`; `PREFIX` / `--link` trỏ `akachick113/vkey`.
- `verify-update-feed.py`: tiền tố URL `https://github.com/akachick113/vkey/releases/download/v`; `--account` mặc định
  mới; `prefix='vkey-tamper-'`.
- `sign-release.sh`: `APP="$OUTPUT/VKey.app"`; `VKEY_SIGNING_IDENTITY`. `prepare-local-update-test.sh`: tên asset / app
  mới, `mktemp … vkey-local-update.XXXXXX`, `VKEY_SPARKLE_ACCOUNT`. `verify-release-signature.py`: không có tên cũ — chỉ
  kiểm lại.
- `make_icon.swift:1`: `Renders the VKey app icon…` (không đổi hình).
- Test: `UpdateRuntimePolicyTests.swift` đường dẫn mẫu `mkey.app` → `VKey.app`, `/Volumes/MKey/` → `/Volumes/VKey/` (cùng
  kỳ vọng true / false); `release-signature-tests.py:14` `Identifier=io.github.akachick113.vkey`; `run-update-smoke.py`
  `VKey.app`, bundle id thử `io.github.akachick113.vkey.updater-smoke.`, app thử `VKey-Updater-Smoke-…`, `CFBundleName`
  `VKey Update Test`, `prefix='vkey-update-smoke-'`, biến môi trường `VKEY_*`; `UpdateControllerSmoke.swift`,
  `EngineHarness.cpp`, `EngineTests.cpp` theo tên mới. Không đổi kỳ vọng nào khác.

## Việc 5 — Tài liệu cho người dùng + ghi công
- `NOTICE.md` (mới, tiếng Việt): VKey © 2026 akachick113, phát hành theo GPL-3.0 (`LICENSE`); VKey là **bản sửa đổi** (GPL
  §5a) dựa trên: (1) **OpenKey** — engine gõ tiếng Việt, © 2019 Tuyen Mai, GPL-3.0, https://github.com/tuyenvm/OpenKey —
  `Sources/Engine/` giữ nguyên, phần event tap ở `Sources/Platform/VKEngineHook.mm` chuyển thể từ `OpenKey.mm`; (2) **mkey**
  — giao diện SwiftUI, bridge, cập nhật Sparkle, © 2026 Anh Tuấn (maclifevn), GPL-3.0, https://github.com/maclifevn/mkey;
  akachick113 sửa đổi từ 2026-10: hỗ trợ bàn phím JIS + bộ gõ tiếng Nhật, đổi tên, ký / phát hành riêng; (3) **Sparkle** —
  MIT, `Vendor/Licenses/Sparkle/LICENSE.txt`.
- `README.md` viết lại theo VKey: tiêu đề `# VKey — Bộ gõ tiếng Việt cho macOS`, đoạn mở (gõ Telex / VNI, chạy tốt trên
  bàn phím JIS cùng bộ gõ tiếng Nhật của macOS); mục `## Tính năng` gộp từ hai mục "Khác gì mkey gốc" + "Có gì mới so với
  OpenKey" (viết theo góc nhìn VKey, không so với ai); Cấu trúc (`VKey/`, tên file mới); Build (`VKey.xcodeproj`,
  `-scheme VKey`, `VKey.app`, bundle id Debug mới); Cài đặt: bước 1 thành "Thoát các bộ gõ tiếng Việt khác đang chạy (hai
  bộ gõ event tap cùng lúc sẽ xử lý mỗi phím hai lần)" — **không nêu tên**; bỏ bước gỡ prototype "MKey"; các bước còn lại
  đổi tên (`VKey-<version>.zip`, `VKey.app`, mục Trợ năng **VKey** — tên file app, `xattr … /Applications/VKey.app`); mục
  `## Nguồn gốc & giấy phép` cuối file: 2–3 câu ghi công OpenKey + mkey (link), GPL-3.0, link `NOTICE.md`.
- `CONTRIBUTING.md`: `VKey`, clone `https://github.com/akachick113/vkey.git`, `cd vkey`, `open VKey.xcodeproj`; câu giấy
  phép: "VKey dựa trên OpenKey và mkey (xem `NOTICE.md`) nên phát hành theo GPL v3".
- `docs/UPDATES.md`: đổi mọi tên / bundle id / feed / account / asset / đường dẫn app sang VKey (worktree phát hành
  `../vkey-release-<version>`, `/tmp/vkey-update-policy-tests`); đoạn "MKey JIS có bundle id riêng nên không nhận cập nhật
  từ mkey gốc…" → bỏ phần nhắc mkey, giữ ý "các bản VKey sau cập nhật trong app, quyền Trợ năng giữ nguyên khi cùng chứng
  chỉ". Giữ đường dẫn `BIN=/Users/duc/Developer/mkey/build/…` (đường dẫn máy, ghi chú ngay dưới: thư mục làm việc trên máy
  phát hành, không đổi tên vì Keychain).
- `git rm docs/releases/1.6.1.md docs/releases/1.7.0.md` (ghi chú của bản cũ, chưa phát hành bản nào; ghi chú VKey viết ở
  phase phát hành; `UPDATES.md` vẫn nói `docs/releases/<version>.md`, thư mục được tạo lại khi có ghi chú đầu tiên).

## Không được làm
- Không đổi hành vi / giao diện / bố cục / icon; không thêm tính năng; không đổi version / build.
- Không sửa `Sources/Engine/`; không đổi `vTempOffOpenKey`, biến `v…`, khoá UserDefaults; không xoá / sửa header bản quyền
  Tuyen Mai, chú thích ghi nguồn OpenKey, `LICENSE`, `Vendor/Licenses/`.
- Không viết code chuyển dữ liệu từ tên cũ. Không tạo repo GitHub, không đổi tên repo / remote, không tag, không Release.
- Không tạo / xuất / nhập khoá Sparkle (chỉ `-p`); không commit khoá, chứng chỉ, `build/`.
- Không sửa `AGENTS.md`, `CLAUDE.md`, `docs/PLAN.md`, `docs/PRODUCT_SPEC.md`, `docs/notes/`, `docs/prompts/`,
  `docs/reviews/`, `docs/workflow-kit/` (tài liệu quy trình — Claude cập nhật sau khi merge), `.github/`.
- Không đổi tên thư mục làm việc `/Users/duc/Developer/mkey`. Không thêm / nâng dependency. Không push `main`.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `PASS: 14 update runtime policy checks`, `PASS: 50 engine tests`,
      `PASS: 8 hotkey key name tests`, `PASS: 6 system hotkey conflict tests`, `PASS: 6 release signature tests`. CI xanh.
- [ ] `git grep -n -P '(?<![A-Za-z])MK[A-Z]|MKEY_|Mkey' -- . ':!docs/prompts' ':!docs/reviews' ':!docs/workflow-kit'
      ':!docs/notes' ':!docs/PLAN.md' ':!docs/PRODUCT_SPEC.md' ':!AGENTS.md' ':!CLAUDE.md'` **không in gì**.
- [ ] `git grep -n -i -E 'mkey|mkeyjis|mkey-jis' -- . ':!docs/prompts' ':!docs/reviews' ':!docs/workflow-kit' ':!docs/notes'
      ':!docs/PLAN.md' ':!docs/PRODUCT_SPEC.md' ':!AGENTS.md' ':!CLAUDE.md'` chỉ còn các dòng ghi công: `NOTICE.md`, mục
      "Nguồn gốc & giấy phép" của `README.md`, dòng ghi công trong `AboutPage.swift`, `NSHumanReadableCopyright` trong
      `Info.plist`, `CONTRIBUTING.md` câu giấy phép, và đường dẫn máy `/Users/duc/Developer/mkey/…` trong `docs/UPDATES.md`.
      Dán kết quả.
- [ ] `git ls-files | grep -i -E 'mkey|/MK'` không in gì.
- [ ] Kịch bản chạy thật — máy JIS này, ABC + Japanese – Romaji, không bộ gõ tiếng Việt nào khác chạy. Ghi kết quả:
  - (a) Debug: `plutil -p build/DerivedData/Build/Products/Debug/VKey.app/Contents/Info.plist` → bundle id
    `io.github.akachick113.vkey.debug`, tên `VKey Debug`, executable `VKey`, feed mới, `SUPublicEDKey` = khoá mới,
    copyright mới. `codesign -dv` → ad-hoc.
  - (b) Chạy Debug: Trợ năng có mục mới (ghi đúng tên hiện ra) → người dùng cấp quyền. TextEdit: `tieengs vieetj` →
    `tiếng việt`; JIS `ddaay` → `đây`; かな → Japanese, `nihongo⏎` ra chữ Nhật; 英数 → ABC. `defaults read
    io.github.akachick113.vkey.debug` có khoá cài đặt.
  - (c) Chuỗi UI: menu bar `Giới thiệu VKey`, `Tắt VKey cho TextEdit`, `Thoát VKey`; tiêu đề cửa sổ `VKey — Bộ gõ Tiếng
    Việt`; trang Giới thiệu: `VKey`, `Phát triển bởi akachick113 · © 2026`, dòng ghi công, 3 link mở đúng URL (repo private /
    chưa tạo → 404 là dự kiến, chỉ cần URL đúng). Liệt kê **mọi** mục menu + tiêu đề trang đọc qua Accessibility, xác nhận
    không còn "MKey" / "mkey".
  - (d) Gõ tắt: thêm một mục, bật đồng bộ iCloud (nếu máy bật iCloud Drive) → file nằm ở `iCloud Drive/VKey/VKeyMacroData.bin`;
    xuất danh sách → tên mặc định `VKeyMacro`. Clipboard: copy một ảnh → có thư mục `~/Library/Application
    Support/VKey/clipboard`. Không xoá thư mục cũ `Application Support/MKey`, `iCloud Drive/mkey` (dữ liệu của người dùng).
  - (e) Release universal (lệnh trong `UPDATES.md`) → `scripts/sign-release.sh … build/release-5a` → `PASS: release signatures`;
    `scripts/build-update-feed.sh build/release-5a/VKey.app <notes tạm trong build/> build/update-5a "$BIN"` →
    `Verified release assets`; dán `grep -E 'url=|sparkle:releaseNotesLink|<link>'` (trỏ `akachick113/vkey`, `VKey-1.7.0.zip`);
    `python3 tests/run-update-smoke.py build/update-5a/appcast.xml` → 4 `PASS:`. Xoá `build/update-5a` sau khi ghi.
  - (f) Dọn: thoát VKey Debug; mục đăng nhập / Trợ năng mới để nguyên.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo việc (Conventional Commits tiếng Việt, vd `refactor: đổi tên project và file sang VKey`, `refactor: đổi tiền
tố MK sang VK`, `feat: định danh và chuỗi giao diện VKey`, `chore: script phát hành cho VKey`, `docs: README, NOTICE cho
VKey`). Push nhánh `phase-5a-rename-vkey`, **mở PR vào `main`** và gửi link. Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR; public key mới (khoá công khai).
2. Kết quả (a)–(f).
3. Kết quả 3 lệnh grep / ls-files ở Done khi.
4. Danh sách chỗ sửa trong test (file:dòng, cũ → mới).
5. Chỗ khác prompt và lý do; chỗ **chưa chắc** / chưa kiểm được.
