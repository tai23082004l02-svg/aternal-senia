# Hướng dẫn dự án

- Đây là game mới Godot 4, main hero + assist, màn hình dọc đang là mặc định.
- Đọc README và docs trước khi sửa. Nội dung riêng, không nhập nguyên asset game gốc.
- Giữ save người chơi; test bằng profile riêng. Không đổi tên project tùy tiện.
- ProgressStore commit trước khi đổi RAM; run snapshot, UID và reward idempotency phải được giữ.
- BattleModel owns hit timing; View/FrameLibrary không được sửa HP hoặc ví.
- Không tự thêm rig, SDK, quảng cáo, server, phí runtime hoặc phá save.
- Chạy regression.gd, mechanics.gd, campaign.gd sau sửa logic. Với UI/art, chạy ui_flow.gd / animation_gallery.gd trên display và xem ảnh.
- Báo đúng giới hạn: Eira/Ryn/Ash/rừng/phế tích/hồ có PNG; Mira, núi/tháp và một số quái còn SVG. Ryn là người trưởng thành 27 tuổi, portrait có lớp thân và tóc/tà áo; 12 pose chiến đấu bakespear. Ash chuyển động bằng transform một sprite. Chưa test điện thoại thật hoặc nghe audio.
- Fetch/status trước khi đẩy; không force push, không ghi đè thay đổi của người khác.
- Thuộc tính 0.8: chạy tests/attribute_training.gd khi sửa điểm hoặc stats; tests/training_ui.gd khi sửa màn thuộc tính/sổ tay. Trường training bổ sung trong save v3 là tùy chọn; save cũ giữ nguyên và có điểm chưa phân bổ theo cấp. Khóa build khi còn pending run.
- Từ 0.9 save v4 đọc v2/v3, giữ nguyên pending snapshot; cây Tinh linh lưu riêng theo assist. Chạy tests/recruitment.gd, tests/skill_effects.gd, tests/progression_ui.gd và tests/skill_gallery.gd khi sửa tính năng mới. Triệu hồi dùng RNG riêng seed/count đã lưu, chi phí + pity + reward cùng transaction; không thêm RNG vào renderer.
- Từ 0.12 save v5 đọc v2/v3/v4. Hero 5★ là độ hiếm catalogue, tương tác thiết kế sẵn theo mẫu; không dùng awakening/sao mở rộng để mở khóa tương tác. Nhóm đối thủ 1–4★ ở catalogue opponents. Trang bị 1–7, tinh linh SR/SSR/UR; ba hệ độc lập. Shop quảng cáo/gói thanh toán chưa có dịch vụ, không tự thêm SDK hoặc phát thưởng giả. Đọc docs/SHOP_RARITY_CHARACTER.md và chạy rarity_system, wardrobe, portrait_touch, shop_ui, character_ui khi sửa các phần này.
- Ryn 0.13: đọc docs/RYN_ART.md; chạy tests/ryn_art.gd và tests/ryn_gallery.gd khi sửa ảnh/nhún. Pose embedded_weapon không vẽ thêm spear rời. Builder nền phải giữ metadata Ryn khi combat builder chạy lại. Không chỉnh pixel source PNG bằng code hoặc tự thêm rig.

- Âm thanh: đọc docs/AUDIO.md. Model phát cue theo marker; View/Pose Lab không phát âm.
- Không dùng RNG chiến đấu để chọn âm. Mute phải dừng voice và tiêu thụ cursor; không phát lại backlog.
- Audio dùng bus/pool riêng; không tăng số node vô hạn, giữ priority/limiter và save volume tương thích v2.
- Sau sửa audio chạy tests/audio.gd và tests/validate_audio.py; kiểm mixer qua audio_capture.gd nếu đổi gain/asset/UI. Kiểm PCM không đồng nghĩa đã nghe loa thật.

- Từ 0.5, 38 SFX + ambience dùng ElevenLabs; giữ raw MP3/receipt/provenance. Không tự đổi lại synth Python. tools/build_audio.py phải từ chối ghi đè provider audio.
- Không đưa ElevenLabs key vào runtime, log hoặc source. Generation dùng secret tại GitHub; hậu kỳ local không cần key. Không tự retry request trả phí.
