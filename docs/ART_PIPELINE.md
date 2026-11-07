# Pipeline frame nhân vật / vũ khí

Artwork mới là SVG chibi cơ bản, không dùng rig và không chứa sprite trích từ
game gốc. Chưa đạt độ chi tiết/chuyển động của mỹ thuật phát hành.

## Canvas và clip

`tools/build_art.py` tạo 84 ảnh pose nhân vật: mỗi hero 4 idle, 6 run, 6 attack,
6 skill, 2 hurt, 4 death. Canvas 192×240, điểm neo nguồn (96,216); manifest
`art/clips.json` ghi file, duration, hand socket và angle. Các duration không
bằng nhau. Idle/run loop; các clip còn lại dừng ở frame cuối khi seek quá dài.

Run thay độ mở chân; attack có windup/extend/recover. Pose chết được thu vào
canvas để không cắt đầu; socket khi hurt được biến đổi cùng pose. Một số pose
vẫn đơn giản và idle lặp gần giống nhau; cần mỹ thuật tinh chỉnh trước phát hành.

Vũ khí SVG 64×160, gốc cầm (32,128). BattleView đặt nó vào hand socket mỗi frame,
xoay theo angle rồi scale cùng nhân vật. Đổi item base ID đổi texture; tăng rank
chỉ đổi stats ở bản này. Giáp đổi stats, chưa có skin riêng. Tách vũ khí khỏi
frame giúp cùng bộ pose dùng nhiều item mà không cắt lại sprite.

## Thay artwork chất lượng cao sau này

Giữ source canvas/foot anchor thống nhất. Nếu trim thì thêm source-size và
trim-offset vào manifest, tính lại draw origin từ source; không căn alpha bbox
và không tự chia lưới sheet. Socket ở tọa độ source, không ở tọa độ ảnh trim.
Bản hiện tại không trim, nên giữ nguyên canvas là đủ. Hệ render chỉ đọc state;
hit marker nằm ở BattleModel. Thay hình không đổi damage hoặc save.

## Preview và kiểm tra

`tests/animation_gallery.gd` xuất contact sheet 3 hero × 6 state với đường chân;
`tests/ui_flow.gd` xuất runtime thật, gồm vũ khí và boss. Xem ảnh thực tế, không
chỉ kiểm PNG tồn tại. `FrameLibrary.frame_at` có thể seek từng thời điểm, pause
và so frame mà không phát lại hit. Hero hurt và death là ngoại lệ chuyển dáng có
chủ đích; chân đứng idle/run giữ source anchor, không căn giữa crop.

Trong lượt này đã xem mẫu run/vũ khí gốc và ảnh runtime/gallery mới. Đã sửa sword
idle che mặt, crop đầu lúc death, socket hurt và HP/SP overlap. Thời lượng clip
mới do dự án tự đặt; không gọi đó là timing gốc. Chưa thử chuyển động trên touch
hoặc đánh giá mỹ thuật với người chơi.

`tools/build_audio.py` tạo 4 tone PCM ngắn cho hit/hurt/heal/win. Có toggle mute;
chưa có nhạc nền hoặc lồng tiếng. Test dùng Dummy audio, chưa nghe trực tiếp.
