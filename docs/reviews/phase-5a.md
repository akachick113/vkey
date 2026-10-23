# Review Phase 5a — PR #7, nhánh `phase-5a-rename-vkey` (vòng 1 `a3579f4`)

## Review lần 1 — `a3579f4`

**Kết luận: Approved — merge sau khi người dùng gõ thử 1 phút (mục "Trước khi merge").** Không có mục Phải sửa. Phần
đổi tên đúng và đủ; chỉ thiếu bằng chứng gõ bằng phím thật vì công cụ của Codex không đi qua event tap.

Kiểm tra trên worktree sạch (`git worktree add --detach ../mkey-review a3579f4`, DerivedData mới):
`scripts/check.sh` ✅ (build Debug ✅ · `14 / 50 / 8 / 6 / 6`) · CI #43 xanh (theo báo cáo Codex) · 4 commit Conventional
Commits tiếng Việt ✅ · không đụng `Sources/Engine/`, `LICENSE`, `Vendor/`, `.github/`, icon, tài liệu quy trình ✅ · không đổi
version / cấu hình ký / dependency ✅ · không commit khoá / `build/` ✅.

Done khi của prompt:
- `git grep -P '(?<![A-Za-z])MK[A-Z]|MKEY_|Mkey'` (trừ tài liệu quy trình) → **không in gì** ✅.
- `git grep -i -E 'mkey|mkeyjis|mkey-jis'` → chỉ còn: `NOTICE.md:9-10`, `README.md:87` (mục Nguồn gốc), `AboutPage.swift:78`
  (dòng ghi công), `Info.plist:32` (copyright), `CONTRIBUTING.md:43`, `docs/UPDATES.md:45` (đường dẫn máy) ✅ — cộng
  `tests/release-signature-tests.py:35` `dict.fromkeys` (khớp nhầm `mkey` trong `fromkeys`: **lỗi của lệnh grep trong prompt**,
  không tính cho PR).
- `git ls-files | grep -i -E 'mkey|/MK'` → không in gì ✅. `docs/releases/` đã xoá ✅.

**Đối chiếu đổi tên = thuần đổi tên:** Claude lấy cây `origin/main`, đổi tên file + thay `MK…`→`VK…`, `MKEY_`→`VKEY_`,
`MkeyApp`→`VKeyApp`, `MKey JIS`→`VKey`, bundle id / repo / `mkey-jis` cũ → mới bằng script, rồi `diff` với `a3579f4`
(Sources, scripts, tests, project.yml). Phần khác còn lại **chỉ** gồm: header `//  mkey`→`//  VKey`, chú thích, `NSLog`,
tên Swift `mk…`→`vk…` của 4 notification (chuỗi `VK…` khớp), `_mkEngineSuspended`→`_vkEngineSuspended`, FourCC hotkey
clipboard `0x4D4B4559`→`0x564B4559`, đường dẫn dữ liệu (`VKey/clipboard`, `VKeyMacro`, `iCloud Drive/VKey/VKeyMacroData.bin`),
trang Giới thiệu (tác giả, dòng ghi công, 3 link), `Info.plist` (copyright, public key mới), `project.yml`, script / test
theo tên mới. Không có thay đổi logic nào ngoài đổi tên.

Tài liệu ✅ — `NOTICE.md` đủ 3 mục (OpenKey, mkey kèm ghi rõ sửa đổi từ 2026-10, Sparkle); README viết theo VKey, bước cài
không nêu tên bộ gõ khác, Trợ năng "bật **VKey** (tên file app)", mục "Nguồn gốc & giấy phép"; CONTRIBUTING, UPDATES đổi đủ.

## Chạy thật
- (a) ✅ Claude kiểm bản Debug build ở worktree: bundle id `io.github.akachick113.vkey.debug`, `VKey Debug`, executable
  `VKey`, feed `akachick113/vkey`, `SUPublicEDKey` = `fcqb3GZ6HvWXoXM+WpYSukjXRGF0mI0pYmJZTR7WTAE=` (khớp khoá người dùng vừa
  tạo), copyright mới.
- (b) ⚠️ **Chưa có bằng chứng gõ bằng phím thật.** Bản Debug có quyền Trợ năng, báo "Đã sẵn sàng", nhưng công cụ điều khiển
  của Codex gõ ra chuỗi thô `tieengs vieetj` — nhiều khả năng công cụ chèn chữ thẳng vào ô (không đi qua event tap), không
  phải lỗi app. Vì diff chỉ là đổi tên (ở trên) và 50 ca engine ANSI / JIS xanh, rủi ro thấp; người dùng kiểm tay trước merge.
- (c) ✅ (theo bằng chứng Accessibility của Codex) cửa sổ `VKey — Bộ gõ Tiếng Việt`, `Chào mừng đến với VKey`, 6 trang, trang
  Giới thiệu đúng chữ và đúng 3 URL. Menu thanh menu mới kiểm theo mã nguồn.
- (d) ✅ một phần — file gõ tắt ở `iCloud Drive/VKey/VKeyMacroData.bin` (Claude thấy thư mục có thật), tên xuất mặc định
  `VKeyMacro`, thư mục `Application Support/VKey/clipboard` có.
- (e) ✅ Claude chạy lại `verify-release-signature.py` trên `build/release-5a/VKey.app` của Codex → `PASS` (6 thành phần,
  team, universal), bundle id `io.github.akachick113.vkey`; feed trỏ `akachick113/vkey/…/VKey-1.7.0.zip`, smoke 4/4 PASS
  (theo log Codex).

## Trước khi merge (người dùng, ~1 phút)
Mở `/Users/duc/Developer/mkey/build/DerivedData/Build/Products/Debug/VKey.app` (thoát bộ gõ khác nếu có; nếu VKey hỏi quyền
Trợ năng thì bật mục **VKey** — nếu đã có mục cũ mà không chạy, gỡ mục đó bằng − rồi thêm lại). Trong TextEdit gõ bằng bàn phím
thật:
1. `tieengs vieetj` → `tiếng việt`
2. `ddaay` → `đây`
3. かな → gõ `nihongo` rồi Enter → ra chữ Nhật; 英数 → về ABC, gõ `ddaay` → `đây`
4. Menu thanh menu có `Tắt VKey cho TextEdit`, `Thoát VKey` (không còn chữ MKey).
Đúng cả 4 → bấm Ready for review + squash merge. Sai bước nào → báo Claude.

## Còn tồn (đề xuất — người dùng chốt khi merge)
- Khoá UserDefaults `mkLoginItemInitialized` (`AppState.swift:248-249`) còn tiền tố `mk` — prompt bảo giữ khoá; chưa có người
  dùng nên đổi thành `vkLoginItemInitialized` ở 5c cho sạch.
- Prompt sau: lệnh grep tên cũ dùng `-P '(?<![a-z])mkey'` để không khớp `fromkeys`.
