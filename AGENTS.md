# Hướng dẫn dự án

- Đây là game mới Godot 4, main hero + assist, màn hình dọc đang là mặc định.
- Đọc README và docs trước khi sửa. Nội dung riêng, không nhập nguyên asset game gốc.
- Giữ save người chơi; test bằng profile riêng. Không đổi tên project tùy tiện.
- ProgressStore commit trước khi đổi RAM; run snapshot, UID và reward idempotency phải được giữ.
- BattleModel owns hit timing; View/FrameLibrary không được sửa HP hoặc ví.
- Không tự thêm rig, SDK, quảng cáo, server, phí runtime hoặc phá save.
- Chạy regression.gd, mechanics.gd, campaign.gd sau sửa logic. Với UI/art, chạy ui_flow.gd / animation_gallery.gd trên display và xem ảnh.
- Báo đúng giới hạn: SVG cơ bản, chưa test điện thoại thật hoặc nghe audio.
- Fetch/status trước khi đẩy; không force push, không ghi đè thay đổi của người khác.
