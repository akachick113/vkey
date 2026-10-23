# Review Phase 4a — PR #5, nhánh `phase-4a-release-identity` (vòng 1 `4a39232`, vòng 2 `89915ba`)

## Review lần 1 — `4a39232`

**Kết luận: Cần sửa — 1 mục Phải sửa (lỗi do prompt), 1 mục Nên sửa.** Phần còn lại khớp prompt, chạy thật đạt.

Kiểm tra trên worktree sạch (`git worktree add ../mkey-review 4a39232`, DerivedData mới):
`scripts/check.sh` ✅ (build Debug ✅ · `PASS: 14 update runtime policy checks` · `PASS: 50 engine tests` ·
`PASS: 8 hotkey key name tests` · `PASS: 6 system hotkey conflict tests`) · không đụng `Sources/Engine/`,
`Sources/Platform/`, `HotkeyEditor.swift`, `SystemHotkeyConflict.swift`, `scripts/check.sh`, `scripts/notarize.sh`, `.github/`,
`AGENTS.md`, `docs/PLAN.md` ✅ · không thêm dependency, không bump version, không commit khoá ✅ · ca 48–51, 55 không đổi
expectation ✅ · ca 62–64 đủ, mỗi ca một hàm có số ca ✅ · 3 commit Conventional Commits tiếng Việt, Việc 0 riêng (`fix:`) ✅.
CI: Claude không xem được (repo private) — người dùng kiểm trước khi merge. Không có báo cáo "Khi xong" của Codex trong
tay Claude lúc review; các kịch bản dưới đây Claude tự chạy.

`git grep -n -E 'maclifevn/mkey/releases|vn\.mkey\.app|CF5PGH3KGK|vn\.mkey\.updates' -- Sources scripts tests project.yml
README.md CONTRIBUTING.md docs/UPDATES.md` → `scripts/notarize.sh:7` và `README.md:69`. Dòng README là câu "gỡ mkey gốc
(`mkey.app`, bundle id `vn.mkey.app`)" mà chính prompt Việc 3 yêu cầu — Done khi của prompt tự mâu thuẫn, **không** tính
cho PR.

Đối chiếu prompt từng việc:
- Việc 0 C1 ✅ — `keyName(keyCode:)` đủ 102 / 104 / 93 / 94, F1–F20 đúng 20 keycode, ← → ↓ ↑; `name(status:)` tra
  `keyName` trước; `recordedCharacter` trả 0x10 cho F1–F20 (sau nhánh Space / ≥ 0xFE). Test bắt lỗi tốt — làm hỏng tạm
  3 kiểu: F17 sai tên → đỏ ca 62; bỏ nhánh 0x10 → đỏ ca 64; ↓ sai → đỏ ca 63.
- Việc 1 ✅ — `bundleIdPrefix`, bundle id base / Debug, `PRODUCT_NAME: mkey-jis`, `PRODUCT_MODULE_NAME: mkey`,
  `MKEY_APP_DISPLAY_NAME` base / Debug, Release `Apple Development` + `8C4YAMZSGP`, giữ hardened runtime / `--timestamp`,
  chú thích mới. `Info.plist`: tên = `$(MKEY_APP_DISPLAY_NAME)`, copyright, `SUFeedURL`, `SUPublicEDKey` =
  `t1bjqHBGylWvh0cWk9EAwWC28rEJgmA0pYPb/+TBtjc=` (khớp `generate_keys … -p`); khoá `SU*` khác giữ nguyên.
- Việc 2 ✅ — `build-update-feed.sh`, `verify-update-feed.py`, `run-update-smoke.py`, `UpdateChecker.swift` đúng từng dòng
  prompt; chuỗi `MKey` → `MKey JIS` ở mọi chỗ prompt liệt kê; About thêm dòng bản JIS + 2 link. **Thiếu 6 chuỗi `mkey`
  thường** — prompt ghi sai "không có chuỗi UI nào viết `mkey` thường" (Phải sửa 1).
- Việc 3 ✅ — README (tiêu đề, "Khác gì mkey gốc", Build, 6 bước cài đặt, chú thích chữ ký), CONTRIBUTING, UPDATES (Cấu hình
  + đoạn "bỏ bước `notarize.sh`", tên file `mkey-jis-<version>.*`).

## Chạy thật
Máy JIS này, input source ABC + Japanese – Romaji, không chọn Input Method "MKey", mkey gốc không chạy. Gõ bằng
`CGEventPost` (keyboard type 93) vào TextEdit, đọc lại bằng AppleScript; UI đọc bằng Accessibility + chụp màn hình. Bản
Debug dùng để gõ / xem UI là bản Codex build ở checkout chính (đang chạy, đã có quyền Trợ năng; mã nguồn trùng `4a39232`,
commit cuối chỉ đổi tài liệu). Định danh / chữ ký / feed kiểm trên bản Claude tự build ở worktree.

- (a) ✅ Debug (worktree): `CFBundleIdentifier` `io.github.akachick113.mkeyjis.debug`, `CFBundleName` /
  `CFBundleDisplayName` `MKey JIS Debug`, `CFBundleExecutable` `mkey-jis`, `SUFeedURL` mới, `SUPublicEDKey` khớp Keychain;
  `codesign -dv` → `Signature=adhoc`.
- (b) ✅ Telex `tieengs vieetj` → `tiếng việt`; `ddaay` → `đây`; phím JIS `[` → `ơ` (phím tắt Telex), `@` → `@`; かな →
  Japanese, `nihongo⏎` → `日本語` (chuyển đổi trực tiếp của Kotoeri), 英数 → ABC, `ddaay` → `đây` ngay sau. Cài đặt nằm ở
  domain `io.github.akachick113.mkeyjis.debug`.
- (c) ⚠️ Menu bar: `Giới thiệu MKey JIS`, `Thoát MKey JIS` ✅ nhưng còn **`Tắt mkey cho TextEdit`** (Phải sửa 1). Tiêu đề
  cửa sổ `MKey JIS — Bộ gõ Tiếng Việt` ✅. Trang Giới thiệu: `MKey JIS`, dòng `Bản cho bàn phím JIS: akachick113`, hàng
  link `Mã nguồn MKey JIS` / `MKey gốc` ✅ — nhưng hàng `Mã nguồn OpenKey` / `Giấy phép GPL v3` bị đẩy xuống dưới mép cửa sổ
  ở kích thước mặc định, phải cuộn mới thấy (Nên sửa 1).
- (d) ✅ `defaults write … SwitchKeyStatus -int 268435832` (⌃F2 lưu kiểu cũ, byte cao 0x10) → keycap `⌃` `F2` kèm cảnh báo
  `“Chuyển tới thanh menu”`; `-int 469762427` (⌃←) → `⌃` `←` kèm cảnh báo `“Sang trái một Space”`. Đã xoá khoá, về ⌥Z mặc
  định. Không ghi thử F17–F20 (máy không có phím).
- (e) ✅ Release (worktree) build thành công, **không cần provisioning profile**, Keychain không hỏi. `codesign -dv` →
  `Authority=Apple Development: akachick113@gmail.com (BCHZ2Y26CN)`, `TeamIdentifier=8C4YAMZSGP`, `flags=0x10000(runtime)`,
  có `Timestamp` (`--timestamp` chạy được với chứng chỉ Apple Development); `codesign --verify --deep --strict` pass; tên
  `MKey JIS`, bundle id `io.github.akachick113.mkeyjis`. Dữ liệu cho 4b: `Sparkle.framework` ký team `8C4YAMZSGP`, nhưng
  **`Autoupdate`, `Updater.app`, `Downloader.xpc`, `Installer.xpc` vẫn ad-hoc** (`flags=0x10002(adhoc,runtime)`).
  `spctl --assess` → `rejected` (đúng dự kiến: chưa notarize).
- (f) ✅ `build-update-feed.sh` → `Verified release assets … (version 1.6.1, build 13)`, `PASS: archive, feed, release notes
  signatures and tamper rejection`. Appcast: `<link>https://github.com/akachick113/mkey-jis</link>`, enclosure
  `…/akachick113/mkey-jis/releases/download/v1.6.1/mkey-jis-1.6.1.zip`, notes `…/mkey-jis-1.6.1.md`.
  `run-update-smoke.py` → `PASS: upToDate`, `PASS: available`, `PASS: failed` (tampered), `PASS: failed` (missing); không
  còn app thử trong `/Applications`. Đã xoá thư mục feed thử.
- (g) ✅ `defaults read com.apple.HIToolbox AppleEnabledInputSources | grep -i mkey` không in gì. Không đụng
  `~/Library/Input Methods/MKey.app`.

Ghi nhận (không phải lỗi PR): lần chạy đầu với bundle id mới, macOS báo "Login Item Added: mkey-jis" — app tự đăng ký mở
cùng macOS (hành vi có sẵn, `SMAppService.mainApp`) và mục đăng nhập đó trỏ vào bản Debug trong `build/`. Người dùng có thể
tắt ở Cài đặt hệ thống → Cài đặt chung → Mục đăng nhập, hoặc trong Bảng điều khiển → Hệ thống.

## Phải sửa
1. **Chuỗi UI còn viết `mkey` thường** (lỗi do prompt — mục Hiện trạng ghi sai là không có). Đổi `mkey` → `MKey JIS`, giữ
   nguyên phần còn lại của câu:
   - `Sources/App/MkeyApp.swift:91` — `Tắt mkey cho \(excludeTargetName)` → `Tắt MKey JIS cho \(excludeTargetName)`.
   - `Sources/App/Views/SystemPage.swift:81` — `… menu \u{201C}Tắt mkey cho…\u{201D} …` → `Tắt MKey JIS cho…`.
   - `Sources/App/Views/SystemPage.swift:82` — `(mkey sẽ không xử lý phím …)` → `(MKey JIS sẽ …)`.
   - `Sources/App/Views/SystemPage.swift:87` — `… mkey bỏ qua hoàn toàn …` → `MKey JIS bỏ qua …`.
   - `Sources/App/Views/SystemPage.swift:98` — `Bàn phím JIS được mkey tự nhận …` → `được MKey JIS tự nhận …`.
   - `Sources/App/Views/TypingPage.swift:84` — `Tạm tắt mkey bằng phím ⌘` → `Tạm tắt MKey JIS bằng phím ⌘`.

   Không đổi chú thích code (`AppState.swift:406`…), tên thư mục iCloud `mkey`, tên file `mkeyMacro`. Kiểm bằng
   `git grep -n -P '"[^"]*(?<![\w./-])mkey(?![\w./-])[^"]*"' -- 'Sources/App/*.swift'` → chỉ còn `MacroPage.swift:252`
   (thư mục iCloud). Chạy lại kịch bản (c): menu bar hiện `Tắt MKey JIS cho TextEdit`.

## Nên sửa
1. **Trang Giới thiệu tràn ở kích thước cửa sổ mặc định** (`AboutPage.swift:72-91`): thêm dòng bản JIS + hàng link thứ hai
   đẩy `Mã nguồn OpenKey` / `Giấy phép GPL v3` xuống dưới mép, phải cuộn mới thấy link giấy phép. Gợi ý: gộp 4 link vào
   **một** `HStack(spacing: 16)` (đủ chỗ trong `maxWidth` 620 với cỡ chữ footnote), hoặc đưa `Bản cho bàn phím JIS:
   **akachick113**` vào cùng dòng `Phát triển bởi **Anh Tuấn** · …`. Kiểm: mở Giới thiệu ở cửa sổ mặc định (820 × 560),
   thấy đủ 4 link không cần cuộn.

## Done khi (vòng 2)
- [ ] Phải sửa 1 xong, `git grep` ở trên chỉ còn dòng iCloud; menu bar hiện `Tắt MKey JIS cho …`.
- [ ] (Nên) trang Giới thiệu thấy đủ 4 link không cần cuộn.
- [ ] `scripts/check.sh` vẫn `14 / 50 / 8 / 6`. Commit `fix: …`, push cùng nhánh, không cần chạy lại (a), (e), (f).

Model: giữ **Sol · Medium** (vòng 1 làm đúng phạm vi; lỗi do prompt).

## Review lần 2 — `89915ba`

**Kết luận: Approved.** Phải sửa 1 xong, Nên sửa 1 xong.

Hai commit mới: `37ea479 fix: thống nhất tên MKey JIS và thu gọn trang giới thiệu`, `89915ba fix: giữ đủ liên kết giới
thiệu trong cửa sổ mặc định`; chỉ đụng `MkeyApp.swift`, `AboutPage.swift`, `SystemPage.swift`, `TypingPage.swift`.
Worktree sạch `89915ba`: `scripts/check.sh` ✅ `14 / 50 / 8 / 6`.

- Phải sửa 1 ✅ — đủ 6 chuỗi đổi `mkey` → `MKey JIS`, phần còn lại của câu giữ nguyên.
  `git grep -n -P '"[^"]*(?<![\w./-])mkey(?![\w./-])[^"]*"' -- 'Sources/App/*.swift'` chỉ còn `MacroPage.swift:252`
  (thư mục iCloud) và các dòng `NSLog("mkey: …")` (log, không phải UI). **Chưa nhìn được mục menu `Tắt MKey JIS cho …` khi
  chạy thật:** bản Debug Codex build lại (ad-hoc, mã băm mới) mất quyền Trợ năng nên menu chỉ còn `Cấp quyền Trợ năng…` /
  `Thoát MKey JIS` (tên đúng). Chuỗi là hằng trong `Text(…)`, rủi ro thấp.
- Nên sửa 1 ✅ — 4 link gộp một `HStack`; Codex còn thu gọn trang (icon 104 → 56 pt, chữ tên 32 → 28, giảm khoảng cách
  `InfoRow` / spacer). Kiểm bằng render `AboutPage` ngoài màn hình (`NSHostingView`, 628 × 590 pt = vùng nội dung cửa sổ
  cài đặt mặc định trừ sidebar, nền tối), đối chứng bản `4a39232`: bản cũ cắt ở dòng `Sử dụng engine…` (còn hụt hơn ảnh chụp
  thật vòng 1 khoảng một hàng → ước lượng an toàn), bản mới thấy đủ `Mã nguồn MKey JIS · MKey gốc · Mã nguồn OpenKey · Giấy
  phép GPL v3` và còn trống ~70 pt phía trên chân trang. Thu nhỏ icon là nhiều hơn gợi ý (chỉ gộp link cũng vừa sát mép),
  chấp nhận được — không yêu cầu đổi lại.

Sau khi merge, người dùng cấp lại quyền Trợ năng cho bản Debug mới (gỡ mục "MKey JIS Debug" cũ, thêm lại bằng +) nếu tiếp tục
dùng bản Debug.

## Còn tồn (đề xuất — người dùng chốt khi merge)
- Cho 4b: 4 helper Sparkle (`Autoupdate`, `Updater.app`, `Downloader.xpc`, `Installer.xpc`) vẫn ad-hoc trong bản Release →
  ký lại từ trong ra ngoài bằng Apple Development (thay `notarize.sh`), kiểm `codesign --verify --deep --strict` + cập nhật
  thật bản cũ → mới. `spctl` từ chối là đúng dự kiến (không notarize) — README đã hướng dẫn "Vẫn mở" / `xattr`.
- Nhỏ, ngoài phạm vi 4a: keycap Tab / Delete / Esc / Home / End / PgUp / PgDn / Forward Delete / Help vẫn là ký tự điều khiển
  (trống) trong `HotkeyEditor`.
