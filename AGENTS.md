# Hướng dẫn cho phiên chat phát triển tiếp

Đọc README → docs/GAME_STATE.md → docs/SYSTEMS.md → docs/INDEX.md trước khi sửa.
Trạng thái tại lần dọn repo 2026-11-08: game0.37.0, Godot4.6.3, savev12.
Yêu cầu mới nhất của người dùng ưu tiên tài liệu; kiểm HEAD và code trước khi làm.

## Định hướng sản phẩm và nội dung (2026-11-08)

- Chủ dự án đã **hủy** các bản thảo *The World That Forgot Tomorrow* và Character/World Story Bible; không dùng chúng làm canon.
- **QUYẾT ĐỊNH SẢN PHẨM:** Phát hành **một bản Full Content Launch hoàn chỉnh** của Aternal Senia (Hybrid Idle/Auto-Battle Fantasy RPG), **không ra mắt công khai game chỉ có vài hero để thử nghiệm retention**. Chủ dự án ưu tiên **nhiều nhân vật đẹp**, nam/nữ đa dạng, nhiều tinh linh, bộ trang bị, Boss, phó bản và gameplay hoàn thiện **ngay khi phát hành**.
- **Launch Content Matrix V0.1 (đang chờ chủ dự án duyệt):** [docs/LAUNCH_CONTENT_MATRIX.md](docs/LAUNCH_CONTENT_MATRIX.md) và [registry JSON](docs/launch/CONTENT_REGISTRY_DRAFT.json). Đây là bộ thiết kế **đầy đủ**: 24 hero (12 nam/12 nữ), 12 tinh linh, 12 set/48 set-items, 7 vùng/84 stage, 12 Boss, 8 dungeon và cosmetics; **đề xuất**, chưa tạo asset/code, không tự import JSON. Đọc trước bất kỳ task triển khai roster/spirits/gear/campaign/dungeon/store. Các ID Hxx/Sxx/Gxx/Rx/Bxx/Dxx chỉ để quy hoạch; runtime ID và save migration cần đặc tả, duyệt và test riêng.
- **Kế hoạch nguồn chuẩn:** [BUSINESS_MONETIZATION_PLAN V0.2](docs/BUSINESS_MONETIZATION_PLAN.md). Số lượng *đề xuất* để lập Launch Content Matrix: 24–30 hero, 10–12 tinh linh, 10–12 gear set, 6–8 vùng, 60–100 encounter, 8–12 Boss; **chưa chốt** và không được suy thành asset/runtime đã có. Khi chủ dự án duyệt nội dung, sản xuất đủ trước public release. Không được giảm roster xuống 4 hero chỉ vì tiết kiệm thời gian.
- **Cho phép và bắt buộc:** Làm từng lô nội bộ, QA kỹ thuật, test Godot/Android/billing/ads/save. Những hoạt động này **không phải public soft launch**; không đưa sản phẩm thiếu nội dung ra cửa hàng để hỏi người chơi có muốn thêm hero không.
- Mô hình kiếm tiền: **rewarded ads tự nguyện + IAP thật** có backend/receipt/entitlement/privacy; chuẩn bị để có thể hoạt động ngày phát hành. Cốt truyện chỉ hỗ trợ tạo ra hero, tinh linh, gear, Boss, vùng đất và nội dung chơi lại; không tiêu tốn nguồn lực vào saga dài nếu không phục vụ game.
- Plan được quyền định hướng các task tiếp theo nhưng **không là lệnh tự tích hợp SDK, mở gói bán, tự xóa item/hero hoặc sửa economy/save**. Phải có chỉ định công việc cụ thể, kiểm thử và bảo toàn giao dịch. Đo retention/LTV sau phát hành để tối ưu kinh doanh, **không dùng như điều kiện cho phép xây roster gốc**.


## Game Design V1.0 — quyết định đã duyệt (2026-11-08)

**ĐỌC BẮT BUỘC:** [docs/GAME_DESIGN_V1.md](docs/GAME_DESIGN_V1.md) trước khi lập kế hoạch hoặc triển khai hero, Gallery, Summon Reveal, Bond, cốt truyện nhân vật. Chủ dự án đã duyệt **24 hero (12 nam/12 nữ), tất cả gốc 5★, ưu tiên Gallery/Summon Reveal, bổ sung Bond, truyện ngắn xoay quanh nhân vật, tiếp tục repo hiện tại**. Đây là quyết định mới hơn các câu ghi "24 hero chưa chốt" ở tài liệu cũ; **chỉ phạm vi sáu quyết định này được duyệt**, các con số khác trong Launch Content Matrix và thông số chi tiết vẫn là draft. Không coi tài liệu thiết kế là code đã chạy. **Bước Codex tiếp theo: WP01 audit chỉ đọc, không sửa/commit/push**, trừ khi chủ dự án giao task mới rõ ràng.


**QUYẾT ĐỊNH MỚI (2026-11-08):** Mục tiêu đội hình V1.0 là **4 hero + 1 tinh linh**, thay cho 3 hero + 1 tinh linh. Đã triển khai theo yêu cầu tiếp theo của chủ dự án: 2 trước + 2 sau, không khóa nghề; save v12 nhận đội cũ 3 ô và đội mới 4 ô, snapshot v1 giữ nguyên, trận mới dùng snapshot v2. Địch vẫn ưu tiên slot còn sống nhỏ nhất. Xem docs/TEAM_COMBAT.md.

## Phân công UI / nhân vật — 2026-11-08

- Người dùng giao UI, bố cục, điều hướng và cảnh nền cho nhánh công việc UI. Người khác phụ trách tạo hình, trang phục, vũ khí, pose, bản sắc và thiết kế kỹ năng nhân vật. Không trộn hoặc tự sửa đầu vào nhân vật trong task UI.
- Handoff UI riêng: [docs/UI_DESIGN_V2.md](docs/UI_DESIGN_V2.md). Tokens ở `game/ui_design_v2.gd`; Gallery/Showcase/Reveal/Home là các module trình bày riêng, đọc art/contract hiện có. Giữ ID, provenance và source artwork; không di chuyển chúng chỉ để tổ chức UI.
- Home mới là page24 khi khởi động; Journey vẫn page0. Header Home và More trên Home giữ điều hướng. Chọn portrait Home chỉ trong RAM, không ghi favorite/avatar/formation. Bond/Story vẫn khóa.

## Cộng tác và phạm vi

- Người dùng yêu cầu luôn đẩy kết quả lên GitHub sau khi hoàn thành nhiệm vụ,
  không hỏi lại. Kiểm main/working tree trước khi sửa
  và trước khi push; giữ thay đổi của người khác. Không force push hoặc viết lại lịch sử.
- Không tự mở SDK/quảng cáo/thanh toán/cloud/server hoặc phát thưởng giả từ giao diện.
  Các dịch vụ chưa có cấu hình phải giữ khóa và giải thích.
- Không suy diễn tính năng đã xong từ ảnh concept. Dữ liệu và hành vi thật là chuẩn.
- Không ghi API key, token hoặc secret vào code, tài liệu, log hay runtime.

## Save, sở hữu và giao dịch

- `ProgressStore.VERSION=12`; file `user://first_light_v2.json` và config/name phải
  giữ ổn định. Đọc v2–v11 qua migration và đường chuyển v1 hiện có. Không xóa/reset
  save lỗi; giữ backup/corrupt/future-version read-only. Tests dùng profile riêng.
- Deep copy → validate → ghi/kiểm file → commit thành công mới thay RAM.
  Reward/run ID, pending snapshot, seed, UID và lịch sử nhận phải được bảo toàn.
- Gear nhiều bản cùng base, mỗi UID/enhance/rank độc lập; 4 slot weapon/armor/boots/
  accessory, túi40, +15, rank3. Loot đầy vào bag_rewards tối đa128; không tự đổi
  gear trùng thành mảnh. Hợp thành giữ1 UID, tiêu thụ2 bản +0 không mặc cùng base/rank.
- Hero/spirit trùng vẫn thành10 mảnh đúng ID. Không gộp lại mô hình singleton0.23.
- Năm bậc gear duy nhất: Hiếm/Sử thi/Huyền thoại/Thần thoại/Thần thánh (mã3–7).
  Độ hiếm hero, tinh linh và nhóm xác suất triệu hồi là các hệ riêng.
- `Supplies` giữ ledger8ID riêng, không chiếm40 ô gear. Chỉ trừ sau xác nhận và
  commit. Một thuốc/run; trừ cùng begin_run, ghi buff vào snapshot, xóa lựa chọn.
  Resume không trừ/cộng lần2; auto-next không tự dùng tiếp. Giá trị buff mới chuẩn
  hóa6 chữ số; không tái tính snapshot cũ.
- Vé dùng pool Thường/RNG/pity/history sẵn có; x1/x10 atomic và rollback toàn bộ
  khi thiếu ô/lỗi ghi. Cao cấp/Sự kiện vẫn khóa. Không tạo bảng rơi tất cả vật phẩm.
- Mốc ngày/tuần theo UTC chỉ tiến; claimed vĩnh viễn không mất. VIP EXP đã có,
  nhưng ngưỡng cấp VIP/quyền lợi/thanh toán chưa chốt.

## Chiến đấu và giao diện

- Ngôn ngữ chính của toàn bộ UI là tiếng Anh; nội dung mới dùng tiếng Anh.
  Không dịch tên người chơi đã lưu. Toàn bộ giao diện dùng Playfair Display Bold,
  gồm tiêu đề, nút, chỉ số, mô tả, menu và ô nhập liệu; xem docs/ENGLISH_UI.md.
  Dùng font đóng gói qua UIFonts và Typography, không dùng font hệ thống.

- Trận mới: TeamBattle/TeamBattleUI, tối đa4 hero sở hữu +1 tinh linh, tối đa4 địch.
  Đội hình không khóa nghề. BattleModel giữ tương thích pending singleton cũ.
- Model sở hữu damage, RNG, marker và phát sự kiện; renderer/frame/socket/seek
  không sửa HP, ví hoặc reward. Nhận thưởng phải commit trước khi auto-next;
  dừng tại Boss quan trọng.
- Catalogue chiến đấu có18 stage. DungeonWorld riêng15 entry theo nhóm5/5/4/1;
  chỉ101/102/103 chơi được. Không biến stage0 preview thành màn thật hoặc phát
  thưởng/quét/3★/BXH giả. Tháp100→500 và sự kiện mùa chưa có màn chơi.
- Mọi vùng cuộn mới dùng SwipeScroll. Giữ cả hai cờ emulate touch/mouse; PASS thẻ/
  nút cho engine nhận drag, SCROLL_BEGIN hủy click. Không thêm bộ kéo song song.
- Chữ/nút/chỉ số là control thật, dùng tr(), wrap/giãn/cuộn. Không bake vào tranh.
  Xem/chọn hero/portrait/filter không tự đổi đội hình hoặc ghi save.
  Pending/read-only khóa build/mutation; mở menu trong trận phải pause/resume đúng.
- Cài đặt: GameOptions/SettingsScreen; studio ZORVYKA Games,
  zorvykagames@gmail.com. Preview đóng là hủy; backup file có validate/xác nhận,
  khóa pending/read-only. Ưu tiên heal nằm trong snapshot trận mới, cũ defaulttrue.

## Mỹ thuật và âm thanh

- Trước tạo/thay/đổi tên hero phải đọc docs/CHARACTER_BIBLE.md và
  docs/CHARACTER_CREATION_GUIDE.md, xem ảnh chuẩn thực tế.
  Ryn27 tuổi tóc đỏ rượu ngang vai; Lyra24 tuổi đuôi ngựa cao là hero khác.
  Không phục hồi art/painted/ryn_* hoặc art/ryn_*.svg đã bị xóa.
- Fantasy anime2D vẽ tay, navy/teal, ngà và vàng ấm; chiến đấu hơi chibi.
  Không lấy asset trích từ repo tham khảo; không gọi nội dung riêng là canon Eternal Senia.
- Tạo/chỉnh ảnh bằng image generation. Giữ nguồn PNG nguyên byte, alpha/provenance/
  receipt; builder hiện hành chỉ metadata/region/socket. Không dùng code xóa nền/
  vẽ lại pixel, không tự thêm rig hoặc thay toàn bộ bộ pose đang có.
- Registry chung art/icons/manifest.json hiện106 vùng. Sửa builder tương ứng;
  xem manifest/runtime thay vì coi mọi atlas là4x4. Giữ alias vũ khí cùng lớp.
- Runtime audio là ElevenLabs:46 WAV,42 cue, ambience và Moonlit Rest music.
  Giữ toàn bộ raw/receipt/provenance kể cả lỗi Music401 lịch sử.
  Không tự tái tạo batch trả phí; không thay bằng synth. build_audio.py chỉ từ chối.
- Audio phát theo marker, RNG presentation riêng; bounded pool12, UI/SFX bus riêng,
  mute/pause/cursor không phát backlog. Import hậu kỳ không cần key; thứ tự
  import_elevenlabs_audio → import_additional_audio → import_chill_music.
  Không gọi generation API trong CI.

## Kiểm tra và vệ sinh repo

- Đọc docs/TESTING.md. Runner chung: `python3 tools/check_project.py` trên display/
  Xvfb; ảnh/log/results chỉ trong work/checks. Dùng FIRST_LIGHT_SAVE_DIR riêng và
  FIRST_LIGHT_CAPTURE_DIR cho test. Không chạy render test bằng --headless.
- Logic: regression/mechanics/campaign; thay combat thêm team_battle/team_matrix/
  team_campaign/team_flow/team_ui. UI/art: suite màn sửa, ui_flow/animation_gallery,
  render và xem ảnh. Migrations/economy: supplies, bag_inventory, unique_collection,
  equipment_sets, additional_equipment, recruitment/summon_batch và UI tương ứng.
- Hero/art thêm character_design/character_ui/wardrobe/portrait_touch/ryn_art/
  ryn_gallery/lyra/complete_art khi liên quan. Audio thêm audio/additional_audio/music,
  settings_audio, tests/validate_audio.py và audio_capture nếu đổi gain/asset/UI.
- Chạy tools/verify_repo.py sau sửa file/tài liệu. Giữ .uid; không xóa asset chỉ vì
  không thấy tên literal: manifest, builder, fallback và migration có tham chiếu động.
- Không commit work/, .godot/, cache, output build, APK, save người chơi, screenshot/
  video/mixer capture. CI read-only, xuất artifact, không tự push chứng cứ.
- Media minh họa cũ liên kết ở docs/ARCHIVED_MEDIA.md; 5 biên bản JSON tại
  docs/verification/. Nguồn canon vẫn ở art/ và docs/concepts/.
- Báo đúng kiểm tra đã chạy và giới hạn. Linux/Xvfb/PCM không chứng minh đã thử
  cảm ứng/FPS hoặc nghe loa trên điện thoại thật. Không viết tính năng đang thiết kế
  thành “đã có” trong bàn giao. Cập nhật GAME_STATE/INDEX khi đổi cơ chế/phạm vi.
