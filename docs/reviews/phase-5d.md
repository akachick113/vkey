# Review Phase 5d — PR #9, nhánh `phase-5d-design-pages` (vòng 1 `5318719`)

## Review lần 1 — `5318719`

**Kết luận: Cần sửa.** 5 mục Phải sửa: (1) formatter làm thụt lề lẫn lộn trên 14 file, (2) bố cục hàng trong thẻ không theo
mẫu `TypingPage`, (3) icon trong bảng lịch sử clipboard bị mất (cùng màu với nền), (4) một chú thích thiếu kiểu chữ, (5) kịch bản
chạy thật còn thiếu phần lớn (Codex tự ghi trong `build/phase-5d-report.md`; PR vẫn là Draft). Model giữ **Sol · Medium**
(vòng 1, chưa có vòng sửa nào sai).

Kiểm tra trên worktree sạch (`git worktree add --detach ../mkey-review 5318719`, `xcodegen generate`, DerivedData mới):
`scripts/check.sh` ✅ — `PASS: 14 update runtime policy checks` · `PASS: 53 engine tests` · `PASS: 8 hotkey key name tests` ·
`PASS: 6 system hotkey conflict tests` · `PASS: 6 release signature tests` · `PASS: 5 keyboard mode tests`. 2 commit Conventional
Commits tiếng Việt ✅. Không đụng `Sources/Engine/`, `Sources/Platform/`, `TypingPage`, giá trị màu `VKTheme`, `.github/`,
`project.yml`, ký, version, `docs/` ✅. Không thêm dependency, không nhúng font ✅.

Đối chiếu prompt:
- Việc 0 ✅ — `PermissionBanner` + `VisualEffectBlur` đã xoá; `HotkeyEditor` cảnh báo dùng `warningIcon` / `warningText`, ô ghi
  `accent` / `card` / `border`; header đủ 6 file, `SettingsRootView` khôi phục ý chú thích sidebar tự dựng; submenu `Bàn phím`
  thêm `.labelsHidden()`; `vkLoginItemInitialized` đổi đủ 2 chỗ, `defaults read io.github.akachick113.vkey.debug
  vkLoginItemInitialized` = `1` ✅ (e).
- Việc 1 — câu chữ: so toàn bộ chuỗi trong 5 trang cũ / mới, chỉ khác đúng các chỗ prompt ghi (nhãn nhóm viết hoa, chú thích
  `TƯƠNG THÍCH NÂNG CAO` mới, bỏ 📌, `Phiên bản x (build)`) ✅. Thứ tự nhóm, alert / `confirmationDialog`, `onChange`, quan hệ
  disabled giữ nguyên ✅. `AppStyle.swift` đã xoá ✅. Chữ hoa / thường dùng popup (5 nhãn không vừa một hàng) — chấp nhận.
  Bố cục hàng: xem Phải sửa 2, 4.
- Việc 2 ✅ code (nền `windowBackground`, icon 96, vòng `accent` 12 %, thẻ `VKCard`, nút `VKPrimaryButtonStyle`, chấm chờ
  `warningIcon` / đã cấp `ok`). Ảnh `welcome-dark.png` là bản trước khi sửa cắt chữ — cần ảnh mới.
- Việc 3 — bỏ blur, nền `card` + viền `border`, hàng chọn `accent`, hover `segmentTrack`, ghim `accent`, bỏ `LinearGradient` ✅;
  `accessibilityLabel` cho nút ghim ✅. Nhưng xem Phải sửa 3.
- Grep 1 ✅ chỉ còn `VKTheme.swift:14` (dịch dòng vì thêm header — đúng). Grep 2: `NSColor.black` / `.white` trong
  `StatusIcon.swift` là code vẽ icon có sẵn, prompt cấm đổi icon → chấp nhận. **Lỗi của prompt:** `git grep -E` không hiểu `\b`
  nên lệnh thứ hai không liệt kê các dòng `.shadow(color: .black…)` — kết quả "sạch" của lệnh này không chứng minh gì; Claude đã
  đọc tay, các chỗ `.black` còn lại đều nằm trong `.shadow(...)` ✅.

Claude **chưa chạy thật** vòng này: bản Debug ở checkout chính (build 13:34 từ đúng `5318719`, đã có quyền Trợ năng) đang chạy,
nhưng mã sẽ đổi nhiều sau Phải sửa 1–3 nên Claude sẽ chạy toàn bộ (a)–(d) ở vòng 2. Vòng này chỉ xem 6 ảnh tối của Codex
(`build/phase-5d-evidence/`) — chúng đủ để thấy Phải sửa 2.

### Phải sửa

**1. Formatter đổi thụt lề / ngắt dòng ngoài phạm vi (quy tắc 14, codebase-map §6 "không thêm formatter; giữ style file").**
Repo thụt 4 dấu cách. Nhánh này có dòng thụt 2 / 6 / 10… dấu cách xen giữa dòng thụt 4, ngay trong một khối (vd `MacroPage`:
`.disabled(!state.useMacro)` thụt 24 dưới `VKSwitchRow` thụt 12; `ClipboardPicker` `.foregroundStyle(...)` lệch so với dòng
trên). Đếm dòng thêm có thụt lề không chia hết cho 4: `ClipboardPicker` 131, `SystemPage` 97, `MacroPage` 54, `HotkeyEditor` 44,
`ClipboardPage` 40, `AboutPage` 35, `VKComponents` 34, `ConvertPage` 32, `WelcomePage` 30, `AppBundleListEditor` 17,
`SettingsRootView` 10, `AppState` 2, `VKeyApp` 1. Ngoài ra formatter ngắt lại các dòng logic không thuộc phase: `MacroCloudSync`
(`coordinate(...)`, `case .downloaded:`), `ClipboardPicker` (`setFrame`, `actualWidth` / `actualHeight`, 4 khối `removeObserver`,
`let iw / ih`), `HotkeyEditor` (bộ ghi phím, `0xFE0000FE` → `0xFE00_00FE`, đảo thứ tự `import`), `AppBundleListEditor`
(`addAppsFromDrop`, `bundleID(for:)`, `name`), `SettingsRootView`, `WelcomePage`, `AboutPage` (`InfoRow(...)`, `Link(...)`).
Diff khó review, dễ che lỗi thật, và làm lệch blame của code upstream.
- Cách sửa: với mỗi file, lấy lại bản `origin/main` rồi áp **chỉ** các thay đổi thực chất (màu / token, bố cục, chuỗi, header,
  khoá), thụt 4 dấu cách theo dòng xung quanh; không ngắt lại dòng cũ, không đổi literal, không đổi thứ tự `import`. File viết
  lại thân (5 trang) cũng thụt 4. `VKComponents` phần thêm mới thụt 4 như phần cũ của file. Không chạy `swift-format` /
  `swiftformat`.
- Kiểm (dán kết quả vào báo cáo):
  `git diff origin/main...HEAD -- Sources/App | grep -E '^\+' | grep -vE '^\+\+\+' | grep -cE '^\+(    )* {1,3}[^ ]'` → `0`;
  `git diff -w --shortstat origin/main...HEAD` và `git diff --shortstat origin/main...HEAD` chênh không quá vài dòng (chỉ những
  dòng đổi thụt lề vì bọc vào `VKCard`); `git diff -w origin/main...HEAD -- Sources/App/Clipboard/ClipboardPicker.swift` chỉ còn
  dòng màu / nền / viền / `accessibilityLabel` / `fontWeight`.

**2. Hàng trong thẻ không theo mẫu `TypingPage` (DESIGN §3, §4).** Mọi thẻ của 5 trang bọc nội dung trong
`VStack(alignment: .leading, spacing: 12) { … }.padding(16)`, trong khi `VKSwitchRow` → `VKRow` đã tự đệm 11 × 16. Hậu quả thấy
trên ảnh của Codex:
- Hàng switch thụt 32 pt, hàng không phải switch thụt 16 pt trong cùng một thẻ (Clipboard: `Tự động ẩn` vs `Kích thước và vị trí
  cửa sổ`; Hệ thống: `Tự động tải…` vs `Phiên bản hiện tại 1.7.0.`; Chuyển mã: `Chuyển đổi` vs `Loại bỏ dấu thanh…`).
- Mỗi hàng cao ~69 pt (11 + control + 11 + 12 + divider + 12) thay vì ~44 pt như trang Bộ gõ; `VKDivider` thụt 32 thay vì 16.
- Thiếu `VKDivider` giữa nhiều hàng: Clipboard (`Bật lịch sử Clipboard` / `Ghim trên cùng`; `Tự động ẩn` / `Kích thước…`),
  Cập nhật (giữa 2 switch và dòng trạng thái), Đồng bộ, Chuyển mã (mọi hàng).
- Chuyển mã: `Từ bảng mã` / `Sang bảng mã` là `Picker` mặc định (nhãn + popup dồn trái, rộng lệch nhau), nút đảo chiều nằm một
  mình trên hàng thứ ba.

Cách sửa: thẻ chứa trực tiếp các hàng, ngăn bằng `VKDivider`, như `TypingPage` — không bọc `VStack(...).padding(16)`:
- switch → `VKSwitchRow`; popup → `VKRow(title: "Từ bảng mã") { Picker(...).labelsHidden().pickerStyle(.menu).frame(width: …) }`
  (hai popup cùng độ rộng; `Chuyển đổi` cũng vậy). Nút đảo chiều đặt trong hàng (vd cạnh popup `Sang bảng mã`, hoặc hàng
  `VKRow(title: "Đảo chiều")` với nút icon bên phải) — giữ `accessibilityLabel("Đảo chiều")`.
- Hàng không phải switch (trạng thái đồng bộ / cập nhật, `Kích thước và vị trí cửa sổ`, `Số mục tối đa` + slider, `Đang lưu N
  mục`, `Khôi phục toàn bộ…`, `HotkeyEditor`, hàng nhập gõ tắt, `Table`) → `VKRow` hoặc `.padding(.vertical, 11).padding(.horizontal,
  16)` để cùng lề 16 với hàng switch.
- `AppBundleListEditor` tự vẽ nền `card` + viền + bo 12 → đang thành thẻ trong thẻ. Bỏ `VKCard` bao ngoài (đặt editor trực tiếp
  dưới `VKSectionLabel`) hoặc bỏ nền / viền của editor khi nằm trong thẻ — chọn một, ghi vào báo cáo.
- Kiểm: ảnh từng trang đặt cạnh ảnh trang Bộ gõ cùng chế độ — lề trái chữ hàng và chiều cao hàng phải giống nhau.

**3. `ClipboardPicker`: icon loại mục biến mất.** Khi thay `Color.white.opacity(…)` bằng `onAccent`, nền ô loại đặc lại:
- Hàng đang chọn: ô loại văn bản / HTML / nhiều file `fill(isSelected ? onAccent : …)` và icon bên trong
  `foregroundStyle(isSelected ? onAccent : …)` → icon trắng trên nền trắng (`ClipboardPicker.swift` ~dòng 683–756, 788–822).
  Thẻ xếp chồng của mục nhiều file cũng thành 3 khối trắng đặc.
- Mục HTML **mọi lúc**: icon `doc.richtext` `foregroundStyle(isSelected ? onAccent : segmentTrack)` trên nền
  `fill(isSelected ? onAccent : segmentTrack)` → không bao giờ thấy icon (~dòng 795–801). DESIGN §10: nhãn loại chữ `textSecondary`.
- Huy hiệu số file: `isSelected ? VKTheme.accent : VKTheme.accent` (hai nhánh như nhau) → trên hàng chọn là khối `accent` trên
  nền `accent`.
- Cách sửa: hàng chọn — nền ô loại `onAccent.opacity(0.16)` (giống độ trong cũ), viền `onAccent.opacity(0.4)`, icon `onAccent`;
  hàng thường — nền `segmentTrack`, viền `keycapBorder`, icon `textSecondary` (cả HTML). Huy hiệu số: hàng chọn nền `onAccent`
  chữ `accent`, hàng thường nền `accent` chữ `onAccent`. Kiểm bằng ảnh (a) có đủ: mục chữ, mục HTML, mục ảnh, mục nhiều file nếu
  tạo được, mục ghim, một hàng đang chọn, một hàng đang rê chuột — sáng và tối.

**4. `SystemPage`: chú thích `TƯƠNG THÍCH NÂNG CAO` thiếu kiểu chữ.** `Text("Khi trang Bộ gõ đang gõ kiểu JIS …")` không có
`.font(.footnote).foregroundStyle(VKTheme.textSecondary)` như các chú thích khác → hiện cỡ 13 màu chữ chính.

**5. Kịch bản chạy thật (Done khi của prompt) còn thiếu.** Báo cáo ghi rõ chưa làm: (a) chỉ có 6 ảnh tối, không có ảnh sáng,
không có ảnh bảng lịch sử clipboard, ảnh Chào mừng là bản trước khi sửa; (b) chưa gõ thử gõ tắt bằng `CGEventPost` type 93, chưa
chuyển mã TCVN3 → Unicode, chưa mở bảng clipboard ⌃V / ↑↓ / Enter / ⌘P, chưa thêm / bỏ app loại trừ; (c) chưa đọc submenu `Bàn
phím` qua Accessibility; (d) chưa Tab / Shift-Tab, VoiceOver mới đọc nút Đảo chiều. Làm đủ trên bản build từ commit cuối, ghi vào
`build/phase-5d-report.md` (ghi đè bản cũ, không để lẫn "trước sửa / sau sửa"), ảnh vào `build/phase-5d-evidence/` với tên
`<màn>-light.png` / `<màn>-dark.png`. Chụp sáng / tối: đổi Giao diện hệ thống, hoặc chạy app với `-AppleInterfaceStyle` — ghi
cách đã dùng. Gõ thử bằng `CGEventPost` chỉ khi người dùng không dùng máy. Xong thì chuyển PR khỏi Draft.

### Nên sửa
1. `AppBundleListEditor` hàng đang chọn đang là `segmentTrack`; prompt ghi `accent` → `VKTheme.accent.opacity(0.16)` (như cũ, chỉ
   đổi sang token).
2. `VKPageContent` / `VKSwitchRow` / `VKPrimaryButtonStyle` thêm vào `VKComponents` — hợp lý, giữ; thêm một dòng chú thích mỗi
   struct như các thành phần cũ của file.

### Ghi nhận (không cần sửa)
- Bảng gõ tắt tắt màu xen kẽ (`.alternatingRowBackgrounds(.disabled)`): `Table` của SwiftUI không cho tô màu hàng theo token →
  chấp nhận nền phẳng; Claude sẽ sửa DESIGN §10 khi chốt phase.
- Hàng đang chọn trong bảng clipboard chữ semibold (`.fontWeight`) — đúng DESIGN §2 (chữ trên `accent` luôn đậm).

### Done khi (vòng 2)
- [ ] Phải sửa 1–5 xong; Nên sửa 1–2 làm hoặc ghi lý do.
- [ ] Lệnh đếm thụt lề ở Phải sửa 1 ra `0`; dán kết quả 2 lệnh `--shortstat`.
- [ ] `scripts/check.sh` pass trên worktree sạch (`14 / 53 / 8 / 6 / 6 / 5`); 2 lệnh grep của prompt (lệnh 1 chỉ còn
      `VKTheme.swift:14`).
- [ ] (a)–(e) đủ theo prompt + Phải sửa 5; báo cáo `build/phase-5d-report.md` viết lại toàn văn; PR hết Draft.

Câu chuyển cho Codex (cùng session): `Đọc docs/reviews/phase-5d.md mục "Review lần 1" và sửa.`

## Review lần 2 — `45d7439` (đọc code; chạy thật để vòng sau)

**Kết luận: Cần sửa — chỉ còn khoảng trắng.** Vòng sửa của Codex (`999c79b` … `45d7439`) đã xong Phải sửa 2, 3, 4 và hai mục Nên
sửa; Phải sửa 1 còn sót. Phải sửa 5 (chạy thật) **chuyển sang Claude** để tiết kiệm hạn mức Codex.

**Đổi model: Luna · High, session Codex mới** (người dùng chọn vì Sol tốn hạn mức; đổi `/model` giữa session Sol cho kết quả lạc
hướng → WORKFLOW §8 đã thêm quy tắc). Việc còn lại là máy móc, Claude đã chạy thử từng bước dưới đây trên worktree review và ra
đúng bảng kết quả ở Bước 4.

Đã kiểm ở `45d7439`:
- Phải sửa 2 ✅ — thẻ chứa trực tiếp `VKSwitchRow` / `VKRow` / `VKDivider`; hàng khác đệm 11 × 16; Chuyển mã: 2 popup cùng rộng
  215 trong `VKRow`, nút đảo chiều trong hàng `Sang bảng mã`; `AppBundleListEditor` không còn thẻ lồng.
- Phải sửa 3 ✅ — ô loại mục hàng chọn `onAccent.opacity(0.16)` + viền `onAccent.opacity(0.4)`; icon HTML `textSecondary`; huy hiệu
  số đảo màu theo hàng chọn.
- Phải sửa 4 ✅. Nên sửa 1 ✅ (`accent.opacity(0.16)`), Nên sửa 2 ✅ (chú thích 3 struct).
- Phải sửa 1 — còn 3 nhóm:
  - **Lỗi của tiêu chí review lần 1:** lệnh "đếm dòng thụt lề không chia hết cho 4" phạt cả dòng nối tiếp căn thẳng hàng theo dấu
    `(`, nên Codex dịch các dòng đó thêm 1 dấu cách cho lọt lệnh đếm → lệch căn ở code ngoài phạm vi: `AppState.swift` (3
    `addObserver`), `VKeyApp.swift` (2 `if let … ,` + 2 `addObserver`), `KeyboardModeStatus.swift` (3 `isWarning:`), `VKTheme.swift`
    (`green:` / `blue:`), và vài dòng trong `ClipboardPicker` / `AboutPage`. Tiêu chí mới (Bước 4) so `--numstat` có / không `-w`.
  - `SettingsRootView.swift`: 3 chỗ ngắt dòng lại code cũ (`NSApp.windows.first(where:)`, `VKSegmented(...)`, `Button { … }`).
  - Mất căn cột trong `switch`: `SystemPage` (`updateStatusText`, `updateIcon`, `updateIconColor`), `MacroPage` / `MacroCloudSync`
    (2 `switch cloudItemState()`); `confirmationDialog` của `SystemPage` gộp nút `Khôi phục mặc định` thành một dòng.
- Thân 4 trang viết lại (Gõ tắt, Chuyển mã, Clipboard, Hệ thống) và `WelcomePage`: thụt 4 đều, chấp nhận như hiện tại.

### Hướng dẫn sửa (cho Luna)

Làm **đúng và chỉ** các bước dưới. Không đổi thân trang, không chạy `swift-format` / `swiftformat`, không sửa file nào ngoài các
file được nêu, không chụp ảnh / gõ thử (Claude làm). Mỗi bước một commit, chỉ `git add <file>`.

**Bước 0 — chuẩn bị**
```bash
git fetch origin
git checkout phase-5d-design-pages
git pull --ff-only origin phase-5d-design-pages
git status --short          # phải trống; HEAD phải là 45d7439
```

**Bước 1 — bỏ thay đổi chỉ-khoảng-trắng ở 11 file** (giữ nguyên mọi thay đổi thật; lệnh chạy bằng `bash`):
```bash
bash -c '
A="Sources/App/AppState.swift Sources/App/VKeyApp.swift Sources/App/KeyboardModeStatus.swift Sources/App/LanguageIndicator.swift Sources/App/StatusIcon.swift Sources/App/Clipboard/ClipboardPicker.swift Sources/App/Views/VKTheme.swift Sources/App/Views/VKComponents.swift Sources/App/Views/HotkeyEditor.swift Sources/App/Views/AppBundleListEditor.swift Sources/App/Views/AboutPage.swift"
git diff -U0 -w origin/main HEAD -- $A > build/phase-5d-ws.patch
git checkout origin/main -- $A
git apply --ignore-whitespace --unidiff-zero build/phase-5d-ws.patch && echo applied
git diff -w --stat HEAD -- $A    # phải KHÔNG in gì (không mất thay đổi thật)
'
```
Không đưa `WelcomePage.swift` và 4 trang vào danh sách này (lệnh làm lệch thụt lề trong thân đã bọc `VKCard`). Commit:
`style: bỏ thay đổi khoảng trắng ngoài phạm vi`.

**Bước 2 — `SettingsRootView.swift`** = bản `origin/main` (116 dòng đầu, tức tới hết `struct SettingsRootView`) + header; xoá
hẳn `PermissionBanner` và `VisualEffectBlur` (dòng 118–161 của bản cũ):
```bash
bash -c '{ printf "//\n//  SettingsRootView.swift\n//  VKey\n//\n//  Settings window: custom sidebar + detail pane. A hand-rolled sidebar avoids\n//  NavigationSplitView drawing its selection row into the titlebar on macOS 26.\n//\n\n"; git show origin/main:Sources/App/Views/SettingsRootView.swift | head -n 116; } > Sources/App/Views/SettingsRootView.swift'
git diff --numstat origin/main -- Sources/App/Views/SettingsRootView.swift   # phải là: 8  45
```
Commit: `style: giữ nguyên định dạng SettingsRootView`.

**Bước 3 — căn cột `switch` và nút trong `confirmationDialog`** (sửa tay, chỉ khoảng trắng / xuống dòng; nội dung giữ y bản hiện
tại). Sau khi sửa, các đoạn phải **đúng từng ký tự** như sau.

`Sources/App/Views/MacroPage.swift`, trong `syncNow()`:
```swift
        switch cloudItemState() {
        case .downloaded:   importFromCloud(force: true)
        case .notDownloaded: startDownload()
        case .missing:      exportToCloud() // first run: seed cloud from this machine
        }
```
và trong `importIfCloudChanged()`:
```swift
        switch cloudItemState() {
        case .downloaded:   importFromCloud(force: false)
        case .notDownloaded: startDownload()
        case .missing:      break // don't auto-overwrite cloud; export only on local change
        }
```
`Sources/App/Views/SystemPage.swift`, cuối `body`:
```swift
        .confirmationDialog("Bạn có chắc chắn muốn thiết lập lại cấu hình mặc định?",
                            isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Khôi phục mặc định", role: .destructive) {
                state.resetToDefaults()
            }
            Button("Huỷ", role: .cancel) {}
        }
```
và 3 thuộc tính cuối file:
```swift
    private var updateStatusText: String {
        switch updater.status {
        case .idle:        return "Phiên bản hiện tại \(updater.currentVersion)."
        case .checking:    return "Đang kiểm tra cập nhật…"
        case .upToDate:    return "Bạn đang dùng bản mới nhất (\(updater.currentVersion))."
        case .available(let info): return "Đã có bản \(info)."
        case .failed(let msg):     return msg
        }
    }

    private var updateIcon: String {
        switch updater.status {
        case .available: return "arrow.down.circle.fill"
        case .failed:    return "exclamationmark.triangle"
        case .upToDate:  return "checkmark.circle"
        default:         return "arrow.triangle.2.circlepath"
        }
    }

    private var updateIconColor: Color {
        switch updater.status {
        case .available, .upToDate: return VKTheme.ok
        case .failed:               return VKTheme.warningIcon
        default:                    return VKTheme.textSecondary
        }
    }
```
Commit: `style: giữ căn cột switch như bản gốc`.

**Bước 4 — kiểm, push, báo cáo**
```bash
scripts/check.sh            # 14 / 53 / 8 / 6 / 6 / 5
bash -c 'git diff --numstat origin/main -- Sources/App | while read a d f; do echo "$a $d | -w $(git diff -w --numstat origin/main -- $f | cut -f1,2 | tr "\t" " ") | $f"; done'
```
Kết quả lệnh thứ hai phải **đúng** bảng này (Claude đã chạy thử):
```text
2 2 | -w 2 2 | Sources/App/AppState.swift
59 58 | -w 59 58 | Sources/App/Clipboard/ClipboardPicker.swift
7 0 | -w 7 0 | Sources/App/KeyboardModeStatus.swift
7 0 | -w 7 0 | Sources/App/LanguageIndicator.swift
7 0 | -w 7 0 | Sources/App/StatusIcon.swift
1 1 | -w 1 1 | Sources/App/VKeyApp.swift
20 32 | -w 20 32 | Sources/App/Views/AboutPage.swift
8 8 | -w 8 8 | Sources/App/Views/AppBundleListEditor.swift
0 30 | -w 0 30 | Sources/App/Views/AppStyle.swift
37 39 | -w 33 35 | Sources/App/Views/ClipboardPage.swift
40 26 | -w 27 13 | Sources/App/Views/ConvertPage.swift
13 13 | -w 13 13 | Sources/App/Views/HotkeyEditor.swift
41 38 | -w 33 30 | Sources/App/Views/MacroPage.swift
8 45 | -w 8 45 | Sources/App/Views/SettingsRootView.swift
71 58 | -w 60 47 | Sources/App/Views/SystemPage.swift
49 0 | -w 49 0 | Sources/App/Views/VKComponents.swift
7 0 | -w 7 0 | Sources/App/Views/VKTheme.swift
31 39 | -w 19 27 | Sources/App/Views/WelcomePage.swift
```
Lệch ở dòng nào → xem lại bước tương ứng, không sửa gì khác để "cho khớp". Xoá `build/phase-5d-ws.patch`. Push nhánh, chuyển PR
khỏi Draft. Báo cáo: **thêm** mục `## Vòng 3 (Luna)` vào cuối `build/phase-5d-report.md` gồm 3 commit, kết quả `check.sh`, bảng
trên — không viết lại các mục cũ, không chụp ảnh.

### Phần chạy thật — Claude làm khi review lần 3
Codex đã chạy được phần lớn (b): thêm / sửa / xoá + gõ `zzphase` bằng `CGEventPost` type 93, TCVN3 → Unicode, ⌃V / ↓ / ⌘P / Enter,
thêm / bỏ app loại trừ, `Cài đặt mặc định` → Huỷ. Claude sẽ làm trên bản Debug build từ commit cuối: (a) ảnh sáng / tối 7 màn
(gồm Chào mừng sáng, bảng clipboard có mục HTML / ảnh / ghim / hàng chọn / hover), (c) đọc submenu `Bàn phím` qua Accessibility,
(d) Tab / Shift-Tab từng trang + VoiceOver nút Đảo chiều / Ghim, chạy lại nhanh (b). Người dùng để máy rảnh vài phút lúc Claude gõ
thử. Lưu ý từ báo cáo Codex: lịch sử clipboard của bản Debug còn 2 mục thử (`TiÕng ViÖt`, `tiếng việt`) — xoá trong bảng lịch sử.

Câu chuyển cho Codex (**session mới**, Luna · High): `Đọc docs/reviews/phase-5d.md mục "Review lần 2" → "Hướng dẫn sửa (cho Luna)" và làm đúng từng bước.`

## Review lần 3 — `90a3e14` (Luna · High, session mới)

**Kết luận: Approved.** Không còn Phải sửa. Ba điểm giao diện nhỏ chuyển vào Còn tồn (một do prompt).

Kiểm tra trên worktree sạch (`git worktree add --detach ../mkey-review 90a3e14`, `xcodegen generate`, DerivedData mới):
`scripts/check.sh` ✅ — `PASS: 14 update runtime policy checks` · `PASS: 53 engine tests` · `PASS: 8 hotkey key name tests` ·
`PASS: 6 system hotkey conflict tests` · `PASS: 6 release signature tests` · `PASS: 5 keyboard mode tests`.
- 3 commit đúng 3 bước hướng dẫn ✅. Bảng `--numstat` có / không `-w` Claude tự chạy lại: **khớp từng dòng** bảng mong đợi ✅.
  `git diff -w 45d7439 90a3e14` chỉ còn `SettingsRootView.swift` (bỏ 3 chỗ ngắt dòng) và nút `Khôi phục mặc định` — đúng phạm vi ✅.
- Luna làm đúng hướng dẫn từng bước, không lan ra file khác → cách "session Luna mới + hướng dẫn chạy thử trước" dùng được.

### Chạy thật (Claude, bản Debug ở checkout chính build từ `90a3e14`, đã có quyền Trợ năng)
Chỉ đọc Accessibility + AXPress chuyển trang, không gửi phím.
- (a) Ảnh sáng / tối của Codex (`build/phase-5d-evidence/`): Gõ tắt, Chuyển mã, Clipboard, Hệ thống, Giới thiệu, bảng lịch sử
  clipboard — khớp DESIGN §10: lề hàng 16 như trang Bộ gõ, đường kẻ đủ, nút chính `accent`, chữ không cắt, Giới thiệu vừa cửa sổ
  không cuộn. Bảng clipboard: hàng chọn nền `accent`, ô loại mục trong mờ thấy rõ icon, ghim `accent`, nhóm `ĐÃ GHIM` ✅. Ảnh có
  lịch sử clipboard thật của người dùng → **không** đính kèm PR (Codex đã không đính kèm — đúng).
- (b) Codex đã chạy (báo cáo vòng 2): thêm / sửa / xoá + gõ `zzphase` bằng `CGEventPost` type 93 → `Xin chào`; TCVN3 → Unicode;
  ⌃V / ↓ / ⌘P / Enter; thêm / bỏ app loại trừ; `Cài đặt mặc định` → Huỷ. Vòng 3 chỉ đổi khoảng trắng → không chạy lại.
- (c) Submenu `Bàn phím` (đọc `AXExtrasMenuBar`): `Tự động`, `JIS (Nhật)`, `Tiếng Anh (US)` — hết dòng tiêu đề ✅, nhưng có 2 dải
  phân cách rỗng đầu / cuối (Còn tồn 1).
- (d) Nhãn Accessibility (thứ VoiceOver đọc), theo thứ tự cây AX = thứ tự Tab: mọi công tắc mang đúng nhãn hàng (`AXCheckBox Bật
  gõ tắt | 1` …), popup `Từ bảng mã` / `Sang bảng mã` / `Chuyển đổi`, nút `Đảo chiều`, slider `Số mục tối đa | 30`, nút `Thêm ứng
  dụng` / `Xóa ứng dụng`, 3 link ✅. Nút ghim trong bảng clipboard có `accessibilityLabel` (Codex đọc AX: `Ghim lên đầu` / `Bỏ ghim`).
- (e) `vkLoginItemInitialized = 1` ✅ (vòng 1).
- Chưa kiểm: ảnh Chào mừng nền sáng (chỉ đổi token, cùng mã với nền tối đã xem); bảng clipboard có mục HTML / ảnh / hover; Tab
  bằng phím thật và nghe VoiceOver → gộp vào lượt kiểm trước phát hành (Phase 6).

### Còn tồn (đề xuất — làm ở Việc 0 phase sau)
1. **Lỗi của prompt:** submenu `Bàn phím` là `Menu { Picker(...).pickerStyle(.inline).labelsHidden() }` → SwiftUI bọc section
   inline bằng 2 dải phân cách. Sửa: bỏ `Menu`, dùng `Picker("Bàn phím", selection: $state.keyboardMode) { … }` như `Kiểu gõ` /
   `Bảng mã` ngay trên (`VKeyApp.swift` ~dòng 114).
2. `SystemPage`: dòng `availabilityNotice` / `Kiểm tra lần cuối` đang căn giữa trong thẻ → thêm
   `.frame(maxWidth: .infinity, alignment: .leading)`.
3. `ConvertPage`: popup `Chuyển đổi` ngắn hơn khung 215 nên lệch khỏi mép phải so với 2 popup bảng mã → `.frame(width: 215,
   alignment: .trailing)` hoặc `.fixedSize()` cho cả ba nhất quán.
4. (có từ trước) 2 ô nhập ở Gõ tắt không có nhãn Accessibility (`labelsHidden()` + prompt) → thêm `accessibilityLabel("Từ tắt")` /
   `("Nội dung thay thế")`.

Người dùng: chuyển PR #9 khỏi Draft (nếu Codex chưa làm) rồi **squash merge**; xoá 2 mục thử `TiÕng ViÖt` / `tiếng việt` trong
lịch sử clipboard.
