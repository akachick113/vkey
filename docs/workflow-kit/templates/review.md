# Review Phase {{N}} — PR #{{n}}, nhánh `phase-{{N}}-{{tên}}` (commit {{sha}})

Kiểm tra trên worktree sạch (cài từ lockfile): `{{CHECK_CMD}}` ✅/❌ ({{số test mỗi phần}}) · formatter ✅/❌ ·
dependency không trùng ✅/❌ · lockfile {{không đổi / đổi vì …}} · {{quy tắc đo được của AGENTS, vd màn ≤ 300 dòng}} ✅/❌
· {{repo có sẵn: test đỏ so với baseline — không có test đỏ mới ✅/❌}}.

{{Phần làm tốt — 1–3 dòng, cụ thể.}}

Chạy thật ({{môi trường: simulator / curl / log}}):
- (a) {{bước → kết quả}} ✅
- (b) {{…}} ❌ (mục {{x}})
- Chưa thử: {{… — vì sao, ai làm}}

## Phải sửa

1. **{{Tiêu đề ngắn: hiện tượng.}}** {{Nguyên nhân (file, hàm). Cách tái hiện. Hậu quả.}}
   Sửa: {{hướng sửa cụ thể}}. Test riêng: {{ca test cần thêm}}.
2. **Thiếu test bắt buộc:** {{số ca + mô tả}}.

## Nên sửa

3. {{…}}

## Done khi
- [ ] Mục 1–{{x}} xong, mỗi mục có test.
- [ ] `{{CHECK_CMD}}` + formatter xanh; CI xanh.
- [ ] Chạy lại kịch bản {{…}} và ghi kết quả trong PR.

---

# Review lần 2 — commit {{sha}}

{{Đã sửa: 1 ✅ 2 ✅ … (kiểm bằng cách nào). Mục mới đánh `R2-1, R2-2…` (vòng 3: `R3-1`…) để khỏi lẫn với vòng trước
và với `C1, C2…` của Còn tồn.}}

## Phải sửa
R2-1. {{…}}

## Nên sửa
R2-2. {{…}}

---

# Review lần {{k}} — commit {{sha}}

**Approved.** {{Những gì đã kiểm.}} Còn tồn chuyển sang Phase {{N+1}}: {{…}}
