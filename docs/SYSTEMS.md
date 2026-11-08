# Kiến trúc hiện hành

Áp dụng cho game0.38/savev13. Trạng thái/phạm vi ở [GAME_STATE](GAME_STATE.md).
Công thức singleton0.2 được giữ riêng trong [tài liệu lịch sử](history/SYSTEMS_0_2.md);
không lấy trần+10, loot đổi shard hoặc đội1 người ở đó áp vào trận mới.

## Luồng chính

`project.godot` → `game/main.tscn` → `game/main.gd`.
Main khởi tạo catalogue, ProgressStore, FrameLibrary/UIIcons, AudioDirector và
các screen. Screen gọi giao dịch model; không tự tăng tài nguyên hoặc resolve hit.

| Thành phần | Trách nhiệm/nguồn |
| --- | --- |
|GameCatalog|Nạp catalog.json, ghép expansion.json và team_encounters.json; normalize số, validate ID/drop/slot/skill, suy ra stats|
|ProgressStore|Profile, migration v1–v13, backup/read-only, validate/commit, begin_run/settle và giao dịch gear|
|Formation|Roster/slot/assist/auto options và snapshot team/encounter; bốn slot không khóa nghề; đọc đội v12 ba ô qua bản sao|
|TeamBattle|Trận mới4vN, action/hit marker, HP/năng lượng, target, hiệu ứng/đội, kết quả|
|BattleModel|Nền model và đường chạy pending singleton cũ; không được xóa chỉ vì UI dùng TeamBattle|
|EquipmentSystem|4 slot, multiplier, bộ2/4, tham chiếu UID, map ID migration|
|CollectionFragments|Mảnh gear/spirit cũ và kiểm map theo phiên bản; không áp singleton vào gear hiện tại|
|Recruitment|RNG/pity/history riêng, pool70/25/5, quay vàng hoặc vé, transaction cả batch|
|Supplies|Ledger8ID, claim/recipe/mua/sử dụng, support snapshot và thưởng101–103|
|Expansion/SpiritSkills/HeroEvolution/AttributeTraining/Wardrobe|Các đường phát triển riêng, kiểm quyền/chi phí và pending|
|MissionBoard/PlayerIdentity/GameOptions|Nhiệm vụ UTC/claimed, hồ sơ/VIP EXP, cài đặt và backup tệp|
|DungeonWorld|Catalogue trình bày riêng15 địa điểm; stage0 không nằm trong catalogue màn chơi|
|FrameLibrary/UIIcons/EquipmentArt|Texture, atlas/region, socket, frame/duration và registry; không mô phỏng chiến đấu|
|BattleView/TeamBattleUI/CombatEffects|Đọc model/events và vẽ; renderer không đổi HP/RNG/ví|
|AudioDirector|Tiêu thụ marker/cursor, bus/pool/limiter và nhạc; presentation variation không dùng RNG trận|

## Character delivery previews

`CharacterPreviews` reads `game/data/character_previews.json` for explicit
presentation-only entries. It does not append to GameCatalog or mutate saves,
recruitment, ownership or Formation. This registers Caelan's delivered art in
Gallery/Home/Showcase without pretending his proposed kit is implemented.

## Presentation V2

`UIDesignV2` owns presentation tokens and controls; `HomeScreen` is startup page24,
Journey remains page0. `HeroShowcase` and `SummonReveal` use `game.modal` for input
blocking and the existing close lifecycle. Reveal reads committed copied results;
Showcase/Home read catalogue/profile without saving. See [UI handoff](UI_DESIGN_V2.md).

## Dữ liệu nguồn và builder

Caelan dùng manifest riêng được FrameLibrary ghép, sword signature chỉ đổi visual; builder hoàn chỉnh gọi build_caelan.py. Migration13 và runtime ở [CAELAN_RUNTIME](CAELAN_RUNTIME.md).

- `game/data/hero_contracts.json`: cấu hình vũ khí/vai trò/skill hiện hành, Gallery và summon group; được HeroContract kiểm tra. Không import registry launch.
- `game/data/catalog.json`:5 hero,44 gear,6 bộ,5 màn chính; builder
  `tools/build_catalog.py` gọi `build_equipment.py`.
- `game/data/expansion.json`:10 nhánh,3 challenge, nhánh kỹ năng/traits/achievements/
  chapters; builder `build_expansion.py`.
- `game/data/team_encounters.json`: encounter chiến đấu theo stage.
- `game/data/dungeon_world.json`:15 entry chỉ trình bày; đừng ghép stage0 vào GameCatalog.
- `art/painted/manifest.json` override `art/clips.json` trong FrameLibrary.
  SVG nền vẫn được load trước PNG; chúng chưa phải file thừa.
- `tools/build_complete_art.py` và các builder metadata giữ alias/socket/nguồn;
  `build_icon_manifest.py` là registry106 icon, atlas có grid khác nhau.
  Không chạy builder rồi bỏ qua diff. Chỉ chạy cái liên quan thay đổi.
- Audio import theo thứ tự nền → bổ sung → chill; giữ raw và receipt trong
  `art/audio/elevenlabs/`. `build_audio.py` là guard từ chối synth.

## Tạo và kết thúc run

1. Kiểm quyền vào ải/pending/cap hàng chờ; clone profile.
2. Tạo run ID/seed, team snapshot v2 (1–4 hero; tiếp tục nhận v1 tối đa3 hero), stats đầu team, options và encounter.
3. Nếu có thuốc, áp một lần vào candidate snapshot, trừ1 và xóa lựa chọn.
4. Commit thành công mới khởi động model. Resume đọc snapshot cùng seed;
   không gọi lại prepare hoặc tính stats theo trang bị mới.
5. Model resolve marker một lần, renderer/audio chỉ đọc events.
6. Settle kiểm run ID; clone candidate, thưởng/first-clear/story/mission/drop/supply,
   ghi settled và xóa pending trong một commit. Gear đầy vào hàng chờ128.
7. Main chỉ chuyển tiếp sau commit; nhận lại cùng run ID không tăng tài nguyên.

## Giao dịch và khôi phục

Deep copy → kiểm điều kiện/cost → validate → ghi file tạm → đọc/kiểm → giữ backup
→ thay file chính → thay RAM. Lỗi ghi/thiếu ô/thiếu nguyên liệu phải rollback
cả phí, RNG/history và reward. Không thay đổi ví trước khi commit xong.

Đường save và config/name giữ nguyên. Backup hợp lệ chỉ phục hồi sau khi giữ
file hỏng; future schema khóa ghi. UI có read-only/pending guards nhưng model
vẫn phải tự kiểm. Migrations giữ các snapshot cũ, không “sửa” chúng theo cân bằng mới.

## Ranh giới cần giữ

- Chọn hero đang xem không tự đổi đội hình. Tương tác portrait/filter không ghi save.
- Asset/nhãn hiển thị không tự cấp vật phẩm hoặc mở chức năng.
- Nguyên liệu/thuốc/vé cộng dồn riêng; gear là UID; nhiệm vụ không dùng nhầm.
- Preview/draft của settings đóng là hủy, trừ khi Lưu thành công.
- Các dịch vụ online chưa cấu hình không được giả lập thành hoạt động thật.
- Clock offline dựa trên máy; chưa có chống sửa giờ phía server.

Test trọng tâm và commands nằm ở [TESTING](TESTING.md), không chạy thử bằng save người chơi.
