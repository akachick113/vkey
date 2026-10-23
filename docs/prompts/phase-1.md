# Phase 1 — Gõ đúng trên bàn phím JIS

> Codex · **GPT-6 Sol** · effort **High** (sửa đường nóng của event tap, nhiều chỗ gửi phím, lỗi tinh vi chỉ lộ khi gõ thật — WORKFLOW §8) · nhánh `phase-1-jis-layout`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PRODUCT_SPEC.md` (§4 bước 1, 2, 7; §6.1), `docs/PLAN.md` (Phase 0 **Quyết định đã chốt** + Phase 1),
`docs/notes/codebase-map.md` (§5, §5a).

Mục tiêu: trên bàn phím **JIS**, Telex / VNI cho kết quả giống như gõ cùng chuỗi ký tự đó trên ANSI. Trên ANSI / ISO
không đổi gì. Phase này **không** làm かな / 英数 (Phase 2), không đổi UI ngoài một dòng chú thích (Việc 5), không sửa
`Sources/Engine/`.

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; test engine viết theo kiểu `tests/engine/` (mỗi ca một hàm
`caseNN_…`, `resetConfiguration()` trước mỗi ca); Conventional Commits tiếng Việt; chỉ `git add <file>`; **mở PR vào
`main` của `origin`** và gửi link.

Hiện trạng đã xem (Claude đo bằng harness Phase 0 + engine thật, 2026-10-19):
- Bảng phím khác nhau JIS / ANSI (layout ABC, UCKeyTranslate với keyboard type JIS = 18 và ANSI = 1), dạng
  keycode: JIS thường/Shift — ANSI thường/Shift:
  `19: 2" — 2@` · `22: 6& — 6^` · `24: ^~ — =+` · `25: 9) — 9(` · `26: 7' — 7&` · `27: -= — -_` · `28: 8( — 8*` ·
  `29: 0 — 0)` · `30: [{ — ]}` · `33: @` — [{` · `39: :* — '"` · `41: ;+ — ;:` · `42: ]} — \|` · `93: ¥| — (không có)` ·
  `94: _ — (không có)` · `95: , (bàn phím số) — (không có)` · `102 英数`, `104 かな`. Chữ cái và phím số không Shift giống nhau.
- Mặc định (tắt "Tương thích bố cục"), JIS: Telex `t[` → `tư`, `t]` → `t]`, `a@b` → `aơb`, `@@` → `[`. Bật "Tương thích
  bố cục": Telex đúng nhưng VNI `a^` → `â`, `a@` → `à`, `tie^ng1` → `tiếng`. Cả hai chế độ: `tooi¥as` → `tôi¥as` (engine
  không coi 93/94/95 là phím ngắt từ; ANSI `tooi\as` → `tôi\á`).
- `MKEngineHook.mm`:
  - `:1009-1010` đọc `_flag`, `_keycode` (vật lý). `:1030-1040` khối "Tương thích bố cục" đổi `_keycode` theo ký tự
    (`ConvertKeyStringToKeyCode` `:920`, cache `_compatKeyCodeCache[128]` xoá ở `MKUpdateInputSourceCache` `:115`).
  - `:1043-1059` so hotkey chuyển ngôn ngữ / chuyển mã bằng `_keycode` **sau** khi đã đổi. `HotkeyEditor.swift:236` ghi
    `event.keyCode` vật lý.
  - Chiều ra mặc định (không "gửi từng bước"): `SendNewCharString` (`:767`) và `TryAXProcessKey` (`:370`) đổi keycode
    logic → ký tự bằng `keyCodeToCharacter()` (bảng ANSI của engine) rồi gửi Unicode, nên chỉ cần keycode logic đúng.
    **Riêng ký tự của phím vừa gõ khi restore** (`:829-831`, `:387`) cũng dựng bằng `keyCodeToCharacter(_keycode | caps)`
    → nếu `_keycode` là keycode logic khác phím thật thì ra sai ký tự.
  - Các chỗ gửi **keycode thật** qua `SendKeyCode` (`:641`, macOS dịch keycode theo layout JIS): phím vừa gõ ở `:851`
    (`_willSendControlKey`), `:889`, `:917` (phím kích hoạt gõ tắt), `:1214` (restore khi gửi từng bước); ký tự trong từ
    ở `:913` (macro, gửi từng bước) và `:1210` (gửi từng bước).
- Đã thử trên engine thật: hoán vị keycode `30→33, 42→30, 33→42` + `93→42, 95→43, 94→27 (Shift)` và ký tự phím vừa gõ
  lấy từ event → mọi ca ở Việc 6 đúng. Nếu vẫn dựng phím vừa gõ bằng bảng ANSI thì ca 20 ra `windows\`.

## Việc 0 — Còn tồn
C1. `scripts/check.sh`: thêm `-Wno-missing-braces` vào lệnh `xcrun clang++` biên dịch test engine (cảnh báo nằm ở engine
gốc `Vietnamese.cpp:811`, không sửa engine).

## Việc 1 — Hàm thuần ánh xạ JIS
File mới `Sources/Platform/MKKeyLayout.h` + `MKKeyLayout.cpp`, **C++ thuần** (chỉ include `DataType.h` / `platforms/mac.h`
của engine, không Carbon / ObjC) để `check.sh` biên dịch cùng test. XcodeGen tự nhận file mới trong `Sources/Platform`.
- `MKKey MKJISToLogicalKey(Uint16 physicalKeycode, bool shift)` → `{keycode, shift}`: `30→33`, `42→30`, `33→42`,
  `93→42`, `95→43` (giữ Shift); `94→27` với Shift = true; còn lại giữ nguyên.
- `Uint16 MKLogicalToJISKeycode(Uint16 logicalKeycode)`: `33→30`, `30→42`, còn lại giữ nguyên. Chỉ dùng cho **ký tự trong
  từ** (chữ cái, `[` `]`) khi phải gửi keycode thật; không dùng cho phím vừa gõ.
- `Uint16 MKCurrentKeyCharacter(bool isJIS, Uint16 logicalKeycode, bool caps, Uint16 eventCharacter)`: JIS và
  `eventCharacter != 0` → `eventCharacter`; còn lại → `keyCodeToCharacter(logicalKeycode | (caps ? CAPS_MASK : 0))`
  (đúng như hiện tại).

## Việc 2 — Nối vào event tap
Trong `MKEngineHook.mm`:
- Loại bàn phím: `CGEventGetIntegerValueField(event, kCGKeyboardEventKeyboardType)` mỗi keyDown; cache giá trị keyboard
  type cuối cùng + kết quả `KBGetLayoutType(type) == kKeyboardJIS`, chỉ gọi lại `KBGetLayoutType` khi giá trị đổi
  (AGENTS quy tắc 9). Lưu `_currentKeyboardIsJIS`.
- Giữ keycode vật lý `_physicalKeycode` và ký tự thật của event (`CGEventKeyboardGetUnicodeString`, 1 ký tự) **trước**
  khi đổi `_keycode`.
- keyDown trên JIS: `_keycode` = `MKJISToLogicalKey(...)`; nếu hàm ép Shift (phím 94) thì engine nhận caps = 1 (tham số
  thứ 4 của `vKeyHandleEvent`), **không** sửa `_flag` thật. Trên JIS **bỏ qua** khối "Tương thích bố cục" `:1030-1040`.
  Không JIS → giữ nguyên code cũ.
- Hotkey `:1043-1059`: trên JIS so bằng `_physicalKeycode` (hotkey ghi bằng keycode vật lý).
- Phím vừa gõ khi restore: `:829-831` và `:387` dùng `MKCurrentKeyCharacter(_currentKeyboardIsJIS, _keycode, caps,
  ký tự event)`.
- `SendKeyCode` cho **phím vừa gõ** (`:851`, `:889`, `:917`, `:1214`) trên JIS: gửi `_physicalKeycode` với Shift thật của
  event. Ký tự trong từ (`:913`, `:1210`) trên JIS: qua `MKLogicalToJISKeycode`. Tách chỗ này thành một hàm nhỏ, không
  rải `if` khắp file.
- Không đổi gì khi không phải JIS: mọi biến mới chỉ được đọc trong nhánh JIS.

## Việc 3 — Harness
- `check.sh` biên dịch thêm `Sources/Platform/MKKeyLayout.cpp` vào test engine (thêm `-ISources/Platform` nếu cần).
- `EngineHarness`: thêm `jisKeys(std::u16string)` đổi chuỗi ký tự → phím vật lý JIS theo bảng ở "Hiện trạng" (chữ cái /
  chữ số / khoảng trắng như ANSI; `[` `{` `]` `}` `@` dấu huyền ASCII (Shift+@) `:` `*` `;` `+` `^` `~` `¥` `_` theo
  bảng JIS), và `typeJIS(keys)` chạy
  `MKJISToLogicalKey` rồi engine; ký tự phím vừa gõ khi restore dựng bằng `MKCurrentKeyCharacter(true, …, ký tự thô)`.
  `type()` cũ giữ nguyên hành vi (16 ca Phase 0 không đổi).

## Việc 4 — Không đụng ANSI
`git diff` của `MKEngineHook.mm` phải cho thấy đường ANSI không đổi logic: mọi thay đổi nằm sau điều kiện
`_currentKeyboardIsJIS` (hoặc là biến mới chỉ ghi, không đọc ở nhánh ANSI). Ghi trong PR cách bạn kiểm điều này.

## Việc 5 — Chú thích UI
`SystemPage.swift`, mục "Tương thích nâng cao": thêm footer 1 dòng dưới toggle "Tương thích bố cục bàn phím khác
QWERTY": `Bàn phím JIS được mkey tự nhận và xử lý riêng, không cần bật tuỳ chọn này.` Không đổi gì khác trong UI.

## Việc 6 — Test
Mỗi ca là **một test riêng**, tên có số ca, đánh số tiếp sau Phase 0 (`case17_…` trở đi trong file hiện có hoặc file
test mới cùng kiểu). Cấu hình mặc định như app trừ khi ghi khác. Kết quả mong đợi Claude đã chạy trên engine thật.

Hàm thuần:
17. `MKJISToLogicalKey`: 30→33, 42→30, 33→42; Shift giữ nguyên (thử cả Shift = 0 và 1).
18. `MKJISToLogicalKey`: 93→42, 95→43 (Shift giữ nguyên); 94→27 với Shift = true.
19. `MKJISToLogicalKey` giữ nguyên: `KEY_A`, `KEY_Z`, `KEY_Q`, `KEY_1`, `KEY_2`, `KEY_0`, 24, 27, 39, 41, `KEY_SPACE`,
    `KEY_RETURN`, 102, 104.
20. `MKLogicalToJISKeycode`: 33→30, 30→42; `KEY_A`, 42, 27 giữ nguyên.
21. `MKCurrentKeyCharacter`: JIS + ký tự event `¥` → `¥`; JIS + ký tự event 0 → `keyCodeToCharacter`; không JIS + ký
    tự event `@` với keycode 42 → `\` (giữ hành vi cũ).

Gõ JIS qua harness (`typeJIS(jisKeys(…))`):
22. Telex `t[` → `tơ`.
23. Telex `t]` → `tư`.
24. Telex `t{` → `tƠ`.
25. Telex `a@b` → `a@b`.
26. Telex `@@` → `@@`.
27. Telex `t[[` → `t[`.
28. Telex `t]]` → `t]`.
29. Telex `tooi¥as` → `tôi¥á`.
30. Telex `tooi_as` → `tôi_á`.
31. VNI `a^` → `a^`.
32. VNI `a@` → `a@`.
33. VNI `tie^ng1` → `tie^ng1`.
34. Telex `Tieengs Vieetj` → `Tiếng Việt`.
35. `vRestoreIfWrongSpelling = 1`, Telex `windows@` → `windows@`. (Trên ANSI ra `ưindows@` vì `@` là Shift+2, không ngắt
    từ; trên JIS `@` là phím riêng nên ngắt từ và restore — đây là hành vi chủ ý, ghi trong PR.)
36. `vRestoreIfWrongSpelling = 1`, Telex `windows¥` → `windows¥` (dựng phím vừa gõ bằng bảng ANSI sẽ ra `windows\`).

## Không được làm
- Không sửa `Sources/Engine/`. Không đổi expectation 16 ca Phase 0.
- Không làm かな / 英数 / hotkey mới (Phase 2–3). Không đổi `HotkeyEditor`.
- Không sửa `ConvertKeyStringToKeyCode` / khối "Tương thích bố cục" cho ANSI.
- Không gọi TIS / AX / `NSEvent` mới trên đường nóng ngoài `CGEventGetIntegerValueField`,
  `CGEventKeyboardGetUnicodeString` và `KBGetLayoutType` (chỉ khi keyboard type đổi).
- Không thêm / nâng dependency; không đổi ký, bundle id, Sparkle, version. Không push `main`.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `PASS: 14 update runtime policy checks`, `PASS: 36 engine tests` (hoặc
      hơn); không còn cảnh báo `-Wmissing-braces` (C1). CI xanh.
- [ ] Đủ ca 17–36, mỗi ca một test.
- [ ] Kịch bản chạy thật — bản Debug từ `check.sh`, máy JIS này, input source **ABC** (không chọn Input Method "MKey"),
      TextEdit, mkey ở Việt:
  - (a) Telex: gõ `tieengs vieejt` → `tiếng việt`; `[` → `ơ`; `]` → `ư`; `@` → `@`; `tooi¥as` → `tôi¥á`.
  - (b) VNI: `a1` → `á`; `a^` → `a^`; `a@` → `a@`.
  - (c) Bật "Tương thích bố cục" rồi lặp (a) và (b) → kết quả giống hệt (JIS bỏ qua tuỳ chọn này).
  - (d) Bật "Gửi phím từng bước" → lặp (a) → giống hệt.
  - (e) Hotkey ⌥Z vẫn đổi Việt/Anh. Gán tạm hotkey ⌃⇧`[` (phím keycode 30 trên JIS) → bấm đổi được → trả về ⌥Z.
  - (f) Có bàn phím ANSI/ISO rời thì gõ lại (a) trên đó → `[` ra `ơ` theo vị trí ANSI. Không có thì ghi "chưa kiểm".
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo từng bước (Conventional Commits). Push nhánh `phase-1-jis-layout`, **mở PR vào `main`** và gửi link.
Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả từng kịch bản (a)–(f).
3. Chỗ nào khác prompt và lý do.
4. Những chỗ bạn **chưa chắc** hoặc chưa kiểm được (và vì sao).
