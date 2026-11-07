# Ryn · Hỏa vũ trưởng thành · 0.13

Ryn được thiết kế lại thành nữ thương thủ trưởng thành 27 tuổi: tóc burgundy
buộc cao, giáp đỏ–đen viền vàng, vai mở, váy chiến bất đối xứng có quần short
kín bên trong, bốt cao và thương lửa. Đây là artwork mới tạo riêng, không lấy
nhân vật/ảnh từ game hoặc clip tham khảo. Giữ danh tính Ryn, nguyên tố, lớp và
các chỉ số gốc, không đổi save v5.

## Chân dung và tương tác

`ryn_portrait.png` là bản đầy đủ dùng cho avatar/fallback. `ryn_body.png` giữ
thân/vũ khí; `ryn_back.png` là tóc dài/tà áo sau trên cùng canvas1024×1536. Các
ảnh được tạo/chỉnh qua image generation, giữ byte source, không chroma-key hoặc
cắt alpha bằng code. SHA256 từng ảnh ở `art/painted/ryn_provenance.json`.

Trong portrait, thân/vũ khí nghiêng và nhún cùng nhau; tóc/tà áo có lag vị trí
và góc dao động riêng. Chạm đẩy nhẹ lên, kéo rồi thả có phản lực giảm dần. Ryn
có drag cap22px, rebound cap28px, xung chạm105, spring115, damping8; Eira/Mira
giữ tuning cũ. Pointer/focus/cancel và clamp delta chống giật khi frame dài.
Không sửa RNG, HP, ví hay phát âm từ portrait. Không tạo node/texture mỗi frame.

Nút **Xem Ryn phóng lớn** mở bản tương tác lớn trong modal. Màu trang phục đã
chọn áp dụng cho cả hai layer. Nhân vật5★ gốc có tương tác độc lập Mở rộng.
Đây là chuyển động bằng các lớp 2D, chưa phải rig/mesh deformation hoặc mô
phỏng riêng từng bộ phận cơ thể. Các lớp và pose tạo sinh có khác biệt chi tiết
nhỏ, không coi là pipeline hình học tuyệt đối nhất quán.

![Chạm và kéo thực trong renderer Godot](previews/ryn-touch.gif)
![Chân dung lớn](previews/ryn-portrait-large.png)

## Chiến đấu

Atlas1254×1254, bốn cột/ba hàng, 12 pose: idle2, run2, attack3, skill2, guard1,
hurt1, defeat1. Clip có entry quay lại idle; attack hit_time0,22 và skill0,5 được
motion sampler map sang marker thật của action. BattleModel giữ quyền gây damage.

Region nguồn/anchor explicit trong builder, không chia lưới mù. Hai cell đâm
thương nới region ngang để giữ mũi thương vượt biên danh nghĩa, không lấy actor
bên cạnh. Đã xem contact sheet và thrust trong trận thật. `embedded_weapon`
ngăn vẽ thêm thương thứ hai. Hai mẫu thương trong trang bị cùng dùng hình thương
lửa này, vẫn có stat/trait/element riêng; chưa có silhouette riêng cho từng mẫu.

Run hiện hai keyframe; các trạng thái guard/hurt/defeat có một pose, không phải
animation hàng chục in-between đã polish hoàn toàn. Bộ Ryn mới được lưu trong
builder nền để `build_combat_manifest.py` không xóa override khi tái tạo Eira/VFX.
Avatar chọn nhân vật dùng crop mặt từ portrait, không còn mặt SVG cũ.

![Ryn trong trận](previews/ryn-battle-thrust.png)
![Màn Nhân vật](previews/ryn-character.png)

## Kiểm chứng

Godot4.6.3 Linux X11/Mesa: ryn_art kiểm tuổi/texture/12 region/duration/cờ weapon,
drag/rebound cap, settle và tap mạnh hơn tuning cũ; ryn_gallery render avatar,
composite portrait, modal lớn và thrust từ action thật. ryn_motion_capture ghi
90 frame tap/drag từ renderer, FFmpeg ghép GIF20fps ở trên.

Regression81, mechanics54 tổ hợp, campaign5 màn, painted_art, combat_presentation
và portrait_touch đạt. Chạy ui_flow, character_ui và animation_gallery trên display,
xem ảnh thực. Test dùng profile riêng. Chưa thử touch/hiệu năng/nhiệt trên điện
thoại thật. Không thay âm thanh. Mira và một số vùng/quái vẫn là SVG.
