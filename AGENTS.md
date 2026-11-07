# Hướng dẫn dự án

- Đây là game mới Godot 4, main hero + assist, màn hình dọc đang là mặc định.
- Đọc README và docs trước khi sửa. Nội dung riêng, không nhập nguyên asset game gốc.
- Giữ save người chơi; test bằng profile riêng. Không đổi tên project tùy tiện.
- ProgressStore commit trước khi đổi RAM; run snapshot, UID và reward idempotency phải được giữ.
- BattleModel owns hit timing; View/FrameLibrary không được sửa HP hoặc ví.
- Không tự thêm rig, SDK, quảng cáo, server, phí runtime hoặc phá save.
- Chạy regression.gd, mechanics.gd, campaign.gd sau sửa logic. Với UI/art, chạy ui_flow.gd / animation_gallery.gd trên display và xem ảnh.
- Báo đúng giới hạn: Eira/rừng có PNG mới; Ryn/Mira/Ash và vùng khác còn SVG. Chưa test điện thoại thật hoặc nghe audio.
- Fetch/status trước khi đẩy; không force push, không ghi đè thay đổi của người khác.

- Âm thanh: đọc docs/AUDIO.md. Model phát cue theo marker; View/Pose Lab không phát âm.
- Không dùng RNG chiến đấu để chọn âm. Mute phải dừng voice và tiêu thụ cursor; không phát lại backlog.
- Audio dùng bus/pool riêng; không tăng số node vô hạn, giữ priority/limiter và save volume tương thích v2.
- Sau sửa audio chạy tests/audio.gd và tests/validate_audio.py; kiểm mixer qua audio_capture.gd nếu đổi gain/asset/UI. Kiểm PCM không đồng nghĩa đã nghe loa thật.

- Từ 0.5, 38 SFX + ambience dùng ElevenLabs; giữ raw MP3/receipt/provenance. Không tự đổi lại synth Python. tools/build_audio.py phải từ chối ghi đè provider audio.
- Không đưa ElevenLabs key vào runtime, log hoặc source. Generation dùng secret tại GitHub; hậu kỳ local không cần key. Không tự retry request trả phí.
