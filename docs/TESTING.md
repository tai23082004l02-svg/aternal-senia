# Kiểm tra và chứng cứ

Godot chuẩn **4.6.3**. UI/capture cần màn hình thật hoặc Xvfb/X11; headless không
phát RenderingServer.frame_post_draw. Linux/Xvfb/PCM không xác nhận điện thoại thật.

## Chuẩn bị Linux

Cài Godot4.6.3, Xvfb, Mesa, thư viện âm thanh và ffmpeg.
Python validator chỉ cần numpy; importer audio dùng thêm scipy:
`python3 -m pip install -r tools/requirements-audio.txt`.
CI dùng Python/numpy hệ thống Ubuntu, không gọi API tạo tài nguyên.

## Bộ kiểm tra chung

```bash
python3 tools/verify_repo.py
python3 tools/validate_english.py
godot --headless --editor --path . --import
xvfb-run -a python3 tools/check_project.py
python3 tests/validate_audio.py --capture work/checks/audio_capture/audio-runtime.wav
git diff --exit-code
```

Runner48 suite:45 suite trước đó cộng character_previews, caelan và caelan_ui; caelan_gallery chạy thêm khi xem pose/socket. Mỗi test dùng profile riêng,
stdout/stderr và timeout75 giây, không bỏ qua assertion/parse error.
Ảnh/PCM/log/results ở **work/checks/**; thư mục có .gdignore, không commit.
Giữ import log khi cần, không in API token hoặc toàn bộ save người chơi.

Workflow [.github/workflows/verify.yml](../.github/workflows/verify.yml) chạy trên
main/PR và nhánh dọn repo, contents:read. Kiểm JSON/link/resource, Python syntax,
import bản đầy đủ và bản xuất Android,48 suite, hash ElevenLabs và mixer.
Artifact Project verification giữ7 ngày. Không tự commit screenshot hoặc push nhánh.

## Chạy tập trung

```bash
godot --headless --path . --script tests/regression.gd
xvfb-run -a python3 tools/check_project.py --tests supplies supplies_ui mobile_inventory
xvfb-run -a python3 tools/check_project.py --tests team_battle team_matrix team_campaign team_flow team_ui
xvfb-run -a python3 tools/check_project.py --tests character_design character_ui equipment_ui ui_flow animation_gallery
```

Có thể thêm tên test ở tests/ bằng --tests; --timeout chỉnh giới hạn.
--emit-reviews dành cho phiên chat cần xem JPEG qua log CI; mặc định tắt để tránh log
base64 nặng. Các test gallery chuyên sâu và tương thích save cũ vẫn giữ; ba recorder legacy đã bỏ ở0.38, xem CLEANUP_0_38.md.

| Thay đổi | Test bổ sung trọng tâm |
| --- | --- |
|Save/economy/migration|regression, mechanics, campaign, bag_inventory, unique_collection, supplies|
|Gear/bộ mới|equipment_sets, equipment_ui, additional_equipment, additional_equipment_ui|
|Triệu hồi|recruitment, summon_batch, summon_ui, shop_ui|
|Đội hình/combat|team_battle, team_matrix, team_campaign, team_flow, team_ui, formation_layout|
|Hero/portrait|character_design, character_ui, wardrobe, portrait_touch, ryn_art, ryn_gallery, lyra|
|Nguồn/manifest/icon|complete_art, icon_gallery, suite art/galleries liên quan; xem ảnh|
|Cuộn/UI|swipe_scroll, mobile_inventory, ui_flow, animation_gallery và suite màn sửa|
|Nhiệm vụ/hồ sơ|missions, missions_ui, mission_polish, player_profile, utilities_ui|
|Cài đặt/audio|settings, settings_audio, settings_ui, audio, additional_audio, music, audio_capture, validate_audio.py|

Không chạy lại mọi bài sau mỗi sửa câu chữ; chọn theo rủi ro. Đợt dọn repo xóa
media và hợp nhất CI nên kiểm cả import/assets, bộ40 và bản xuất điện thoại.

## Bằng chứng cũ

Các JSON nhỏ giữ ở [verification/](verification/); có commit nguồn/lượt CI.
Ảnh/video/đoạn ghi cũ dùng [ARCHIVED_MEDIA](ARCHIVED_MEDIA.md), không phải chứng cứ
cho giao diện của commit mới. Kết quả mới nhất cần dẫn đúng workflow run/artifact.
