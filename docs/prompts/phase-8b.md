# Phase 8b — Phát hành VKey 1.0.2

> Codex · **GPT-6 Luna** · effort **High** (lặp lại đúng 7b, lệnh đã đo trước — WORKFLOW §8; Luna làm sai 1 lần → Sol · Medium,
> session mới) · nhánh `phase-8b-release-1.0.2` · **session Codex mới**

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Phase 7** "✅ Phase 7 xong" — quy trình bản vá; **Phase 8**: "✅ 8a xong", "8b — kế hoạch chi
tiết"), `docs/UPDATES.md` ("Tạo bản phát hành"), `docs/prompts/phase-7b.md` + `docs/reviews/phase-7b.md` (1.0.1 đã làm y hệt).
Repo `akachick113/vkey` (`origin`, public). VKey 1.0.1 (build 3) đang phát hành; 1.0.2 chỉ gồm thay đổi của 8a (tên tác giả ở
Giới thiệu, rút gọn ghi công, công tắc nhỏ). Phase có **hai phần**: Phần A là PR như mọi phase; Phần B làm **sau khi** PR merge
và Claude ghi "Review lần 1" trong `docs/reviews/phase-8b.md` cho phép.

Quy ước đã có, phải theo: `scripts/check.sh`; Conventional Commits tiếng Việt; chỉ `git add <file>`; không chạy formatter.
Không có ca test mới (ca mới từ **80**).

### Hiện trạng đã xem (Claude, `origin/main` @ `daf0d10`, 2026-10-24)
- `Sources/Support/Info.plist`: `CFBundleShortVersionString` `1.0.1`, `CFBundleVersion` `3`. `docs/releases/` có `1.0.0.md`,
  `1.0.1.md`.
- Feed đang phát hành: `https://github.com/akachick113/vkey/releases/latest/download/appcast.xml` — **2 mục** (1.0.1 build 3,
  1.0.0 build 2).
- Claude đã đo trên worktree tạm @ `daf0d10` với đúng thay đổi Phần A: build Release universal (`x86_64 arm64`),
  `sign-release.sh` → `PASS: release signatures (6 components, team 8C4YAMZSGP, universal)`, DR như 1.0.0 / 1.0.1;
  `build-update-feed.sh … "$BIN" <appcast 1.0.1>` → `Wrote 1 new update, updated 0 existing updates, and removed 0 old updates`,
  `PASS: archive, feed, release notes signatures and tamper rejection`, feed **3 mục** (1.0.2 build 4 → `…/download/v1.0.2/…`;
  1.0.1 build 3 và 1.0.0 build 2 giữ URL cũ); smoke 4/4 PASS (`upToDate`, `available`, `failed` × 2). Keychain không hỏi.
- `BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin` — chỉ dùng đúng thư mục này.
- `/Applications/VKey.app` 1.0.1 là bộ gõ hằng ngày của người dùng — **không** đụng tới (kiểm chấp nhận 1.0.1 → 1.0.2 do người
  dùng làm sau khi phát hành). Không có VKey Debug nào cài.

## Phần A — PR version 1.0.2 (build 4)
Một commit: `chore: chuẩn bị phát hành VKey 1.0.2`.
- `Sources/Support/Info.plist`: `CFBundleShortVersionString` → `1.0.2`, `CFBundleVersion` → `4`. Không đổi khoá khác.
  **Sửa dạng văn bản** đúng 2 dòng `<string>1.0.1</string>` → `<string>1.0.2</string>` và `<string>3</string>` →
  `<string>4</string>` ngay dưới hai khoá đó — **không** dùng `PlistBuddy -c Set` / `plutil` / `defaults` để ghi.
  `PlistBuddy -c Print` để kiểm thì được.
- Tạo `docs/releases/1.0.2.md` với **đúng** nội dung sau (giữa hai dòng `---8<---`, không chép hai dòng đó):

---8<---
# VKey 1.0.2

Bản sửa nhỏ cho VKey 1.0.1. Phát hành theo giấy phép GPL v3.

## Thay đổi

- Công tắc trong cửa sổ cài đặt nhỏ gọn hơn.
- Trang Giới thiệu ghi tên tác giả và rút gọn phần ghi công (xem link **Ghi công**).

## Cập nhật

- Đang dùng VKey 1.0.0 hoặc 1.0.1: chọn **Kiểm tra cập nhật…** ở menu VKey trên thanh menu → **Cài đặt và mở lại**. Không cần
  cấp lại quyền Trợ năng.
- Cài mới: tải **VKey-1.0.2.zip** và làm theo mục “Cài đặt & cấp quyền” trong README.

Hỗ trợ **Apple Silicon và Intel**, yêu cầu **macOS 14 trở lên**.
---8<---

Done khi (Phần A):
- [ ] `scripts/check.sh` pass trên worktree sạch: `14 / 53 / 8 / 6 / 6 / 5`. CI xanh.
- [ ] Lệnh sau in **đúng**:
      `bash -c 'git diff --numstat origin/main -- . | while read a d f; do echo "$a $d | -w $(git diff -w --numstat origin/main -- $f | cut -f1,2 | tr "\t" " ") | $f"; done'`
      ```text
      2 2 | -w 2 2 | Sources/Support/Info.plist
      16 0 | -w 16 0 | docs/releases/1.0.2.md
      ```
- [ ] `PlistBuddy` → `1.0.2` / `4`; `docs/releases/1.0.2.md` khớp từng ký tự (`diff` với bản chép từ prompt → rỗng).
- [ ] Push nhánh `phase-8b-release-1.0.2`, **mở PR vào `main` của `origin`**, không Draft. Ghi báo cáo Phần A vào
      `build/phase-8b-report.md` (không commit): tóm tắt, số test, CI, link PR, output `numstat` + `PlistBuddy`.
- Dừng ở đây, chờ người dùng nhắn đã merge.

## Phần B — Build, ký, feed (sau khi PR merge; cùng session)
Chỉ làm khi người dùng nhắn PR đã merge **và** `git show origin/main:docs/reviews/phase-8b.md` có "Review lần 1" Approved.
Không commit, không tag, không upload. Chạy đúng thứ tự, bước nào lệch → dừng, ghi báo cáo.
```bash
BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin
git -C /Users/duc/Developer/mkey fetch origin
MERGE=$(git -C /Users/duc/Developer/mkey rev-parse origin/main)        # commit squash PR — sẽ tag v1.0.2
git -C /Users/duc/Developer/mkey log -1 --format='%h %s' $MERGE         # phải là commit squash của PR Phần A
git -C /Users/duc/Developer/mkey diff --stat <SHA Review lần 1 ghi> $MERGE -- . ':!docs/reviews'   # rỗng
REL=/Users/duc/Developer/vkey-release-1.0.2
git -C /Users/duc/Developer/mkey worktree add --detach $REL $MERGE
cd $REL && git status --short && git rev-parse HEAD                      # rỗng / = MERGE
xcodegen generate
xcodebuild -project VKey.xcodeproj -scheme VKey -configuration Release \
  -derivedDataPath build/DerivedData ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO build
lipo -archs build/DerivedData/Build/Products/Release/VKey.app/Contents/MacOS/VKey   # x86_64 arm64
scripts/sign-release.sh build/DerivedData/Build/Products/Release/VKey.app build/release-1.0.2
codesign -d -r- build/release-1.0.2/VKey.app       # DR như 1.0.0 (PLAN 6c)
codesign -dvvv build/release-1.0.2/VKey.app 2>&1 | grep CDHash=
curl -fsSL -o build/previous-appcast.xml https://github.com/akachick113/vkey/releases/latest/download/appcast.xml
grep -c '<item>' build/previous-appcast.xml                              # 2
scripts/build-update-feed.sh build/release-1.0.2/VKey.app docs/releases/1.0.2.md build/update-1.0.2 "$BIN" \
  build/previous-appcast.xml
diff docs/releases/1.0.2.md build/update-1.0.2/VKey-1.0.2.md && echo notes-ok
grep -E '<title>|sparkle:version>|url=|releaseNotesLink' build/update-1.0.2/appcast.xml | sed 's/sparkle:edSignature="[^"]*"//'
python3 tests/run-update-smoke.py build/update-1.0.2/appcast.xml 2>&1 | grep -E 'PASS|FAIL'   # 4 PASS
ls -l build/update-1.0.2 && shasum -a 256 build/update-1.0.2/*
git status --short                                                       # rỗng
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u \
  build/DerivedData/Build/Products/Release/VKey.app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u \
  build/release-1.0.2/VKey.app
```
Feed phải có đúng **3 mục**: `1.0.2` (build 4, URL `…/download/v1.0.2/VKey-1.0.2.zip`), `1.0.1` (build 3, URL
`…/download/v1.0.1/VKey-1.0.1.zip`) và `1.0.0` (build 2, URL `…/download/v1.0.0/VKey-1.0.0.zip`). `build/update-1.0.2` đúng 3
file `appcast.xml`, `VKey-1.0.2.zip`, `VKey-1.0.2.md`; từ đây **không sửa / tạo lại**. **Không** chạy
`prepare-local-update-test.sh` (quy trình bản vá, PLAN Phase 7). Ghi vào cuối `build/phase-8b-report.md` mục "Phần B": `MERGE`,
output từng lệnh, CDHash, SHA-256 3 file. Giữ worktree `$REL`.

## Không được làm
- Phần A: không sửa file nào ngoài `Info.plist` (2 dòng) và `docs/releases/1.0.2.md`. Không push `main`.
- Phần B: không commit / tag / public / Release / upload; không sửa file trong `build/update-1.0.2` sau khi tạo; không dùng
  công cụ Sparkle ngoài `BIN`; không tạo / xuất khoá Sparkle. Hộp thoại Keychain hiện → dừng, nhờ người dùng.
- Không mở bản VKey vừa build; không thoát / thay `/Applications/VKey.app`; không chạy hai VKey cùng lúc.
- Checkout chính `/Users/duc/Developer/mkey` đang ở nhánh `phase-8a-gioi-thieu-cong-tac` (đã merge): tạo nhánh mới từ
  `origin/main`, không làm tiếp trên nhánh cũ.

## Khi xong
Phần A: trả lời bằng tiếng Việt (tóm tắt, số test, CI, link PR, output `numstat` / `PlistBuddy`, chỗ khác prompt) và ghi vào
`build/phase-8b-report.md`. Phần B: nối báo cáo như trên, trả lời ngắn gồm `MERGE`, CDHash, SHA-256 3 file, kết quả smoke,
chỗ khác prompt / chưa chắc.
