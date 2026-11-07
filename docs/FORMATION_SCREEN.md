# Đội hình · 0.25

Áp dụng sơ đồ người dùng vào giao diện xanh đen/viền vàng hiện tại:

- Tiêu đề và số hero đang xếp / tinh linh.
- Một thẻ hàng trước nằm giữa; hai thẻ hàng sau cùng hàng phía dưới.
- Thanh tinh linh riêng, chạm để mở danh sách chọn Lumi/Ash.
- Lưới chân dung nhân vật, LV, trạng thái khóa và số đã sở hữu.
- Tự dùng Ultimate, Tự vượt ải và hai lối sang Nâng cấp/Hành trình.

Tất cả phần điều khiển nằm trong vùng dọc hiện có trên viewport540×960 với
roster4 người hiện tại; lưới tự xuống hàng nếu thêm hero. Thẻ dùng face từ bộ art
đang chạy, không tạo ảnh/đổi tạo hình hoặc gán nghề từ biểu tượng trong sơ đồ.

Chọn ô rồi chọn tướng: có sẵn ở ô khác thì hoán đổi, không nhân bản hero. Có
Bỏ khỏi ô, nhưng không bỏ hero cuối cùng. Hai ô dưới chỉ đổi cách trình bày,
vẫn là slot1/2, không đổi targeting hay khóa nghề. Tướng và tinh linh chưa sở
hữu bị khóa. Có thể mở xem tinh linh khi pending, các nút chọn đều vô hiệu.

Checkbox nối tùy chọn Formation đã có; roster/tinh linh/options cùng giữ quy
tắc commit và khóa pending/read-only cũ. Lỗi ghi không thay RAM hoặc trừ ví.
Không đổi schema save v8, stats, mô hình3vN hay phần thưởng. Những hero/LV trong
ảnh là fixture minh họa Mira trước, Eira/Ryn sau; không áp đặt đội đó lên save.

Kiểm thử formation_layout: vị trí ô, cùng hàng phía sau, độ cao màn, click thật
chọn/hoán đổi, tinh linh, checkbox, nhân vật khóa, lỗi ghi và pending snapshot.
team_ui, ui_flow, animation_gallery và regression87/mechanics72/campaign5 đạt.
Đã xem ảnh Godot Linux; chưa thử điện thoại thật.

![Đội hình mới](previews/team-formation.png)
