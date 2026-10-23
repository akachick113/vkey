# Review Phase 1 — PR #2, nhánh `phase-1-jis-layout` (commit `92e4a4a`)

Kiểm tra trên worktree sạch (`git worktree add ../mkey-review 92e4a4a`, DerivedData mới): `scripts/check.sh` ✅
(build Debug ✅ · `PASS: 14 update runtime policy checks` · `PASS: 36 engine tests`) · C1 ✅ (không còn `-Wmissing-braces`) ·
không đụng `Sources/Engine/`, `project.yml`, `docs/` ✅ · không thêm dependency ✅ · 16 ca Phase 0 không đổi ✅ · 2 commit
Conventional Commits ✅. (Dòng `error: the following command failed with exit code 0` trong log build là Xcode in kèm
cảnh báo deprecated có sẵn ở `ClipboardPicker.swift:310`; build vẫn thành công, không phải lỗi của PR.)

Làm tốt: hàm thuần gọn, đúng bảng. Mọi thay đổi trong `MKEngineHook.mm` nằm sau `_currentKeyboardIsJIS`; nhánh ANSI
đọc lại y như cũ (đã đi từng hunk). `KBGetLayoutType` chỉ gọi khi keyboard type đổi. Test bắt lỗi tốt: làm hỏng tạm
`MKKeyLayout.cpp` 3 kiểu (bỏ `93`, bỏ `33→42`, dựng phím vừa gõ bằng bảng ANSI) → lần lượt đỏ 3 / 4 / 3 ca đúng chỗ.

Chạy thật:
- Engine + harness (Claude tự chạy): xác nhận 2 lỗi dưới đây.
- Gõ thử bản Debug trên máy: Claude **chưa thử** (cần cấp quyền Trợ năng cho bản build mới). Kết quả (a)–(f) lấy theo
  báo cáo của Codex; sau khi sửa phải chạy lại thêm kịch bản (g), (h) ở "Done khi".

## Phải sửa

1. **Trên JIS, Return / Tab / mũi tên bị biến thành ký tự khi mkey khôi phục từ sai chính tả.** Bật "Khôi phục phím
   nếu từ sai chính tả", gõ `windows` rồi Enter. Engine trả `vRestoreAndStartNewSession`. Trên ANSI,
   `keyCodeToCharacter(KEY_RETURN) == 0` nên hook đặt `_willSendControlKey` và gửi phím Return thật. Trên JIS,
   `MKCurrentKeyCharacter` trả ký tự của event (`\r`, `\t`, `U+F702`/`U+F703` cho ←/→), khác 0, nên
   `SendNewCharString` (`MKEngineHook.mm:854-859`) và `TryAXProcessKey` (`:393-397`) **chèn ký tự đó vào chuỗi** thay vì
   gửi phím. Hậu quả: Enter không submit form / không xuống dòng đúng, Tab không chuyển ô, mũi tên chèn ký tự rác.
   Claude đã chạy thử: Return, Tab, ←, → đều lệch; Space không lệch. Mặc định (tắt khôi phục) engine trả `vDoNothing`
   nên không lỗi. **Lỗi do prompt**: Việc 1 ghi "JIS và `eventCharacter != 0` → `eventCharacter`", thiếu điều kiện phím
   điều khiển.
   Sửa: `MKCurrentKeyCharacter` trả 0 khi `keyCodeToCharacter(logicalKeycode | caps) == 0` (phím điều khiển), bất kể JIS;
   chỉ khi khác 0 và JIS mới thay bằng `eventCharacter` (nếu khác 0). Harness: khi hàm trả 0 thì `appendRaw(key)` (mô
   phỏng gửi phím thật), không `push_back(0)`.
   Test riêng:
   - **37.** `MKCurrentKeyCharacter(true, KEY_RETURN, false, u'\r') == 0`; tương tự `KEY_TAB` + `u'\t'`, `KEY_LEFT` +
     `0xF702`, `KEY_RIGHT` + `0xF703`; `KEY_SPACE` + `u' '` → `u' '`.
   - **38.** `vRestoreIfWrongSpelling = 1`, `typeJIS(jisKeys(u"windows\n"))` → `windows\n` (khớp ANSI `type(ansiKeys(…))`,
     Claude đã chạy).

2. **Gõ tắt khi bật "Gửi phím từng bước" ra sai ký hiệu trên JIS.** Nội dung gõ tắt lưu ký tự ASCII dưới dạng keycode
   ANSI (`_characterMap` ở `Vietnamese.cpp:594-609`, dùng ở `Macro.cpp:38`: `@` = `KEY_2|CAPS`, `:` =
   `KEY_SEMICOLON|CAPS`, `_` = `KEY_MINUS|CAPS`…).
   `SendLayoutKey` (`:777-786`) chỉ đổi `33`/`30` qua `MKLogicalToJISKeycode`, còn lại gửi keycode ANSI thật, rồi macOS
   dịch theo JIS. Ví dụ gõ tắt `a@b.com` ra `a"b.com`, `12:30` ra `12+30`, `x_y` ra `x=y` (theo bảng JIS ở prompt: 19+Shift
   = `"`, 41+Shift = `+`, 27+Shift = `=`). Ký tự trong từ ở `:1256` (restore khi gửi từng bước) cũng đi đường này.
   **Lỗi do prompt**: "Hiện trạng" ghi ký tự trong từ chỉ là chữ cái và `[ ]`, sai với macro.
   Sửa: trên JIS, dữ liệu **không phải phím vừa gõ** mà là keycode (không có `CHAR_CODE_MASK` / `PURE_CHARACTER_MASK`)
   gửi bằng ký tự: `keyCodeToCharacter(data)` → `SendPureCharacter`; nếu ra 0 (phím điều khiển) thì gửi keycode như cũ.
   `MKLogicalToJISKeycode` khi đó không cần dùng trong hook nữa (giữ hàm + ca 20 cũng được). Tách quyết định thành hàm
   thuần, ví dụ `Uint16 MKJISWordCharacter(Uint32 data)` (0 = gửi keycode).
   Test riêng:
   - **39.** `MKJISWordCharacter`: `KEY_2|CAPS_MASK` → `@`; `KEY_SEMICOLON|CAPS_MASK` → `:`; `KEY_MINUS|CAPS_MASK` → `_`;
     `KEY_A` → `a`; `33` → `[`; `KEY_RETURN` → 0; giá trị có `CHAR_CODE_MASK` → 0.

## Nên sửa

3. **CapsLock ở phím vừa gõ khi gửi từng bước.** `SendLayoutKey(…, true)` tự tính lại Shift chỉ từ
   `kCGEventFlagMaskShift`, bỏ bit `CAPS_MASK` mà chỗ gọi đã tính. Chỗ gọi ở `:1260` (trước là `:1214`) tính cả CapsLock.
   Giữ bit của chỗ gọi: `data = _physicalKeycode | (data & CAPS_MASK)`. Phím 94 vẫn đúng, vì chỗ gọi tính CAPS từ cờ
   Shift thật chứ không từ Shift ép.

## Done khi
- [ ] Mục 1–2 xong, có ca 37–39 (mỗi ca một test); mục 3 sửa hoặc ghi lý do không sửa.
- [ ] `scripts/check.sh` xanh (`PASS: 39 engine tests` trở lên); CI xanh.
- [ ] Chạy lại (a)–(e) của prompt trên máy JIS, thêm:
  - (g) Bật "Khôi phục phím nếu từ sai chính tả": trong TextEdit gõ `windows` + Enter → xuống dòng, không có ký tự lạ;
    trong ô tìm kiếm Safari gõ `windows` + Enter → tìm kiếm chạy. Lặp với Tab và ← →.
  - (h) Bật "Gửi phím từng bước", tạo gõ tắt `mm` → `a@b.com 12:30 x_y`; gõ `mm` + Space trên JIS → ra đúng nguyên văn.
- [ ] Ghi kết quả (a)–(h) trong PR.

**Kết luận: cần sửa (2 mục Phải sửa, cả hai do prompt).** Giữ model **Sol · High**, cùng session.

---

# Review lần 2 — commit `5ea67d5`

Đã sửa: 1 ✅ 2 ✅ 3 ✅. Kiểm trên worktree sạch: `scripts/check.sh` ✅ (`PASS: 14 update runtime policy checks` ·
`PASS: 39 engine tests`); commit sửa không đụng `Sources/Engine/`, `project.yml`, `docs/`.
- **1:** `MKCurrentKeyCharacter` trả 0 khi `keyCodeToCharacter(logic)` = 0, nhánh ANSI giữ kết quả cũ; harness gửi phím
  thật khi ra 0. Claude chạy lại engine với restore bật: `windows` + Return / Tab / ← / → → hàm trả 0 cho cả 4 phím, giống
  ANSI; Space vẫn ra ` `. Ca 37, 38 có.
- **2:** `SendLayoutKey` trên JIS gửi dữ liệu keycode in được bằng `SendPureCharacter(MKJISWordCharacter(data))`, còn
  phím điều khiển và dữ liệu đã mã hoá đi đường cũ. `SendPureCharacter` cũng gọi `InsertKeyLength(1)` với bảng mã đôi
  như `SendKeyCode`. Ca 39 có.
- **3:** phím vừa gõ giữ bit `CAPS_MASK` của chỗ gọi.
- Làm hỏng tạm (bản sao ngoài worktree): bỏ dòng chặn phím điều khiển → ca 37 đỏ; bỏ loại trừ dữ liệu đã mã hoá → ca
  39 đỏ.

Ghi nhận, không chặn: trên JIS + "Gửi phím từng bước", chữ cái ASCII trong từ / gõ tắt giờ cũng gửi bằng Unicode thay vì
keycode (trên ANSI vẫn gửi keycode). Chữ có dấu vốn đã gửi bằng Unicode ở chế độ này, nên app đang dùng được chế độ này
sẽ nhận được. Nếu có app nào chỉ chịu keycode thật thì ghi vào Còn tồn, không sửa ở đây.

Chưa thử bằng tay: Claude không chạy bản Debug (cần quyền Trợ năng). Kịch bản (a)–(h) lấy theo báo cáo của Codex trong
PR.

**Approved**, merge (**Squash and merge**) khi: CI của PR #2 xanh, và báo cáo PR có kết quả (a)–(h) đạt trên máy JIS.
Còn tồn chuyển sang Phase 2: không có.
