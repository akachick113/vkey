# Bản đồ codebase — maclifevn/mkey

> Khảo sát tại commit `b3c6f61` (nhánh `main`, "MKey 1.6.1"), ngày 2026-10-19. Claude viết ở bước khảo sát, **trước khi
> sửa code**. Prompt các phase sau trích "Hiện trạng" từ file này. Cập nhật khi một phase đổi kiến trúc / lệnh / quy ước.

## 1. Tổng quan
- Bộ gõ tiếng Việt cho macOS 14+ (tối ưu macOS 26). Engine C++ lấy nguyên từ OpenKey, glue ObjC++ dùng **CGEventTap**
  (cần quyền Trợ năng), UI SwiftUI (MenuBarExtra + cửa sổ cài đặt). Có thêm Clipboard manager, gõ tắt (macro), chuyển mã,
  loại trừ ứng dụng, cập nhật qua Sparkle.
- Đang được bảo trì: commit gần nhất 2026-09-21 (1.6.1). Tác giả: `maclifevn` (26 commit), `Theodore` (21 commit).
- Nguồn: **clone làm dự án riêng** (`upstream` = `maclifevn/mkey`, chỉ fetch). License: **GPL-3.0** (kế thừa OpenKey).
  App phát hành bản sửa đổi → phải giữ GPL-3.0 và công bố mã nguồn.

## 2. Stack & môi trường
| Phần | Hiện trạng | Lấy từ đâu |
|---|---|---|
| Ngôn ngữ | Swift 5.9 (UI), ObjC++ (Platform), C++17 (Engine) | `project.yml` |
| Project | XcodeGen 2.46 sinh `mkey.xcodeproj` (không commit) | `project.yml`, `.gitignore` |
| Dependency | Sparkle 2.9.6 (SPM, `exactVersion`) | `project.yml` |
| Toolchain đã chạy | Xcode 27.1 (27A9275), macOS 27.0.1 | máy khảo sát |
| Deployment target | macOS 14.0 | `project.yml` |
| Ký | Debug: ad-hoc. Release: Developer ID team `CF5PGH3KGK` (của chủ repo gốc). **Từ Phase 4a:** Release Apple Development team `8C4YAMZSGP`, bundle id `io.github.akachick113.mkeyjis`, app `mkey-jis.app` | `project.yml` |
| Biến môi trường | `MKEY_ENABLE_UPDATES` (bật updater ở Debug) | `UpdateRuntimePolicy.swift` |

## 3. Lệnh
| Việc | Lệnh | Ghi chú |
|---|---|---|
| Cài | `brew install xcodegen && xcodegen generate` | SPM tự resolve Sparkle |
| Build | `xcodebuild -project mkey.xcodeproj -scheme mkey -configuration Debug -derivedDataPath build/DerivedData build` | Release cần chứng chỉ (từ Phase 4a: Apple Development `8C4YAMZSGP`); ra `mkey-jis.app` |
| Test | `xcrun swiftc Sources/App/UpdateRuntimePolicy.swift tests/UpdateRuntimePolicyTests.swift -o /tmp/mkey-policy && /tmp/mkey-policy` | test duy nhất chạy được không cần khoá ký |
| Smoke updater | `python3 tests/run-update-smoke.py <appcast.xml>` | cần feed ký Ed25519 + bản Release → không đưa vào CHECK_CMD |
| Lint / format | không có | không bật formatter cho cả repo |

**`CHECK_CMD` đề xuất:** `xcodegen generate && xcodebuild … -configuration Debug … build && <policy test>` +
**test engine/JIS mới** (Phase 1 thêm một harness C++/ObjC++ chạy bằng `xcrun clang++`, giống cách test policy đang làm).

## 4. Baseline (cài sạch, chưa sửa gì)
| Lệnh | Kết quả | Ghi chú |
|---|---|---|
| `xcodegen generate` | ✅ | |
| Build Debug | ✅ `BUILD SUCCEEDED` | 2 cảnh báo deprecated `activateIgnoringOtherApps` (ClipboardManager.swift:661, ClipboardPicker.swift:310) |
| Policy test | ✅ 14/14 check | |
| Smoke updater | ⏭ không chạy | cần khoá ký Sparkle |
| CI | ❌ chưa có `.github/` | |

Test đỏ sẵn: không có. **Thiếu hoàn toàn test cho engine / event tap.**

## 5. Cấu trúc & luồng chính
```
Sources/
├── Engine/      C++ OpenKey gốc (Engine.cpp 1709 dòng, Vietnamese.cpp, Macro, SmartSwitchKey, ConvertTool)
│   └── platforms/mac.h   bảng keycode — chỉ có vị trí ANSI
├── Platform/    ObjC++: MKEngineHook.mm (callback CGEventTap, 1230 dòng), MKBridge (facade cho Swift), MKGlobals.h
├── App/         SwiftUI: MkeyApp (menu bar, AppDelegate), AppState (UserDefaults ↔ biến global C), Views/*, Clipboard/*
└── Support/     Info.plist, entitlements, bridging header, Assets
tests/           policy test + smoke updater (Python)
scripts/         icon, build feed Sparkle, notarize
```
- Điểm vào: `MkeyApp.swift` → `MKBridge.startEventTap` → `MKEngineCallback` (`MKEngineHook.mm:989`).
- Luồng gõ: keyDown → (loại trừ app?) → (compat layout: đổi keycode theo ký tự, `MKEngineHook.mm:1030`) → kiểm hotkey
  chuyển ngôn ngữ (`:1043`) → `vLanguage == 0` thì cho qua → `vOtherLanguage` + input source không phải `en` thì cho qua
  (`:1125`) → `vKeyHandleEvent` → gửi backspace + chuỗi Unicode / keycode tổng hợp.
- Trạng thái ngôn ngữ: `vLanguage` (0 Anh / 1 Việt) — **chỉ là trạng thái nội bộ của mkey**, không phải input source
  của macOS. Hotkey là bitfield `vSwitchKeyStatus` (byte thấp = keycode 8 bit, bit 0x100–0x800 = ⌃⌥⌘⇧, 0x8000 = beep,
  byte cao = ký tự hiển thị). Hỗ trợ hotkey chỉ-modifier (vd ⌃⇧).
- Theo dõi input source: `MKUpdateInputSourceCache` (`:115`) — chỉ lấy ngôn ngữ đầu tiên, so `isLike:@"en"`.
- Test: chưa có cho engine.

### 5a. Phân tích riêng cho bàn phím JIS (đã kiểm trên máy này)
Máy khảo sát: `LMGetKbdType() = 93`, layout type `'JIS '` → **bàn phím JIS**. Input source đang bật: `ABC`,
`Kotoeri.RomajiTyping.Japanese`, `vn.mkey.inputmethod.MKey.Telex` (bản prototype IMK, xem §9). Phím tắt hệ thống
⌃Space (60) và ⌃⌥Space (61) đang **bật**.

Bảng ký tự theo keycode (UCKeyTranslate, layout ABC, không Shift / có Shift):

| keycode | ANSI | JIS | Engine hiểu là |
|---|---|---|---|
| 33 | `[` `{` | `@` `` ` `` | `KEY_LEFT_BRACKET` (Telex → ơ) |
| 30 | `]` `}` | `[` `{` | `KEY_RIGHT_BRACKET` (Telex → ư) |
| 42 | `\` `\|` | `]` `}` | — |
| 39 | `'` `"` | `:` `*` | `KEY_QUOTE` |
| 24 | `=` `+` | `^` `~` | `KEY_EQUALS` |
| 19 / 22 | `2@` / `6^` | `2"` / `6&` | số (VNI: dấu) |
| 93 / 94 | — | `¥` / `_` | — |
| 102 / 104 | — | 英数 / かな | — |

Hệ quả:
1. **Tắt "Tương thích bố cục" (mặc định):** trên JIS, gõ `@` ra **ơ**, gõ `[` ra **ư**, gõ `]` không ra gì.
2. **Bật "Tương thích bố cục":** `ConvertKeyStringToKeyCode` (`:920`) ánh xạ theo ký tự kiểu ANSI, nên `@`→`KEY_2`,
   `^`→`KEY_6`, `:`→`KEY_SEMICOLON` (mất Shift). Với **VNI**, gõ `@` / `^` bị hiểu là số 2 / 6 → bỏ dấu sai. Khi engine
   "restore" / gửi lại phím bằng `SendKeyCode(keycode)`, macOS dịch keycode theo layout JIS → `[` gửi lại thành `@`.
3. Cache compat (`_compatKeyCodeCache`) chỉ xoá khi đổi input source, **không** xoá khi đổi bàn phím vật lý (JIS
   built-in ↔ bàn phím ANSI rời) — CGEvent có trường `kCGKeyboardEventKeyboardType` cho từng phím, chưa dùng.
4. Kotoeri: các mode Nhật báo ngôn ngữ `["ja"]` → mkey **tự cho qua** (nhờ `vOtherLanguage = 1` mặc định). Mode 英数
   trong Kotoeri (`…RomajiTyping.Roman`) báo `["en"]` → mkey hoạt động bình thường. Tức là hiện nay: かな = Nhật,
   英数 = Latin (Việt hay Anh tuỳ `vLanguage`), ⌥Z = đổi Việt/Anh. Chưa có cách "đi thẳng" Nhật → Việt bằng một phím.
   **Sửa (đo 2026-10-19, khi viết Phase 2):** "tự cho qua" chỉ đúng khi cache input source mới — `MKEngineInit` đăng ký
   `kTISNotifySelectedKeyboardInputSourceChanged` trên Darwin center, notification này chỉ đến Distributed center, nên
   `_cachedIsEnglishLayout` chỉ được làm mới lúc khởi động và khi đổi app (smart switch). Phase 2 sửa.
5. Engine không biết phím 英数 (102) / かな (104); hotkey lưu keycode 8 bit nên chứa được, nhưng `HotkeyEditor` hiển thị
   bằng ký tự (byte cao) → sẽ hiện ký tự rác cho 2 phím này.

## 6. Quy ước đang dùng
| Mục | Repo đang làm | Kit mặc định | Đề xuất |
|---|---|---|---|
| Commit | Tự do, tiếng Việt, kiểu "MKey 1.6.1: …"; vài commit `perf(engine)+fix:` | Conventional Commits | Conventional Commits, mô tả tiếng Việt (CONTRIBUTING cho phép tự do) |
| Nhánh chính | `main` (+ `dev`, `perf-and-bugfixes`) | `main` / `phase-N-<tên>` | `main`, nhánh `phase-N-<tên>` |
| Merge PR | merge commit (`Merge branch 'dev'`) | squash | squash (nếu là dự án riêng); theo chủ repo nếu gửi PR ngược |
| Ngôn ngữ tài liệu | tiếng Việt | tiếng Việt | tiếng Việt |
| Style / formatter | không có | — | không thêm; giữ style file đang sửa |
| Phiên bản | bump trong Info.plist mỗi bản | — | không bump trong phase tính năng |

## 7. Tài liệu & quy tắc AI sẵn có
| File | Có? | Xử lý |
|---|---|---|
| README / CONTRIBUTING | có | giữ, trích lệnh build |
| AGENTS.md / CLAUDE.md / .cursorrules | không | tạo mới từ kit |
| Template PR / issue | không | dùng `templates/pull_request_template.md` |
| `docs/UPDATES.md`, `docs/releases/` | có | giữ, không đụng trong phase JIS |

## 8. CI / CD hiện tại
Không có CI. Phát hành thủ công: `scripts/build-update-feed.sh`, `scripts/notarize.sh`, GitHub Releases + appcast
Sparkle ký Ed25519 (khoá của chủ repo gốc). Runner GitHub macOS cần Xcode đủ mới để build target macOS 14 + Swift 5.9.

## 9. Nợ kỹ thuật & rủi ro
- Không có test engine → mọi thay đổi ở `MKEngineHook.mm` chỉ kiểm được bằng gõ tay. Phase đầu nên thêm harness test.
- `SUFeedURL`, team ID, khoá Sparkle trỏ về chủ repo gốc. Nếu làm dự án riêng và phát hành: phải đổi bundle id / feed /
  khoá, nếu không bản build của bạn sẽ nhận cập nhật từ repo gốc (ghi đè thay đổi JIS).
- Không thấy bí mật bị commit (`git log -p` không có key / secret).
- **Prototype IMK ngoài repo:** `~/Desktop/ki12026/…/MKeyInputMethod/` (README: "Bản thử nghiệm … MKey 1.5.2 thành Input
  Method chuẩn", ~470 dòng, không có git). Bản build `1.5.2-imk5` đang cài ở `~/Library/Input Methods/MKey.app` và đang
  là input source hiện hành. Thay text bằng `insertText:replacementRange:` theo `selectedRange` — cách này hay hỏng ở
  app không hỗ trợ replacementRange (Terminal, một số app Electron / ô địa chỉ trình duyệt). Không có macro, clipboard,
  bảng mã cũ. Cũng dùng keycode thô → **cùng lỗi JIS ở §5a**.
- Cảnh báo deprecated `activateIgnoringOtherApps` (2 chỗ) — chỉ ghi, không sửa trong phase JIS.

## 10. Câu hỏi cho người dùng
Đã trả lời 2026-10-19:
1. Kiến trúc → **giữ event tap + điều phối input source** (không IMK).
2. Phím → **かな = Nhật, 英数 = về Latin / đổi Việt ⇄ Anh**; ⌥Z giữ nguyên.
3. Nguồn → **clone làm dự án riêng**.
4. Codex → **local trên máy này**.

Còn mở (mặc định đang dùng, đổi thì báo):
5. Bộ gõ Nhật: chỉ Apple Japanese (Kotoeri). Google Japanese Input / ATOK chưa hỗ trợ riêng.
6. Prototype IMK: không đưa vào repo (xem PLAN "Ngoài phạm vi").
7. Quy ước §6: dùng cột "Đề xuất".
