# Các mốc phát triển

Các mốc mô tả lịch sử, không thay [GAME_STATE](GAME_STATE.md).
Bản hiện tại0.38/savev13; mốc dọn repo trước đó không đổi gameplay/schema.

| Mốc | Thay đổi |
| --- | --- |
|0.38|Caelan chơi được,16 pose/kiếm riêng, tuyển miễn phí sau stage1 và mảnh103; Ryn/Lyra kit riêng, migration13 giữ snapshot/UID; giữ UI V2 và4+1|
|Gallery2026-11-08|Contract hero/vũ khí/kỹ năng giữ hành vi cũ; Gallery4 hero; Summon Reveal vàng/vé, tổng kết và replay lô đã commit; giữ savev12|
|Dọn repo2026-11-08|Bỏ output minh họa khỏi checkout, tài liệu bàn giao hiện hành, CI40 suite/artifact, xuất Android gọn|
|0.37|8 vật phẩm dùng thật,106 icon, ledger supplies, savev12|
|0.36|Cài đặt fantasy, tùy chọn đồ họa/tự chiến/UI audio/backup và thông tin ZORVYKA Games|
|0.35|18 trang bị, thêm Lâm Vệ/Lôi Ảnh/Nguyệt Tinh, tổng44 gear/6 bộ, savev11|
|0.34|Thế giới15 phó bản, trang chi tiết/Tháp,12 preview chờ màn chơi|
|0.33|Giao diện Cổng triệu hồi, banner và control tách khỏi ảnh|
|0.32|Nhạc ElevenLabs Moonlit Rest và8 SFX bổ sung|
|0.31.1|Vuốt cuộn trực tiếp trên thẻ/nút cho màn dài|
|0.31|Trang Nhân vật liền tranh, hai phần Thông tin/Trang bị, nhãn có tr()/wrap|
|0.30|Túi đồ nhiều bản gear/UID, hàng chờ/hợp thành, bốn lối vào, savev10; thay singleton gear|
|0.29–0.28|Banner4 hero và bố cục Nhân vật mới|
|0.27|4 slot, bộ2/4,5 bậc gear,+15,26 item, savev9|
|0.26–0.25|Giao diện nhiệm vụ và đội hình3 ô|
|0.24|TeamBattle3vN cho trận mới, giữ singleton pending cũ|
|0.23|Lịch sử singleton/mảnh, savev7; singleton gear không còn áp dụng|
|0.22|Bộ icon nền chung, sau đó mở rộng gear và supply|
|0.20|Nhiệm vụ ngày/tuần/tiến trình và VIP EXP; chưa có ngưỡng VIP|
|0.19|Ryn tóc ngang vai,16 pose/vũ khí rời; xóa raw cũ theo yêu cầu|
|0.18–0.17|Menu Tiện ích, triệu hồi x1/x10 atomic và counter riêng cho banner tương lai|
|0.16|Hero thứ tư Lyra, khác Ryn, savev6|
|0.15|Tên/avatar, VIP UI chưa dịch vụ thanh toán|
|0.14–0.10|Các lượt portrait/mobile/Shop/tiến hóa; thiết kế Ryn0.14 đã bị thay|
|0.9–0.7|Nhánh kỹ năng, phát triển, triệu hồi, điểm thuộc tính, truyện nhánh/tinh linh|
|0.6–0.3|Pose/socket/marker, VFX, ElevenLabs và lượt Eira/rừng đầu tiên|
|0.2|Prototype singleton, cơ chế/save nền; còn dùng tương thích pending cũ|

[Bản README đầy đủ trước dọn repo](https://github.com/tai23082004l02-svg/aternal-senia/blob/8422241ab7c6361b215b235d75208425d1597207/README.md)
lưu diễn giải từng lần triển khai. Dùng link cố định này khi nghiên cứu lịch sử,
không sao chép cơ chế lỗi thời trở lại code.

## 2026-11-08 — Four-hero teams

- Implement 4 owned heroes + 1 spirit, 2 front/2 back formation and Journey preview, four hero Ultimate cards plus a separate spirit strip.
- Keep v12 three-slot formations readable without view-time writes; new edits save four slots. New battle snapshots are v2; v1 three-hero and singleton pending runs remain compatible.
- Preserve slot-priority targeting, ownership, transaction guards, rewards and combat coefficients. Add four-hero determinism, reload, rollback, settlement and UI coverage.

## 2026-11-08 — Portrait Gallery refresh

- Replace the text-heavy hero list with four-column portrait cards, navy/gold styling, real owned/total count and affinity tabs.
- Add compact/detail views, combined ownership/role filters, reset and empty results. Locked heroes remain inspectable; source artwork, acquisition and save data stay intact.
- Extend collection_ui with card bounds, 24-entry scrolling fixtures and view/filter interactions without profile mutation.

## 2026-11-08 — UI Design V2: Showcase, Reveal, Home

- Add shared presentation tokens and separate Home/Showcase modules; startup Home is page24, Journey stays page0 and the header has a Home action.
- Replace Gallery's simple preview with a read-only Showcase, real Information/Skills and guarded Equipment/Wardrobe routes. Bond/Story remain locked.
- Refresh committed-results Reveal and summary, including hero details and reduced motion. Preserve summon transactions, replay, old saves and pending battle behavior.
- Document UI/character workstream boundaries in UI_DESIGN_V2; source character art, contracts and mechanics are unchanged.
