# Cảm giác chiến đấu · 0.6

## Nội dung

- Eira: 32 pose nguồn, 39 entry có duration trong 7 trạng thái. Thêm 16 pose chuyển tiếp cho chạy, vung kiếm, thủ thế, niệm phép, thở và trúng đòn. Giữ kiếm theo socket tay; nội suy góc kiếm giữa pose. Đây vẫn là sprite animation, không phải rig xương.
- Cổ thụ ải đầu: 8 pose cho đứng, tụ lực, giáng đòn và hồi thế. Các boss vùng khác vẫn dùng artwork SVG hiện có.
- Atlas 16 mẫu hiệu ứng: ba vệt kiếm, va chạm, tinh linh, vòng hồi phục, cánh sáng, hạt sáng, khiên, nứt/vỡ khiên, sóng chấn động, bụi, cảnh báo và năng lượng niệm phép.
- Eira lướt tới ở marker sát thương, thu người về sau đòn; phản ứng giật lùi khi trúng đòn. Rung hình tối đa 3,2 px, chỉ trong khung trận; HUD đứng yên. Cảnh báo boss đặt dưới người chơi vì đòn hiện tại luôn đánh vào người chơi, không giả vờ có cơ chế né vùng.
- Giữ hoạt ảnh cuối đòn, quái tan và pose thua trước khi mở kết quả sau 0,65 giây. Tiến trình/phần thưởng được ghi ngay khi trận kết thúc.

## Đồng bộ và giới hạn

BattleModel vẫn quyết định damage, marker, cooldown và phần thưởng. Event mang snapshot hành động, thời gian và wave cho renderer. CombatPresentation/CombatEffects chỉ đọc; không tiêu thụ RNG chiến đấu, không phát âm. AudioDirector tiếp tục tiêu thụ cue ElevenLabs từ model một lần. Không gọi API tạo âm mới, không thêm key hoặc phí runtime.

Hiệu ứng dùng cursor theo run/event ID, trần 96 phần tử, tự hết hạn; pause giữ nguyên thời gian. ×1/×2/×3 dùng cùng marker mô phỏng; số nổi giữ thời gian đọc gần tương đương. View reset cả khi retry cùng run ID bằng cách theo dõi instance trận.

PNG được tạo riêng bằng công cụ tạo ảnh. Giữ file nguồn, region và hash trong `art/combat/`; không nhập asset game tham khảo. Bộ Eira trung gian đầu tiên bị loại vì tỷ lệ đầu quá lớn. Builder hiện tại: `python tools/build_combat_manifest.py`.

## Bằng chứng kiểm tra

Godot 4.6.3, Linux, renderer Compatibility/X11/Mesa:

- regression: 81 assertions; mechanics: 15 tổ hợp hero/ải; campaign: đủ 5 ải.
- audio: 93 assertions; validate_audio: 38 SFX ElevenLabs cùng raw/receipt; không đổi âm lượng hoặc file âm.
- painted_art: 32 pose nguồn / 39 entry; ui_flow, animation_gallery, painted_gallery được render và xem ảnh.
- combat_presentation: read-only HP/SP/RNG/cooldown/event, pause, cursor dedupe, cap VFX, reset, marker remap, lunge recovery ở ×1/×2/×3.
- combat_scenarios: 9 ảnh của slash, burst, heal, cảnh báo boss, guard/slam, khiên, vỡ khiên, phản đòn và thua. Đây là fixture thử các trạng thái, không phải toàn bộ ảnh chụp từ một lượt chơi tự nhiên.
- combat_movie: một trận ải 1 từ profile mới với seed cố định; điều khiển qua API đánh/guard/skill thực, không sửa HP/chỉ số. Kiểm thắng, lưu kết quả và modal trễ. Video 475 frame / 30 FPS, dài 15,83 giây, ghi hình và mixer bằng Godot Movie Maker rồi nén H.264/AAC. Đã xem các frame trích xuất; không xem việc kiểm PCM là đã nghe qua loa.

[Video có âm thanh](previews/combat-demo.mp4) · [Va chạm kiếm](previews/combat-impact.png) · [Boss tụ lực](previews/combat-telegraph.png) · [16 pose mới](previews/eira-motion.png)

Chưa thử điện thoại, touch thật, FPS/nhiệt trên thiết bị hoặc nghe qua loa thật. Ryn/Mira/Ash và các vùng ngoài rừng còn SVG. Chuyển pose sprite vẫn có thể nhận ra, chưa phải animation mượt như game thương mại.
