# Cập nhật VKey bằng Sparkle

VKey dùng Sparkle 2.9.6: kiểm tra định kỳ, giao diện cập nhật trong
ứng dụng, tải gói, xác thực chữ ký, cài đặt và mở lại. Mặc định tự kiểm tra mỗi
24 giờ; tự tải/cài khi thoát là tuỳ chọn, mặc định tắt. Có nút kiểm tra thủ công
trong menu, trang Giới thiệu và Hệ thống. Lựa chọn `autoCheckUpdate` cũ được chuyển
sang Sparkle một lần, bao gồm trường hợp người dùng đã tắt kiểm tra tự động.

## Cấu hình

- Feed: `https://github.com/akachick113/vkey/releases/latest/download/appcast.xml`.
- Kho phát hành: `akachick113/vkey`, tag `v<CFBundleShortVersionString>`.
- Khóa Ed25519 riêng của VKey: tài khoản Keychain `io.github.akachick113.vkey`.
  Public key nằm trong `Sources/Support/Info.plist`; private key không nằm trong repo.
- Cả ZIP, appcast và ghi chú phát hành đều phải có chữ ký hợp lệ. Archive được
  xác thực trước khi giải nén. Không sửa các file sau khi đã ký.
- Bundle id Release: `io.github.akachick113.vkey`; tên **VKey**, file `VKey.app`.
- Release ký Apple Development team `8C4YAMZSGP`, **không có Developer ID, không notarize**.
  Debug ký ad-hoc, bundle id `io.github.akachick113.vkey.debug`, tên **VKey Debug**.
- Chứng chỉ Apple Development hết hạn **2027-08-11**: gia hạn trước bản phát hành kế.
  Chứng chỉ mới cùng CN thì app đã cài vẫn coi là cùng app theo designated requirement
  (chưa kiểm — kiểm ở lần gia hạn đầu). Nếu Keychain có hai chứng chỉ cùng tên,
  `codesign` báo trùng: đặt `VKEY_SIGNING_IDENTITY` bằng SHA-1 của chứng chỉ mới
  từ `security find-identity -v -p codesigning`.
- Chỉ cập nhật app nằm trực tiếp trong `/Applications`, có quyền ghi, không chạy
  từ DMG hay App Translocation. Debug tắt updater trừ khi đặt `VKEY_ENABLE_UPDATES=1`;
  XCTest và SwiftUI previews luôn tắt. Không có feed override trong bản sản xuất.

Sparkle so sánh **CFBundleVersion**, không chỉ số phiên bản hiển thị. Mỗi bản phát
hành phải tăng build và có tag phiên bản mới. Không tái sử dụng phiên bản đã phát hành.

## Tạo bản phát hành

Yêu cầu Xcode, XcodeGen, Python 3, chứng chỉ Apple Development và khoá Sparkle
trong Keychain. Quy trình chỉ tạo file cục bộ; không tự upload hay công bố.

1. **Chuẩn bị** bằng PR thường: tăng `CFBundleShortVersionString` và
   `CFBundleVersion` trong `Sources/Support/Info.plist`, viết
   `docs/releases/<version>.md`, rồi merge vào `main`. Kiểm chứng chỉ còn hạn và
   public key trong Keychain bằng `SUPublicEDKey`:

   ```bash
   security find-identity -v -p codesigning
   security find-certificate -c 'Apple Development: akachick113@gmail.com (BCHZ2Y26CN)' -p | openssl x509 -noout -enddate
   BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin
   "$BIN/generate_keys" --account io.github.akachick113.vkey -p
   /usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' Sources/Support/Info.plist
   ```

   `BIN` trỏ thư mục làm việc trên máy phát hành; không đổi tên thư mục vì Keychain.

2. **Build** từ đúng commit đã merge trên `main`, trong worktree riêng để không
   đổi nhánh ở checkout chính đang làm việc. Thay `<commit>` bằng commit đã merge
   và `<version>` bằng phiên bản đã chuẩn bị trong các bước sau. Các bước 3–5
   chạy trong worktree này; `BIN` vẫn trỏ công cụ Sparkle ở checkout chính:

   ```bash
   RELEASE_CHECKOUT="$(pwd)"
   git fetch origin && git worktree add --detach ../vkey-release-<version> <commit>
   cd ../vkey-release-<version>
   git status --short
   git rev-parse HEAD  # phải là commit cần phát hành
   xcodegen generate
   xcodebuild -project VKey.xcodeproj -scheme VKey -configuration Release \
     -derivedDataPath build/DerivedData ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO build
   ```

3. **Ký** bản sao: helper Sparkle từ SwiftPM vẫn ad-hoc, nên ký từ trong ra ngoài.
   Bản Release chỉ ký bằng chứng chỉ hiện có:

   ```bash
   scripts/sign-release.sh build/DerivedData/Build/Products/Release/VKey.app build/release-<version>
   ```

4. **Kiểm cập nhật cục bộ**: tạo feed ký khoá thật và bản thử `old` có build thấp
   hơn một đơn vị. Thoát Debug và các bộ gõ tiếng Việt khác. Chạy server, chép bản `old` vào `/Applications`, mở và
   cấp Trợ năng cho mục **VKey**. Gõ Telex/JIS trong TextEdit, ghi PID; chọn “Kiểm tra cập nhật…” →
   “Cài đặt và mở lại”. Xác nhận PID đổi, version/build mới, feed GitHub thật,
   chữ ký hợp lệ, gõ tiếp không cần cấp lại Trợ năng; thử かな / 英数. Khi repo còn
   private, kiểm cập nhật lần nữa báo lỗi feed là dự kiến. Dừng khi cập nhật lỗi,
   giữ log để điều tra. Dọn server, app thử và thư mục kiểm cục bộ, giữ mục Trợ năng.
   Bản `old` **không bao giờ phát hành**.

   ```bash
   scripts/prepare-local-update-test.sh build/release-<version>/VKey.app \
     docs/releases/<version>.md build/local-update-<version> "$BIN"
   python3 -m http.server 8765 --bind 127.0.0.1 --directory build/local-update-<version>/feed
   # Trong terminal khác, khi server đang chạy:
   ditto build/local-update-<version>/old/VKey.app /Applications/VKey.app
   open /Applications/VKey.app
   ```

5. **Đóng gói + feed** từ app đã ký. Công cụ kiểm cấu hình, đủ sáu chữ ký,
   archive/feed/notes và việc sửa một byte phải bị từ chối. Công cụ Sparkle phải
   chạy từ đúng thư mục đã được Keychain cho phép (checkout chính ở trên); đường
   dẫn khác có thể hỏi quyền. Nếu có hộp thoại Keychain, dừng để người dùng xử lý.

   ```bash
   scripts/build-update-feed.sh build/release-<version>/VKey.app \
     docs/releases/<version>.md build/update-<version> "$BIN"
   # Từ bản thứ hai: tải feed đang phát hành, truyền làm tham số thứ năm.
   curl -fsSL -o /tmp/previous-appcast.xml https://github.com/akachick113/vkey/releases/latest/download/appcast.xml
   scripts/build-update-feed.sh build/release-<version>/VKey.app \
     docs/releases/<version>.md build/update-<version> "$BIN" /tmp/previous-appcast.xml
   ```

   Công cụ xác thực feed cũ trước khi sử dụng, từ chối build không tăng và lưu
   tối đa năm bản. Các release assets cũ phải còn tồn tại tại URL ban đầu.

6. **Phát hành** do người dùng thực hiện qua web, chỉ khi repo đã **public**.
   Tạo tag trỏ đúng commit đã build rồi push:

   ```bash
   git tag v<version> <commit> && git push origin v<version>
   ```

   GitHub → Releases → Draft a new release → chọn tag, tiêu đề
   `VKey <version>`, nội dung từ `docs/releases/<version>.md`. Đính kèm đủ
   `appcast.xml`, `VKey-<version>.zip`, `VKey-<version>.md` trong
   `build/update-<version>/`, rồi **Publish release** (không prerelease; là latest).
   Không công bố appcast trỏ tới file chưa upload. Không đánh dấu prerelease là
   latest. Không sửa file sau khi ký.

7. **Kiểm sau phát hành**: kiểm chữ ký feed, URL zip trả 200. Tải zip bằng trình
   duyệt, cài theo README (có bước “Vẫn mở”), chọn “Kiểm tra cập nhật…” và xác
   nhận đã mới nhất:

   ```bash
   curl -fsSL -o /tmp/appcast.xml https://github.com/akachick113/vkey/releases/latest/download/appcast.xml
   "$BIN/sign_update" --verify --account io.github.akachick113.vkey /tmp/appcast.xml
   curl -fsSIL https://github.com/akachick113/vkey/releases/download/v<version>/VKey-<version>.zip
   ```

Sau khi kiểm sau phát hành và lưu các gói cần giữ ra ngoài worktree, trở về
checkout chính rồi dọn worktree phát hành:

```bash
cd "$RELEASE_CHECKOUT"
git worktree remove ../vkey-release-<version>
```

Các bản VKey sau cập nhật trong app, quyền Trợ năng giữ nguyên khi cùng chứng chỉ.

Không mất khóa Ed25519: giữ bản sao lưu Keychain an toàn. Không tạo khóa mới để ký
bản kế tiếp nếu không có kế hoạch xoay khóa; app đã cài sẽ từ chối chữ ký khác.

## Kiểm thử

```bash
xcrun swiftc Sources/App/UpdateRuntimePolicy.swift tests/UpdateRuntimePolicyTests.swift \
  -o /tmp/vkey-update-policy-tests
/tmp/vkey-update-policy-tests
python3 tests/release-signature-tests.py
python3 tests/run-update-smoke.py build/update-<version>/appcast.xml
```

Smoke test dùng controller thật và HTTP server loopback, tạo app thử có bundle ID
riêng trong `/Applications`, rồi tự dọn chúng. Kiểm tra: chuyển lựa chọn opt-out
cũ, đã mới nhất, có bản mới, feed bị sửa chữ ký và lỗi HTTP. Cửa sổ Sparkle có thể
xuất hiện trong lúc chạy; smoke test không cài gói và không thay thế VKey đang dùng.
Truyền feed được tạo từ chính Release build đang nằm trong `build/DerivedData`.

Trước khi phát hành công khai, kiểm tra thêm bằng `scripts/prepare-local-update-test.sh` (bước 4): cài bản cũ,
cập nhật lên bản mới, xác nhận relaunch, gõ tiếng Việt và quyền Trợ năng. Đây là
kiểm tra khác với smoke test; không suy ra việc cài/relaunch từ việc đọc feed thành công.

Tài liệu upstream: https://sparkle-project.org/documentation/
