# Selena — bộ mẫu mỹ thuật nhân vật

Ngày tạo: 2026-11-08. Bộ ảnh để chủ dự án xem, làm chuẩn chất lượng cho sản xuất các hero sau. Theo yêu cầu mới, mở rộng từ concept đã được khen đẹp sang toàn bộ nhóm thiết kế nhân vật. Không có thay đổi runtime trong đợt này.

## Xem bộ ảnh

| Hạng mục | Nguồn PNG |
| --- | --- |
| Tranh chủ đạo toàn thân | [key-art](../art/selena/selena_splash_art.png) |
| Bốn góc và chi tiết chất liệu | [turnaround](../art/selena/selena_turnaround_reference.png) |
| Nhân vật riêng | [cutout](../art/selena/selena_fullbody_transparent.png) |
| Sáu biểu cảm | [expressions](../art/selena/selena_expression_sheet_6.png) |
| Tám tư thế chibi chiến đấu | [battle-chibi](../art/selena/selena_battle_chibi_keyposes_8.png) |
| Trượng riêng | [staff](../art/selena/selena_weapon_staff.png) |
| Sáu icon kỹ năng | [skill-icons](../art/selena/selena_skill_icon_sheet_6.png) |

[Concept được chọn trước đó](../art/concepts/selena/design-board.png). Nguồn mới giữ nguyên byte công cụ; kích thước, alpha, hash và tham chiếu ghi tại [provenance](../art/selena/provenance.json). Không có receipt riêng nếu công cụ không cung cấp.

## Nhận diện cần giữ

Selena là tên làm việc; H03 trong roster quy hoạch trước đó tên Selene. Bộ này chưa đổi tên/ID roster. Ngoại hình nữ trưởng thành, tuổi và tiểu sử chưa chốt. Mắt tím, tóc rất dài tím bạc, hoa lily trắng với lá vàng ở thái dương; mặt dây đá tím hình thoi. Váy nhiều lớp ngà/lilac, lớp trong tím đậm, viền vàng ấm và tay áo rời. Trượng vàng với trăng khuyết bao ngôi sao tám cánh, đá tím treo và dải lụa lilac.

Ba dấu nhận diện: **lily trắng — đá tím — trăng/ngôi sao vàng**. Tranh lớn ưu tiên khuôn mặt, chất liệu và chuyển động tóc/vải; bản chiến đấu ưu tiên silhouette và tay chân dễ đọc. Tranh nhân vật trưởng thành không dùng làm tỷ lệ sprite; bản chibi là nguồn riêng.

Bảng màu định hướng: ngà #F4EBED, lilac #B59CDB, tím tóc #D5C5E8, tím đêm #302347, vàng ấm #D5A34F. Đây là swatch định hướng, không phải cam kết mọi pixel trùng mã.

## Diễn xuất và kỹ năng hình ảnh

Biểu cảm: dịu dàng, quyết tâm, vui nhắm mắt, bất ngờ, lo lắng, buồn. Chân dung đại diện có thể lấy region từ ảnh riêng/biểu cảm khi tích hợp; không bake tên, sao hay chỉ số vào artwork.

Bộ chibi riêng có idle/run/basic/skill/ultimate/guard/hurt/defeat, là tám key pose để chốt tạo hình nhỏ.

Icon đề xuất đọc theo hàng: đạn trăng–sao, lily hồi phục, khiên sao, trăng–sen tối thượng, sao dẫn đường, cộng hưởng trăng. Đây là ngôn ngữ hình ảnh, chưa phải kit combat hay thông số đã duyệt.

## Bàn giao sản xuất

Đây là **bộ thiết kế và keyframe nguồn**, chưa phải animation đã căn socket/pivot, cắt region, cân timing hoặc kiểm trong game. Các PNG yêu cầu nền trong suốt cần đối chiếu alpha thực tế trong provenance trước khi dùng; không suy ra đã sẵn sàng runtime từ vẻ ngoài của contact sheet. Giữ nguyên nguồn, dùng image generation khi cần sửa, không xóa nền/vẽ lại pixel bằng code.

Khi tích hợp: chọn region chân dung/avatar; cắt pose sau kiểm ranh ô thực tế; cân baseline, hand/socket và góc trượng từng pose; bổ sung in-between nếu cần; căn icon theo vùng thực tế. Không tự dùng kích thước grid danh nghĩa làm region đã kiểm. Không thêm hero, mảnh, quyền sở hữu hoặc skill chỉ vì có ảnh.

Chuẩn cho hero sau là độ hoàn thiện và tính nhất quán giữa các loại asset, không phải sao chép tóc tím, hoa lily hay trượng trăng của Selena. Mỗi hero cần silhouette, màu nhấn, vũ khí và mô-típ riêng.


## Dọn nguồn lỗi theo yêu cầu

Đã xóa sheet 24 tư thế người lớn và sheet VFX vì nền alpha còn haze; bộ tư thế còn lệch phong cách chibi và lặp dáng. Giữ bảy PNG có công dụng rõ, đổi tên có tiền tố selena. Turnaround là tài liệu tham chiếu trang phục, không phải sprite. Nguồn chibi là tám key pose, chưa phải animation hoàn chỉnh. Chưa có VFX Selena đạt chuẩn để nhập game.
