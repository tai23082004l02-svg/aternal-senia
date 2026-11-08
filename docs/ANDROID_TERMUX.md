# Godot Android và Termux

Git hoạt động ổn định hơn trong thư mục riêng của Termux. Không dùng Git trực tiếp
trong /storage/emulated/0/Download để tránh ownership/getcwd lỗi đã gặp.
Godot trên điện thoại mở bản xuất ở bộ nhớ chung.

## Lần đầu

Trong Termux:

```bash
pkg update
pkg install git tar
termux-setup-storage
cd ~
git clone --depth 1 https://github.com/tai23082004l02-svg/aternal-senia.git aternal-senia-termux
cd ~/aternal-senia-termux
sh tools/export_android.sh
```

Cho phép quyền bộ nhớ khi Android hỏi. Nếu đã có thư mục repo, dùng bước cập nhật,
không clone chồng lên. --depth1 chỉ tải lịch sử nông; nguồn trên main vẫn đầy đủ.

Script in đường dẫn dạng:
`/storage/emulated/0/Download/GodotProjects/AternalSenia-0.38.0-COMMIT-NGAY-GIO/project.godot`.
Trong Godot4.6.x chọn Import/Mở dự án, tìm đúng file đó, chờ import rồi chạy.
Bản xuất chỉ gồm project.godot, game/, art/; không có .git, tests, docs hay output CI.

## Mỗi lần cập nhật

Đóng dự án đang chạy trong Godot, rồi:

```bash
cd ~/aternal-senia-termux
git pull --ff-only
sh tools/export_android.sh
```

Mở project.godot ở **thư mục mới được in ra**. Mỗi lần xuất tạo thư mục khác để
không giữ lại file đã xóa của phiên bản cũ. Script không xóa thư mục hoặc save cũ.
Giữ config/name giúp tiếp tục dùng user:// cũ; backup qua Cài đặt trước khi đổi/
gỡ ứng dụng Godot. Không dùng FIRST_LIGHT_SAVE_DIR để chơi bình thường.

Có thể chỉ định một thư mục **chưa tồn tại**:

```bash
sh tools/export_android.sh /storage/emulated/0/Download/GodotProjects/AternalSenia-test
```

Script xuất **HEAD đã commit**, không bao gồm thay đổi chưa commit trong repo.
Nếu thiếu quyền storage, kiểm lại quyền Termux; không khắc phục bằng safe.directory=*.
Repo full-history cũ vẫn chứa các blob lịch sử; git pull không làm .git nhỏ lại.
Khi cần bản tải mới nhẹ hơn dùng clone --depth1 vào thư mục mới, giữ bản cũ nếu có
thay đổi của bạn. Không dùng reset --hard hoặc xóa dữ liệu để cập nhật.

## Nếu Godot vẫn hiện UI/nhân vật cũ

Home bản mới phải hiện **v0.38.0**. Script in version, commit và đường dẫn cụ thể;
đóng project cũ và import đúng `project.godot` trong thư mục mới đó. Chỉ `git pull`
trong Termux không cập nhật bản xuất ở Download đã mở trước đó. Caelan hiện là
**Design preview** trong Gallery/Showcase, chưa phải hero có thể xếp đội.
Không xóa save hoặc source PNG để buộc Godot cập nhật.
