# Trạng thái dự án — bắt đầu ở đây

> **0.41.0 — Arena trong Dungeons:** Đã thêm nơi setup hai phe1–4 hero và xem trận AI trên sân Celestial Courtyard được tạo mới. Thử hero runtime chưa sở hữu, full Energy, HP thử×1/3/5, Pause/x2/Replay; toàn bộ chỉ trong RAM, không phát thưởng hoặc đổi đội hình/save. Campaign và15 dungeon cũ giữ nguyên. Xem [ARENA_LAB](ARENA_LAB.md).

> **0.40.1 — preset hành vi AI:** Theo yêu cầu mới, áp dụng cự ly/tốc độ di chuyển, áp sát/truy kích/nối chiêu/phản công/liều chiến/đổi mục tiêu/né di chuyển riêng từng hero. Giữ nguyên chỉ số nâng cấp/trang bị và cooldown kỹ năng. Trận mới snapshotv4 đóng băng preset; v3 giữ ArenaBattle cũ, v1/v2/singleton giữ đường cũ. Savev13 không đổi. Đây là lượt chỉnh thực dụng trước khi làm lại nhân vật/cân bằng sâu. Xem [ARENA_COMBAT](ARENA_COMBAT.md).

> **0.40.0 — AI Arena:** Theo yêu cầu mới, trận mới dùng đấu trường2D di chuyển tự do: cận chiến áp sát, staff giữ cự ly/đạn phép, chọn mục tiêu gần, né vòng cảnh báo. Đội4+1 và các ải/phần thưởng hiện có giữ nguyên. Team snapshot mới **v3**; pendingv1/v2/singleton tiếp tục luật cũ. Savev13 không đổi. Đọc [ARENA_COMBAT](ARENA_COMBAT.md). Mô tả địch đánh theo slot bên dưới chỉ áp dụng combat cũ.

> **Mốc0.38 — đội hình4+1 (combat đã thay ở0.40):** Đội hình tối đa **4 hero + 1 tinh linh**, bố cục 2 trước + 2 sau, không khóa nghề. Save v12 đọc đội 3/4 ô; xem đội cũ chỉ thêm ô trống trên bản sao, ghi 4 ô khi người chơi chỉnh đội. Snapshot v1 và singleton cũ giữ nguyên; trận mới dùng v2. Xem [TEAM_COMBAT](TEAM_COMBAT.md).

Cập nhật2026-11-08. Game **0.41.0**, **Godot4.6.3**, save **v13**.
Đợt dọn repo không đổi gameplay hoặc schema. Repo triển khai:
[tai23082004l02-svg/aternal-senia](https://github.com/tai23082004l02-svg/aternal-senia).
Repo tham khảo: [Tham-kh-o-game](https://github.com/tai23082004l02-svg/Tham-kh-o-game).
Studio **ZORVYKA Games**, hỗ trợ **zorvykagames@gmail.com**.

Đọc [AGENTS](../AGENTS.md), [kiến trúc](SYSTEMS.md), [mục lục](INDEX.md).
Nếu có thay đổi sau mốc này, đọc HEAD/code và yêu cầu mới nhất trước khi tiếp tục.
Các con số dưới đây lấy từ catalogue/model, không lấy số minh họa trong ảnh.

## Admin code — 0.39.1

Theo yêu cầu chủ dự án, **More → Redeem Gift Code → admin** mở toàn bộ nội dung runtime và nâng tiến độ; có xác nhận, một lần/save, khóa pending/read-only. Giữ UID/đội hình/lịch sử, đồ dư vào hàng chờ. Không mở các hệ thống chưa triển khai. Xem [ADMIN_CODE](ADMIN_CODE.md). Save vẫn v13, thêm marker tùy chọn `redeemed_codes`.

## UI Celestial0.39 — đã triển khai theo yêu cầu mới

Thay trình bày Home, Gallery/Showcase, Summon/Reveal, menu và HUD chiến đấu; xem [UI_CELESTIAL_0_39](UI_CELESTIAL_0_39.md). Selena xuất hiện dưới ID xem trước `selena_preview`, không nằm trong catalogue chiến đấu hoặc pool triệu hồi. Home mặc định giới thiệu Selena, đổi portrait chỉ trong RAM. Có màn xem trước Reveal ghi rõ không phải kết quả triệu hồi. Thanh đáy theo mẫu: Formation / Equipment / Bag / Shop / More; Equipment mở đúng trang bị nhân vật, More giữ lối vào Characters/Adventure/Dungeons. Save vẫn v13; Bond/Story và banner chưa cấu hình vẫn khóa. Giữ PNG nguồn nguyên byte, không đổi tên Selene trong roster quy hoạch.

## Quyết định sản phẩm mới nhất — 2026-11-08 (chưa phải runtime)

**ĐÃ DUYỆT:** [GAME_DESIGN_V1.md](GAME_DESIGN_V1.md) chốt **24 hero, 12 nam/12 nữ, tất cả gốc 5★**, Gallery và Summon Reveal ưu tiên cao, Bond System, truyện ngắn theo nhân vật, tiếp tục repo này. Đây là ưu tiên cao hơn các dải mục tiêu 24–30 và ghi chú "chưa duyệt 24 hero" bên dưới. **Các số còn lại trong Launch Content Matrix vẫn là đề xuất.** Codex: WP01 audit chỉ đọc trước khi triển khai; không tự sửa gameplay/economy/save.

## Ưu tiên chiến lược trước đó (bối cảnh, chưa phải runtime)

Ngày 2026-11-08, chủ dự án xác nhận mục tiêu **Full Content Launch**: không đưa một game ít hero ra thị trường để thử retention rồi mới làm thêm nội dung. **Dự kiến phát hành Aternal Senia khi đã có roster nam/nữ phong phú, nhiều tinh linh, bộ trang bị, Boss, phó bản, hành trình và hệ kiếm tiền hoạt động thực**. Xem [Game Business & Monetization Plan V0.2](BUSINESS_MONETIZATION_PLAN.md) cho dải mục tiêu đề xuất và lộ trình sản xuất.

Các dải 24–30 hero, 10–12 tinh linh, 10–12 gear set là **đề xuất quy hoạch, chưa được chốt/triển khai**. QA và kiểm thử nội bộ vẫn bắt buộc, nhưng **không có public soft launch với 4 hero làm tiền đề**. Retention/LTV đo **sau phát hành chính thức** để cải thiện game và quyết định marketing. Monetization: rewarded ads tự nguyện + IAP có xác minh, cần triển khai thật riêng, hiện **chưa có**. Các hệ thống trong phần dưới phản ánh trạng thái 0.37 đang hoạt động, không phải mức hoàn thiện để phát hành.

**Danh mục phát hành dự kiến đã được biên soạn (chưa duyệt/chưa triển khai):** [LAUNCH_CONTENT_MATRIX V0.1](LAUNCH_CONTENT_MATRIX.md) và [registry JSON](launch/CONTENT_REGISTRY_DRAFT.json) định nghĩa chi tiết 24 hero nam/nữ cân đối, 12 tinh linh, 12 gear set, 7 vùng/84 stage, 12 Boss và 8 dungeon. Dùng để thống nhất nội dung trước khi giao Codex triển khai; **không lẫn với số lượng hiện đã hoạt động trong bảng dưới**.

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
làm ngôn ngữ chính. Toàn bộ giao diện dùng font đóng gói Playfair Display Bold; xem [ENGLISH_UI](ENGLISH_UI.md). Giữ tên người chơi Unicode, savev12,
ID và toàn bộ chỉ số/giao dịch.

## Gallery và nền dữ liệu hero — cập nhật triển khai

Đã thêm contract dữ liệu/vũ khí/kỹ năng cho bốn hero hiện có, Gallery lọc theo
hệ/vai trò/sở hữu và showcase, Summon Reveal cho vàng/vé x1/x10 có skip,
tổng kết và xem lại lô đã commit sau khi tải save. Giữ savev12, chỉ số, unlock,
pool/pity/giá và art cũ; chưa thêm 20 hero, Bond hoặc combat launch mới.
Chi tiết tương thích snapshot và kế hoạch migration roster: [HERO_COLLECTION](HERO_COLLECTION.md).

## Cập nhật0.38 — dọn UI và hiển thị Caelan (mốc trước tích hợp)

Ở mốc dọn UI, Caelan hiện qua registry preview riêng; bản tích hợp mới bên dưới đã thay entry này bằng hero runtime. Khi đó dùng đúng
art mới; ghi rõ **Design preview · Not playable**. Không tự cấp hero, mảnh hoặc
nhập kit đang đề xuất vào combat. Vẫn4 hero gameplay; thêm1 thiết kế xem trước.
Đã bỏ UI kỹ năng/tinh linh trùng, helper không dùng và recorder cũ; giữ model và
renderer singleton để resume save cũ. Home hiện version0.38.0; export Android in
version/commit để tránh mở nhầm thư mục cũ. [Chi tiết dọn](CLEANUP_0_38.md).

## UI Design V2 — Showcase, Reveal, Home

Đã có Home riêng khi khởi động (page24), nút Home trên header; Journey giữ page0.
Showcase xem art/identity/skill copy thật, chọn portrait, mở Equipment/Wardrobe qua
trang quản lý hiện hành; Bond/Story khóa. Reveal mới trình bày snapshot kết quả đã commit, có summary,
skip/replay và reduced motion; không gọi summon/RNG. Chọn portrait Home chỉ trong
RAM, không ghi save/formation/avatar. Module và handoff riêng ở
[UI_DESIGN_V2](UI_DESIGN_V2.md); artwork, pose, kỹ năng và nhân vật không đổi.

## Gallery — giao diện mới 2026-11-08

Gallery dùng lưới chân dung4 cột, khung vàng/navy, bộ đếm sở hữu thật, tab hệ,
lọc vai trò/sở hữu, reset và chế độ thẻ chi tiết2 cột. Hero khóa vẫn xem được;
xem/lọc/preview không đổi đội hình hoặc save. Hiện có5 hero runtime, không tạo
hero giả cho đủ24. Xem [HERO_COLLECTION](HERO_COLLECTION.md).

## Caelan và kit riêng — đã tích hợp0.38

[CAELAN_RUNTIME](CAELAN_RUNTIME.md): Caelan chơi được, có16 pose/kiếm riêng, tuyển miễn phí qua Showcase sau stage1 và farm2 mảnh tại103 khi có trong đội. Ryn có Ember Guard; Lyra có Twilight Comet đơn mục tiêu. Savev13 giữ pending/UID/đầu tư, UI V2 và đội4+1 hiện có.

## Đã hoạt động

| Phần | Trạng thái thực |
| --- | --- |
| Hero | Eira/light, Ryn/fire, Mira/water, Lyra/fire, Caelan/light;5 hero gốc5★, bốn hero đầu qua tiến trình/triệu hồi, Caelan qua tuyển miễn phí sau stage1; không sở hữu mặc định tất cả |
| Tinh linh | Lumi/SR, Ash/SSR; hỗ trợ đội, nâng cấp/nhánh/tiến hóa; UR mới là bậc dự trữ |
| Trận mới | Tối đa4 hero sở hữu +1 tinh linh, AI Arena di chuyển tự do, điều khiển Ultimate/target/tốc độ, tối đa4 địch cùng lúc |
| Đội hình | Hai ô trước, hai ô sau làm vị trí xuất phát; không khóa nghề; snapshot lúc vào trận |
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

Save `user://first_light_v2.json`, schema13, giữ project name để không chuyển user://.
Đọc v2–v12 và đường chuyển v1, bảo toàn UID/đầu tư/mảnh/ví/pending.
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
Sau dọn repo, dùng workflow Project verification, runner48 suite và kiểm tra
tham chiếu/audio. Ảnh/log/PCM mới ở work/checks hoặc artifact của lượt chạy,
không đưa output trở lại repo. Xem [TESTING](TESTING.md) và
[REPOSITORY_CLEANUP](REPOSITORY_CLEANUP.md) cho kết quả cụ thể.

## Selena — bộ ảnh mẫu

Đã tạo bảy ảnh nguồn theo mẫu Selena được chủ dự án thích, kèm [hướng dẫn mỹ thuật](SELENA_ART_BIBLE.md). Chưa đổi roster, UI, save hoặc kit; chibi là key pose thiết kế, chưa animation runtime.
