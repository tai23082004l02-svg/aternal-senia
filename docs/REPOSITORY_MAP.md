# Bản đồ repo

| Đường dẫn | Nội dung/ghi chú |
| --- | --- |
|project.godot|Entry Godot, version0.37.0, canvas540×960, Compatibility; giữ config/name|
|AGENTS.md|Quy tắc ngắn cho mọi phiên chat phát triển|
|README.md|Cách chạy, trạng thái và lối vào tài liệu|
|game/main.tscn, game/main.gd|Khởi động, điều hướng/callback, nối model/view/audio|
|game/core/|Model, catalogue, lưu/giao dịch, chiến đấu, đội hình, phát triển, cài đặt|
|game/data/|JSON nguồn runtime;18 stage thực ghép từ catalog+expansion,15 preview riêng|
|game/*screen.gd|Các màn Godot, chữ/control thật, SwipeScroll cho vùng dài|
|game/core/frame_library.gd|Load manifest/fallback rồi PNG override; không xóa SVG theo suy đoán|
|art/painted, art/combat, art/complete, art/ryn|Battle sprite, chân dung/layer, nền/quái/vũ khí, manifest/socket|
|art/banners, character_panels, bag, dungeons, summon, settings|Tranh UI nguồn, giữ byte và provenance|
|art/icons, equipment, ui, supplies|Atlas icon/khung/đạo cụ; registry chung106 vùng|
|art/audio/|46 WAV runtime, ambience/music Ogg, manifest/provenance|
|art/audio/elevenlabs/|Raw MP3, request/receipt, hash, kể cả lỗi lịch sử; cần để xác minh/tái nhập|
|art/*.svg, art/clips.json|Fallback/metadata còn được runtime load; không phải cache|
|docs/concepts/|Concept nhân vật Eira được hồ sơ canon tham chiếu|
|docs/|Trạng thái, chuyên đề, hướng dẫn, biên bản nhỏ; mục lục ở INDEX.md|
|docs/history/|Chỉ tài liệu mô tả cơ chế cũ, không phải yêu cầu khôi phục|
|docs/verification/|5 JSON chứng cứ đã phát hành, không chứa ảnh/video/PCM|
|tests/|Kiểm tra logic/UI/art/audio và công cụ capture; giữ .gd.uid|
|tools/|Builder/validator/importer, runner chung, Pose Lab và xuất Android|
|.github/workflows/verify.yml|CI read-only, import/kiểm/render, artifact; không tự push hoặc tạo âm trả phí|
|work/|Output local/CI: ảnh, log, PCM, results; ignore, không commit|
|exports/, dist/, build/|Output phát hành cục bộ; ignore, không phải nguồn|

## Công cụ

- `check_project.py`:40 suite mặc định; có chọn tên test, timeout, emits review khi cần.
- `verify_repo.py`:kiểm tham chiếu literal, link nội bộ, file sinh ra, inventory JSON.
- `export_android.sh`:xuất HEAD chỉ gồm project/game/art sang thư mục mới.
- `pose_lab.tscn`/`pose_lab.gd`:xem frame/socket, không đổi model hoặc phát âm.
- `build_catalog.py`, `build_equipment.py`, `build_expansion.py`:dữ liệu gameplay.
- `build_*manifest.py`, `build_complete_art.py`, `build_*art.py`:metadata đã duyệt.
  Riêng `build_art.py` là generator SVG prototype cho fallback, không tạo mỹ thuật mới.
- `import_*audio.py`:hậu kỳ nguồn ElevenLabs sẵn có, không gọi generation API.
- `build_audio.py`:guard an toàn cho tên lệnh prototype cũ; không còn mã synth.

Tài nguyên chưa dùng trực tiếp có thể là nguồn tham chiếu, dữ liệu migration, fallback,
raw hoặc input builder. Muốn xóa phải tìm cả literal lẫn manifest/đường dẫn động.
Chỉ đổi cấu trúc thư mục runtime khi có cập nhật tất cả tham chiếu và kiểm import.
