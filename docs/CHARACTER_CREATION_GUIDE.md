# Quy trình tạo và tích hợp nhân vật

Đọc [CHARACTER_BIBLE.md](CHARACTER_BIBLE.md) và [AGENTS.md](../AGENTS.md) trước.
Đây là hướng dẫn thực hiện cho phiên chat sau; không thay yêu cầu người dùng.

## 1. Kiểm tra đầu vào

Kiểm tra branch/HEAD và thay đổi chưa commit trước khi sửa. Đọc yêu cầu mới,
catalogue, manifest và builder; xem PNG thực tế, không chỉ tên file hoặc mô tả
chat. Chọn ảnh chuẩn từ bộ đang dùng. Đặc biệt: Ryn tóc ngang vai, Lyra đuôi
ngựa cao; Ash là phượng lửa. Phân biệt thiết kế lại một ID với thêm hero mới.

Ghi brief: ID/tên, tuổi đã xác định hoặc chưa chốt, vai trò/hệ, silhouette tóc,
mặt, bảng màu, trang phục, vũ khí, nguồn tham chiếu, pose và đầu ra cần làm.
Giữ save/chỉ số khi yêu cầu chỉ thay tạo hình. Không cần tự tạo một lượt xin
duyệt mới cho các bước người dùng đã cho phép.

## 2. Tạo ảnh nguồn

Dùng công cụ image generation cho ảnh mới và chỉnh ảnh; khi sửa ảnh local,
xem ảnh trước và đưa đúng ảnh chuẩn làm reference. Không tạo hình từ mô tả
trống nếu đã có mẫu Eira/Mira và mẫu nhân vật cần giữ. Không dùng Python để
vẽ lại, chroma-key, xóa alpha hay thay pixel PNG nguồn. Các script builder tạo
metadata, không phải công cụ thay tranh vẽ tay bằng SVG.

Mẫu prompt nền, điền brief cụ thể và kèm ảnh chuẩn thực tế:

> Original2D hand-painted fantasy anime game character, compact battle sprite
> about3.4 heads tall. Match the attached Eira/Mira reference in line weight,
> painted shading, ivory light armor, fabric detail and warm metal highlights.
> Character: [ID, identity, hair, eyes, outfit, palette]. Preserve the same face,
> costume and proportions across all views. Full body, readable silhouette,
> consistent foot baseline, transparent background. [Required pose/layout].

Với Ryn thêm: adult27, shoulder-length wavy burgundy hair, small side braid,
gold phoenix pin, amber eyes, ivory armor, charcoal high-neck underlayer,
short crimson/navy split-tail cape with gold trim. No long high ponytail.
Với Lyra giữ adult24 và long high auburn ponytail. Không tự dùng hai brief đổi
cho nhau. Mẫu prompt chỉ là khởi điểm; ảnh duyệt và hồ sơ mới là chuẩn kiểm.

Ảnh chiến đấu dùng vũ khí rời: yêu cầu bàn tay/pose cầm đúng hướng nhưng không
vẽ liền vũ khí. Chân dung có thể có vũ khí trong lớp thân, như Ryn hiện tại.
Tạo đủ idle, run, attack, skill, guard, hurt, death. Số frame theo brief; không
giảm pose đang có mà không nêu rõ. Duyệt atlas cả ở kích thước thật trong game.

Lưu nguồn được chọn vào `art/` ổn định; ghi phương pháp, ảnh tham chiếu, ngày
và SHA256 trong provenance. Không để runtime phụ thuộc đường dẫn tạm của công
cụ tạo ảnh. Giữ byte nguồn PNG đã chọn; sửa cần tạo nguồn mới và cập nhật hash.
Không commit khóa API hoặc thông tin xác thực.

## 3. Atlas, anchor và vũ khí

Đọc kích thước ảnh thật trước khi chia region. Ví dụ atlas Ryn1254×1254 chia
4×4 có ranh0,314,627,940,1254; không phải mọi ô đều rộng314. Region có thể cần
thu theo pose để tránh lấy áo/giày ô cạnh; không tự lấy bbox alpha rồi căn giữa.
Giữ chân bằng `source_size`, `source_anchor`, `trim_offset`, anchor và region.
Ryn đang dùng canvas logic512×512, source_anchor(256,460); đây không phải yêu
cầu kéo mọi vùng ảnh thành512×512. Pose không được nhảy chân khi đổi frame.

Ghi hand/socket, angle và `grip_rect` cho từng pose; bàn tay được vẽ đè lên cán.
Với Ryn giữ `embedded_weapon=false`; hai mẫu thương phải hiện đúng khi thay
trang bị. Pose death ẩn vũ khí. Dùng filter clipping để không rò ô cạnh.

Kiếm Dawnveil nằm ở `art/painted/dawnveil.png`; thương/trượng dùng
`art/complete/weapons.png`. Giữ socket theo tài nguyên hiện hành, không đoán
điểm cầm bằng tâm ảnh. Hai kiếm hiện dùng chung silhouette có tint; thương và
trượng có mẫu khác nhau. Đừng mô tả đổi tint là đã có vũ khí hình dáng mới.

## 4. Chân dung có layer

Ryn có canvas1024×1536 cho portrait/body/hair/cloth. Các lớp phải giữ cùng
kích thước và tọa độ; không crop hoặc scale riêng từng lớp. Lớp thân gồm mặt,
tóc trước, tay/chân và thương; tóc sau và cape ở sau thân. Avatar Ryn dùng
face crop[460,245,220,220]. Không áp crop đó cho hero khác.

Runtime dùng mesh8×16 và `portrait_sway.gdshader`, có cache, không phải rig
xương hoặc SDK vật lý. Giữ giới hạn kéo22, rebound28 và hành vi hủy pointer
khi ẩn/mất focus; kiểm layer không tách khỏi cổ/vai lúc kéo. Metadata Ryn hiện
spring115, damping8, impulse105; root_y cape0.31/tóc0.13, span0.55/0.18.
Khi sửa, đối chiếu giá trị thực trong code/manifest thay vì chép mù các số này.
Giữ early return khi accessory rỗng trong `_sync_accessories` để tránh lỗi
library null. Preview trang phục cần tint cả bộ layer.

Eira/Mira/Lyra hiện tương tác trên toàn actor. Không ghi rằng họ đã có tóc/vải
độc lập nếu chưa thực hiện. RGB ngoài alpha có thể khác màu nền; xem ảnh composited
trong Godot trước khi kết luận cần xử lý pixel.

## 5. Tích hợp và tái tạo metadata

Sửa builder và file sinh ra cùng nhau. Ryn nằm ở `build_painted_manifest.py`,
Eira mở rộng ở `build_combat_manifest.py`, Mira/Lyra ở `build_complete_art.py`.
Lệnh tái tạo đầy đủ từ thư mục repo:

```sh
python tools/build_complete_art.py
```

Builder đầy đủ gọi combat rồi painted trước khi thêm override cuối. Chạy riêng
builder nền/combat có thể làm mất override về sau cho đến khi chạy lại builder
đầy đủ. Kiểm diff để tránh thay metadata ngoài phạm vi. `tools/build_art.py`
là pipeline SVG cũ, đã bỏ qua Ryn; không dùng nó để thay PNG hiện hành.

FrameLibrary và View chỉ trình bày. BattleModel sở hữu damage/hit timing;
marker attack0.22, skill nguồn0.5 được sampler ánh xạ theo kỹ năng. Không gây
sát thương từ frame vẽ, không tiêu thụ RNG chiến đấu trong animation. Seek,
scrub và gallery không được phát lại hit hoặc âm thanh. AudioDirector tiêu thụ
event một lần; giữ bộ âm ElevenLabs hiện có khi chỉ đổi hình.

Nếu **thêm hero mới**, kiểm cả catalogue, clips/manifest, weapon, avatar,
portrait, UI, pool triệu hồi và map dữ liệu cố định trong Recruitment.fresh,
HeroEvolution.fresh, Wardrobe.fresh. AttributeTraining dùng catalogue động.
Đọc tests/migration trước khi bổ sung ID. Save hiện v6 đọc v2–v5, giữ đường dẫn
`first_light_v2.json`; giữ ví, item UID, sở hữu, pity và pending run snapshot.
Snapshot hero/variant/assist/weapon/look của trận đang dở phải bất biến.
Không reset save hoặc âm thầm sửa save hiện hành hỏng thành profile mới.

## 6. Kiểm tra theo phạm vi thay đổi

Chỉ sửa tài liệu: kiểm đường dẫn, dữ kiện, diff và không cần chạy game suite.
Sửa ảnh/metadata: import Godot, kiểm dữ liệu và **render xem ảnh thực tế**:

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script tests/complete_art.gd
godot --headless --path . --script tests/ryn_art.gd
godot --headless --path . --script tests/portrait_touch.gd
```

Chọn test liên quan; `ryn_art` dành cho Ryn. Dùng profile riêng qua
`FIRST_LIGHT_SAVE_DIR`, output riêng qua `FIRST_LIGHT_CAPTURE_DIR`; không chạm
save người chơi. Gallery/UI cần display hoặc Xvfb: `ryn_gallery.gd`,
`complete_art_gallery.gd`, `animation_gallery.gd`, `character_ui.gd`,
`ui_flow.gd`, `visual_ui.gd`. Xem đủ pose, baseline, vũ khí hai mẫu, grip,
death, ảnh chân dung lớn, alpha, tint trang phục và thao tác kéo. Với Ryn có
`ryn_motion_capture.gd` để ghi chuyển động. Test số liệu không thay việc xem ảnh.

Nếu đổi roster/logic/save, chạy các suite liên quan: regression, mechanics,
campaign, lyra, recruitment, hero_management, wardrobe, rarity_system,
attribute_training và summon_batch/summon_ui. Đọc AGENTS để lấy yêu cầu từng
hệ mới như nhiệm vụ. Đổi audio thì đọc AUDIO.md và chạy audio/validate_audio;
chỉ đổi art không cần tạo lại âm hoặc gọi API trả phí.

Báo rõ cái gì đã kiểm. Headless pass không chứng minh đã xem animation, nghe
loa hoặc thử touch/FPS/nhiệt/safe-area trên Android/iOS thật.

## 7. Dọn nguồn và bàn giao trên Git

Sau khi kiểm bộ mới, bỏ file raw cũ đã được thay theo yêu cầu; cập nhật mọi
reference, fallback, builder và provenance. Không để builder hồi sinh raw đã
xóa. Không xóa asset dùng chung bởi nhân vật khác. Giữ danh sách retired để
phiên sau hiểu lịch sử; không giữ backup raw cũ trong cây phát hành hoặc force
push để xóa lịch sử. Ryn cũ là trường hợp đã hoàn tất, không cần phục hồi.

Cập nhật CHARACTER_BIBLE, tài liệu nhân vật, ảnh xem trước và README cùng
commit. Kiểm HEAD remote trước push, giữ thay đổi người khác và không force.
Ghi bàn giao: ID, brief được dùng, file nguồn/hash, metadata/builder, test và
ảnh đã xem, giới hạn chưa kiểm. Người dùng đã cho phép đẩy trong dự án này;
không tự đặt thêm cổng xin phép cho thao tác đã được ủy quyền.
