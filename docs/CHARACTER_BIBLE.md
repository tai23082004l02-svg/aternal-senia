# Hồ sơ tạo hình nhân vật — nguồn tham chiếu cho các phiên chat

Cập nhật: 2026-11-07. Thiết kế hiện hành sau Ryn0.19; tính năng dự án đã đến0.20.
Đọc tài liệu này trước khi vẽ, đổi tên, thêm hoặc thiết kế lại nhân vật.
Quy trình thực hiện nằm ở [CHARACTER_CREATION_GUIDE.md](CHARACTER_CREATION_GUIDE.md).

## Thứ tự đọc và xử lý mâu thuẫn

1. Yêu cầu mới nhất của người dùng trong phiên đang làm.
2. [AGENTS.md](../AGENTS.md), hồ sơ này và hướng dẫn thực hiện.
3. Asset đang được runtime sử dụng, catalogue, manifest và builder tương ứng.
4. Tài liệu chuyên đề hiện hành, đặc biệt [RYN_ART.md](RYN_ART.md).
5. Changelog, ảnh và tài liệu phiên bản cũ chỉ để hiểu lịch sử.

Nếu mã và hồ sơ lệch nhau, kiểm tra commit mới nhất và báo rõ điểm lệch; không
tự hợp thức hóa lỗi bằng cách thay thiết kế. Cập nhật hồ sơ khi thiết kế được đổi.
Không suy diễn tuổi, tiểu sử, quan hệ hoặc cốt truyện từ ngoại hình.

## “Theo nguyên tác” có nghĩa gì trong dự án này?

Đây là **game mới**, tham khảo Eternal Senia 2 về tổ chức animation/frame, trang
bị và logic chiến đấu. Không phải bản phục dựng toàn bộ game gốc. Eira, Ryn,
Mira, Lyra và bộ mỹ thuật hiện tại là nội dung riêng của dự án; không gọi họ là
nhân vật chính thức của Eternal Senia, không gán Eira thành Senia hoặc tự lập
bảng nhân vật tương ứng với nguyên tác.

Repo nghiên cứu: [Tham-kh-o-game](https://github.com/tai23082004l02-svg/Tham-kh-o-game),
thư mục `research/eternal-senia-2/`: đọc `START_HERE.md`, `GRAPHICS_WORKFLOW.md`,
`ANIMATION.md`, `DATA_MODEL.md` và `catalogs/`. Trong repo game, đọc thêm
[REFERENCE_MAP.md](REFERENCE_MAP.md) để biết bằng chứng nào đã được đối chiếu.

Có thể học cách tổ chức atlas, pivot, trim, socket vũ khí và tách model/view.
Không nhập asset trích xuất, tên, thoại hoặc cốt truyện gốc vào game này.
`dump.cs` chứa khai báo, không chứng minh đã khôi phục thân hàm. Công thức sát
thương, crit, loot, pity và offline của dự án không được quảng bá là công thức
nguyên tác đã phục hồi. Nghiên cứu bone/Spine không có nghĩa game đang dùng rig đó.

## Ngôn ngữ hình ảnh chung

- Fantasy anime2D vẽ tay, bóng đổ có khối, nét viền mảnh rõ. Sprite chiến đấu
  hơi chibi, khoảng3,3–3,4 đầu; chân dung chi tiết hơn nhưng cùng mặt và trang phục.
- Giáp nhẹ màu ngà, vải xanh đêm/teal, viền vàng ấm hoặc bạc theo nhân vật;
  tinh thể và ánh phép là điểm nhấn. Trang phục đầy đủ, hợp vai trò chiến đấu.
- Cùng góc nhìn, tỷ lệ cơ thể, kích thước đầu và baseline bàn chân giữa các pose.
  Màu nhân vật cần đọc được trên rừng, phế tích, hồ và các nền tối.
- Giữ nhận diện bằng silhouette tóc, áo choàng, vũ khí và màu chủ đạo; đổi pose
  không được tự đổi mặt, phụ kiện hay chiều dài tóc.
- Không chuyển sang ảnh thật,3D, pixel art hoặc placeholder hình học. Tỷ lệ chibi
  là lựa chọn mỹ thuật, không phải xác nhận tuổi.

## Đội hình và nhận diện bắt buộc

Bốn hero chơi được, đều có rarity gốc5★. Sao thức tỉnh1–5 là hệ riêng, không phải
điều kiện mở tương tác chân dung. Trận dùng một hero chính và một trợ chiến.

| ID | Vai trò / hệ | Nhận diện hiện hành | Tuổi đã xác định |
| --- | --- | --- | --- |
| `eira` | Kiếm sĩ bình minh / light | Tóc bob bạc, mắt xanh tím, cape xanh tím lót ngà viền vàng, giáp ngà, kẹp hoa/mặt trời vàng | Chưa chốt |
| `ryn` | Thương thủ hỏa vũ / fire | Tóc đỏ rượu ngang vai gợn nhẹ, bím nhỏ bên tóc, kẹp phượng vàng; mắt hổ phách; cape đỏ rượu | 27 |
| `mira` | Pháp sư thủy triều / water | Tóc teal tối ngắn/ngang vai, mắt aquamarine, vòng trán trăng bạc, áo ngà/teal, cape xanh đêm viền bạc | Chưa chốt |
| `lyra` | Thương thủ hoàng hôn / fire | Tóc nâu đỏ buộc đuôi ngựa cao dài, mắt hổ phách, phụ kiện phượng, cape đỏ viền vàng, giáp ngà | 24 |

### Eira

Mẫu nền để đối chiếu độ chibi, nét và vật liệu. Kiếm riêng gắn vào tay theo pose;
nguồn kiếm Dawnveil. Có32 pose nguồn khác nhau trong7 trạng thái, không đếm
frame lặp theo thời gian thành pose mới. Atlas nền ở
[`art/painted/eira_atlas.png`](../art/painted/eira_atlas.png), pose trung gian ở
[`art/combat/eira_motion.png`](../art/combat/eira_motion.png).
Chân dung hiện dùng renderer nhân vật, tương tác trên toàn sprite; chưa có bộ
layer tóc/vải độc lập như Ryn. Không tự bịa tuổi hoặc thay màu tóc theo Lyra.

### Ryn — chỉ dùng thiết kế0.19

Ryn trưởng thành27 tuổi. Tóc đỏ rượu ngang vai có bím nhỏ, **không buộc đuôi
ngựa dài cao**. Giáp ngà trên áo cổ cao màu than; cape ngắn xẻ tà đỏ rượu/xanh
đêm viền vàng; quần/váy ngắn màu maroon trên legging tối, găng và bốt.

Bộ duy nhất đang dùng ở [`art/ryn/`](../art/ryn/): `atlas.png`, `portrait.png`,
`body.png`, `hair.png`, `cloth.png`, `provenance.json`. Có16 pose chiến đấu;
atlas không chứa thương vẽ liền, thương được runtime gắn rời. Chân dung có thể
chứa thương trong lớp thân. Layer tóc và cape giữ tọa độ cùng canvas1024×1536.
Chi tiết, hình duyệt và GIF: [RYN_ART.md](RYN_ART.md).

Thiết kế Ryn tóc dài, trang phục đỏ/đen ở0.13–0.14 đã bị thay theo yêu cầu người
dùng. Đã xóa7 file PNG/metadata cũ và28 SVG mẫu khỏi cây hiện tại. **Không khôi
phục `art/painted/ryn_*` hoặc `art/ryn_*.svg`**, kể cả khi builder/tài liệu cũ
nhắc đến. Lịch sử Git vẫn tồn tại; không viết lại lịch sử để xóa raw.
Thiết kế lại giữ ID, tên, chỉ số, sở hữu và tiến trình; không thêm hero thay Ryn.

### Mira

Pháp sư dùng trượng, hệ nước. Giữ vòng trăng và silhouette tóc gọn, **không thêm
mũ pháp sư khổng lồ**. Áo ngà/teal, cape xanh đêm ngắn viền bạc, legging và bốt
tối màu. Nguồn [`art/complete/mira.png`](../art/complete/mira.png),16 pose trong7
trạng thái. Chân dung/tương tác hiện dùng toàn actor, chưa có layer độc lập.

### Lyra

Hero thứ tư, **khác Ryn**. Một bản tạo hình mới từng được gọi Ryn trong quá
trình làm; người dùng đã yêu cầu giữ Ryn có sẵn và đổi bản đó thành nhân vật
mới, tên hiện hành là Lyra. Không đổi ID hoặc nhập hai nhân vật làm một.

Tuổi24, đuôi ngựa cao dài màu nâu đỏ là đặc điểm phân biệt với tóc ngang vai
của Ryn. Giữ giáp ngà, cape đỏ viền vàng và legging tối. Nguồn
[`art/complete/lyra.png`](../art/complete/lyra.png),16 pose trong7 trạng thái;
chân dung/tương tác dùng toàn actor. Dùng thương hệ lửa không có nghĩa hai hero
phải cùng khuôn mặt, tóc hoặc kỹ năng.

### Trợ chiến và đối thủ

**Lumi** là tinh linh hồi phục SR, nhỏ, màu teal nhạt/vàng, có cánh:
[`art/painted/lumi.png`](../art/painted/lumi.png).
**Ash** là trợ chiến tấn công SSR, hiện hiển thị **phượng lửa cam/vàng**:
[`art/painted/ash.png`](../art/painted/ash.png). Ash không phải nam cung thủ.
Một hàng nam cung thủ trong sheet `art/complete/enemies.png` không phải asset
Ash đang dùng. Hai trợ chiến hiện chuyển động bằng transform một sprite,
không tuyên bố có animation cánh đầy đủ. Hệ có hỗ trợ UR nhưng không tự thêm
nhân vật UR mới khi chỉ sửa hình ảnh.

Quái/boss là nhóm riêng, không tự đưa vào roster hero. Rarity đối thủ1–4★,
hero5★, trang bị1–7 và tinh linh SR/SSR/UR là các hệ độc lập.

## Nơi lấy sự thật kỹ thuật

| Nội dung | Nguồn |
| --- | --- |
| ID, tên, hệ, stats, rarity, unlock | `game/data/catalog.json` và phần bổ sung `game/data/expansion.json`, được GameCatalog hợp nhất |
| Metadata art hiện hành | `art/painted/manifest.json`, override `art/clips.json` |
| Nguồn tái tạo metadata | `tools/build_painted_manifest.py`, `build_combat_manifest.py`, `build_complete_art.py` |
| Vẽ battle/portrait/gallery và socket | `game/core/frame_library.gd` |
| Chân dung tương tác | `game/hero_portrait.gd`, `game/shaders/portrait_sway.gdshader` |
| Avatar và màn nhân vật | `game/character_screen.gd` |
| Hash và nguồn ảnh | `art/ryn/provenance.json`, `art/painted/provenance.json`, `art/combat/provenance.json`, `art/complete/provenance.json` |

Tổng hiện tại80 pose hero nguồn: Eira32 + Ryn16 + Mira16 + Lyra16. Đây là
ảnh keyframe kết hợp nội suy/transform, không phải80 animation dựng bằng rig.
Tên resource còn đuôi `.svg` có thể là khóa API cũ trỏ đến PNG; kiểm texture
thực tế, không kết luận game còn dùng SVG chỉ từ tên khóa.

## Những việc chưa được quyết định

Chưa có hồ sơ tiểu sử, quê quán, quan hệ hay tuổi chính thức của Eira/Mira.
Không tự công bố chi tiết đó thành canon. Nhân vật mới cần brief riêng về ID,
vai trò, silhouette, bảng màu, trang phục và sự khác biệt với roster hiện tại.
Không suy ra quyền thêm hero, đổi lore hoặc thay hệ thống từ yêu cầu sửa art.

Khi bàn giao phiên sau, ghi: commit đang làm, yêu cầu người dùng, ID bị tác
động, hình chuẩn, file đã đổi, builder cần chạy, kiểm tra đã thực hiện và giới
hạn còn lại. Giữ tài liệu này cùng thay đổi art để không phải đoán từ chat cũ.
