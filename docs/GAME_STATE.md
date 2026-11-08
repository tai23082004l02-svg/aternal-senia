# Trạng thái dự án — bắt đầu ở đây

Cập nhật2026-11-08. Game **0.37.0**, **Godot4.6.3**, save **v12**.
Đợt dọn repo không đổi gameplay hoặc schema. Repo triển khai:
[tai23082004l02-svg/aternal-senia](https://github.com/tai23082004l02-svg/aternal-senia).
Repo tham khảo: [Tham-kh-o-game](https://github.com/tai23082004l02-svg/Tham-kh-o-game).
Studio **ZORVYKA Games**, hỗ trợ **zorvykagames@gmail.com**.

Đọc [AGENTS](../AGENTS.md), [kiến trúc](SYSTEMS.md), [mục lục](INDEX.md).
Nếu có thay đổi sau mốc này, đọc HEAD/code và yêu cầu mới nhất trước khi tiếp tục.
Các con số dưới đây lấy từ catalogue/model, không lấy số minh họa trong ảnh.

## Hướng sản phẩm và phong cách

Game mới fantasy anime2D, offline, auto battle, giao diện dọc540×960.
Học cách tổ chức atlas/frame/socket và logic từ tài liệu Eternal Senia2;
nhân vật, thoại, công thức và artwork là nội dung riêng, không phải phục dựng nguyên tác.
Mỹ thuật navy/teal, giáp ngà, vàng ấm, ánh tinh thể; chiến đấu hơi chibi,
chân dung chi tiết hơn. Chữ, chỉ số và nút tách khỏi tranh.

Người dùng ưu tiên hoàn thiện từng phần dùng được, không thêm hàng trăm vật phẩm
trang trí hoặc triển khai tất cả đề xuất cùng lúc. Người dùng đã cho phép push.
Đọc [hồ sơ nhân vật](CHARACTER_BIBLE.md) trước mọi thay đổi nhân vật.
Ryn tóc ngang vai và Lyra đuôi ngựa cao là hai ID khác nhau; raw Ryn cũ đã xóa.

## Giao diện tiếng Anh

Toàn bộ chữ hiển thị, tên ải/Boss/vật phẩm, hội thoại và thông báo dùng tiếng Anh
làm ngôn ngữ chính. Font đóng gói Playfair Display Bold và Be Vietnam Pro theo
vai trò; xem [ENGLISH_UI](ENGLISH_UI.md). Giữ tên người chơi Unicode, savev12,
ID và toàn bộ chỉ số/giao dịch.

## Đã hoạt động

| Phần | Trạng thái thực |
| --- | --- |
| Hero | Eira/light, Ryn/fire, Mira/water, Lyra/fire;4 hero gốc5★, mở theo tiến trình/triệu hồi; không sở hữu mặc định tất cả |
| Tinh linh | Lumi/SR, Ash/SSR; hỗ trợ đội, nâng cấp/nhánh/tiến hóa; UR mới là bậc dự trữ |
| Trận mới | Tối đa3 hero sở hữu +1 tinh linh, auto battle, điều khiển Ultimate/target/tốc độ, tối đa4 địch cùng lúc |
| Đội hình | Một ô trước, hai ô sau; không khóa nghề; snapshot lúc vào trận |
| Hành trình | 5 màn chính ID1–5 và10 màn nhánh ID6–15 |
| Phó bản chơi thật |101 Săn cổ thụ (UI Sân Cổ Thụ);102 Tháp sáu đợt;103 Tam vệ bình minh |
| Thế giới Phó bản |15 entry, lọc tài nguyên5/chiến thuật5/Boss4/chinh phục1, trang chi tiết, nguồn thưởng/đối thủ;12 entry stage0 chỉ preview |
| Trang bị |44 ID,6 bộ,4 slot weapon/armor/boots/accessory; mỗi bản có UID; túi40; cường hóa+15/rank3, rèn/hợp thành/phân giải |
| Bộ trang bị |Bình Minh, Hỏa Vũ, Thủy Triều, Lâm Vệ, Lôi Ảnh, Nguyệt Tinh; thưởng2/4 món |
| Nhận trùng |Gear giữ nhiều bản; hero/spirit trùng thành10 mảnh đúng ID; mảnh gear cũ giữ lại |
| Loot đầy túi |Hàng chờ bag_rewards tối đa128; không tự đổi gear rơi thành mảnh |
| Triệu hồi |Banner Thường, x1/x10:120 vàng/lượt hoặc1 vé/lượt, cùng pool/RNG/pity/history và transaction;20 lượt bảo đảm nhóm cao nhất của pool Thường |
| Phát triển |LV, kỹ năng, điểm thuộc tính, cây nhánh, thức tỉnh/tiến hóa, trang phục phối màu; các cơ chế riêng không thay cho độ hiếm gốc |
| Tiện ích |Nhiệm vụ ngày/tuần/tiến trình, thành tựu/bộ sưu tập, hồ sơ/avatar, AFK vàng trần2h |
| Cài đặt |Âm lượng riêng nhạc/SFX/UI/ambience, preview, đồ họa2D/FPS/pin, tự chiến, badge, backup/restore tệp có kiểm tra |
| Trình bày |Roster/nền/vai trò quái dùng PNG,106 vùng icon;46 WAV,42 cue ElevenLabs, ambience rừng và nhạc chill Moonlit Rest |

Mã nhóm xác suất triệu hồi1/2/3 (70/25/5) **không phải** năm độ hiếm gear hoặc
độ hiếm hero/spirit. Thêm18 gear0.35 mở rộng pool trong các nhóm, không tạo
banner Cao cấp/Sự kiện chơi được. Tên “Cao cấp” của nhóm pool không mở dịch vụ banner.

## Tám vật phẩm thiết yếu đã làm

Kho supplies cộng dồn riêng, không chiếm40 ô gear.
Túi đồ → Vật phẩm → Quà tiến trình để nhận quà1 lần theo cleared hiện có.

| ID | Công dụng/nguồn hiện tại |
| --- | --- |
|forge_stone|Đá Rèn Sáng:1 đá thay1 tinh thạch khi cường hóa, vẫn trả vàng;103 rơi2/thắng hoặc rương chọn|
|memory_shard|Mảnh Ký Ức: nâng một trong2 kỹ năng hero, cost bằng LV hiện tại, trần10;102 rơi2/thắng hoặc rương|
|ancient_seed|Hạt Giống Cổ Thụ:3 hạt →1 lõi tinh linh của hệ hiện có;101 rơi1/thắng hoặc rương|
|normal_ticket|Vé Thường: x1/x10, không trừ vàng; quà vượt ải2 một lần|
|material_chest|Rương chọn:3 đá hoặc2 mảnh hoặc3 hạt; quà vượt ải1 một lần|
|rage_potion|Thuốc Cuồng Nộ: +10% ATK đội trong1 run; Shop60 vàng|
|ward_potion|Thuốc Hộ Vệ: +10% phòng thủ đội trong1 run; Shop60 vàng|
|afk_hourglass|Đồng Hồ Cát AFK:2 giờ vàng theo công thức AFK, không mất phần AFK đang tích; quà vượt ải3 một lần|

Chọn thuốc chưa tiêu. Bắt đầu trận commit cùng phí/snapshot, kể cả thua đã dùng.
Resume không trừ lại; auto-next/đánh lại không tự chọn thuốc mới.
[Chi tiết giao dịch và hình](SUPPLIES.md).

## Chưa triển khai hoặc còn khóa

- Màn chơi cho12 phó bản preview, cơ chế Boss mới, Tháp Vô Tận100→500 tầng.
  Chưa có quét/3★/BXH, lịch sự kiện mùa hoặc tài khoản/server.
- 22 món còn lại và5 gear đặc biệt ở [ITEM_ROADMAP](ITEM_ROADMAP.md).
  Thuốc hồi/cleanse giữa đợt chưa có thời điểm dùng; không thêm nút combat giả.
- Banner Cao cấp/Sự kiện, rate-up/thưởng mốc; quà bộ đếm chưa cấu hình.
- Thanh toán, VIP cấp/quyền lợi, quảng cáo thưởng, cloud, hộp thư, giftcode,
  push OS và voice nhân vật. VIP EXP nhiệm vụ đã có, không đồng nghĩa VIP đã xếp cấp.
- Một số portrait dùng transform toàn tranh; Ryn có lớp tóc/vải riêng, không coi
  tất cả hero đã có rig hoặc animation mới. Tinh linh chuyển động bằng sprite transform.
- Chưa có APK phát hành, chưa xác nhận cảm ứng/FPS/nhiệt hoặc nghe loa điện thoại thật.

## Dữ liệu và tương thích bắt buộc

Save `user://first_light_v2.json`, schema12, giữ project name để không chuyển user://.
Đọc v2–v11 và đường chuyển v1, bảo toàn UID/đầu tư/mảnh/ví/pending.
v11→12 chỉ thêm ledger rỗng, không tự phát vật phẩm; v10 bổ sung18 ID mảnh0 theo
migration trang bị trước khi thêm ledger. Save hỏng/future giữ nguyên, có backup.

Model commit trước RAM và thưởng idempotent theo run ID. Trận singleton cũ vẫn
được chạy bằng BattleModel; không tính lại snapshot bằng stats hiện tại.
Build/mutation khóa khi pending/read-only, UI xem trước không tự ghi save.
Dùng profile test riêng bằng FIRST_LIGHT_SAVE_DIR.

## Những yêu cầu gần nhất cần nhớ

1. Tạo hệ15 phó bản **giao diện/đồ họa trước**, từng màn chơi làm sau.
2. Vật phẩm có công dụng/giá/nguồn thật, tận dụng lõi/tinh thạch/mảnh có sẵn.
3. Làm8 món thiết yếu trước; chưa làm toàn bộ30 món và5 gear đề xuất.
4. Dọn file sinh ra, giữ tài nguyên cần thiết và bàn giao đủ để chat sau tiếp tục.

Bước tiếp theo hợp lý: kiểm thử bản0.37 trên điện thoại của người dùng, xử lý lỗi
được báo; sau đó chốt một cơ chế/phó bản để làm thật. Đây là gợi ý, không phải
ủy quyền tự mở cả12 màn hoặc tất cả dịch vụ còn khóa.

## Chứng cứ và cách kiểm tra

Bản0.37 đã qua39 suite trên Godot4.6.3/Linux/Xvfb:
[biên bản](verification/supplies-0.37.json).
Sau dọn repo, dùng workflow Project verification, runner40 suite và kiểm tra
tham chiếu/audio. Ảnh/log/PCM mới ở work/checks hoặc artifact của lượt chạy,
không đưa output trở lại repo. Xem [TESTING](TESTING.md) và
[REPOSITORY_CLEANUP](REPOSITORY_CLEANUP.md) cho kết quả cụ thể.
