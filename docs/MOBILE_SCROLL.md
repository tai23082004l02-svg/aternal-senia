# Vuốt cuộn nội dung · 0.31.1

Sửa lỗi phải kéo đúng thanh cuộn bên phải trên Godot Android. Các vùng cuộn
dùng chung `SwipeScroll`, kế thừa ScrollContainer của Godot, và bật cả
`input_devices/pointing/emulate_touch_from_mouse` lẫn `emulate_mouse_from_touch`.
Nhờ vậy thao tác trong trình chạy nhúng dùng chuột cũng kéo nội dung được;
cảm ứng thật vẫn dùng đường xử lý cuộn gốc của engine.

Các thẻ, panel và nút con chuyển STOP thành PASS để sự kiện kéo tới vùng cuộn.
Giữ IGNORE của hình trang trí. Chuẩn bị cả cây có sẵn và control được thêm
sau khi chuyển tab. Sau ngưỡng12px, engine phát SCROLL_BEGIN để hủy lần bấm
nút đang giữ; nhả tay sau khi vuốt không nhận thưởng/mua/chuyển trang ngoài ý
muốn. Chạm bình thường vẫn bấm một lần. Quán tính và thanh cuộn dùng engine.

Áp dụng Nhiệm vụ/các trang dài ở main, Túi đồ, Lò rèn, chi tiết trang bị,
Nhân vật, Shop, lịch sử triệu hồi và hộp chọn trang bị. Vùng cuộn con nhận
thao tác trước vùng cha; hàng tab Shop vuốt ngang. Range/slider/SpinBox, ô nhập
chữ và portrait tương tác giữ thao tác riêng, không biến kéo thanh âm lượng
hoặc tương tác nhân vật thành cuộn. Không sửa nội dung, ví hoặc save.

`tests/swipe_scroll.gd` gửi InputEvent qua Input.parse_input_event, kiểm cuộn
bằng chuột và cảm ứng trên nút nhiệm vụ, không bấm nhầm, cuộn túi đồ lồng nhau,
vuốt ngang Shop và hủy click khi nhả vẫn nằm trong nút lớn. Các suite UI hiện
có kiểm lại chuyển màn và hành động. Chạy trên Godot4.6.3/X11 với Xvfb; chưa
xác nhận trực tiếp trên thiết bị Android của người dùng.

Cập nhật trên Termux sau khi đóng project:

```bash
cd ~/storage/downloads/GodotProjects/aternal-senia
git pull --ff-only
```

Mở lại project trong Godot và chạy lại game để nhận cấu hình input mới.
