# Mục lục tài liệu

Phiên mới: [AGENTS](../AGENTS.md) → [GAME_STATE](GAME_STATE.md) →
[SYSTEMS](SYSTEMS.md) → chuyên đề cần sửa → [TESTING](TESTING.md).
Trạng thái chuẩn là0.37/savev12. Phần mang số phiên bản cũ trong chuyên đề mô tả
thời điểm triển khai; không áp lại singleton, +10,7 bậc gear hoặc savev4/v7.

## Bàn giao và thao tác

| Tài liệu | Dùng khi |
| --- | --- |
|[GAME_STATE](GAME_STATE.md)|Xem đã làm/chưa làm, yêu cầu gần nhất và bước tiếp theo|
|[SYSTEMS](SYSTEMS.md)|Theo luồng model/save/run/view/audio hiện hành|
|[REPOSITORY_MAP](REPOSITORY_MAP.md)|Tìm nguồn, builder, validator và output|
|[TESTING](TESTING.md)|Chạy kiểm tra và tìm artifact|
|[ANDROID_TERMUX](ANDROID_TERMUX.md)|Tải/cập nhật/xuất Godot trên điện thoại|
|[CHANGELOG](CHANGELOG.md)|Các mốc phát triển, tránh nhầm cơ chế lịch sử|
|[REPOSITORY_CLEANUP](REPOSITORY_CLEANUP.md)|File bỏ/giữ, lý do và giới hạn dung lượng Git|
|[ARCHIVED_MEDIA](ARCHIVED_MEDIA.md)|Ảnh/video/PCM cũ qua link cố định, không tải cùng repo|
|[verification](verification/)|Biên bản JSON nhỏ đã phát hành|

## Chiến lược sản phẩm và kiếm tiền

| Tài liệu | Phạm vi |
| --- | --- |
|[BUSINESS_MONETIZATION_PLAN](BUSINESS_MONETIZATION_PLAN.md)|**Business Design V0.2 — Full Content Launch**: sản xuất nhiều hero nam/nữ đẹp, tinh linh, gear, Boss và phó bản trước khi phát hành chính thức; rewarded ads + IAP thật, QA nội bộ, kinh tế, business KPI sau phát hành|
|[LAUNCH_CONTENT_MATRIX](LAUNCH_CONTENT_MATRIX.md)|**Full Content Launch · Draft V0.1**: 24 hero (12 nam/12 nữ), 12 tinh linh, 12 gear set, 7 vùng, 84 stage, 12 Boss, 8 dungeon, 24 costume variants; bảng sản xuất và điều kiện nghiệm thu|
|[CONTENT_REGISTRY_DRAFT](launch/CONTENT_REGISTRY_DRAFT.json)|Danh mục JSON cấu trúc cho Codex tra cứu 24 hero, 12 tinh linh, 12 set, 7 region, 84 stage, 12 Boss, 8 dungeon; **không tự import vào runtime**|

**Ưu tiên:** Hoàn thiện dàn nội dung lớn và hệ kiếm tiền thật trước khi phát hành; QA nội bộ kỹ lưỡng, không public bản thiếu nội dung. Retention/KPI dùng sau phát hành để cải thiện sản phẩm. Giá, mức thưởng và số lượng nội dung trong kế hoạch chưa được chốt.

## Gameplay và dữ liệu

| Tài liệu | Phạm vi |
| --- | --- |
|[TEAM_COMBAT](TEAM_COMBAT.md)|Trận đội3vN, snapshot, model/events, tương thích singleton|
|[FORMATION_SCREEN](FORMATION_SCREEN.md)|Bố cục đội hình, slot, chọn hero/tinh linh|
|[BAG_INVENTORY](BAG_INVENTORY.md)|Gear nhiều bản/UID,40 ô, hàng chờ, hợp thành/rèn/tách|
|[EQUIPMENT_SETS](EQUIPMENT_SETS.md)|4 slot,5 độ hiếm,+15, hiệu ứng và bộ2/4|
|[ADDITIONAL_EQUIPMENT](ADDITIONAL_EQUIPMENT.md)|18 món/3 bộ mới, pool và migration v10→v11|
|[SUPPLIES](SUPPLIES.md)|8 vật phẩm ưu tiên, ledger, source/cost/claim/rollback|
|[ITEM_ROADMAP](ITEM_ROADMAP.md)|22 món và5 gear còn lại, chưa được triển khai|
|[DUNGEON_WORLD](DUNGEON_WORLD.md)|15 entry UI,3 màn thật,12 preview|
|[JOURNEY_SCREEN](JOURNEY_SCREEN.md)|Bản đồ Hành trình, AFK và lối tắt|
|[MISSIONS](MISSIONS.md)|Nhiệm vụ UTC, EXP, reward/claimed|
|[MISSION_VISUALS](MISSION_VISUALS.md)|Trạng thái rương, giao diện ngày/tuần/tiến trình|
|[SETTINGS_SCREEN](SETTINGS_SCREEN.md)|GameOptions, preview, backup và thông tin studio|
|[PLAYER_VIP](PLAYER_VIP.md)|Hồ sơ/avatar và phần VIP còn chờ cấu hình|
|[UTILITIES_MENU](UTILITIES_MENU.md)|Menu/badge, dịch vụ chưa có|
|[TRAINING](TRAINING.md)|Điểm thuộc tính/sổ tay; phần combat lịch sử cần đối chiếu model mới|
|[EXPANSION](EXPANSION.md)|Traits/talents, tinh linh, nhánh/achievement; mốc0.7|
|[UNIQUE_COLLECTION](UNIQUE_COLLECTION.md)|Lịch sử mảnh/migration; singleton gear0.23 đã bị0.30 thay thế|
|[PROGRESSION_09](PROGRESSION_09.md)|Lịch sử skill/triệu hồi; dùng SUMMON_VISUALS/SUPPLIES cho UI/vé hiện tại|

## Nhân vật, mỹ thuật và âm thanh

| Tài liệu | Phạm vi |
| --- | --- |
|[CHARACTER_BIBLE](CHARACTER_BIBLE.md)|Canon, tuổi/nhận diện, nguồn chuẩn; bắt buộc trước tạo hero|
|[CHARACTER_CREATION_GUIDE](CHARACTER_CREATION_GUIDE.md)|Prompt/reference, image generation, nguồn và tích hợp|
|[RYN_ART](RYN_ART.md)|Ryn0.19,16 pose và layer tóc/vải; không phục hồi raw cũ|
|[CHARACTER_PANEL_UI](CHARACTER_PANEL_UI.md)|Trang Nhân vật0.31, tr()/wrap và control thật|
|[CHARACTER_BANNERS](CHARACTER_BANNERS.md)|Tranh dọc0.29 và chuyển động toàn tranh|
|[CHARACTER_REDESIGN](CHARACTER_REDESIGN.md)|Bố cục0.28 và mapping index; không đổi model vì ảnh|
|[CHARACTER_SCREEN](CHARACTER_SCREEN.md)|Lịch sử bố cục0.11, không phải layout hiện tại|
|[ICONS](ICONS.md)|Registry106 vùng, grid từng atlas|
|[AUDIO](AUDIO.md)|ElevenLabs, raw/receipt, hậu kỳ, marker/pool/limiter|
|[AUDIO_ADDITIONS](AUDIO_ADDITIONS.md)|Moonlit Rest,8 SFX mới và ducking|
|[SUMMON_VISUALS](SUMMON_VISUALS.md)|Triệu hồi0.33, banner/control và dịch vụ khóa|
|[SUMMON_SCREEN](SUMMON_SCREEN.md)|Mốc0.17, x1/x10/counter; vé mới ở SUPPLIES|
|[ENGLISH_UI](ENGLISH_UI.md)|Tiếng Anh mặc định, font theo vai trò và kiểm tra giao diện|
|[MOBILE_SCROLL](MOBILE_SCROLL.md)|SwipeScroll, drag trên thẻ/nút và Android|
|[REFERENCE_MAP](REFERENCE_MAP.md)|Bằng chứng từ repo tham khảo, giới hạn phục hồi|

## Pipeline và hình ảnh lịch sử

[ART_PIPELINE](ART_PIPELINE.md), [COMBAT_FEEL](COMBAT_FEEL.md),
[ENVIRONMENT_ART](ENVIRONMENT_ART.md), [GRAPHICS_COMPLETE](GRAPHICS_COMPLETE.md),
[MOBILE_INVENTORY](MOBILE_INVENTORY.md), [SHOP_RARITY_CHARACTER](SHOP_RARITY_CHARACTER.md),
[UI_ICONS](UI_ICONS.md), [SYSTEMS0.2](history/SYSTEMS_0_2.md).

Giữ các tài liệu này cho nguồn gốc/migration/thiết kế, không coi số liệu cũ là
hợp đồng hiện hành. Ảnh đi kèm đã liên kết đến commit trước dọn repo.
