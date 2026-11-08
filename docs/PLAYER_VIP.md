> Trạng thái chuẩn: [GAME_STATE](GAME_STATE.md), [mục lục](INDEX.md). Các phần ghi phiên bản cũ là lịch sử; ưu tiên yêu cầu mới và quy tắc hiện hành.

# Hồ sơ và VIP · 0.15–0.20

## Giao diện hồ sơ hiện hành

Cửa sổ navy/teal viền vàng, nền rừng và chân dung tròn lớn; tên hiển thị,
ô nhập tối đa20 ký tự, bốn thẻ avatar có trạng thái chọn/khóa theo sở hữu,
khối VIP EXP và nút Lưu hồ sơ vàng. Nội dung dùng SwipeScroll, nút lưu cố định
phía dưới và nút đóng ở góc phải; chữ/control thật, tái dùng tranh hiện có.
Chỉ đổi trình bày: giữ PlayerIdentity.save, preview avatar chỉ trong bản nháp,
đóng là hủy; quyền sở hữu, read-only, VIP1–10, ví và schema không đổi.


Theo phác thảo: avatar tròn ở góc trái, tên bên phải phía trên, trạng thái VIP
phía dưới. Chạm cụm hồ sơ để đổi tên (1–20 ký tự, hỗ trợ tiếng Việt) và chọn
avatar từ nhân vật đã sở hữu. Avatar hồ sơ độc lập với hero ra trận.

Từ0.20, người dùng đổi yêu cầu: nhiệm vụ ngày/tuần cấp VIP EXP thật khi nhận
thưởng. EXP được lưu và hiển thị trong hồ sơ, chưa tự xếp cấp VIP. Bảng có đủ
VIP1–10, chọn từng bậc để xem trạng thái. Tài khoản hiện ghi “Chưa kích hoạt”.
Mốc nạp và quyền lợi chờ cấu hình; nút nạp bị vô hiệu và ghi “Sắp ra mắt”.
Chưa tích hợp thanh toán/xác minh hóa đơn hoặc cấp VIP thật. Mốc EXP/cấp và
quyền lợi chờ cấu hình; không buff hoặc trừ ví khi xem bảng. Chi tiết EXP ở
[Hệ thống nhiệm vụ](MISSIONS.md).

Hồ sơ lưu trong trường tùy chọn `identity` của save v5; save cũ không cần đổi
phiên bản, mặc định “Nhà lữ hành” và avatar Eira. Tên/avatar được kiểm tra trước
khi commit, lỗi ghi không đổi RAM. Không mở hồ sơ giữa trận; không đổi snapshot.
Save chỉ đọc vẫn xem được và khóa lưu hồ sơ.

![Trang chính](https://raw.githubusercontent.com/tai23082004l02-svg/aternal-senia/8422241ab7c6361b215b235d75208425d1597207/docs/previews/vip-header.png)
![Hồ sơ](https://raw.githubusercontent.com/tai23082004l02-svg/aternal-senia/8422241ab7c6361b215b235d75208425d1597207/docs/previews/player-profile.png)
![VIP1–10](https://raw.githubusercontent.com/tai23082004l02-svg/aternal-senia/8422241ab7c6361b215b235d75208425d1597207/docs/previews/vip-tiers.png)

Kiểm chứng trên Godot4.6.3 Linux: player_profile kiểm save cũ, tên tiếng Việt,
avatar sở hữu, reload, lỗi ghi/read-only, 10 bậc không đổi dữ liệu. Regression81,
mechanics54 tổ hợp, campaign5 màn, ui_flow và animation_gallery đạt. Đã xem ảnh
render thực; chưa kiểm thử trên điện thoại thật.
