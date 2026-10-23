# Review Phase 2 — PR #3, nhánh `phase-2-kana-eisu` (commit `0da7487`)

Kiểm tra trên worktree sạch (`git worktree add ../mkey-review origin/phase-2-kana-eisu`, DerivedData mới):
`scripts/check.sh` ✅ (build Debug ✅ · `PASS: 14 update runtime policy checks` · `PASS: 47 engine tests` ·
`PASS: 4 hotkey key name tests`) · cảnh báo build chỉ còn 2 cảnh báo deprecated `activateIgnoringOtherApps` có sẵn từ
baseline ✅ · không đụng `Sources/Engine/`, `project.yml`, `docs/` ✅ · không thêm dependency ✅ · ca 1–39 không đổi ✅ ·
ca 40–51 đủ, mỗi ca một hàm có số ca ✅ · 3 commit Conventional Commits tiếng Việt, Việc 1 commit riêng (`fix:`) ✅.

Đối chiếu prompt từng việc:
- Việc 1 ✅ — chỉ đổi `CFNotificationCenterGetDarwinNotifyCenter` → `GetDistributedCenter`, callback giữ nguyên.
- Việc 2 ✅ — `MKLanguageKeyActionFor` đúng thứ tự quy tắc, C++ thuần trong `MKKeyLayout`.
- Việc 3 ✅ — đặt sau khối app loại trừ / ánh xạ JIS, trước khối hotkey; chỉ keyDown; `PassToSystem` gọi
  `RequestNewSession()` + `_lastFlag = 0` + `return event`; `ToggleLanguage` gọi `switchLanguage()` + `_lastFlag = 0` +
  `_hasJustUsedHotKey = true` + `return NULL`; ⌘ / ⌃ / ⌥ lấy từ `_flag`, không dùng `OTHER_CONTROL_KEY`. Không thêm lời
  gọi TIS / AX / NSEvent trong callback. Nhánh `NotHandled` y như cũ.
- Việc 4 ✅ — khoá `vUseJISLanguageKeys` có trong `registerDefaultSettings` (mặc định theo `isJISKeyboard`),
  `resetToDefaults` (danh sách khoá, `@Published`, global C), `LOAD_DATA`; không đụng iCloud. Toggle + chú thích đúng
  chuỗi, đúng section.
- Việc 5 ✅ — `HotkeyKeyName` Swift thuần; `hotkeyParts` và `AppState.hotkeyDescription` dùng chung; 3 chỗ dùng
  `HotkeyEditor` đều truyền `blocksLanguageKeys`; hai dòng chú thích đúng chuỗi; không tự đổi hotkey đã lưu. Không sửa
  `char == 49` ✅.

Làm tốt: diff nhỏ, đúng chỗ. Test bắt lỗi tốt — làm hỏng tạm `MKLanguageKeyActionFor` 3 kiểu (英数 luôn đổi Việt/Anh; bỏ
điều kiện app loại trừ; かな không xử lý khi đang Nhật) → lần lượt đỏ ca 41 + 47 / ca 44 / ca 40. Codex còn tự xử lý một
chỗ prompt không nói: bấm ⌃ + 英数 bị chặn thì lúc thả ⌃ không biến thành phím tắt chỉ-modifier (nhưng xem mục 2).

Chạy thật:
- Probe của Claude (trước khi viết prompt): notification đổi input source chỉ tới Distributed center — khớp Việc 1.
- Bản Debug trên máy: Claude **chưa chạy được**. Tiến trình mkey Debug đang chạy (pid 30261, khởi động 14:54:33 — trước
  commit cuối `0da7487` lúc 14:55:15) hiện cửa sổ "Chào mừng đến với MKey" và gõ thử `ddaay ` vào TextEdit ra `ddaay ` →
  bản build này **không có quyền Trợ năng**, event tap không chạy. Claude không được tự cấp quyền.
- Chưa thử: toàn bộ kịch bản (a0)–(j). Claude chưa thấy báo cáo của Codex trong PR (trình duyệt trong app chưa đăng nhập
  GitHub, repo private).

## Phải sửa

1. **Chưa có kết quả chạy thật (a0)–(j) trên bản có quyền Trợ năng.** Phase này đổi đường nóng của event tap và thứ tự
   notification — chỉ test thuần là chưa đủ (vòng 1 Phase 1 cũng chỉ lộ lỗi khi gõ thật).
   Làm: người dùng cấp quyền Trợ năng cho `build/DerivedData/Build/Products/Debug/mkey.app` (Cài đặt hệ thống → Quyền
   riêng tư & Bảo mật → Trợ năng; bản ad-hoc build lại thì có thể phải gỡ ra thêm lại). Thoát tiến trình mkey Debug cũ
   trước. Chạy (a0) trên bản build từ `main` (`a03fc39`) rồi (a)–(j) trên bản build từ commit cuối của nhánh, input
   source **ABC** / Japanese (không chọn Input Method "MKey"). Ghi kết quả từng mục vào mô tả PR (a0 ghi cả trước và sau).
   Mục nào không chạy được thì ghi lý do. Thêm vào (h) bước kiểm mục 2.

## Nên sửa

2. **Bấm 英数 / かな không kèm modifier khi đang ghi phím tắt làm hỏng lần ghi phím tắt chỉ-modifier ngay sau đó.**
   `HotkeyEditor.swift`, nhánh keyDown: khi chặn phím ngôn ngữ luôn đặt `rejectedKeyInModifierSequence = true`. Nếu lúc đó
   không giữ modifier nào thì không có flagsChanged "thả hết" để xoá cờ; người dùng giữ ⌃⇧ rồi thả để ghi phím tắt
   chỉ-modifier → nhánh flagsChanged gặp cờ còn bật → bỏ qua, không ghi ⌃⇧ (phải thử lần nữa mới được).
   Tái hiện: ở "Phím chuyển chế độ" (tuỳ chọn bật) bấm vào ô ghi → bấm 英数 (hiện chú thích) → giữ ⌃⇧ rồi thả → không
   ghi được.
   Sửa: chỉ đặt cờ khi đang giữ modifier (`event.modifierFlags` có `.control` / `.option` / `.command` / `.shift`, hoặc
   `peakModifiers != 0`). Không cần test tự động (UI); thêm vào kịch bản (h): sau khi bấm 英数 bị chặn, ghi ⌃⇧ → nhận
   `⌃⇧` ngay lần đầu; giữ ⌃ + 英数 rồi thả ⌃ → vẫn không ghi thành phím tắt.

## Done khi
- [ ] Mục 1: kết quả (a0)–(j) có trong PR, chạy trên bản Debug build từ commit cuối, đã cấp quyền Trợ năng.
- [ ] Mục 2 sửa (hoặc ghi lý do không sửa trong PR), kiểm bằng bước thêm ở (h).
- [ ] `scripts/check.sh` xanh (`14` / `47` / `4`); CI xanh.

Model: giữ **Sol · High** (vòng này không có lỗi logic, chỉ thiếu chạy thật + một lỗi UI nhỏ).

---

# Review lần 2 — commit `5748c46`

**Approved.** `scripts/check.sh` trên worktree sạch ✅ (`14` / `47` / `4`). Mục 2 ✅: chỉ đặt cờ khi đang giữ modifier.
Mục 1 ✅: sau khi người dùng cấp quyền Trợ năng, Claude tự chạy trên bản Debug đang chạy (build 15:14 từ checkout chính,
cùng code với `5748c46` ở phần event tap). Cách chạy: phím tổng hợp `CGEventPost` có keyboard type 93 (JIS) vào một tài
liệu TextEdit mới, input source ABC / Japanese – Romaji (đã bỏ chọn Input Method "MKey"). Bấm toggle trong cửa sổ cài đặt
bằng Accessibility. Trạng thái V / E đọc ở khoá `InputMethod`.

Chạy thật:
- (a) ✅ Việt, 英数 ở ABC → Anh; 英数 lần nữa → Việt, `ddaay ` → `đây `; かな → Japanese, `nihongo` + Return → `日本語`
  (Kotoeri chuyển đổi trực tiếp), trạng thái Việt/Anh không đổi; 英数 từ Japanese → ABC, giữ trạng thái trước đó; 英数 ở ABC
  đảo Việt ⇄ Anh, `ddaay` lần lượt ra `ddaay` / `đây`.
- (b) ✅ Đang Anh: かな → 英数 → vẫn Anh; ⌥Z → Việt.
- Đang **Việt**, かな rồi gõ `aaas` + Return → `あああs` (mkey không chen Telex vào Kotoeri) ✅.
- (c) ✅ Đổi sang Japanese bằng `TISSelectInputSource` (không qua phím), đang Việt, `aaas` → `あああs`; về ABC bằng TIS →
  `ddaay ` → `đây ` — Việc 1 có tác dụng.
- (g) ✅ Tắt tuỳ chọn: 英数 ở ABC không đổi V / E; かな / 英数 vẫn đổi input source; tiếng Nhật không bị chen; ⌥Z vẫn đổi.
- (h) ✅ Tuỳ chọn bật: bấm 英数 khi đang ghi → không ghi, hiện chú thích, vẫn ở trạng thái ghi; ngay sau đó ghi ⌃⇧ → nhận
  `⌃⇧` lần đầu (mục 2); ⌃⇧ + 英数 rồi thả → không thành phím tắt; Esc → giữ phím tắt cũ. Tắt tuỳ chọn: ghi 英数 → hiện `英数`;
  bấm 英数 trong TextEdit → đổi V / E. Bật lại → hiện chú thích trùng. Ghi ⌃¥ → hiện `⌃¥` (không phải `Â`); phím tắt lưu
  ký tự `|` (0x7C) vẫn hiện `¥` nhờ hiển thị theo keycode.
- (j) ✅ Bật "Gửi phím từng bước": chuỗi (a) cho kết quả giống hệt; `[` `]` trên JIS vẫn ra `ơ` `ư`.
- Chưa thử: (a0) — cần bản build từ `main` có quyền Trợ năng (bản ad-hoc build mới mất quyền); thay bằng probe trước khi
  viết prompt + (c) ở trên. (d) beep — không nghe được qua công cụ; `switchLanguage()` dùng chung với ⌥Z. (e) nhớ theo app
  — không mở thêm app của người dùng; trong lúc chạy thấy TextEdit được trả về Việt khi kích hoạt, `switchLanguage()` gọi
  `OnInputMethodChanged` như ⌥Z. (f) app loại trừ — kiểm bằng đọc code (khối loại trừ `return` trước) + ca 44.
  (i) "Cài đặt mặc định" — không bấm vì xoá toàn bộ cài đặt thật của người dùng; kiểm bằng đọc code.

**Lỗi của prompt.** Kịch bản (h) bảo "ghi ⌃英数". Probe cho thấy NSEvent local monitor của app **không nhận** ⌃英数 /
⌃かな (macOS không giao các tổ hợp này cho app), nên chỉ ghi được 英数 / かな không kèm modifier. PR đúng, prompt sai.

Ghi nhận cho phase sau (không chặn PR này):
- **C1 — khi tắt tuỳ chọn, 英数 / かな làm hỏng từ gõ ngay sau.** Đường cũ (1.6.1) đưa keycode 102 / 104 vào bộ đệm engine
  như một ký tự trong từ. Chạy thật, tuỳ chọn tắt, ở ABC + Việt: `⏎ ddaay␣` → `đây`, nhưng `⏎ 英数 ddaay␣` → `đaay`
  (harness cũng cho `tie` + かな + `es` → không ra `tiés`). Khi tuỳ chọn bật thì không bị (かな / 英数 kết thúc từ). Cần người
  dùng quyết: giữ đúng 1.6.1, hay luôn coi 102 / 104 là phím kết thúc từ kể cả khi tắt tuỳ chọn.
- `HotkeyEditor`: `peakModifiers` không được xoá khi thả một modifier đơn lẻ (lỗi có sẵn), nên cờ mục 2 vẫn có thể bật nhầm
  sau khi bấm rồi thả ⌃ một mình. Ghi ⌥Z bằng tay lưu ký tự `Ω` và hiện `⌥Î` (lỗi có sẵn, không riêng JIS). Cả hai nhỏ,
  để Phase 3 nếu đụng HotkeyEditor.

Trạng thái máy sau khi chạy: input source để ở **ABC** (trước đó là Input Method "MKey" — không chọn lại vì AGENTS quy tắc
15); khoá `SwitchKeyStatus` và `vUseJISLanguageKeys` đã xoá về mặc định (⌥Z, bật). Bản Debug (pid 40962) vẫn đang chạy.
