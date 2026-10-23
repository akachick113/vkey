# Phase 4a — Định danh phát hành riêng: MKey JIS

> Codex · **GPT-6 Sol** · effort **Medium** (phần lớn là config / chuỗi / tài liệu đã đặc tả từng dòng, nhưng chạm ~15
> file và phải tự build Release ký thật + dựng feed Sparkle thử — Luna dễ sót file — WORKFLOW §8) · nhánh
> `phase-4a-release-identity`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Quyết định chung**, Phase 0–3 **Quyết định đã chốt**, Phase 3 **Còn tồn**, Phase 4),
`docs/notes/codebase-map.md` (§2, §6, §8, §9), `docs/UPDATES.md`.

Mục tiêu:
1. **Việc 0 — C1 (còn tồn Phase 3):** keycap F1–F20 / mũi tên trong `HotkeyEditor` hiện đúng tên; F17–F20 ghi được.
2. Bản build của dự án này có **định danh riêng** — bundle id, tên app, feed Sparkle, khoá Sparkle, chữ ký Release của chủ
   dự án — để không bao giờ nhận cập nhật / đè lên mkey gốc của `maclifevn`, và README hướng dẫn cài đặt bản JIS (gồm
   gỡ prototype IMK "MKey").

Phase này **không** phát hành: không tag, không GitHub Release, không upload, không notarize, không bump version (4b).

Thông tin phát hành (người dùng chốt 2026-10-22, AGENTS quy tắc 6 cho phép đổi trong phase này):

| Mục | Giá trị |
|---|---|
| Bundle id (Release) | `io.github.akachick113.mkeyjis` |
| Bundle id (Debug) | `io.github.akachick113.mkeyjis.debug` (Claude chọn: tách quyền Trợ năng / UserDefaults của Debug khỏi Release — Phase 3 từng vướng hai bản cùng id khác chữ ký) |
| Tên hiển thị | `MKey JIS` (Debug: `MKey JIS Debug`) |
| File app | `mkey-jis.app` (`PRODUCT_NAME`); target / scheme / project giữ `mkey` |
| Ký Release | chứng chỉ **Apple Development** có sẵn trên máy, team `8C4YAMZSGP`. **Không** có Developer ID → không notarize. Debug giữ ad-hoc |
| Feed Sparkle | `https://github.com/akachick113/mkey-jis/releases/latest/download/appcast.xml` |
| Asset phát hành | `https://github.com/akachick113/mkey-jis/releases/download/v<version>/` |
| Khoá Ed25519 | tài khoản Keychain `io.github.akachick113.mkeyjis` (người dùng tạo, xem "Trước khi giao") |

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; logic thuần Swift là file chỉ `import Foundation` ở
`Sources/App/`, test bằng `xcrun swiftc` trong `check.sh` (mỗi ca một hàm `caseNN_…`); chuỗi UI tiếng Việt theo giọng sẵn
có; Conventional Commits tiếng Việt; chỉ `git add <file>`; **mở PR vào `main` của `origin`** và gửi link. Ca test mới
đánh số từ **62**.

### Trước khi giao (người dùng làm, Codex chỉ kiểm)
Tạo khoá Sparkle trong Keychain của máy (private key **không bao giờ** vào repo):
```bash
build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_keys --account io.github.akachick113.mkeyjis
```
In ra public key. Sao lưu private key ra **ngoài repo** (ổ ngoài / trình quản lý mật khẩu), rồi xoá file tạm:
`generate_keys --account io.github.akachick113.mkeyjis -x <đường dẫn ngoài repo>`. Mất khoá này thì bản đã cài không bao
giờ nhận cập nhật được nữa.

Codex lấy public key bằng `generate_keys --account io.github.akachick113.mkeyjis -p` (chỉ đọc). Lệnh báo không có khoá →
**dừng, hỏi người dùng**; không tự tạo khoá, không dùng `-x` / `-f`.

### Hiện trạng đã xem (Claude, `origin/main` @ `916888c`, máy JIS này, 2026-10-22)
- **C1 — keycap.** `HotkeyKeyName.name(status:)` (`HotkeyKeyName.swift:15`) tra keycode trước cho 102 / 104 / 93 / 94, còn
  lại hiển thị byte cao (ký tự lưu lúc ghi) `.uppercased()`. Byte cao lấy từ `recordedCharacter(keyCode:baseCharacters:)`
  (`:5`) với `characters(byApplyingModifiers: [])` (`HotkeyEditor.swift:320`). Đo bằng `NSEvent(cgEvent:)` (keyboard type
  93, ABC):

  | Phím | keycode | `characters(byApplyingModifiers: [])` | Byte cao lưu | Keycap hiện |
  |---|---|---|---|---|
  | F1–F16 | 122 120 99 118 96 97 98 100 101 109 103 111 105 107 113 106 | U+0010 | 0x10 | ký tự điều khiển (trống) |
  | F17–F20 | 64 79 80 90 | `""` (rỗng) | — | **không ghi được** (`recordedCharacter` → nil → `return event`) |
  | ← → ↓ ↑ | 123 124 125 126 | U+001C U+001D U+001F U+001E | 0x1C–0x1F | ký tự điều khiển (trống) |

  Ví dụ: ghi ⌃F2 lưu `0x10000178` (268435832) → keycap chỉ thấy `⌃`. Engine chỉ dùng byte thấp + bit modifier nên phím
  tắt vẫn chạy; lỗi chỉ ở hiển thị. Phím khác cũng ra ký tự điều khiển (Tab 0x09, Delete 0x08, Esc 0x1B, Home 0x01, End
  0x04, PgUp 0x0B, PgDn 0x0C, Forward Delete 0x7F, Help 0x05) — **ngoài phạm vi** phase này.
- **Định danh hiện tại (của chủ repo gốc):**
  - `project.yml`: `bundleIdPrefix: vn.mkey` (`:3`); Release `CODE_SIGN_IDENTITY: "Developer ID Application"`,
    `DEVELOPMENT_TEAM: CF5PGH3KGK`, chú thích nhắc MFinder (`:23-29`); target `PRODUCT_BUNDLE_IDENTIFIER: vn.mkey.app`,
    `PRODUCT_NAME: mkey` (`:66-67`). Base: `CODE_SIGN_IDENTITY: "-"`, `CODE_SIGN_STYLE: Manual`, `DEVELOPMENT_TEAM: ""`.
  - `Sources/Support/Info.plist`: `CFBundleDisplayName` / `CFBundleName` = `MKey` (`:8`, `:16`); `NSHumanReadableCopyright`
    (`:30`); `SUFeedURL` = `https://github.com/maclifevn/mkey/releases/latest/download/appcast.xml` (`:34`);
    `SUPublicEDKey` = `A5eEoN42…` (`:36`, khoá của chủ repo gốc). Version `1.6.1` / build `13`.
  - `scripts/build-update-feed.sh`: `ACCOUNT` mặc định `vn.mkey.app` (`:9`), kiểm `CFBundleIdentifier == 'vn.mkey.app'`
    (`:26`) và `SUFeedURL` cũ (`:30`), `NAME="mkey-${VERSION}"` (`:62`), `PREFIX` + `--link` trỏ `maclifevn/mkey`
    (`:63`, `:68`).
  - `scripts/verify-update-feed.py`: URL asset phải bắt đầu bằng `https://github.com/maclifevn/mkey/releases/download/v`
    (`:39`); `--account` mặc định `vn.mkey.app` (`:62`).
  - `tests/run-update-smoke.py`: đọc `products / 'mkey.app/Contents/Info.plist'` (`:36`); bundle id app thử
    `vn.mkey.updater-smoke.<uuid>` (`:45`).
  - `scripts/notarize.sh`: identity `Developer ID Application: Anh Tuan Vu Nguyen (CF5PGH3KGK)`, profile `MFinderNotary`,
    `APP="$OUTPUT/mkey.app"` — dùng cho notarize, mà dự án này **không notarize** → không sửa ở 4a (4b quyết).
  - `Sources/App/UpdateChecker.swift`: chuỗi `MKey` (`:56`, `:112`), `NSError(domain: "vn.mkey.updates"` (`:127`).
  - Chuỗi UI có tên app: `MkeyApp.swift:26` (`MKey — Bộ gõ Tiếng Việt`), `:35`, `:77`, `:129`, `:135`;
    `AboutPage.swift:30` (`Text("MKey")`), `:72` (`Phát triển bởi **Anh Tuấn** · © 2026`);
    `SettingsRootView.swift:206`; `WelcomePage.swift:37`, `:60`. Không có chuỗi UI nào viết `mkey` thường.
  - `Bundle.main.bundleIdentifier` dùng động ở `MkeyApp.swift:176`, `:289`, `MKEngineHook.mm:552`, `:566` → không cần sửa.
  - Đường dẫn dữ liệu: ảnh clipboard `~/Library/Application Support/MKey/clipboard` (`ClipboardManager.swift:154`), gõ tắt
    iCloud `iCloud Drive/mkey/` (`MacroPage.swift:252`) — **giữ nguyên** (dùng chung với mkey gốc, hai app không chạy cùng
    lúc).
  - `README.md`: mục Build (`:41-54`) build Release không nói tới chứng chỉ của ai; mục "Cài đặt & cấp quyền" (`:56-67`)
    không nhắc gỡ mkey gốc / prototype IMK. `CONTRIBUTING.md:22` clone `maclifevn/mkey`. `docs/UPDATES.md` mục "Cấu hình"
    (`:9-21`) toàn giá trị của repo gốc; mục "Tạo bản phát hành" dùng `notarize.sh` + `MFinderNotary`.
- **Máy này:** chứng chỉ ký duy nhất `Apple Development: akachick113@gmail.com (BCHZ2Y26CN)`, `OU=8C4YAMZSGP`
  (`security find-identity -v -p codesigning`). Không có Developer ID. Sparkle tools ở
  `build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin/`. Prototype IMK `~/Library/Input Methods/MKey.app`
  (`vn.mkey.inputmethod.MKey`) còn file nhưng **không** còn trong `AppleEnabledInputSources`. Bản mkey gốc 1.6.1
  (`vn.mkey.app`) ở `~/Downloads/mkey.app`.

## Việc 0 — Còn tồn Phase 3

### C1 — Keycap F1–F20 / mũi tên
`Sources/App/HotkeyKeyName.swift`:
- Thêm hàm thuần (dùng chung cho `name` và `recordedCharacter`):
  ```swift
  /// Tên phím theo keycode cho các phím không có ký tự in được; nil = hiển thị theo ký tự lưu ở byte cao.
  static func keyName(keyCode: UInt16) -> String?
  ```
  102 `英数`, 104 `かな`, 93 `¥`, 94 `_` (chuyển từ `switch` hiện có); F1 122, F2 120, F3 99, F4 118, F5 96, F6 97, F7 98,
  F8 100, F9 101, F10 109, F11 103, F12 111, F13 105, F14 107, F15 113, F16 106, F17 64, F18 79, F19 80, F20 90 →
  `"F1"`…`"F20"`; 123 `←`, 124 `→`, 125 `↓`, 126 `↑`.
- `name(status:)`: `if let name = keyName(keyCode: UInt16(value & 0xFF)) { return name }` thay cho `switch`; phần sau giữ
  nguyên. Hotkey chỉ-modifier (byte thấp 0xFE) vẫn nil.
- `recordedCharacter`: thứ tự `keyCode == 49 → 32`; `keyCode >= 0xFE → nil`; **F1–F20 → 0x10** (giống byte F1–F16 đang
  lưu, để F17–F20 có ký tự rỗng vẫn ghi được); còn lại như cũ `baseCharacters?.utf8.first`. Mũi tên vẫn lưu 0x1C–0x1F.
- Không đổi `HotkeyEditor.swift`, `SystemHotkeyConflict.swift`, định dạng bitfield, phím tắt đã lưu. Không thêm tên cho Tab /
  Delete / Esc / Home / End / PgUp / PgDn / Forward Delete / Help (ghi vào báo cáo nếu thấy nên làm).

## Việc 1 — Bundle id, tên app, chữ ký (`project.yml`, `Info.plist`)
- `project.yml`:
  - `options.bundleIdPrefix: io.github.akachick113`.
  - Target `mkey`, `settings.base`: `PRODUCT_BUNDLE_IDENTIFIER: io.github.akachick113.mkeyjis`, `PRODUCT_NAME: mkey-jis`,
    **`PRODUCT_MODULE_NAME: mkey`** (giữ tên module Swift như cũ), `MKEY_APP_DISPLAY_NAME: "MKey JIS"`. Target thêm
    `settings.configs.Debug`: `PRODUCT_BUNDLE_IDENTIFIER: io.github.akachick113.mkeyjis.debug`,
    `MKEY_APP_DISPLAY_NAME: "MKey JIS Debug"`.
  - `settings.configs.Release` (cấp project): `CODE_SIGN_IDENTITY: "Apple Development"`, `DEVELOPMENT_TEAM: 8C4YAMZSGP`;
    giữ `ENABLE_HARDENED_RUNTIME: YES`, `OTHER_CODE_SIGN_FLAGS: "--timestamp"` và mọi dòng tối ưu. Thay chú thích MFinder
    bằng chú thích tiếng Anh ngắn cùng giọng: Release ký bằng chứng chỉ Apple Development của chủ dự án (không có
    Developer ID, không notarize) để quyền Trợ năng giữ nguyên qua các bản cập nhật; Debug vẫn ad-hoc.
  - Base giữ `CODE_SIGN_IDENTITY: "-"`, `DEVELOPMENT_TEAM: ""` → `scripts/check.sh` / CI (Debug) không cần chứng chỉ.
- `Sources/Support/Info.plist`: `CFBundleDisplayName` và `CFBundleName` = `$(MKEY_APP_DISPLAY_NAME)`;
  `NSHumanReadableCopyright` = `Engine © Tuyen Mai (OpenKey, GPL v3). UI mkey 2026. Bản JIS: akachick113.`;
  `SUFeedURL` = feed ở bảng trên; `SUPublicEDKey` = kết quả `generate_keys … -p`. Các khoá `SU*` khác, version / build
  giữ nguyên.
- Không đổi tên target / scheme / `mkey.xcodeproj` (`scripts/check.sh`, CI, AGENTS dùng `-scheme mkey`). Sau khi đổi,
  Debug ra `build/DerivedData/Build/Products/Debug/mkey-jis.app`; `check.sh` không tham chiếu tên `.app` nên không cần sửa
  — kiểm lại bằng `git grep -n 'mkey\.app'`.

## Việc 2 — Script phát hành + chuỗi UI
- `scripts/build-update-feed.sh`: `ACCOUNT` mặc định `io.github.akachick113.mkeyjis`; kiểm `CFBundleIdentifier ==
  'io.github.akachick113.mkeyjis'` và `SUFeedURL` mới; `NAME="mkey-jis-${VERSION}"`;
  `PREFIX="https://github.com/akachick113/mkey-jis/releases/download/v${VERSION}/"`;
  `--link 'https://github.com/akachick113/mkey-jis'`. Không đổi logic kiểm khác.
- `scripts/verify-update-feed.py`: tiền tố URL asset `https://github.com/akachick113/mkey-jis/releases/download/v`;
  `--account` mặc định `io.github.akachick113.mkeyjis`.
- `tests/run-update-smoke.py`: `products / 'mkey-jis.app/Contents/Info.plist'`; bundle id app thử
  `'io.github.akachick113.mkeyjis.updater-smoke.' + uuid…`.
- `Sources/App/UpdateChecker.swift`: `MKey` → `MKey JIS` ở `:56`, `:112`; domain lỗi
  `io.github.akachick113.mkeyjis.updates`.
- Chuỗi UI: `MKey` → `MKey JIS` ở mọi chỗ liệt kê trong Hiện trạng (`MkeyApp.swift`, `AboutPage.swift:30`,
  `SettingsRootView.swift:206`, `WelcomePage.swift:37`, `:60`). Chú thích code giữ nguyên.
- `AboutPage.swift`: giữ dòng `Phát triển bởi **Anh Tuấn** · © 2026` (công tác giả mkey gốc), thêm ngay dưới dòng
  `Bản cho bàn phím JIS: **akachick113**` cùng kiểu chữ. Hàng link thêm `Link("Mã nguồn MKey JIS", …
  "https://github.com/akachick113/mkey-jis")` và `Link("MKey gốc", … "https://github.com/maclifevn/mkey")` cạnh link
  OpenKey / GPL (GPL-3.0: bản phân phối phải chỉ tới mã nguồn). Nếu hàng quá rộng thì xuống hai hàng.

## Việc 3 — README, CONTRIBUTING, UPDATES
- `README.md`:
  - Tiêu đề + đoạn mở đầu: `MKey JIS` là bản mkey (link `maclifevn/mkey`) mở rộng cho **bàn phím JIS + bộ gõ tiếng Nhật
    của macOS**, giữ ghi nguồn OpenKey. Thêm mục ngắn "Khác gì mkey gốc" (3–5 gạch đầu dòng, lấy từ PLAN Phase 1–3: gõ đúng
    ký tự trên bàn phím JIS; かな = Nhật, 英数 = về Latin / đổi Việt ⇄ Anh (tuỳ chọn); 英数 / かな luôn kết thúc từ; cảnh báo
    phím tắt trùng phím tắt macOS). Mục "Có gì mới so với OpenKey" giữ nguyên.
  - Mục Build: lệnh Release giữ, ghi rõ Release ký bằng chứng chỉ Apple Development team `8C4YAMZSGP` của chủ dự án;
    người khác tự build thì dùng Debug (`scripts/check.sh`) hoặc thêm `CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=` vào lệnh
    `xcodebuild`. Sửa đường dẫn kết quả thành `mkey-jis.app`.
  - Mục "Cài đặt & cấp quyền" viết lại, theo thứ tự:
    1. **Thoát và gỡ mkey gốc** (`mkey.app`, `vn.mkey.app`) nếu có — hai bộ gõ event tap chạy cùng lúc sẽ xử lý mỗi phím
       hai lần. Gỡ cả mục "mkey" cũ trong Trợ năng.
    2. **Gỡ prototype Input Method "MKey"** nếu từng cài: Cài đặt hệ thống → Bàn phím → Nguồn nhập → Sửa… → chọn "MKey" →
       nút −; thoát MKey nếu đang chạy; xoá `~/Library/Input Methods/MKey.app`; đăng xuất / đăng nhập lại. Kiểm:
       `defaults read com.apple.HIToolbox AppleEnabledInputSources | grep -i mkey` không in gì.
    3. Tải `mkey-jis-<version>.zip` ở GitHub Releases của `akachick113/mkey-jis`, giải nén, kéo `mkey-jis.app` vào
       **Applications** (cập nhật tự động chỉ chạy khi app nằm trực tiếp trong `/Applications`).
    4. Lần mở đầu: app **chưa notarize** nên macOS chặn → Cài đặt hệ thống → Quyền riêng tư & Bảo mật → "Vẫn mở"; hoặc
       `xattr -dr com.apple.quarantine /Applications/mkey-jis.app`.
    5. Cấp quyền **Trợ năng** cho **MKey JIS** (như các bước 2–3 cũ). Cài đặt bắt đầu từ mặc định (bundle id mới, không
       lấy cài đặt của mkey gốc).
    6. Bộ gõ tiếng Nhật: bật Japanese – Romaji trong Nguồn nhập, **không** cần Input Method nào khác; ⌥Z giữ nguyên,
       tuỳ chọn 英数 / かな ở Bảng điều khiển → Bộ gõ.
  - Chú thích "Chữ ký ứng dụng" cập nhật theo Việc 1; mục "Auto update và phát hành" giữ, link `docs/UPDATES.md`.
- `CONTRIBUTING.md:22`: clone `https://github.com/akachick113/mkey-jis.git`, `cd mkey-jis`. Phần còn lại giữ.
- `docs/UPDATES.md`: mục "Cấu hình" theo bảng ở Bối cảnh (feed, kho `akachick113/mkey-jis`, tag `v<CFBundleShortVersionString>`,
  tài khoản Keychain mới, Release ký Apple Development team `8C4YAMZSGP`, **không notarize**, Debug ad-hoc + bundle id
  `.debug`). Đầu mục "Tạo bản phát hành" thêm một đoạn: bản JIS không có Developer ID nên **bỏ bước `notarize.sh`**; quy
  trình ký helper Sparkle / đóng gói / phát hành sẽ được viết lại ở Phase 4b. Tên file output `mkey-<version>.*` →
  `mkey-jis-<version>.*`. Phần khác giữ.

## Ca test bắt buộc (mỗi ca một hàm riêng trong `tests/HotkeyKeyNameTests.swift`, tên có số ca)
Helper `status(_:_:char:)` có sẵn trong file test.

62. `case62_functionKeyNames`: với cả 20 cặp (keycode, `"F1"`…`"F20"`) ở Việc 0: `name(status(kc, 0x100, char: 0x10))`,
    `name(status(kc, char: 0x00))` và `name(status(kc, 0x100 | 0x8000, char: 0xEF))` đều bằng tên F tương ứng. Thêm
    `name(status: 0x10000178) == "F2"` (⌃F2 đã lưu từ trước).
63. `case63_arrowKeyNames`: `name(status(123, 0x100, char: 0x1C)) == "←"`, `(124, 0x1D) == "→"`, `(125, 0x1F) == "↓"`,
    `(126, 0x1E) == "↑"`; cùng 4 keycode với `char: 0x20` vẫn ra mũi tên.
64. `case64_recordedFunctionAndArrowCharacter`: `recordedCharacter(120, "\u{10}") == 0x10`; `(64, "") == 0x10`;
    `(90, nil) == 0x10`; `(122, "x") == 0x10`; `(123, "\u{1C}") == 0x1C`; `(126, "\u{1E}") == 0x1E`; không đổi:
    `(6, "z") == 0x7A`, `(0, "") == nil`, `(0xFE, "a") == nil`, `(49, nil) == 32`.

Ca 48–51, 55 giữ nguyên expectation (ca 48–50 phải vẫn xanh sau khi chuyển `switch` sang `keyName`).

## Không được làm
- Không tag, tạo GitHub Release, upload, push asset; không đổi visibility repo; không notarize, không sửa
  `scripts/notarize.sh`; không bump `CFBundleShortVersionString` / `CFBundleVersion`.
- Không tạo / xuất / nhập khoá Sparkle (`generate_keys` chỉ dùng `-p`); không commit private key, file khoá, chứng chỉ,
  `.p12`, mật khẩu. Không đổi `SURequireSignedFeed`, `SUVerifyUpdateBeforeExtraction` và các khoá `SU*` khác ngoài
  `SUFeedURL` / `SUPublicEDKey`.
- Không đổi tên target / scheme / project `mkey`; không đổi `PRODUCT_MODULE_NAME` khỏi `mkey`.
- Không đổi đường dẫn dữ liệu (`Application Support/MKey`, `iCloud Drive/mkey`), không viết code chuyển cài đặt từ domain
  `vn.mkey.app`.
- Không sửa `Sources/Engine/`, `Sources/Platform/`, `HotkeyEditor.swift`, `SystemHotkeyConflict.swift`, `.github/`,
  `scripts/check.sh`. Không sửa `AGENTS.md`, `CLAUDE.md`, `docs/PLAN.md`, `docs/PRODUCT_SPEC.md`, `docs/notes/` (Claude cập
  nhật sau khi merge).
- Không xoá / đổi file của người dùng ngoài repo (`~/Library/Input Methods/MKey.app`, `~/Downloads/mkey.app`, mục Trợ năng
  của app khác); không sửa nguồn nhập của macOS.
- Không sửa expectation ca 1–61. Không thêm / nâng dependency. Không push `main`.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `PASS: 14 update runtime policy checks`, `PASS: 50 engine tests`,
      `PASS: 8 hotkey key name tests`, `PASS: 6 system hotkey conflict tests`. CI xanh.
- [ ] Đủ ca 62–64, mỗi ca một test.
- [ ] `git grep -n -E 'maclifevn/mkey/releases|vn\.mkey\.app|CF5PGH3KGK|vn\.mkey\.updates' -- Sources scripts tests
      project.yml README.md CONTRIBUTING.md docs/UPDATES.md` chỉ còn dòng trong `scripts/notarize.sh` (dán kết quả vào báo
      cáo).
- [ ] Kịch bản chạy thật — máy JIS này, input source bật ABC + Japanese – Romaji (**không** chọn Input Method "MKey"),
      mkey gốc (`~/Downloads/mkey.app`) **không** chạy. Ghi kết quả từng mục:
  - (a) Định danh Debug: `plutil -p build/DerivedData/Build/Products/Debug/mkey-jis.app/Contents/Info.plist` →
    `CFBundleIdentifier` `io.github.akachick113.mkeyjis.debug`, `CFBundleName` / `CFBundleDisplayName` `MKey JIS Debug`,
    `CFBundleExecutable` `mkey-jis`, `SUFeedURL` mới, `SUPublicEDKey` = `generate_keys … -p`. `codesign -dv` → ad-hoc.
  - (b) Chạy bản Debug: Trợ năng hiện mục mới **MKey JIS Debug** → cấp quyền (bản build lại thì gỡ mục cũ, thêm lại bằng +).
    TextEdit, Telex: `tieengs vieetj` → `tiếng việt`; trên JIS `ddaay` → `đây`, `[` / `@` gõ ra đúng ký tự; かな sang
    Japanese, `nihongo⏎` → `にほんご`, 英数 về ABC. `defaults read io.github.akachick113.mkeyjis.debug` có các khoá cài
    đặt; domain `vn.mkey.app` không đổi (so `defaults read vn.mkey.app` trước / sau).
  - (c) Chuỗi UI: menu bar có `Giới thiệu MKey JIS`, `Thoát MKey JIS`; cửa sổ cài đặt tiêu đề `MKey JIS — Bộ gõ Tiếng Việt`;
    trang Giới thiệu hiện `MKey JIS`, dòng `Bản cho bàn phím JIS`, 4 link mở đúng URL.
  - (d) C1: ở phím tắt chuyển chế độ ghi ⌃F2 → keycap `⌃F2` (kèm cảnh báo `Chuyển tới thanh menu` của Phase 3); ghi
    ⌃← → `⌃←`. Ghi F17–F20 nếu có bàn phím có phím đó, không thì ghi "không có phím". Cách chắc chắn: thoát app,
    `defaults write io.github.akachick113.mkeyjis.debug SwitchKeyStatus -int 268435832` (⌃F2 lưu kiểu cũ, byte cao 0x10)
    → mở lại → keycap `⌃F2`; `-int 469762427` (⌃←, byte cao 0x1C) → `⌃←`. Trả về ⌥Z (`2046820870`).
  - (e) Release: `xcodebuild -project mkey.xcodeproj -scheme mkey -configuration Release -derivedDataPath build/DerivedData
    build` thành công (Keychain hỏi quyền dùng khoá ký → người dùng bấm "Luôn cho phép"; không được thì ghi lại).
    `codesign -dv --verbose=2 build/DerivedData/Build/Products/Release/mkey-jis.app` → `Authority=Apple Development:
    akachick113@gmail.com (BCHZ2Y26CN)`, `TeamIdentifier=8C4YAMZSGP`, có `runtime`; `codesign --verify --deep --strict` pass;
    `plutil -p` → bundle id `io.github.akachick113.mkeyjis`, tên `MKey JIS`. Ghi thêm `codesign -dv` của
    `Sparkle.framework`, `Autoupdate`, `Updater.app`, `Downloader.xpc`, `Installer.xpc` (ký team hay ad-hoc — dữ liệu
    cho 4b). **Không** chạy / cài bản Release vào `/Applications`.
  - (f) Feed thử (chỉ file cục bộ): ghi một file notes Markdown tạm trong `build/`, chạy
    `scripts/build-update-feed.sh build/DerivedData/Build/Products/Release/mkey-jis.app <notes> build/update-4a
    build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin` → `Verified release assets`; dán
    `grep -E 'url=|sparkle:releaseNotesLink|<link>' build/update-4a/appcast.xml` (phải trỏ `akachick113/mkey-jis`,
    file `mkey-jis-1.6.1.zip`). Nếu chạy được: `python3 tests/run-update-smoke.py build/update-4a/appcast.xml` (tạo / tự
    xoá app thử trong `/Applications`) → 4 dòng `PASS:`. Không upload gì. Xoá `build/update-4a` sau khi ghi kết quả.
  - (g) README: đọc lại mục cài đặt; chạy thử lệnh kiểm `defaults read com.apple.HIToolbox AppleEnabledInputSources |
    grep -i mkey` (máy này phải không in gì). **Không** xoá `~/Library/Input Methods/MKey.app`.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo từng bước (Conventional Commits; Việc 0 commit riêng `fix: …`; định danh `chore: …` / `feat: …`; tài liệu
`docs: …`). Push nhánh `phase-4a-release-identity`, **mở PR vào `main`** và gửi link. Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR; public key đã dùng (khoá công khai, không phải bí mật).
2. Kết quả từng kịch bản (a)–(g); (e) ghi chữ ký từng helper Sparkle; (f) dán đoạn appcast.
3. Kết quả lệnh `git grep` ở Done khi.
4. Chỗ nào khác prompt và lý do.
5. Những chỗ bạn **chưa chắc** hoặc chưa kiểm được (và vì sao) — đặc biệt: Release ký Apple Development có cần
   provisioning profile không, `--timestamp` có chạy với chứng chỉ Apple Development không, helper Sparkle có còn ad-hoc
   trong bản Release không.
