# Review Phase 6c — Build, ký, kiểm cập nhật và Gatekeeper VKey 1.0.0

Codex Sol · Medium · prompt [`prompts/phase-6c.md`](../prompts/phase-6c.md) · báo cáo `build/phase-6c-report.md` (không commit)

## Review lần 1 — tài sản `build/update-1.0.0` từ `b296283` + nhánh local `phase-6c-gioi-thieu` @ `84a0a90` (`origin/main` = `f521f12`)

**Kết luận: Cần sửa (3 Phải sửa, đều là tài liệu).** Phần phát hành kỹ thuật **đạt hết**; chỉ còn tài liệu đi kèm. App đã ký và đã kiểm
(`build/release-1.0.0/VKey.app`, CDHash `f873fef1d2348eba81a65ae2a2ef1206785b30d0`) **dùng lại** được; chỉ cần tạo lại feed
với ghi chú phát hành mới.

### Lỗi của prompt
- Điều kiện `git diff --stat b766993 $COMMIT -- . ':!docs'` phải rỗng là sai: chính commit `323ec6e` của 6b sửa `AGENTS.md`,
  `CLAUDE.md` (tài liệu ở gốc repo). Codex dừng đúng và hỏi; người dùng cho ngoại lệ. Lần sau dùng
  `-- Sources project.yml Vendor scripts`.

### Đã kiểm (Claude tự chạy lại)
- Worktree `/Users/duc/Developer/vkey-release-1.0.0` @ `b296283`, sạch. Ba file `build/update-1.0.0` SHA-256 khớp báo cáo
  (`appcast.xml` `f9ea7f74…`, `VKey-1.0.0.zip` `282b5d41…`, `VKey-1.0.0.md` `3afb4c87…`); `sign_update --verify` feed pass;
  `verify-update-feed.py` → `PASS: archive, feed, release notes signatures and tamper rejection`; `VKey-1.0.0.md` = ghi chú phát
  hành ở `b296283`; URL feed `…/releases/download/v1.0.0/VKey-1.0.0.{zip,md}`.
- App ký: universal (`x86_64 arm64`, cả `Autoupdate`), 6 thành phần pass, DR đúng như Hiện trạng; Info.plist `1.0.0` / `2`,
  feed GitHub thật, không còn `NSAppTransportSecurity`. Smoke 4/4 PASS (báo cáo).
- Cập nhật thật `1.0.0-old` (build 1) → `1.0.0` (build 2): PID 25842 → 31871, người dùng gõ Telex / JIS ngay không cấp lại
  Trợ năng; かな / 英数 đạt; kiểm lần nữa → "Lỗi cập nhật! Đã xảy ra lỗi khi lấy thông tin cập nhật…" (repo private — dự kiến).
  Lưu ý: lần cài thật dùng feed thử có ghi chú mới (`local-update-1.0.0-intro`), zip cùng app đã ký — hợp lệ.
- **Gatekeeper thật trên macOS 27.0.1** (zip tải bằng Safari, quarantine `0083;…;Safari;…`, SHA-256 trùng; Safari **tự giải
  nén**): Finder mở → hộp thoại *"VKey" Not Opened — Apple could not verify "VKey" is free of malware…*, nút **Move to Trash** /
  **Done** (không có nút Open) → Done → Cài đặt hệ thống → Quyền riêng tư & Bảo mật → **Open Anyway** → Touch ID → app mở,
  giữ quyền Trợ năng. README bước 3 đúng hướng nhưng thiếu các bước này (Phải sửa 2).
- `/Applications/VKey.app` đang chạy (PID 36249) **chính là** bản ký phát hành: CDHash trùng `build/release-1.0.0/VKey.app`;
  quarantine `01c3;…;Safari` (đã cho phép). Icon do macOS trả về là icon VKey (Còn tồn 6a C2 xong; ô lưới người dùng thấy lúc
  cấp quyền cho bản `old` là cache chưa kịp tạo).
- Keychain không hỏi lần nào.

### Phải sửa
1. **Giữ `NOTICE.md`** (người dùng chốt 2026-10-24 sau khi Claude giải thích). Commit `84a0a90` xoá file này, nhưng:
   app đã ký có nút **Ghi công** ở trang Giới thiệu trỏ `https://github.com/akachick113/vkey/blob/main/NOTICE.md`
   (`AboutPage.swift:80`) → sẽ 404; `README.md:91`, `CONTRIBUTING.md:43` cũng link tới nó; đây là nơi ghi "bản sửa đổi, từ
   2026-10" theo GPL §5a; và `b766993` trên repo đã chứa file nên giữ "ở local" không giấu được gì. → Khôi phục `NOTICE.md` y
   nguyên. Phần rút gọn lời giới thiệu trong `docs/releases/1.0.0.md` ("Phát hành theo giấy phép GPL v3.") **giữ** như người dùng
   muốn.
2. **Bước 3 (Gatekeeper)** trong `README.md` và `docs/releases/1.0.0.md` viết theo đúng luồng macOS 27 đã thấy.
3. **README mục "Nguồn gốc & giấy phép"** — người dùng sửa trên web (`f521f12`, 01:54) để bỏ chữ mkey, còn lại câu cụt
   "VKey là bản sửa đổi dựa trên engine [OpenKey](…)" không dấu chấm, không còn link `LICENSE` / `NOTICE.md`. Viết lại thành
   một câu đủ: vẫn **không** nhắc mkey trong README (ý người dùng), giữ giấy phép và trỏ `NOTICE.md` (ghi công đầy đủ, gồm mkey).

### Hướng dẫn sửa (Codex, cùng session, nhánh `phase-6c-gioi-thieu`)
1. `git checkout b296283 -- NOTICE.md` (nội dung y nguyên `build/NOTICE.private.md`; kiểm `cmp`), rồi xoá
   `build/NOTICE.private.md`.
2. `README.md`, thay **cả** bước 3 bằng (giữ thụt 3 dấu cách ở dòng nối):
   ```text
   3. App **chưa notarize**, nên lần mở đầu macOS báo **“VKey” không được mở** (“VKey” Not Opened): bấm **Xong** (Done),
      vào Cài đặt hệ thống → Quyền riêng tư & Bảo mật, cuối mục **Bảo mật** bấm **Vẫn mở** (Open Anyway) cạnh dòng về VKey,
      rồi xác thực bằng Touch ID hoặc mật khẩu. Hoặc chạy `xattr -dr com.apple.quarantine /Applications/VKey.app` trước
      khi mở.
   ```
3. `docs/releases/1.0.0.md`, thay **cả** bước 3 bằng:
   ```text
   3. App **chưa notarize**: lần mở đầu macOS báo **“VKey” không được mở** — bấm **Xong**, vào Cài đặt hệ thống → Quyền
      riêng tư & Bảo mật → mục Bảo mật → **Vẫn mở** rồi xác thực Touch ID / mật khẩu; hoặc chạy
      `xattr -dr com.apple.quarantine /Applications/VKey.app` trước khi mở.
   ```
   Không đổi dòng nào khác của hai file (ngoài dòng giới thiệu đã sửa ở `84a0a90`).
4. `git fetch origin && git rebase origin/main` (nhánh phải nằm trên `f521f12`; không xung đột vì `84a0a90` không chạm
   README). `README.md`, thay dòng duy nhất dưới `## Nguồn gốc & giấy phép` bằng:
   ```text
   VKey là bản sửa đổi dựa trên engine [OpenKey](https://github.com/tuyenvm/OpenKey) (© Tuyen Mai), phát hành theo
   [GPL-3.0](LICENSE); ghi công đầy đủ tại [NOTICE.md](NOTICE.md).
   ```
5. Gộp thành **một** commit trên nhánh (sửa lại `84a0a90` bằng `git commit --amend` hoặc thêm commit — tuỳ, miễn diff cuối
   so với `origin/main` đúng như dưới), `scripts/check.sh` pass, push nhánh, **mở PR #1 vào `main` của `origin`
   (`akachick113/vkey`)**, gửi link. Diff cuối phải là:
   `git diff --stat origin/main` → chỉ `README.md` và `docs/releases/1.0.0.md`; `git diff origin/main -- NOTICE.md` rỗng.
6. **Không** đụng `build/update-1.0.0`, `build/release-1.0.0`, worktree phát hành; chưa tạo feed mới (làm sau khi merge).

### Sau khi PR #1 merge (Codex, cùng session — Claude sẽ ghi lệnh chính xác ở review lần 2)
Tạo lại feed từ **app đã ký sẵn** với ghi chú mới vào thư mục mới `build/update-1.0.0-r2` (không build lại app: điều kiện
`git diff --stat b296283 <commit merge> -- Sources project.yml Vendor scripts` rỗng), `verify-update-feed.py` + smoke, chuyển
`build/update-1.0.0` cũ vào Thùng rác. Tag `v1.0.0` trỏ commit merge.

### Còn tồn (không chặn phát hành)
- 6a C3 (Chào mừng nền sáng; bảng clipboard HTML / ảnh / hover; Tab + VoiceOver) chưa kiểm — chuyển sang kiểm sau phát hành
  trên bản cài từ GitHub.
- Quy trình: Codex nhận yêu cầu mới của người dùng giữa phase (sửa tài liệu, commit trên nhánh ở checkout chính) — đã ghi rõ
  trong báo cáo; chấp nhận như ngoại lệ người dùng cho.
