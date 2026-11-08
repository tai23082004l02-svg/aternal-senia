# Caelan — bàn giao thiết kế nhân vật

> **Đã tích hợp0.38/savev13 theo yêu cầu tiếp theo của chủ dự án.** Đây là brief nguồn và lịch sử thiết kế; trạng thái chơi được, kỹ năng đã áp dụng và migration ở [CAELAN_RUNTIME](CAELAN_RUNTIME.md).

**Phạm vi theo phân công mới của chủ dự án:** tạo hình, trang phục, vũ khí,
pose và bản sắc/kỹ năng nhân vật. UI, bố cục màn hình, cảnh nền và tích hợp
runtime do người khác phụ trách. Gói nguồn ban đầu chỉ bàn giao thiết kế; bản tích hợp sau đó được ghi riêng ở CAELAN_RUNTIME.

## Nhận diện

- Tên: **Caelan** · planning **H02** · ID đề xuất `caelan`.
- Nam trưởng thành **30 tuổi**, hệ **Light**, vai trò **Vanguard**, gốc **5★**.
- Khuôn mặt nam trưởng thành, đường hàm rõ, mắt teal, tóc vàng tro vuốt về sau
  với bím nhỏ ở thái dương/nối về gáy. Không đội mũ, không có râu.
- Giáp ngà khắc họa tiết mặt trời vàng; lớp lót chần navy; cape xanh đêm dài,
  mặt trong teal, hoa văn bình minh và lá vàng. Khiên kite xanh lam ở tay trái,
  kiếm thẳng cán navy/guard vàng và ngọc lam ở tay phải.
- Silhouette: vai rộng, tấm khiên lớn, cape dài; khác kiếm sĩ Eira và hai thương
  thủ Ryn/Lyra. Tỷ lệ minh họa người lớn; sprite chiến đấu khoảng3,4 đầu.
- Bảng màu định hướng: navy `#132849`, teal `#1F666F`, ivory `#EEE6D2`,
  gold `#CBA65D`, ash-blond `#B7AC98`. Tranh nguồn là chuẩn khi đối chiếu.

Caelan từng là hiệp sĩ tại một trạm gác và không muốn lặp lại sai lầm tuân lệnh
quá lâu. Anh đo chiến thắng bằng số người trở về an toàn. Trọng tâm tính cách:
điềm tĩnh, biết nhận trách nhiệm, bảo vệ bằng hành động; không phải nhân vật
chỉ đứng che chắn mà không có quyết định riêng.

**Collection quote:** “Stand behind me. We all go home.”

## Bộ nguồn đã hoàn thiện

| File | Nội dung |
| --- | --- |
|[illustration.png](../art/caelan/illustration.png)|Tranh toàn thân1024×1536, nhận diện mặt/giáp/khiên/kiếm và vật liệu|
|[turnaround.png](../art/caelan/turnaround.png)|Tạo hình người lớn trước–nghiêng–sau, rõ cấu trúc giáp và cape|
|[atlas.png](../art/caelan/atlas.png)|Nguồn alpha1254×1254,16 pose chiến đấu cùng một thiết kế|
|[props.png](../art/caelan/props.png)|Nguồn alpha1536×1024, kiếm và khiên riêng|
|[manifest.json](../art/caelan/manifest.json)|Region, anchor, socket tay, góc vũ khí, crop mặt và timing tham khảo|
|[generation.json](../art/caelan/generation.json)|Công cụ, output filenames, nguồn tham chiếu và SHA256|
|[provenance.json](../art/caelan/provenance.json)|Danh mục nguồn PNG nguyên byte và SHA256 từ builder|

Nguồn được tạo bằng image generation. Minh họa dùng banner Eira làm chuẩn phong
cách; atlas dùng minh họa Caelan và tỷ lệ battle Ryn. Turnaround và props bám theo
minh họa. Không trích asset từ game tham khảo. Công cụ không trả receipt provider
riêng; generation.json ghi đúng giới hạn này, không tạo receipt giả.

Không sửa pixel, xóa nền, resample hoặc vẽ lại PNG bằng code. Các crop dùng region
metadata. Mỗi file nguồn được giữ nguyên byte của output đã chọn.

## Pose và chuyển động

| Hàng atlas | Pose theo thứ tự trái → phải |
| --- | --- |
|1|Idle0, idle1, run2, run3|
|2|Run4, run5, attack windup6, attack follow-through7|
|3|Skill prepare8, skill release9, guard10, guard brace11|
|4|Hurt12, stagger13, defeated kneeling14, defeated lying15|

Manifest có7 trạng thái idle/run/attack/skill/guard/hurt/death, dùng16 ảnh pose
nguồn riêng. Frame giữ thời gian/lặp lại không được tính là pose mới. Attack dùng
marker tham khảo0,22s, skill0,5s; người tích hợp cần khớp marker model, không gây
hit từ renderer. Kiếm không được vẽ liền vào atlas: tay phải dùng socket/grip,
khiên trái là nhận diện gắn cùng nhân vật. Khi nằm/khuỵu thua thì ẩn kiếm gắn rời.

`tools/build_caelan.py` chỉ sinh metadata, không đọc/ghi lại pixel. Có thể chạy
riêng để tái tạo manifest/provenance; chưa móc vào pipeline runtime hiện tại.
Các region đã được render trong harness tạm để xem đủ pose và vũ khí. Ảnh kiểm
ở ignored work/checks/caelan_gallery, không commit ảnh render vào repo.

Đây là keyframe sprite và nội suy trình bày, không phải rig xương hoặc mô phỏng
tóc/vải độc lập. Nhóm tích hợp có thể dùng face crop/banner/panel crop trong
manifest, nhưng các tên presentation chỉ là dữ liệu bàn giao, chưa tạo UI mới.

## Bản sắc kỹ năng — chuyển cho người phụ trách gameplay

Các thông số dưới đây là **đề xuất benchmark**, không phải thay đổi đã áp dụng
cho game hoặc cân bằng launch đã chốt. Điểm quan trọng là ba nhân vật khác nhau
ở mục tiêu bảo vệ, cách gây sát thương và trade-off.

| Nhân vật | Bản sắc và kit đề xuất | Điểm đánh đổi |
| --- | --- | --- |
|**Caelan**|Bảo vệ đồng đội: Shield Line đánh mục tiêu và tạo khiên cho đồng đội sống có tỷ lệ HP thấp nhất; Unbroken Dawn tạo khiên cả đội; Dawnward giảm sát thương cho người khác khi đứng trước và còn sống.|ATK và burst thấp, Ultimate không tự gây AoE/hồi máu; cần đồng đội DPS.|
|**Ryn**|Đấu sĩ tự trụ: Ember Guard đánh và tạo khiên bản thân; giữ hướng Ultimate diện rộng và tự bảo vệ.|Bảo vệ bản thân nhiều hơn đồng đội, tốc độ dồn sát thương thấp hơn Lyra.|
|**Lyra**|Thương thủ kết liễu: Flare Thrust nhịp nhanh; Twilight Comet đánh một đối thủ sống có tỷ lệ HP thấp nhất; tăng sát thương khi mục tiêu yếu máu.|Không tự hồi máu hoặc tạo khiên, không thay vai trò AoE của Ryn.|

Mốc thử nghiệm đề xuất cho Caelan: HP285, ATK17, DEF6, crit8%; basic125% ATK và
khiên14% max HP/5s cho đồng đội yếu nhất; Ultimate khiên22% max HP/6s; aura12%
giảm sát thương cho đồng đội khi đứng trước. Đề xuất cho Ryn: basic thêm khiên8%
max HP/4s. Đề xuất cho Lyra: basic cooldown4,3s, +35% sát thương trực tiếp khi
mục tiêu dưới30% HP, Ultimate440% ATK đơn mục tiêu và không tự hồi máu.

Nhóm gameplay cần kiểm scaling, shield stacking, cooldown, crit, điều kiện mở,
nguồn sở hữu/mảnh, giao dịch và tương thích pending trước khi triển khai. Gợi ý
nguồn Caelan là tuyển miễn phí sau milestone đầu và nguồn mảnh có thể farm;
**gói thiết kế này không phát hero/mảnh và không sửa xác suất triệu hồi**.

Ryn vẫn27 tuổi, tóc đỏ rượu ngang vai/bím nhỏ/kẹp phượng. Lyra vẫn24 tuổi, tóc
nâu đỏ đuôi ngựa cao dài. Giữ asset, ID và nhận diện hiện tại; không nhập hai
nhân vật thành một và không thay artwork của họ trong gói này.

## Bàn giao và giới hạn

Người phụ trách tích hợp nhận PNG, manifest, props và brief này. Cần tự triển
khai catalogue, ownership, save migration, combat, UI và kiểm Android trong task
riêng. Roster, đội hình và nguồn nhận phải theo code HEAD hiện hành; gói thiết kế không tự tạo các tính năng đó.

Prototype tích hợp ban đầu được lưu riêng trong ignored
`work/handoff/caelan-integration-prototype.tar.gz` và patch cùng thư mục để tránh
mất công việc; nó không nằm trong thay đổi giao nhân vật lên main. Các kết quả
kiểm thử prototype không được dùng để tuyên bố game hiện đã có Caelan.

Mẫu Caelan cần chủ dự án xem chất lượng trước khi sản xuất hàng loạt. Gói này
không bao gồm màn hình, bố cục UI, cảnh nền mới cho game, giọng thoại hoặc SDK.
