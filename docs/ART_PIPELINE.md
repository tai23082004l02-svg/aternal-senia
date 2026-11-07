# Pipeline tạo hình 0.3

Âm thanh mới từ 0.4 được mô tả riêng tại [AUDIO.md](AUDIO.md).

## Định hướng

Anime fantasy 2D hơi chibi: Eira tóc bạc, cape xanh tím lót ngà, giáp nhẹ ngà,
vàng ấm/tinh thể bình minh. Không rig. Artwork gốc tạo riêng bằng image generation;
Eternal Senia 2 chỉ là tham khảo cách tổ chức frame, không dùng asset trích từ game.

Lượt đầu tập trung hoàn chỉnh Eira + kiếm + Lumi + rừng và quái đầu. Ryn/Mira/Ash,
4 nền khác và một số boss vẫn là SVG mẫu; chưa coi toàn game đã thay mỹ thuật.

## Hai pipeline cùng tồn tại

`art/clips.json` và `tools/build_art.py` giữ bộ SVG mẫu 192×240, anchor (96,216).
`art/painted/manifest.json` override Eira ở FrameLibrary, không sửa danh tính hero,
item hoặc save. `tools/build_painted_manifest.py` chỉ tạo metadata, không vẽ lại
PNG và không xóa nguồn. Provenance ghi SHA256 từng PNG. Concept trong docs/concepts.

Bộ nền 0.3 có **16 ảnh pose nguồn, 21 entry có duration trong 6 clip** (0.6 mở rộng thành 32 pose / 39 entry / 7 clip; xem [COMBAT_FEEL.md](COMBAT_FEEL.md)):
- idle 2 pose (4 entries lặp nhẹ), run 4 pose;
- attack anticipation/windup/impact/recovery và một entry idle;
- skill cast/release/recovery/idle;
- hurt/recovery và kneel/defeat.

Từng frame có atlas, region, size, source anchor, hand socket, angle, grip_rect
và render_scale. Atlas 1254×1254 không chia nguyên cho 4: dùng các region pixel
đã ghi rõ (313/314 px), không chia lưới số nguyên rồi bỏ cột. Đã xem từng vùng
và bốn mép để tránh lấy sang pose khác. Rect không suy từ alpha bounding box.
Anchor được đặt theo chân/đường đất của từng pose, không căn giữa ảnh đã cắt.
Không có alpha trimming trong pipeline mới. `AtlasTexture.filter_clip` chống
lọt pixel ô lân cận khi sampling.

## Kiếm và bàn tay

Dawnveil là PNG riêng, blade hướng lên, điểm cầm ở (512,1225) trên canvas
1024×1536. Weapon scale nhân với character scale; angle lấy từ pose. Sword_1 và
sword_2 dùng cùng hình học, tint lạnh/ấm khác nhau, chưa có silhouette thứ hai.
`draw_actor` dùng chung cho battle, portrait, gallery và Pose Lab để tránh lệch
công thức. Vẽ nhân vật → vũ khí → vùng grip của bàn tay che lại cán, nên kiếm
không nổi trước ngón tay. Pose chết không vẽ kiếm.

Renderer hỗ trợ size/anchor riêng; không ép atlas vuông vào canvas SVG 192×240.
Hurt dùng thời gian kể từ lúc bị đánh, thay vì clock action cũ. Death có clock
trình bày riêng khi mô phỏng đã dừng. Không ảnh hưởng HP, hit hoặc phần thưởng.

## Quái, trợ chiến và nền

Forest enemies có vùng nguồn chọn riêng cho slime/sói/cổ thụ/cổ thụ tụ lực.
Không dùng lưới 2×2 mù: cành boss vượt qua đường giữa, region đã hiệu chỉnh tránh
cắt cành hoặc lấy ảnh từ hàng khác. Idle/charge có anchor và scale riêng.
Lumi là một sprite riêng, bob nhẹ theo battle clock; chưa có bộ wing animation.
Nền rừng là tranh tĩnh, chưa tách parallax. Các giới hạn này được giữ rõ.

## Alpha và kiểm trực quan

Atlas Eira đầu tiên trông có RGB fringe khi xem raw, nhưng compositing alpha
trên nền tối ở Godot sạch. Một phiên bản cleanup khác có nền mờ thật trong
runtime đã bị loại, không commit. Giữ nguyên PNG được chọn, không tự chroma-key,
threshold alpha hoặc bóp méo artwork để che lỗi. Đã xem runtime ở nền rừng và
contact sheet tất cả 16 pose gắn kiếm, bao gồm windup, impact và death.

Không tuyên bố các pose tạo sinh có độ nhất quán tuyệt đối: có khác biệt nhỏ
ở chi tiết cape/giáp; run hiện 4 pose, cần tiếp tục tinh nhịp và in-between nếu
muốn chuyển động mượt hơn. Timing mới do dự án đặt, không phải timing gốc.

## Công cụ xem và kiểm

- `tools/pose_lab.tscn` (F6): sáu trạng thái, phát/dừng, tiến/lùi frame, thanh
  seek, ×0.25/×0.5/×1/×2/×3, hai kiếm và overlay điểm chân/tay.
- `tests/painted_art.gd`: bounds, socket, timed entries và command của Pose Lab.
- `tests/painted_gallery.gd`: contact sheet hai trang đủ 32 pose, render cùng helper game.
- `tests/animation_gallery.gd`: ba hero × sáu trạng thái, pipeline hỗn hợp.
- `tests/ui_flow.gd`: chạy game thật, tab/truyện/trận/boss/result.

Đã chạy Godot 4.6.3 Linux X11/Mesa, xem ảnh render. Không suy ra đã thử touch thật
hoặc FPS/nhiệt điện thoại. Không có thay đổi audio trong mốc này.
