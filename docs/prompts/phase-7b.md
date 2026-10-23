# Phase 7b — Phát hành VKey 1.0.1

> Codex · **GPT-6 Luna** · effort **High** (version + ghi chú ghi sẵn; phát hành chạy đúng lệnh đã đo trước — WORKFLOW §8; Luna
> làm sai 1 lần → Sol · Medium, session mới) · nhánh `phase-7b-release-1.0.1` · **session Codex mới**

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Phase 7**: "✅ 7a xong", "7b — kế hoạch chi tiết"), `docs/UPDATES.md` ("Tạo bản phát hành"),
`docs/reviews/phase-6c.md` (cách 1.0.0 đã làm). Repo `akachick113/vkey` (`origin`, public). VKey 1.0.0 (build 2) đang phát
hành; 1.0.1 chỉ gồm thay đổi của 7a (ẩn nút "Lịch sử phiên bản"). Phase có **hai phần**: Phần A là PR như mọi phase; Phần B
làm **sau khi** PR merge và Claude ghi "Review lần 1" trong `docs/reviews/phase-7b.md` cho phép.

Quy ước đã có, phải theo: `scripts/check.sh`; Conventional Commits tiếng Việt; chỉ `git add <file>`; không chạy formatter.
Không có ca test mới (ca mới từ **80**).

### Hiện trạng đã xem (Claude, `origin/main` @ `2cd2168`, 2026-10-24)
- `Sources/Support/Info.plist`: `CFBundleShortVersionString` `1.0.0`, `CFBundleVersion` `2`. `docs/releases/` chỉ có `1.0.0.md`.
- Feed đang phát hành: `https://github.com/akachick113/vkey/releases/latest/download/appcast.xml` — 1 mục (1.0.0, build 2).
- Claude đã đo trên worktree tạm với Info.plist tạm `1.0.1` / `3`: build Release universal, `sign-release.sh` pass;
  `build-update-feed.sh <app> <notes> <out> "$BIN" <appcast 1.0.0>` → `Wrote 1 new update, updated 0 existing updates, and
  removed 0 old updates in appcast.xml`, `PASS: archive, feed, release notes signatures and tamper rejection`, feed **2 mục**
  (1.0.1 build 3 trỏ `…/download/v1.0.1/VKey-1.0.1.{zip,md}`; 1.0.0 build 2 giữ URL + chữ ký cũ); smoke 4/4 PASS (gồm ca 79).
  Keychain không hỏi.
- `BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin` — chỉ dùng đúng thư mục này.
- `/Applications/VKey.app` 1.0.0 là bộ gõ hằng ngày của người dùng — **không** đụng tới (bước kiểm chấp nhận 1.0.0 → 1.0.1 do
  người dùng làm sau khi phát hành). Không có VKey Debug nào cài.

## Phần A — PR version 1.0.1 (build 3)
Một commit: `chore: chuẩn bị phát hành VKey 1.0.1`.
- `Sources/Support/Info.plist`: `CFBundleShortVersionString` → `1.0.1`, `CFBundleVersion` → `3`. Không đổi khoá khác.
  **Sửa dạng văn bản** đúng 2 dòng `<string>1.0.0</string>` → `<string>1.0.1</string>` và `<string>2</string>` →
  `<string>3</string>` ngay dưới hai khoá đó — **không** dùng `PlistBuddy -c Set` / `plutil` / `defaults` để ghi (Claude thử:
  `PlistBuddy` sắp xếp lại khoá → diff 13/13 thay vì 2/2). `PlistBuddy -c Print` để kiểm thì được.
- Tạo `docs/releases/1.0.1.md` với **đúng** nội dung sau (giữa hai dòng `---8<---`, không chép hai dòng đó):

---8<---
# VKey 1.0.1

Bản sửa nhỏ cho VKey 1.0.0. Phát hành theo giấy phép GPL v3.

## Thay đổi

- Hộp thoại “Bạn đang dùng phiên bản mới nhất!” không còn nút **Lịch sử phiên bản** (nút này tải về tệp ghi chú thay vì
  hiển thị).

## Cập nhật

- Đang dùng VKey 1.0.0: chọn **Kiểm tra cập nhật…** ở menu VKey trên thanh menu → **Cài đặt và mở lại**. Không cần cấp lại
  quyền Trợ năng.
- Cài mới: tải **VKey-1.0.1.zip** và làm theo mục “Cài đặt & cấp quyền” trong README.

Hỗ trợ **Apple Silicon và Intel**, yêu cầu **macOS 14 trở lên**.
---8<---

Done khi (Phần A):
- [ ] `scripts/check.sh` pass trên worktree sạch: `14 / 53 / 8 / 6 / 6 / 5`. CI xanh.
- [ ] Lệnh sau in **đúng**:
      `bash -c 'git diff --numstat origin/main -- . | while read a d f; do echo "$a $d | -w $(git diff -w --numstat origin/main -- $f | cut -f1,2 | tr "\t" " ") | $f"; done'`
      ```text
      2 2 | -w 2 2 | Sources/Support/Info.plist
      16 0 | -w 16 0 | docs/releases/1.0.1.md
      ```
- [ ] `PlistBuddy` → `1.0.1` / `3`; `docs/releases/1.0.1.md` khớp từng ký tự (`diff` với bản chép từ prompt → rỗng).
- [ ] Push nhánh `phase-7b-release-1.0.1`, **mở PR vào `main` của `origin`**, không Draft. Ghi báo cáo Phần A vào
      `build/phase-7b-report.md` (không commit): tóm tắt, số test, CI, link PR, output `numstat` + `PlistBuddy`.
- Dừng ở đây, chờ người dùng nhắn đã merge.

## Phần B — Build, ký, feed (sau khi PR merge; cùng session)
Chỉ làm khi người dùng nhắn PR đã merge **và** `git show origin/main:docs/reviews/phase-7b.md` có "Review lần 1" Approved.
Không commit, không tag, không upload. Chạy đúng thứ tự, bước nào lệch → dừng, ghi báo cáo.
```bash
BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin
git -C /Users/duc/Developer/mkey fetch origin
MERGE=$(git -C /Users/duc/Developer/mkey rev-parse origin/main)        # commit squash PR — sẽ tag v1.0.1
git -C /Users/duc/Developer/mkey log -1 --format='%h %s' $MERGE         # phải là commit squash của PR Phần A
git -C /Users/duc/Developer/mkey diff --stat <SHA Review lần 1 ghi> $MERGE -- . ':!docs/reviews'   # rỗng
REL=/Users/duc/Developer/vkey-release-1.0.1
git -C /Users/duc/Developer/mkey worktree add --detach $REL $MERGE
cd $REL && git status --short && git rev-parse HEAD                      # rỗng / = MERGE
xcodegen generate
xcodebuild -project VKey.xcodeproj -scheme VKey -configuration Release \
  -derivedDataPath build/DerivedData ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO build
lipo -archs build/DerivedData/Build/Products/Release/VKey.app/Contents/MacOS/VKey   # x86_64 arm64
scripts/sign-release.sh build/DerivedData/Build/Products/Release/VKey.app build/release-1.0.1
codesign -d -r- build/release-1.0.1/VKey.app       # DR như 1.0.0 (PLAN 6c)
codesign -dvvv build/release-1.0.1/VKey.app 2>&1 | grep CDHash=
curl -fsSL -o build/previous-appcast.xml https://github.com/akachick113/vkey/releases/latest/download/appcast.xml
scripts/build-update-feed.sh build/release-1.0.1/VKey.app docs/releases/1.0.1.md build/update-1.0.1 "$BIN" \
  build/previous-appcast.xml
diff docs/releases/1.0.1.md build/update-1.0.1/VKey-1.0.1.md && echo notes-ok
grep -E '<title>|sparkle:version>|url=|releaseNotesLink' build/update-1.0.1/appcast.xml | sed 's/sparkle:edSignature="[^"]*"//'
python3 tests/run-update-smoke.py build/update-1.0.1/appcast.xml       # 4 PASS
ls -l build/update-1.0.1 && shasum -a 256 build/update-1.0.1/*
git status --short                                                       # rỗng
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u \
  build/DerivedData/Build/Products/Release/VKey.app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u \
  build/release-1.0.1/VKey.app
```
Feed phải có đúng **2 mục**: `1.0.1` (build 3, URL `…/download/v1.0.1/VKey-1.0.1.zip`) và `1.0.0` (build 2, URL
`…/download/v1.0.0/VKey-1.0.0.zip`). `build/update-1.0.1` đúng 3 file `appcast.xml`, `VKey-1.0.1.zip`, `VKey-1.0.1.md`; từ đây
**không sửa / tạo lại**. **Không** chạy `prepare-local-update-test.sh` (PLAN 7b bước 4: bỏ bước feed cục bộ cho bản vá này).
Ghi vào cuối `build/phase-7b-report.md` mục "Phần B": `MERGE`, output từng lệnh, CDHash, SHA-256 3 file. Giữ worktree `$REL`.

## Không được làm
- Phần A: không sửa file nào ngoài `Info.plist` (2 dòng) và `docs/releases/1.0.1.md`. Không push `main`.
- Phần B: không commit / tag / public / Release / upload; không sửa file trong `build/update-1.0.1` sau khi tạo; không dùng
  công cụ Sparkle ngoài `BIN`; không tạo / xuất khoá Sparkle. Hộp thoại Keychain hiện → dừng, nhờ người dùng.
- Không mở bản VKey vừa build; không thoát / thay `/Applications/VKey.app`; không chạy hai VKey cùng lúc.

## Khi xong
Phần A: trả lời bằng tiếng Việt (tóm tắt, số test, CI, link PR, output `numstat` / `PlistBuddy`, chỗ khác prompt) và ghi vào
`build/phase-7b-report.md`. Phần B: nối báo cáo như trên, trả lời ngắn gồm `MERGE`, CDHash, SHA-256 3 file, kết quả smoke,
chỗ khác prompt / chưa chắc.
