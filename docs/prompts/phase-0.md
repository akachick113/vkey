# Phase 0 — Đưa repo về trạng thái xanh + có chỗ test

> Codex · **GPT-6 Sol** · effort **High** (Phase 0 của repo có sẵn + harness C++ cho engine chưa từng có test — WORKFLOW §8) · nhánh `phase-0-check-ci`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PRODUCT_SPEC.md` (§2, §6.1), `docs/PLAN.md` (Quyết định chung + Phase 0), `docs/notes/codebase-map.md`
(§3 Lệnh, §4 Baseline, §5 Cấu trúc).

Mục tiêu: có một lệnh `scripts/check.sh` build + chạy toàn bộ test, có CI chạy lệnh đó, và có **harness test engine**
cùng bộ test "đặc tả hiện trạng" trên keycode ANSI để Phase 1 (JIS) sửa mà không làm hỏng ANSI. Phase này **không**
làm gì liên quan tới JIS, không sửa engine, không sửa `Sources/Platform/`, không sửa UI.

Quy ước đã có, phải theo: Conventional Commits (mô tả tiếng Việt), nhánh `phase-0-check-ci`, chỉ `git add <file>`,
không commit `mkey.xcodeproj` / `build/`; **mở PR vào `main` của `origin`** (không phải `maclifevn/mkey`) và gửi link.

Hiện trạng đã xem (để bạn khỏi tìm lại):
- Build: `xcodegen generate` rồi `xcodebuild -project mkey.xcodeproj -scheme mkey -configuration Debug -derivedDataPath
  build/DerivedData build` → `BUILD SUCCEEDED` trên Xcode 27.1 / macOS 27.0.1 (2 cảnh báo deprecated
  `activateIgnoringOtherApps` — có sẵn, không sửa).
- Test duy nhất: `tests/UpdateRuntimePolicyTests.swift`, chạy bằng
  `xcrun swiftc Sources/App/UpdateRuntimePolicy.swift tests/UpdateRuntimePolicyTests.swift -o <tmp> && <tmp>` → in
  `PASS: 14 update runtime policy checks`. `tests/run-update-smoke.py` cần feed Sparkle đã ký → **không** đưa vào check.
- Engine (`Sources/Engine/*.cpp`) biên dịch độc lập được bằng `xcrun clang++ -std=c++17 -ISources/Engine`; chỉ thiếu các
  biến cấu hình global (`vLanguage`, `vInputType`, `vCodeTable`, `vCheckSpelling`, `vUseModernOrthography`, … — danh
  sách trong `Sources/Platform/MKGlobals.h`; bản thật định nghĩa ở `Sources/Platform/MKBridge.mm:20-48`). Test phải tự
  định nghĩa các biến này.
- API engine: `vKeyInit()` trả `vKeyHookState*`; mỗi phím gọi `vKeyHandleEvent(vKeyEvent::Keyboard,
  vKeyEventState::KeyDown, keycode, caps /*0, 1=Shift, 2=CapsLock*/, otherControlKey)`; đọc `code`, `backspaceCount`,
  `newCharCount`, `charData[]` (**thứ tự ngược**: duyệt từ `newCharCount-1` về 0, như `MKEngineHook.mm:1209`),
  `vRestore` / `vRestoreAndStartNewSession` thì thêm chính phím vừa gõ. Giá trị có `CHAR_CODE_MASK` / `PURE_CHARACTER_MASK`
  là mã Unicode (bảng mã 0), còn lại là keycode → `keyCodeToCharacter()`. `startNewSession()` để bắt đầu từ mới.
- Mặc định của app (`AppState.registerDefaultSettings`, `AppState.swift:276`): Telex, Unicode, `Spelling=1`,
  `ModernOrthography=0`, `vRestoreIfWrongSpelling` không đăng ký → 0, `UseMacro=1`. Harness dùng đúng các giá trị này
  làm mặc định.
- Tham khảo được (đọc để hiểu, viết lại trong `tests/`, không copy nguyên): adapter + test của prototype IMK ở
  `~/Desktop/ki12026/AWSクラウド演習2（IE3A、SK3A）/MKeyInputMethod/InputMethod/Sources/MKeyEngineAdapter.cpp` và
  `…/Tests/engine_test.cpp` (cùng GPL-3.0). Không đưa thư mục đó vào repo.
- Repo chưa có `.github/` workflow; `.github/pull_request_template.md` đã có (Claude thêm), giữ nguyên.

## Việc 1 — `scripts/check.sh`
- Bash/zsh, `set -euo pipefail`, chạy được từ bất kỳ thư mục nào (tự `cd` về gốc repo).
- Bước: kiểm `xcodegen` có sẵn (thiếu thì báo cách cài và thoát mã ≠ 0) → `xcodegen generate` → build Debug như trên
  (thêm `-quiet`, giữ log lỗi) → policy test → test engine (Việc 2). Mọi file tạm vào `build/tests/`.
- In tóm tắt cuối: số check / test pass của từng phần. Thoát mã ≠ 0 nếu bất kỳ bước nào lỗi.
- `chmod +x`. Cập nhật README mục **Build** thêm 1 dòng `scripts/check.sh`.

## Việc 2 — Harness test engine
- `tests/engine/EngineHarness.{h,cpp}`: định nghĩa các global cấu hình (mặc định như app), hàm reset cấu hình, và hàm
  `type(keys) → std::u16string` mô phỏng một ô text: áp `backspaceCount` + ký tự mới như event tap làm, phím
  `vDoNothing` thì thêm ký tự thô của phím đó. Đầu vào là danh sách `{keycode, caps, ký tự thô}`; có helper đổi chuỗi
  ASCII → phím theo **vị trí ANSI** (bảng keycode trong `Sources/Engine/platforms/mac.h`).
- `tests/engine/EngineTests.cpp`: framework tối giản tự viết (không thêm dependency), mỗi ca một hàm test có tên
  `case01_…`, in `PASS: N engine tests` hoặc tên ca hỏng + giá trị thực / mong đợi (UTF-8), thoát mã ≠ 0 khi hỏng.
- Biên dịch trong `check.sh` bằng `xcrun clang++ -std=c++17 -Wall -ISources/Engine` cùng 5 file `Sources/Engine/*.cpp`.
  Không sửa file nào trong `Sources/Engine/`.

## Việc 3 — CI
- `.github/workflows/ci.yml`: `on: pull_request` + `push` vào `main`; `runs-on: macos-15` (hoặc image macOS mới nhất có
  Xcode ≥ 16; ghi lý do chọn trong PR); `brew install xcodegen`; chạy `scripts/check.sh`; `timeout-minutes: 30`;
  `concurrency` theo `github.ref`. Cache SPM nếu đơn giản (không bắt buộc).
- Build Debug ký ad-hoc (`CODE_SIGN_IDENTITY: "-"`) — không cần chứng chỉ trên CI. Không thêm secret nào.

## Việc 4 — Test
Mỗi ca là **một test riêng**, tên có số ca. Cấu hình mặc định như app trừ khi ghi khác. Kết quả dưới đây Claude đã chạy
thật trên engine tại `b3c6f61` — đây là **đặc tả hiện trạng**, test phải khớp, không sửa engine cho khác đi.
1. Telex `Tieengs Vieetj` → `Tiếng Việt`.
2. Telex `ddawng` → `đăng`.
3. Telex `ddaay` → `đây`.
4. Telex `hoaf` → `hòa` (ModernOrthography = 0).
5. Telex `hoaf` → `hoà` khi `vUseModernOrthography = 1`.
6. Telex `t` + keycode 33 (`KEY_LEFT_BRACKET`) → `tơ`.
7. Telex `t` + keycode 30 (`KEY_RIGHT_BRACKET`) → `tư`.
8. Telex keycode 33 đứng một mình → `ơ`; keycode 30 đứng một mình → `ư` (hai assert trong một ca được).
9. Telex `tesst` → `test` (gõ lặp dấu thì bỏ dấu).
10. VNI `a1` → `á`.
11. VNI `tie6ng1` → `tiếng`.
12. VNI `d9a6y` → `đây`.
13. VNI `a` + Shift+keycode 19 (ký tự thô `@`) → `a@` (số có Shift không thành dấu).
14. VNI `a` + Shift+keycode 22 (ký tự thô `^`) → `a^`.
15. `vLanguage = 0` (Anh): Telex `ddaay` → `ddaay`. Engine **không** tự bỏ qua khi `vLanguage = 0` (Claude đã thử: gọi
    thẳng engine vẫn ra `đây`); event tap mới là chỗ bỏ qua (`MKEngineHook.mm:1099`). Harness mô phỏng đúng chỗ đó:
    `vLanguage = 0` thì không gọi `vKeyHandleEvent`, ghi ký tự thô.
16. Chữ hoa: Telex `DDaay` (Shift ở hai phím đầu) → `Đây`.

## Không được làm
- Không sửa `Sources/Engine/`, `Sources/Platform/`, `Sources/App/`, `project.yml` (trừ khi build trên CI bắt buộc —
  khi đó giải thích trong PR).
- Không làm gì về JIS / かな / 英数 (Phase 1–2).
- Không thêm / nâng dependency; không thêm XCTest target.
- Không đổi ký, bundle id, Sparkle. Không bump version.
- Không sửa expectation của test cũ. Không push `main`.

## Done khi
- [ ] Clone sạch → `brew install xcodegen` → `scripts/check.sh` pass trên máy này; in `PASS: 14 update runtime policy
      checks` và `PASS: 16 engine tests` (hoặc nhiều hơn nếu tách nhỏ, mỗi ca số trên vẫn có tên riêng).
- [ ] CI xanh trên PR (gửi link run).
- [ ] Đủ 16 ca ở Việc 4.
- [ ] Kịch bản chạy thật:
  - (a) `scripts/check.sh` khi thiếu `xcodegen` (tạm đổi `PATH`) → báo lỗi rõ, mã thoát ≠ 0.
  - (b) Làm hỏng tạm một expectation → `check.sh` đỏ, in tên ca + thực / mong đợi; hoàn tác trước khi commit.
  - (c) Mở `build/DerivedData/Build/Products/Debug/mkey.app` một lần (đã cấp quyền Trợ năng), chọn input source ABC, gõ
        `Tieengs Vieetj` trong TextEdit → `Tiếng Việt` (xác nhận build từ `check.sh` chạy được). Không chạy được → ghi lý do.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo từng bước (Conventional Commits). Push nhánh `phase-0-check-ci`, **mở PR vào `main`** và gửi link.
Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả từng kịch bản (a)–(c).
3. Chỗ nào khác prompt và lý do.
4. Những chỗ bạn **chưa chắc** hoặc chưa kiểm được (và vì sao).
