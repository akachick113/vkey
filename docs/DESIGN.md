# VKey — Đặc tả giao diện (hướng B "Song ngữ Việt–Nhật")

Người dùng chọn 2026-10-23. Bản vẽ: canvas "VKey — 3 hướng thiết kế"
(https://claude.ai/artifact/3n4aSe5KNjboWuSSKfMs6h), khung **B · Song ngữ Việt–Nhật** và **B · khi chọn bàn phím Tiếng
Anh (US)**. Bản vẽ là minh hoạ; khi bản vẽ và file này khác nhau, **theo file này**. Nghiệp vụ chọn bàn phím:
`PRODUCT_SPEC.md` §6.4.

## 1. Nguyên tắc
- Ấm, giấy kem + đỏ son (con dấu), nhấn mạnh điểm riêng của VKey: Việt · Anh · 日本語 trên bàn phím JIS.
- Vẫn là app macOS: control gốc của SwiftUI / AppKit (`Toggle` kiểu switch, `Picker`, `Button`, `Menu`), điều hướng bàn
  phím, VoiceOver, sáng / tối theo hệ thống. Không gradient, không blur trang trí, không emoji, không viền trái kiểu thẻ.
- **Font hệ thống** (SF Pro; chữ Nhật macOS tự dùng Hiragino Sans). Bản vẽ dùng Be Vietnam Pro / Noto Sans JP chỉ để minh
  hoạ — **không nhúng font** (giữ app nhẹ, không thêm file giấy phép).
- Chuỗi tiếng Việt, theo giọng hiện có. Không nhắc tên sản phẩm khác trong giao diện (ngoài dòng ghi công ở Giới thiệu).

## 2. Màu (token)
Khai báo một chỗ (`VKTheme`), mỗi token có bản sáng / tối (`NSColor(name:dynamicProvider:)` theo
`NSAppearance.bestMatch(from: [.aqua, .darkAqua])`). Mọi view dùng token, không viết mã màu rời.

| Token | Sáng | Tối | Dùng cho |
|---|---|---|---|
| `windowBackground` | `#FBF8F3` | `#1E1B19` | nền vùng nội dung cửa sổ |
| `sidebarBackground` | `#F3EDE3` | `#252120` | thanh bên |
| `card` | `#FFFDF9` | `#2B2623` | thẻ / nhóm cài đặt, ô Anh / 日本語, mục sidebar đang chọn |
| `border` | `#E4DACB` | `#3D3530` | viền thẻ (1 pt), viền sidebar, viền segmented |
| `divider` | `#EFE7DA` | `#342E2A` | đường kẻ giữa các hàng trong thẻ |
| `textPrimary` | `#2B2724` | `#F2ECE4` | chữ chính |
| `textSecondary` | `#6E6458` | `#B5A99A` | chú thích, giá trị phụ |
| `accent` | `#C2412B` | `#E0583F` | ô ngôn ngữ đang gõ, `tint` của switch, chấm mục đang chọn, nền icon app |
| `accentText` | `#A8341F` | `#F08A72` | chữ mục sidebar đang chọn, link |
| `onAccent` | `#FFFDF9` | `#FFFDF9` | chữ trên nền `accent` (đậm) |
| `keycapBorder` | `#CDBFAA` | `#574C43` | viền phím ⌥Z / 英数 / かな |
| `segmentTrack` | `#F3EDE3` | `#332D29` | nền rãnh segmented |
| `segmentThumb` | `#FFFDF9` | `#4A403A` | ô đang chọn trong segmented |
| `ok` | `#3F8F4E` | `#6CC07A` | chấm trạng thái "đang nhận" |
| `warningBackground` | `#FBEBDD` | `#3A2A1C` | nền cảnh báo |
| `warningBorder` | `#EBC7A6` | `#6B4A2C` | viền cảnh báo |
| `warningText` | `#5A3A1E` | `#F2D3B5` | chữ cảnh báo |
| `warningIcon` | `#A35A1C` | `#E9A06A` | biểu tượng tam giác cảnh báo |

Tương phản đã tính: chữ chính / phụ trên `card` ≥ 4.5:1 cả hai chế độ; `onAccent` trên `accent` ≈ 5:1 (sáng), ≈ 4.5:1 (tối,
nên chữ trên `accent` luôn đậm).

## 3. Chữ, khoảng cách, bo góc
| Phần | Cỡ / kiểu |
|---|---|
| Tiêu đề trang | 24 pt, bold, `textPrimary` |
| Chữ ô ngôn ngữ (Việt / Anh / 日本語) | 26 pt, bold |
| Hàng cài đặt | 13 pt (`.body` của macOS) |
| Chú thích dưới hàng, trạng thái | 11–12 pt, `textSecondary` |
| Nhãn nhóm (VD `CHÍNH TẢ`) | 11 pt, semibold, chữ hoa, tracking 0.04 em, `textSecondary` |
| Phím (keycap) | 12 pt, viền `keycapBorder` 1 pt, bo 4, đệm 1 × 6 |

Khoảng cách: vùng nội dung đệm 28 (trên) × 32 (trái / phải); các khối cách nhau 18; hàng trong thẻ đệm 11 × 16; đường kẻ
giữa hàng thụt 16 hai bên. Bo góc: thẻ 12, segmented 9 (ô trong 6), nút / popup 7, cảnh báo 10.

## 4. Thành phần dùng chung (`Sources/App/Views/VKComponents.swift`)
- `VKCard { … }` — nền `card`, viền `border` 1 pt, bo 12; các hàng con ngăn bằng `VKDivider`.
- `VKRow(title:, subtitle:) { control }` — tiêu đề trái (13 pt) + chú thích (11 pt) dưới tiêu đề, control phải.
- `VKSectionLabel("CHÍNH TẢ")` — nhãn nhóm trên thẻ.
- `VKSegmented(selection:, options:)` — rãnh `segmentTrack` + viền `border`, ô chọn `segmentThumb` + bóng nhẹ, chữ ô chọn
  semibold `textPrimary`, ô khác `textSecondary`. Là `Picker` thật (`.pickerStyle(.segmented)` không tô màu được → dựng bằng
  `HStack` các `Button` với `accessibilityAddTraits(.isSelected)` và `accessibilityLabel` của nhóm).
- `VKKeycap("英数")` — một phím; `VKKeycapRow` nhiều phím cách nhau chữ "hoặc".
- `VKBanner(message:, actionTitle:, action:)` — nền / viền / chữ / icon theo token cảnh báo; icon tam giác SF Symbol
  `exclamationmark.triangle`.
- Switch: `Toggle(…).toggleStyle(.switch).tint(VKTheme.accent)`; popup: `Picker(…).pickerStyle(.menu)`.

## 5. Cửa sổ cài đặt
- Kích thước 860 × 600 (tối thiểu 860 × 560, chỉ cao thêm được). Thanh tiêu đề ẩn, giữ nút đèn giao thông, kéo được bằng nền.
  Bỏ hiệu ứng blur / mask / gradient của bản cũ.
- **Thanh bên** rộng 200, nền `sidebarBackground`, viền phải `border`:
  - Trên cùng (dưới nút đèn giao thông): chữ **VKey** 20 pt bold + `Việt · 日本語` 11 pt `textSecondary` cùng dòng. Không
    hiện icon app ở đây.
  - 6 mục chữ (không SF Symbol): Bộ gõ · Gõ tắt · Chuyển mã · Clipboard · Hệ thống · Giới thiệu. Mục đang chọn: nền `card`,
    viền `border`, bo 8, chấm tròn 6 pt `accent` bên trái, chữ semibold `accentText`. Mục khác: chữ `textPrimary`, thụt bằng
    chỗ của chấm.
  - Dưới cùng: huy hiệu trạng thái Trợ năng như hiện có, đổi màu theo token (`ok` / `warningIcon`).
- **Vùng nội dung** nền `windowBackground`, cuộn dọc. Đầu trang: tiêu đề trang bên trái; trang Bộ gõ có thêm **chọn bàn phím**
  bên phải cùng hàng (§6.1).

## 6. Trang Bộ gõ
Thứ tự từ trên xuống:

### 6.1 Chọn bàn phím (đầu trang, bên phải tiêu đề)
- Nhãn `Bàn phím` (`textSecondary`) + `VKSegmented`: `Tự động` · `JIS (Nhật)` · `Tiếng Anh (US)`.
- Ngay dưới hàng tiêu đề, một dòng trạng thái (12 pt) hoặc một cảnh báo (`VKBanner`), theo bảng (chữ chính xác):

| Chế độ | Bàn phím của phím gõ gần nhất | Hiện |
|---|---|---|
| Tự động | JIS | chấm `ok` + `Đang nhận: bàn phím JIS — gõ kiểu JIS, dùng được 英数 / かな` |
| Tự động | không JIS | chấm `ok` + `Đang nhận: bàn phím US / ISO — gõ như bàn phím tiếng Anh` |
| JIS (Nhật) | JIS | chấm `ok` + `Luôn gõ kiểu JIS` |
| JIS (Nhật) | không JIS | cảnh báo `Bạn đang gõ trên bàn phím không phải JIS. Ở chế độ JIS, một số phím sẽ ra sai ký tự.` + nút `Về Tự động` |
| Tiếng Anh (US) | không JIS | chấm `ok` + `Luôn gõ như bàn phím tiếng Anh (US)` |
| Tiếng Anh (US) | JIS | cảnh báo `Bạn đang gõ trên bàn phím JIS. Ở chế độ Tiếng Anh, một số phím sẽ ra sai ký tự (vd @ ra ơ) và 英数 / かな không chuyển ngôn ngữ.` + nút `Về Tự động` |

"Bàn phím của phím gõ gần nhất": từ event tap (báo về UI khi loại bàn phím đổi); trước phím đầu tiên dùng loại bàn phím
của máy (`LMGetKbdType`).

### 6.2 Dải ngôn ngữ (3 ô bằng nhau, cách 10)
| Ô | Nội dung | Phím hiện |
|---|---|---|
| **Việt** | `Telex · Unicode` (kiểu gõ · bảng mã hiện tại, rút gọn: `Unicode dựng sẵn` → `Unicode`) | phím chuyển đã lưu (vd `⌥Z`); thêm `hoặc 英数` khi đang gõ kiểu JIS và bật tuỳ chọn 英数 / かな |
| **Anh** | `Chữ Latin, không dấu` | như ô Việt |
| **日本語** | đang gõ kiểu JIS: `Bộ gõ Nhật của macOS`; chế độ Tiếng Anh: `Chọn trong menu Nguồn nhập của macOS` | `かな` (chỉ khi gõ kiểu JIS và bật tuỳ chọn) |

- Ô **đang dùng**: nền `accent`, chữ `onAccent`, nhãn nhỏ `ĐANG GÕ` (11 pt semibold, nền trắng 20 %) góc phải. Ô khác: nền
  `card`, viền `border`, chữ phụ `textSecondary`, phím viền `keycapBorder`.
- Ô đang dùng = **日本語** khi nguồn nhập hiện tại của macOS không phải Latin; nếu không, **Việt** hoặc **Anh** theo
  `isVietnamese`.
- Ô Việt / Anh là **nút**: bấm = đặt Tiếng Việt / Tiếng Anh (như toggle "Bật Tiếng Việt" cũ; thay thế toggle đó). Ô 日本語
  **không** bấm được (giữ quyết định Phase 3: VKey không tự đổi nguồn nhập). VoiceOver: `Tiếng Việt, đang gõ` /
  `Tiếng Anh` / `Tiếng Nhật, bấm かな để chuyển`.

### 6.3 Các thẻ cài đặt (nội dung giữ nguyên như trang cũ, chỉ đổi kiểu)
1. **Thẻ không nhãn:** `Kiểu gõ` (`VKSegmented`: Telex · VNI · Simple Telex 1 · Simple Telex 2) · `Bảng mã` (popup) ·
   `Phím chuyển Việt ⇄ Anh` (HotkeyEditor hiện có, giữ cảnh báo trùng phím tắt macOS) · `Kêu beep khi chuyển chế độ` ·
   `Dùng 英数 / かな để chuyển ngôn ngữ` với chú thích `かな: sang tiếng Nhật · 英数: về chữ Latin, bấm lần nữa để đổi Việt ⇄
   Anh`; ở chế độ Tiếng Anh: switch mờ (disabled) và chú thích đổi thành `Không dùng khi chọn bàn phím Tiếng Anh`. Chú thích
   ghi phím tắt bằng tổ hợp chức năng (⌃⇧…) đặt dưới HotkeyEditor như cũ.
2. `CHÍNH TẢ` — 6 toggle như cũ (giữ quan hệ disabled theo "Kiểm tra chính tả").
3. `GÕ NHANH` — 4 toggle như cũ.
4. `TƯƠNG THÍCH` — như cũ (kể cả chú thích Adobe / Affinity).
5. `HỖ TRỢ TRỢ NĂNG` — như cũ (danh sách app kéo thả), khung danh sách dùng `card` / `border`.

## 7. Menu thanh menu
Giữ **menu gốc của macOS** (MenuBarExtra kiểu menu): macOS không cho tô màu menu, và menu gốc có phím tắt, điều hướng bàn phím,
VoiceOver. Bản vẽ (rãnh 3 ô màu trong menu) chỉ là minh hoạ bố cục. Thứ tự:
1. `Tiếng Việt` (toggle, hiện phím tắt như cũ). Khi nguồn nhập hiện tại là tiếng Nhật, thêm ngay dưới một dòng mờ
   (disabled) `Đang gõ tiếng Nhật — bấm 英数 để về`.
2. `Tắt VKey cho <app>` (như cũ).
3. ── `Kiểu gõ ›` · `Bảng mã ›` · **`Bàn phím ›`** (radio: `Tự động` · `JIS (Nhật)` · `Tiếng Anh (US)`; tiêu đề menu cha
   không ghi giá trị).
4. ── `Chuyển mã nhanh` · `Công cụ chuyển mã…` · `Gõ tắt…` · `Lịch sử Clipboard` (như cũ).
5. ── `Cài đặt VKey…` (đổi tên từ `Bảng điều khiển…`) · `Giới thiệu VKey` · `Kiểm tra cập nhật…`.
6. ── `Thoát VKey`.
Khi chưa có quyền Trợ năng: giữ menu rút gọn như cũ.

## 8. Icon thanh menu
Ảnh cao 18 pt, rộng theo chữ (đệm ngang 4 pt), bo 3.5 pt, chữ 11 pt bold:
| Trạng thái | Hình |
|---|---|
| Tiếng Việt | khối đặc, chữ `VI` khoét rỗng |
| Tiếng Anh | viền 1.5 pt, chữ `EN` |
| Nguồn nhập tiếng Nhật đang chọn | viền 1.5 pt, chữ `あ` |
| App đang bị loại trừ | như trên, độ mờ 35 % |
- Tuỳ chọn "Biểu tượng đơn sắc trên thanh menu" (khoá `GrayIcon`, mặc định bật): bật = ảnh template (macOS tự đổi đen /
  trắng); tắt = khối / viền màu `accent` (sáng) với chữ `onAccent` cho `VI`, chữ `accent` cho `EN` / `あ`.
- Ưu tiên: loại trừ (mờ) áp lên hình đang có; `あ` thắng `VI` / `EN` khi nguồn nhập là tiếng Nhật.

## 9. Icon app
- Nền: hình vuông bo góc kiểu icon macOS (vùng hình 824 / 1024, bo ≈ 22.5 % cạnh), màu `accent` sáng `#C2412B`, phẳng (không
  gradient, không viền sáng); bóng đổ nhẹ như icon macOS chuẩn.
- Chữ **V** nét tròn màu `#FFFDF9` có **dấu sắc**, và **con dấu tròn** `#FFFDF9` chứa chữ `あ` màu `#C2412B` ở góc phải dưới.
  Toạ độ theo bản vẽ, khung 112 × 112 đặt giữa ô 144: V `M24 34 L52 86 L80 34` nét 12; dấu sắc `M56 22 L70 11` nét 9 (đầu
  tròn); con dấu tâm (86, 84) bán kính 17; chữ `あ` 19, bold, căn giữa con dấu.
- Cỡ 16 và 32 px (cả @1x / @2x của 16): **bỏ con dấu**, chỉ V + dấu sắc, nét dày hơn cho rõ.
- Sinh bằng `scripts/make_icon.swift` (bỏ hoàn toàn hình "ngọn núi" cũ).

## 10. Các màn còn lại (Phase 5d)
Dùng cùng `VKTheme` + thành phần §4; nội dung / tuỳ chọn giữ nguyên, chỉ đổi kiểu.
- **Gõ tắt:** thẻ `TUỲ CHỌN` (3 toggle) · thẻ `THÊM / SỬA GÕ TẮT` (2 ô nhập + nút) · bảng danh sách trong `card` (nền
  phẳng — `Table` của SwiftUI không tô màu hàng theo token; cột "Từ tắt" font monospaced) · thẻ `ĐỒNG BỘ` · nút Nhập / Xuất
  ở chân trang. (Thứ tự thực tế giữ như trang cũ: Tuỳ chọn · Đồng bộ · Thêm / sửa · Danh sách.)
- **Chuyển mã:** thẻ `BẢNG MÃ` (Từ / Sang popup cùng rộng + nút Đảo chiều dạng icon trong hàng `Sang`) · thẻ `CHỮ HOA / CHỮ
  THƯỜNG` (popup — 5 nhãn không vừa `VKSegmented` một hàng) · thẻ `PHÍM TẮT CHUYỂN NHANH` · nút chính `Chuyển mã clipboard`
  nền `accent`.
- **Bố cục chung (chốt ở 5d):** thân trang `VKPageContent`; thẻ chứa trực tiếp `VKSwitchRow` / `VKRow` / `VKDivider`, hàng
  khác đệm 11 × 16 — không bọc thêm `VStack(...).padding`. Nút chính `VKPrimaryButtonStyle`, nút phụ `.bordered`.
- **Clipboard:** thẻ bật / số mục (slider) / phím tắt / cửa sổ; dòng "Đang lưu N mục" + nút Xoá lịch sử. Bảng lịch sử nổi
  (ClipboardPicker): nền `card`, viền `border` (bỏ blur), mục đang chọn nền `accent` + chữ / icon `onAccent` (giữ kiểu chọn
  đặc như hiện tại), mục rê chuột nền `segmentTrack`, ghim và ô "đã ghim" màu `accent`, nhãn loại (ảnh / HTML) viền
  `keycapBorder` + chữ `textSecondary`; bỏ mọi gradient.
- **Hệ thống:** thẻ `KHỞI ĐỘNG`, `BIỂU TƯỢNG`, `CHUYỂN CHẾ ĐỘ THÔNG MINH`, `ỨNG DỤNG LOẠI TRỪ`, `TƯƠNG THÍCH NÂNG CAO`,
  `CẬP NHẬT`; nút `Khôi phục mặc định` kiểu nút viền ở cuối.
- **Giới thiệu:** icon app 96 pt, `VKey` 28 pt bold, `Phiên bản x (build)`, `Phát triển bởi akachick113 · © 2026`, dòng ghi
  công 11 pt `textSecondary`, 3 link `accentText` (Mã nguồn · Ghi công · Giấy phép GPL v3), nút Kiểm tra cập nhật.
- **Chào mừng:** nền `windowBackground`, icon app 96, `Chào mừng đến với VKey` 24 bold, một câu mô tả, thẻ hướng dẫn cấp
  quyền Trợ năng với nút chính nền `accent` `Mở Cài đặt hệ thống`, trạng thái chờ / đã cấp như cũ.

## 11. Kiểm tra giao diện (mọi phase giao diện)
- Chụp màn hình sáng + tối từng màn đã đổi; so với bản vẽ / file này; chữ không cắt ở cửa sổ mặc định.
- Tab / Shift-Tab đi qua mọi control; VoiceOver đọc đúng nhãn của segmented, ô ngôn ngữ, phím.
- Không còn màu viết rời ngoài `VKTheme` (`git grep -n -E 'Color\(red|#[0-9A-Fa-f]{6}|srgbRed' -- Sources/App` chỉ còn trong
  `VKTheme.swift` và `scripts/make_icon.swift`).
