# Aternal Senia — First Light

Bản mẫu Godot 4 độc lập, lấy cảm hứng từ vòng chơi hero + assist của Eternal Senia 2.
Hình ảnh hiện là vector placeholder tự vẽ, chưa phải mỹ thuật hoàn chỉnh.

## Chạy
Mở `project.godot` bằng Godot 4.6 và nhấn F6/F5, hoặc chạy:
```sh
godot --path .
```

Màn hình dọc 540×960 tạm thời. Nhấn Bắt đầu hành trình; kiếm sĩ và trợ chiến tự đánh.
Ba nút kỹ năng: sát thương, hồi máu và đòn tinh linh. Vượt hai đợt quái và boss để
nhận 40 vàng; nâng cấp giá 30 vàng. Vòng cung cam báo đòn sắp tới.
Tiến trình dùng file riêng `user://first_light_v1.json`.

## Kiểm tra
```sh
godot --headless --path . --script tests/smoke.gd
```
Test có ghi tiến trình trong profile Godot của nó; dùng môi trường thử riêng.
Đã kiểm logic trên Godot 4.6.3 Linux headless. Chưa kiểm hình trực tiếp, touch,
âm thanh hoặc hiệu năng điện thoại. Không có âm thanh và bản APK trong mốc này.

## Mốc tiếp theo
- Xác nhận màn hình ngang/dọc trước khi hoàn thiện bố cục.
- Artwork riêng nhất quán và bộ frame idle/run/attack/skill/hurt/death.
- Tách BattleModel/View, thêm kiểm thử thời điểm hit và chuyển trạng thái.
- Làm save migration/backup, xử lý lỗi ghi và phiên bản tương lai trước khi phát hành.

Tài liệu tham khảo: https://github.com/tai23082004l02-svg/Tham-kh-o-game/tree/main/research/eternal-senia-2
