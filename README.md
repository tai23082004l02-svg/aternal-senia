# Aternal Senia — First Light

Game fantasy anime 2D, offline, xây bằng **Godot 4.6.3**, giao diện dọc **540 × 960**.
Bản chơi hiện tại **0.39.0**, save schema **v13**.
Giao diện chính **tiếng Anh**, dùng font đóng gói Playfair Display Bold;
xem [English UI](docs/ENGLISH_UI.md).
Studio **ZORVYKA Games** · **zorvykagames@gmail.com**.

Caelan đã chơi được: vượt **Forest Entrance**, vào **Heroes → Gallery → Caelan → Recruit Caelan · Free**. [Chi tiết](docs/CAELAN_RUNTIME.md).

UI Celestial mới: Home/Selena preview, Gallery, Showcase, Summon/Reveal và HUD chiến đấu. [Bàn giao UI0.39](docs/UI_CELESTIAL_0_39.md). Selena là thiết kế xem trước, chưa phải hero có thể tuyển.

## Bắt đầu

Mở `project.godot` trong Godot 4.6.x, đợi import rồi chạy F5.
Khởi động ở **Home**; mở **Journey** để chuẩn bị đội hình và chọn vào ải.
UI và handoff riêng: [UI Design V2](docs/UI_DESIGN_V2.md).
Không cần API key, tài khoản hoặc dịch vụ trả phí để chơi.

- Năm hero Eira, Ryn, Mira, Lyra, Caelan; đội tối đa bốn hero đã sở hữu và một tinh linh.
- 5 màn chính, 10 màn nhánh và 3 phó bản chơi được.
- 44 trang bị, 6 bộ, 4 vị trí/hero; nhiều bản cùng tên có UID riêng, túi 40 món.
- 8 vật phẩm thiết yếu; xem công dụng, nguồn và nhận quà trong **Túi đồ → Vật phẩm**.
- Hệ thống nhiệm vụ, phát triển nhân vật/tinh linh, triệu hồi Thường, AFK và Cài đặt.
- Thế giới Phó bản có 15 địa điểm để xem; 12 địa điểm còn là bản thiết kế.

## Định hướng sản phẩm đã duyệt\n\n[Game Design V1.0 — Collector First](docs/GAME_DESIGN_V1.md): 24 hero (12 nam/12 nữ), tất cả 5★ gốc, ưu tiên Gallery/Summon Reveal, Bond, truyện ngắn nhân vật và tiếp tục repo hiện tại. Đây là **kế hoạch**, không phải tính năng đã có. Codex bắt đầu WP01 audit chỉ đọc; các con số nội dung khác chưa tự động được duyệt.\n\n## Tiếp tục phát triển

**Phiên chat mới đọc theo thứ tự:**

1. [AGENTS.md](AGENTS.md): quy tắc phải giữ.
2. [Trạng thái game](docs/GAME_STATE.md): cái đã làm, giới hạn và việc tiếp theo.
3. [Kiến trúc](docs/SYSTEMS.md), [bản đồ repo](docs/REPOSITORY_MAP.md).
4. [Mục lục tài liệu](docs/INDEX.md): chọn chuyên đề cần sửa.
5. [Kiểm tra](docs/TESTING.md) và [tạo hình nhân vật](docs/CHARACTER_CREATION_GUIDE.md).

Yêu cầu mới nhất của người dùng được ưu tiên. Không lấy mô tả phiên bản cũ làm
quy tắc hiện hành: trang bị không còn singleton, trần cường hóa là +15, trận mới
dùng đội hình; save không còn v4/v7/v10.

## Kiểm tra

```bash
godot --headless --editor --path . --import
python3 tools/verify_repo.py
xvfb-run -a python3 tools/check_project.py
python3 tests/validate_audio.py
```

Godot, Xvfb, ffmpeg và thư viện âm thanh cần được cài trước; xem
[TESTING.md](docs/TESTING.md). CI dùng workflow **Project verification**,
chỉ đọc repo và xuất artifact; không tự commit ảnh hoặc gọi API tạo âm thanh.

## Điện thoại và Termux

Xem [ANDROID_TERMUX.md](docs/ANDROID_TERMUX.md).
Giữ Git trong thư mục riêng của Termux; xuất bản gọn chỉ gồm game và tài nguyên:

```bash
cd ~/aternal-senia-termux
git pull --ff-only
sh tools/export_android.sh
```

Mở `project.godot` ở thư mục mới được lệnh in ra.
Script giữ nguyên project/save và không xóa dự án điện thoại đang có.

## Dung lượng và ảnh minh họa

Đã bỏ khoảng **56,2 MB** file sinh ra, bản ghi minh họa và công cụ CI trùng lặp
khỏi cây hiện tại. Tranh nguồn, audio ElevenLabs gốc, biên nhận, code, tests và
dữ liệu migration được giữ. [Biên bản dọn repo](docs/REPOSITORY_CLEANUP.md).

Ảnh/video cũ vẫn xem được qua [kho liên kết cố định](docs/ARCHIVED_MEDIA.md).
Kết quả kiểm thử mới nằm trong `work/` hoặc artifact CI, không thêm lại vào Git.
Lịch sử Git vẫn giữ nguyên; clone `--depth 1` khi cần tải bản hiện tại nhẹ hơn.

Game tham khảo cách tổ chức Eternal Senia 2; nhân vật, mỹ thuật và công thức là
nội dung riêng. Không kèm tài nguyên trích xuất từ repo nghiên cứu.
Chưa xác nhận cảm ứng/FPS trên điện thoại thật, chưa phát hành APK hoặc dịch vụ online.
