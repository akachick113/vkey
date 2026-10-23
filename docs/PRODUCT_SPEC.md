# VKey — Đặc tả sản phẩm

> VKey (đổi tên từ "mkey bản JIS" ở Phase 5a) — dự án riêng clone từ [maclifevn/mkey](https://github.com/maclifevn/mkey) @ `b3c6f61` (1.6.1), GPL-3.0. Phần mô tả
> hành vi hiện có suy ra từ code (`docs/notes/codebase-map.md`). Mục đánh **(suy ra — cần xác nhận)** chưa được người
> dùng xác nhận.

## 1. Mục tiêu
mkey là bộ gõ tiếng Việt chạy bằng CGEventTap trên macOS. Bản này giữ toàn bộ tính năng của mkey và thêm hỗ trợ cho
người dùng **bàn phím JIS** có bật bộ gõ tiếng Nhật của macOS: gõ Telex/VNI đúng trên layout JIS, và chuyển nhanh
Nhật / Việt / Anh bằng phím かな / 英数 sẵn có trên bàn phím, không thêm tổ hợp trùng với phím tắt hệ thống.

## 2. Phạm vi
- **Có:**
  - Mọi tính năng hiện có của mkey 1.6.1 (Telex/VNI, 5 bảng mã, gõ tắt, chuyển mã, nhớ chế độ theo app, loại trừ app,
    clipboard, menu bar) — giữ nguyên hành vi trên bàn phím ANSI/ISO.
  - Gõ đúng trên bàn phím JIS (§6.1).
  - Phím かな / 英数 điều phối Nhật ⇄ Việt ⇄ Anh (§6.2).
  - Cảnh báo khi hotkey trùng phím tắt đang bật của macOS (Phase 3, §6.3).
- **Không (bản này):**
  - Không chuyển sang Input Method (InputMethodKit). Prototype IMK ngoài repo không đưa vào.
  - Không tự viết bộ gõ tiếng Nhật; tiếng Nhật luôn do bộ gõ của macOS (Kotoeri) xử lý.
  - Không sửa engine C++ trừ khi một phase giao rõ.
  - Không đổi bundle id / feed Sparkle / chữ ký cho tới phase Phát hành.
- **Nền tảng:** macOS 14+ · **Ngôn ngữ giao diện:** tiếng Việt (như hiện tại).

## 3. Khái niệm & dữ liệu
- **Input source của macOS:** ABC (Latin) hoặc Japanese (Kotoeri, các mode かな / カナ / Roman…). Do macOS quản lý.
- **Trạng thái ngôn ngữ của mkey (`vLanguage`):** Việt / Anh. Chỉ có tác dụng khi input source là Latin (ngôn ngữ `en`).
  Khi input source là tiếng Nhật (`ja`) và bật "Tắt Tiếng Việt khi dùng bàn phím ngôn ngữ khác" (mặc định bật), mkey cho
  mọi phím đi qua.
- Ba trạng thái người dùng thấy: **Nhật** (input source `ja`), **Việt** (Latin + `vLanguage=1`), **Anh** (Latin +
  `vLanguage=0`).
- **Loại bàn phím vật lý:** ANSI / ISO / JIS — lấy theo từng phím (`kCGKeyboardEventKeyboardType` → `KBGetLayoutType`).
  Có thể đổi giữa hai phím liên tiếp (bàn phím JIS built-in + bàn phím ANSI rời).

## 4. Ví dụ chuẩn
Máy: MacBook bàn phím JIS, input source bật: ABC + Japanese – Romaji. mkey: Telex, đang ở **Việt**.
1. Gõ `tieesng vieejt` → `tiếng việt`.
2. Gõ phím `[` (phím bên phải `@`, keycode 30) → `ơ`; phím `]` (keycode 42) → `ư`. Gõ `@` (keycode 33) → ra `@`, không
   ra `ơ`.
3. Bấm **かな** → macOS chuyển sang Japanese; gõ `nihongo` → `にほんご` (mkey không can thiệp).
4. Bấm **英数** → về ABC, mkey ở **Việt** (trạng thái trước khi sang Nhật); gõ `ddaay` → `đây`.
5. Bấm **英数** lần nữa → **Anh**; gõ `ddaay` → `ddaay`.
6. Bấm **英数** lần nữa → **Việt**. Icon menu bar đổi đúng V/E sau mỗi lần.
7. Chuyển sang VNI, gõ `a1` → `á`; gõ `^` (keycode 24 trên JIS) → ra `^`, không làm đổi dấu.

## 5. Luồng màn hình
- **Bảng điều khiển → Bộ gõ:** thêm tuỳ chọn "Dùng phím 英数 / かな để chuyển ngôn ngữ (bàn phím JIS)" — mặc định **bật
  khi phát hiện bàn phím JIS** (suy ra — cần xác nhận).
- **HotkeyEditor:** hiển thị đúng tên phím 英数 / かな / ¥ / _ thay vì ký tự rác; không cho gán 英数 / かな làm hotkey khi
  tuỳ chọn trên đang bật.
- **Hệ thống → Tương thích nâng cao:** giữ "Tương thích bố cục bàn phím khác QWERTY" cho Dvorak / AZERTY…; JIS được xử
  lý riêng, không cần bật tuỳ chọn này.

## 6. Quy tắc nghiệp vụ & biên
### 6.1 Gõ trên JIS
- Engine chỉ nhận "keycode logic" kiểu ANSI. Trên JIS, phím ra `[` (30) phải tới engine như `KEY_LEFT_BRACKET` (33), phím
  ra `]` (42) như `KEY_RIGHT_BRACKET` (30). Phím ra `@` (33), `:` (39), `^` (24), `¥` (93), `_` (94) **không** được hiểu
  là phím engine dùng (dấu, ơ/ư, số VNI) — cho qua như ký tự thường / phím ngắt từ.
- Khi mkey gửi lại phím (restore từ sai chính tả, gõ tắt, gửi từng bước), ký tự hiện ra phải giống ký tự người dùng
  gõ trên JIS (gửi lại `[` không được thành `@`).
- Phím chỉ có trên JIS `¥` (93), `_` (94), `,` bàn phím số (95) là phím ngắt từ như `\`, `-`, `,` trên ANSI
  (`tooi¥as` → `tôi¥á`).
- Trên JIS, "Tương thích bố cục bàn phím khác QWERTY" không có tác dụng (JIS được xử lý riêng). Giới hạn đã chấp nhận:
  bàn phím JIS + layout không phải QWERTY (Dvorak…) chưa hỗ trợ.
- Bàn phím ANSI/ISO: hành vi giữ nguyên 100% so với 1.6.1.
- Bộ nhớ đệm ánh xạ keycode phải tính theo loại bàn phím, không chỉ theo input source.

### 6.2 Chuyển ngôn ngữ bằng かな / 英数
- **かな:** luôn để macOS xử lý (chuyển sang Japanese). mkey kết thúc từ đang gõ (new session), không nuốt phím.
- **英数** khi input source hiện tại **không phải** Latin: để macOS xử lý (về ABC/Roman); mkey giữ nguyên `vLanguage`
  (= trạng thái Việt/Anh trước khi sang Nhật).
- **英数** khi input source **đã là** Latin: đổi Việt ⇄ Anh như hotkey ⌥Z (beep nếu bật, cập nhật icon, lưu "nhớ theo
  app" nếu bật).
- ⌥Z (hoặc hotkey người dùng đặt) vẫn hoạt động như cũ.
- App nằm trong danh sách loại trừ: không đổi gì (かな / 英数 đi thẳng tới macOS).
- Tuỳ chọn tắt → mkey không đổi input source / Việt ⇄ Anh khi bấm 英数 / かな, nhưng vẫn kết thúc từ đang gõ (khác 1.6.1:
  bản cũ đưa hai phím này vào giữa từ — chốt 2026-10-19, PLAN Phase 2 Còn tồn C1).

### 6.3 Không trùng phím tắt hệ thống
- Không dùng làm mặc định: ⌃Space, ⌃⌥Space (Chọn input source), ⌘Space (Spotlight), Globe/Fn.
- (Phase 3) Khi phím tắt đã lưu (chuyển chế độ, chuyển mã, clipboard) trùng một phím tắt **đang bật** của macOS (giá trị
  hiệu lực từ `CopySymbolicHotKeys`, gồm cả mặc định), `HotkeyEditor` hiện cảnh báo kèm tên mặc định của tổ hợp nếu biết.
  Chỉ cảnh báo: không chặn ghi, không tự đổi. 英数 / かな trơn dùng chú thích riêng của §6.2, không cảnh báo thêm.
- Không có hotkey đi thẳng Nhật / Việt / Anh (bỏ, 2026-10-19).

### 6.4 Chọn bàn phím (Phase 5c, người dùng chốt 2026-10-23)
- Tuỳ chọn **Bàn phím: Tự động / JIS (Nhật) / Tiếng Anh (US)**, mặc định **Tự động**. Ở đầu trang Bộ gõ và mục "Bàn phím"
  trong menu thanh menu.
- **Tự động:** như §6.1–6.2 — mỗi keyDown xét loại bàn phím của chính phím đó (`kCGKeyboardEventKeyboardType`).
- **JIS (Nhật):** mọi phím xử lý kiểu JIS (§6.1), 英数 / かな theo §6.2, bất kể bàn phím vật lý.
- **Tiếng Anh (US):** tắt toàn bộ xử lý JIS — không ánh xạ keycode, ký tự theo bảng ANSI, "Tương thích bố cục" như cũ,
  英数 / かな không được xử lý (đi thẳng vào engine như mkey gốc 1.6.1). Gõ y như mkey gốc.
- Chế độ chọn tay **khác** bàn phím vừa gõ (JIS trên bàn phím ANSI/ISO, hoặc Tiếng Anh trên bàn phím JIS) → trang Bộ gõ hiện
  cảnh báo kèm nút "Về Tự động". Không tự đổi chế độ.

## 7. Lỗi, bảo mật
- Ô mật khẩu (Secure Input): macOS chặn event tap — giữ hành vi hiện tại.
- Không chạy đồng thời với Input Method "MKey" (prototype IMK) — hướng dẫn gỡ trong README phần cài đặt
  (suy ra — cần xác nhận).

## 8. Phát hành
- Tới trước phase Phát hành: chỉ dùng bản **Debug** (updater tắt ở Debug nên không bị Sparkle của repo gốc cập nhật đè).
- Phase Phát hành: đổi bundle id, `SUFeedURL`, khoá Sparkle, chữ ký sang của chủ dự án (Phase 4a: `io.github.akachick113.mkeyjis`, Apple Development team `8C4YAMZSGP`, không notarize); giữ GPL-3.0 + ghi
  nguồn OpenKey / mkey.
