# Aternal Senia — First Light · 0.4

Game Godot 4 màn hình dọc, chiến đấu một nhân vật chính + một trợ chiến.
Tham khảo cấu trúc Eternal Senia 2; nội dung, công thức và hình ảnh trong game
được tạo riêng. Đây là bản chơi hoàn chỉnh nhỏ với các hệ thống chính, chưa phải
bản thương mại hoặc bản phục hồi toàn bộ nội dung game gốc.

## Chơi

Mở `project.godot` bằng **Godot 4.6.x**, đợi import rồi nhấn **F5**.
Hoặc `godot --path .` sau khi import. Chọn Hành trình → Vào ải → Tiến vào.

- Tự đánh hoặc tap nhân vật / nút Đánh để nối combo ba nhịp.
- Ba kỹ năng dùng SP: đòn mạnh, hồi phục, tinh linh phá khiên. SP tự hồi.
- Bấm Thủ thế ngay trước khi vòng cảnh báo đầy: giảm 80% sát thương trong 0,7s.
- Boss có đòn nặng, khiên hoặc phản đòn. Ngưng kỹ năng lúc phản đòn.
- Dừng/tiếp tục, tốc độ ×1/×2/×3 và bật/tắt âm. Nút ♫ mở mức hiệu ứng/tiếng rừng và nghe thử.
- Các trang quản lý chiếm toàn màn hình; mở chúng trong trận sẽ tạm dừng trận.

## Nội dung hiện có

| Hệ thống | Nội dung chơi được |
|---|---|
| Nhân vật | Eira, Ryn, Mira; nội tại và chỉ số riêng; mở sau ải 1/2 |
| Trợ chiến | Lumi hồi máu, Ash tấn công; tăng cấp riêng |
| Vũ khí | 6 mẫu kiếm/thương/trượng; giới hạn theo nhân vật; đổi hình khi trang bị |
| Trang bị | 3 món giáp; UID riêng; cường hóa +10, tiến bậc 3, rèn, phân giải |
| Kỹ năng | 3 kỹ năng × 10 cấp; SP, cooldown, windup/hit/recovery |
| Bản đồ | 5 khu vực, mỗi khu 2 đợt quái + boss; mở tuần tự, đánh lại |
| Phần thưởng | Vàng, XP, tinh thạch, loot; thưởng lần đầu; túi 40 ô, đổi loot dư |
| Mục tiêu | 5 nhiệm vụ nhận một lần; 10 đoạn truyện và nhật ký xem lại |
| Tiếp tế | Tích theo thời gian thực, kể cả khi đóng game; trần 2 giờ |
| Trình bày | Eira 16 pose PNG / 6 trạng thái, kiếm Dawnveil, Lumi, rừng đêm và quái rừng mới; Ryn/Mira và các vùng khác còn SVG; 38 SFX mới + loop tiếng rừng |

Tăng cấp nhân vật dùng vàng + XP. Nâng kỹ năng/trợ chiến dùng vàng. Nâng trang
bị dùng vàng + tinh thạch. Vũ khí bậc hiếm giảm hồi chiêu 8%; hệ khắc chế tăng
20% sát thương (quy tắc mới, xem tài liệu hệ thống).

## Lưu tiến trình

Save mới: `user://first_light_v2.json`; tự chuyển vàng và cấp Eira từ v1, giữ
nguyên file cũ. Ghi qua file tạm, kiểm dữ liệu, tạo `.bak` rồi thay file chính.
Save lỗi được giữ lại; nếu backup hợp lệ sẽ phục hồi. Save của phiên bản mới hơn
bị khóa ghi. Lỗi nâng cấp/nhận thưởng không đổi ví trong RAM; có thể thử lại.

Thoát giữa trận: lần sau được chạy lại trận từ snapshot đã lưu, cùng seed. Rút
lui không thưởng. Thưởng theo run ID, nhiệm vụ và tiếp tế không nhận trùng.
Đây là game offline: đồng hồ máy ảnh hưởng tiếp tế, không có chống chỉnh giờ.

Biến `FIRST_LIGHT_SAVE_DIR` chọn thư mục save riêng để thử mà không chạm profile
người chơi. Không đổi tên project nếu muốn giữ đúng vị trí `user://`.

## Kiểm tra

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script tests/regression.gd
godot --headless --path . --script tests/mechanics.gd
godot --headless --path . --script tests/campaign.gd
# Cần màn hình hoặc Xvfb; ảnh mặc định tại user://first_light_previews:
godot --path . --script tests/ui_flow.gd
godot --path . --script tests/animation_gallery.gd
```

Tests dùng profile riêng. Có thể đặt `FIRST_LIGHT_CAPTURE_DIR` để chọn nơi lưu
ảnh. `tests/smoke.gd` vẫn chạy được và chuyển sang bộ regression mới.

Đã kiểm trên Godot 4.6.3 / Linux: 81 assertions hồi quy, cơ chế boss, 15 tổ hợp
nhân vật/ải, chiến dịch đủ 5 ải từ profile mới chỉ dùng thưởng kiếm được; kiểm UI
render thực với X11/Mesa và xem ảnh. Chưa thử Android/iOS, touch thật hoặc đo
FPS/nhiệt. Audio đã được ghi từ mixer thật qua AudioEffectRecord với driver Dummy, kiểm PCM và clipping; chưa nghe qua loa thật.

## Tài liệu và công cụ

- [Đối chiếu repo tham khảo](docs/REFERENCE_MAP.md): nguồn, bằng chứng, giới hạn.
- [Kiến trúc và công thức](docs/SYSTEMS.md).
- [Pipeline frame / vũ khí](docs/ART_PIPELINE.md).
- `tools/build_catalog.py`, `tools/build_art.py`, `tools/build_audio.py`: tái tạo nội dung mẫu. `tools/build_painted_manifest.py` tái tạo metadata cho artwork PNG được giữ nguyên.

## Tạo hình 0.3 · Eira và rừng đầu tiên

![Eira và cổ thụ trong game](docs/previews/eira-battle.png)

Eira có tóc bạc, áo choàng xanh tím, giáp ngà và tinh thể bình minh. Atlas có
16 pose vẽ riêng; kiếm Dawnveil gắn theo socket từng pose, có lớp bàn tay che
cán. Lumi, slime, sói và boss cổ thụ có artwork mới, boss đổi pose khi tụ lực.
Nền rừng đã thay bằng tranh đêm xanh sâu với phế tích và ánh vàng ấm.

- [Concept Eira](docs/concepts/eira-design.png)
- [Đủ 16 pose trong renderer](docs/previews/eira-poses.png)
- Mở `tools/pose_lab.tscn`, nhấn F6: phát/dừng, tiến/lùi frame, seek,
  ×0.25/×0.5/×1/×2/×3, đổi hai kiếm, hiện điểm neo.
- `tests/painted_art.gd` kiểm manifest/sockets/seek; `tests/painted_gallery.gd`
  chụp toàn bộ pose. PNG gốc và provenance nằm ở `art/painted/`.

Đây là lượt mỹ thuật đầu cho Eira và khu rừng. Ryn, Mira, Ash và các khu vực
khác vẫn dùng hình mẫu SVG, cần làm tiếp cùng phong cách. Animation Eira hiện
có 4 pose chạy và 4 pose đánh chính, chưa phải animation nhiều frame đã tinh
chỉnh hoàn toàn; có khác biệt nhỏ về nếp áo/chi tiết giữa các pose tạo hình.
Chưa có APK, nhạc nền dài hoặc nội dung dài hàng trăm ải. Không kèm tài nguyên gốc
trích từ archive nghiên cứu.

## Âm thanh 0.4

Bộ SFX riêng khớp marker: tiếng vung/trúng theo vũ khí, chí mạng, kỹ năng,
trợ chiến, thủ thế, khiên, boss và UI. Có 38 WAV / 34 cue và loop rừng stereo,
pool voice và limiter chống âm dồn. Mute tức thì; pause dừng âm combat, UI vẫn
nghe được. Volume độc lập, preview/áp dụng/hủy, tương thích save cũ.

[Xem cách áp dụng quy tắc từ repo tham khảo](docs/AUDIO.md) ·
[Nghe đoạn ghi trong game](docs/audio/combat-preview.wav) ·
[Ảnh bảng chỉnh âm](docs/previews/audio-settings.png).

Kiểm thêm: `godot --headless --path . --script tests/audio.gd` (93 checks) và
`python3 tests/validate_audio.py`. Các file âm tự tổng hợp, không nhập audio gốc.
