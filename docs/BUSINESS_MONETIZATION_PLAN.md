# Aternal Senia — Game Business & Monetization Plan

> **BUSINESS DESIGN V0.2 · 2026-11-08 · FULL CONTENT LAUNCH FIRST · KẾ HOẠCH, CHƯA CODE**
>
> **Quyết định chủ dự án:** **KHÔNG phát hành bản nhỏ/soft launch với vài hero để thăm dò người chơi.** Chỉ công bố sản phẩm khi đã hoàn thiện dàn nhân vật phong phú, đa dạng nam nữ, nhiều tinh linh, trang bị, Boss, hành trình, nội dung chơi lại, hình ảnh và hệ thống kiếm tiền thực. Không trì hoãn sản xuất roster chỉ vì chưa có dữ liệu D1/D7/D30.
>
> **Phân biệt:** **Sản xuất và QA nội bộ theo từng giai đoạn** là bắt buộc để chất lượng tốt; đó **không phải** phát hành game thử công khai. Có thể dùng build nội bộ để phát hiện crash, lỗi save, lỗi billing, lỗi ad reward. **Một lần ra mắt chính thức với nội dung đầy đủ.**
>
> **Trọng tâm:** Android, thị trường Mỹ, người chơi yêu thích fantasy anime / sưu tầm hero / auto-battle idle. Rewarded ads chủ động + IAP xác minh thật ngay khi phát hành (nếu đạt chuẩn kỹ thuật/pháp lý). Cốt truyện dùng để tạo nhân vật, tinh linh, vũ khí, thế giới, sự kiện — không đầu tư đại truyện dài chỉ để kể chuyện.
>
> **Hướng dẫn Codex:** Đây là kế hoạch sản phẩm **không tự cấp quyền sửa code, mở SDK, tự xóa hero/item, tăng tỉ lệ quay hoặc reset save**. Các số lượng nội dung bên dưới là **mục tiêu quy hoạch đề xuất** để lập ngân sách và lịch sản xuất, chưa phải đã có trong runtime hoặc là số cuối cùng được duyệt. Cần task được giao và test mỗi phần.
>
> Đã hủy Story Bible cũ *The World That Forgot Tomorrow*; không dùng làm canon hoặc ràng buộc hệ thống mới. Trạng thái thật phải xem [GAME_STATE](GAME_STATE.md) và HEAD của repository.

# 1. Quyết định chiến lược — Full Content Launch

**Thể loại:** **Hero Collection Idle Fantasy RPG** — build đội hình tự đánh 3 hero + 1 tinh linh, triệu hồi, phân vai, trang bị theo set, PvE campaign, Boss, dungeon, AFK, nhiệm vụ và sưu tầm.

**Phương pháp sản xuất:** **Content-first, quality-first, monetization-ready**. Tạo hình hero đẹp và nhận diện độc lập là giá trị cốt lõi của sản phẩm; cần đủ nhân vật để người chơi thấy bộ sưu tập có chiều sâu ngay ngày đầu. Nội dung được sản xuất theo đợt nội bộ để quản lý chất lượng, **không public từng đợt nhỏ để chờ phản ứng**.

**Nguồn thu ngày phát hành (nếu đã tích hợp và xác thực):**
- **Rewarded ads tự nguyện**, phần thưởng nhỏ và cố định/có trần, không đè lên trận chiến.
- **IAP**: gói tân thủ, trang phục, vật phẩm nâng cấp xác định, gói tài nguyên và gói sưu tầm; bán quyền triệu hồi random chỉ khi có đủ disclosures, kiểm toán pool và purchase backend.
- **Không thiết kế bức tường paywall**: người chơi miễn phí vẫn có đội hình mạnh, nội dung chính và nguồn nguyên liệu hợp lý.

## 1.1. Mục tiêu quy mô của **bản phát hành hoàn chỉnh**

| Mảng | Mục tiêu thiết kế đề xuất | Điều kiện chất lượng |
| --- | --- | --- |
| **Hero** | **24–30** hero có thể sở hữu lúc ra mắt, **nam/nữ cân đối** (ví dụ đích 12 nam + 12 nữ cho 24 đầu) | Mỗi hero có silhouette, portrait, battle animation, vũ khí, kit, vai trò và nguồn sở hữu riêng; không chỉ recolor |
| **Tinh linh** | **10–12** | Bộ dáng, hiệu ứng, vai trò chiến thuật và cách sở hữu rõ; đủ lựa chọn 1 slot hỗ trợ |
| **Bộ trang bị** | **10–12 set** có nhận diện; gear phổ thông và unique bên ngoài set được định nghĩa riêng | Có 2/4-piece effects, nguồn rơi, hướng build, art icon, cân bằng |
| **Vùng/chương** | **6–8 vùng fantasy** khác biệt | Background, quái, Boss, chủ đề gear/hero riêng; lore ngắn phục vụ thiết kế |
| **Hành trình** | **60–100 stage/encounter PvE** có nhịp độ | Không nhân bản stage vô nghĩa; có milestone, cơ chế và thưởng hợp lý |
| **Boss** | **8–12 Boss** khác chiến thuật | Telegraph, kỹ năng, counterplay, đồ rơi và trình diễn |
| **Phó bản thật** | **6–10 hoạt động** có gameplay và rewards thật | Farm nguyên liệu, gear, spirit, boss; không stage0 preview giả |
| **Trang phục/sưu tầm** | Một gallery/collection và các ngoại hình có thể nhận hoặc mua | Đẹp, rõ giá trị, không dùng skin pay-to-win |
| **Store & ads** | 2–4 ad placements tự nguyện, **6–8 SKU IAP thực** là mục tiêu ban đầu | SDK, backend entitlement/receipt, giá từ storefront, refund, lỗi offline, privacy đầy đủ |

**Các con số là mục tiêu sáng tác/ước lượng khối lượng để phê duyệt ngân sách. Không phải yêu cầu cứng hoặc thành tựu đã hoàn thành.** Khi sản xuất, hãy quyết định roster chính thức bằng một **Launch Content Matrix** và art pipeline. Không tự rút về 4 hero vì thấy ít tốn công hơn.

## 1.2. Những gì phải hoàn thiện trước khi gọi là “đã sẵn sàng phát hành”

- Tất cả hero/tinh linh/set/stage/Boss trong **Launch Content Matrix đã duyệt** đều có **asset thật, gameplay thật, UI thật, source/reward thật**; không icon trống hay nút “coming soon” đặt như tính năng đã hoạt động.
- Có **onboarding cho roster lớn**: người chơi nhìn thấy nhiều hero và con đường sở hữu, chứ không phải chỉ thấy bốn người.
- Vòng lặp farm/AFK/upgrade, summon, collections, daily/weekly hoàn chỉnh; không có content chỉ đẹp trên ảnh.
- Rewarded ads/IAP **không được giả lập**; nếu một phương thức tiền thật chưa đạt điều kiện store/security, không được tự tuyên bố live.
- Bảo toàn UID, pending runs, transaction, save/migration; cần phương án chuyển đổi cho content cũ.
- Android thực đã QA trên nhóm thiết bị mục tiêu; kiểm tra crash, startup, FPS, mạng yếu, offline/resume, dữ liệu lớn, asset RAM và đúng kích thước màn hình.
- Có khả năng cập nhật và sửa lỗi sau phát hành; “hoàn chỉnh” không có nghĩa ngừng cải tiến.

## 1.3. Những việc không lựa chọn

- Không ra mắt công khai bằng **4 hero và 2 tinh linh** rồi chờ retention mới sản xuất roster đầy đủ.
- Không vận hành **soft launch/closed beta công khai nhằm quyết định có làm thêm hero hay không**.
- Không coi 10–15 phút gameplay thiếu nội dung là “bản thương mại thử”.
- Không lấy D1/D7 làm **điều kiện cấp phép sáng tác art hoặc tăng số hero**.
- Không phát hành sớm chỉ để kiếm tiền nếu game thiếu nội dung hoặc payment/ad reward thiếu xác thực.
- Không đánh đổi chất lượng hình ảnh/hoạt ảnh của dàn nhân vật để khoe số lượng.

**QA nội bộ, unit tests, review art, test giao dịch và device tests vẫn bắt buộc.** Chúng là quy trình làm game hoàn chỉnh, không phải phương án phát hành thử.

# 2. Cơ sở tham khảo bên ngoài (tính đến 2026-11-08)

- **Sensor Tower, State of Gaming 2026 (công bố 26/02/2026):** báo cáo IAP game mobile khoảng **82 tỷ USD trong năm 2025**; thị trường trưởng thành, cạnh tranh về retention và monetization. **Đây là doanh thu IAP ngành, KHÔNG gồm toàn bộ doanh thu quảng cáo**: https://sensortower.com/press/press-release-sensor-tower-state-of-gaming-gaming-drove-52-billion-downloads-82b-iap-revenue-on-mobile-and-12b-premium-revenue-on-steam
- **GameAnalytics Benchmarks Hub** (cohort công bố September 2026, D30 lấy August 2026, đối tượng game có tối thiểu 3.000 MAU trong bảng được nêu): **P50 D1 20,78% / D7 3,80% / D30 0,87%; P75 tương ứng 28,32% / 6,90% / 2,00%.** Đây là **tham chiếu game mobile nhiều thể loại, không phải benchmark RPG Mỹ riêng**: https://www.gameanalytics.com/benchmarks
- **GameAnalytics 2026 Mobile & PC Gaming Benchmarks** mô tả retention có độ phân tán lớn, session ngắn và tính chất thói quen hằng ngày: https://www.gameanalytics.com/cn/reports/2026-mobile-pc-gaming-benchmarks
- **Google AdMob policy về rewarded ads**: phải công bố hành động/phần thưởng rõ, người chơi chủ động opt-in (trừ định dạng rewarded interstitial theo điều kiện riêng), không cản sử dụng bình thường nếu bỏ qua, cấp đúng thưởng: https://support.google.com/admob/answer/7313578?hl=en
- **Google Play Payments policy**: mua nội dung số theo cơ chế Google Play Billing khi áp dụng; vật phẩm ngẫu nhiên có thể mua cần công bố xác suất trước/gần giao dịch: https://support.google.com/googleplay/android-developer/answer/9858738?hl=en
- **Play Billing integration**: xác minh, chỉ cấp quyền lợi khi giao dịch hoàn tất, acknowledge/consume theo vòng đời giao dịch: https://developer.android.com/google/play/billing/integrate
- **AdMob UMP Privacy**: xử lý trạng thái đồng ý, quyền riêng tư theo khu vực: https://developers.google.com/admob/android/privacy

**Không dùng các con số eCPM, CPI, tỷ lệ chuyển đổi mua hàng phía dưới như số liệu thị trường đã xác minh.** Chúng là giả định mô hình để quyết định có nên thử nghiệm hay không.

# 3. Product Market Fit — Người chơi, lời hứa và đối thủ cạnh tranh

## 3.1. Audience giả định

**Đầu tiên:** người trưởng thành tại Mỹ thích anime fantasy, xây đội nhỏ, giải trí 5–15 phút/lượt, chơi không cần tay nhanh, muốn tích lũy tiến bộ khi bận.

**Hai phân khúc có thể cùng tồn tại:**
- **Collector/optimizer:** thích sở hữu nhiều hero, tối ưu đội và bộ trang bị; dễ trở thành người mua skin/tiện ích nếu game đủ chiều sâu.
- **Relaxed idle player:** chơi ngắn, thích nhận thưởng, tăng lực chiến, thấy hiệu quả nâng cấp; có thể xem rewarded ads nhưng hiếm khi mua.

**Không giả định:** mọi người chơi Mỹ sẽ trả tiền, tuổi 18–35 là nhóm duy nhất, hoặc đồ họa đẹp tự tạo được retention. Cần xem analytics, khảo sát và đánh giá từ người chơi thật.

## 3.2. Lời hứa cho người chơi (player-facing)

**“Build a party of heroes and spirits, collect powerful gear, and conquer fantasy realms — even when you're away.”**

Bốn cảm giác phải có: **sở hữu → tiến bộ → lựa chọn chiến thuật → chiến thắng**.

Trong 30–60 giây đầu, người chơi phải thấy: nhân vật có cá tính, trận đánh dễ hiểu, phần thưởng thật và một lựa chọn nâng cấp có tác dụng nhìn thấy được.

## 3.3. Định vị cạnh tranh của bản đầy đủ

**Điểm bán hàng khi ra mắt:** **một dàn nhân vật anime đẹp ngay từ ngày đầu**, cả nam lẫn nữ, đủ chiều sâu build đội; phép thuật và chuyển động 2D sắc nét; hệ thống tinh linh, trang bị nhiều set, Boss đẹp và một hành trình có độ dài thực.

Không nhấn mạnh “chúng tôi mới có vài nhân vật nhưng sẽ thêm dần” trong store listing. Truyền thông phải cho thấy **nội dung có sẵn thật ở bản ra mắt**, không trailer dựng có hero chưa thể sở hữu.

**Rủi ro cần quản trị:** khối lượng 24–30 hero sẽ lớn. Giải bằng art bible, shared production pipeline, asset reuse hợp lý ở kỹ thuật (không recolor thành nhân vật giả), animation kit, lịch nội bộ và quality gate — không giải bằng việc phát hành sớm ít hero.

# 4. Hiện trạng thật của project vs những thứ chưa có

Nguồn đối chiếu: docs/GAME_STATE.md (0.37.0; Godot 4.6.3; save v12) ở thời điểm viết plan. Phải kiểm HEAD khi Code tiếp tục.

| Hệ thống | Hiện có thật | Kế hoạch / chưa có |
| --- | --- | --- |
| Auto Battle | 3 hero + 1 spirit, tối đa 4 kẻ địch, AUTO Ultimate | Cải thiện trải nghiệm đầu game, phân tích thất bại |
| Hero | Eira/Ryn/Mira/Lyra đang có; roster nhỏ | Roster cân bằng hơn, thêm nam/nữ khi có vai trò chiến đấu |
| Spirits | Lumi, Ash | Mở rộng hệ vai trò và tương tác khi retention đã ổn |
| Gear | 44 ID, 6 set, 4 slot, nhiều UID, nâng cấp/rank | Nguồn rơi rõ, filter hữu ích, build đa dạng |
| Journey | 5 main + 10 side stage | Mạch tiến trình có đủ mục tiêu dài hạn; không mở 100 ải vô nghĩa |
| Dungeons | 3 stage chơi thật; 12 preview | Ít nhất 1 hoạt động lặp theo ngày có phần thưởng rõ |
| AFK | Gold, cap 2 giờ theo model hiện tại | Test cap 2h so với 4–8h sau khi đo trải nghiệm |
| Summon | Banner thường bằng vàng/vé, pity và history | **Chưa** bán premium gacha, chưa tự mở banner Event/Premium |
| Supplies | 8 món thực, transactional | Nâng cấp economy; không thêm vật phẩm lặp công dụng |
| Monetization | UI VIP chỉ hiển thị, nút nạp khóa; chưa ads/IAP thật | SDK, store product, verifier, entitlement, privacy, reporting cần xây |
| Analytics | Chưa có đủ bằng chứng một pipeline sản phẩm đang đo các KPI đề xuất | Thiết kế privacy-safe telemetry/đánh giá thủ công trước scale |

**Tất cả thay đổi mới phải tôn trọng giao dịch atomic, UID, pending run, rollback, save migration và quy định không giả vờ cấp thưởng.**

# 5. Gameplay loop kiếm tiền được nhưng không gây ức chế

## 5.1. Core loop (3–6 phút)

1. **Claim:** Nhận phần thưởng AFK / thưởng nhiệm vụ.
2. **Improve:** Nâng cấp hero, trang bị hoặc tinh linh; thấy chỉ số hoặc kỹ năng thay đổi.
3. **Choose:** Chọn đội/element/set khác cho thử thách kế tiếp.
4. **Fight:** Auto Battle nhanh, trận nhỏ, thắng/thua có lý do.
5. **Reward:** Nhận chiến lợi phẩm và mục tiêu mới.
6. **Return:** Thấy rõ phần thưởng còn thiếu, hoạt động/ngày mới hoặc Boss tiếp theo.

**Không được** tạo bức tường tài nguyên giả rồi dùng quảng cáo và IAP làm “lối thoát duy nhất”.

## 5.2. Chu kỳ ba tầng

| Chu kỳ | Mục tiêu người chơi | Hệ thống |
| --- | --- | --- |
| **Trong lượt chơi** | Thắng trận tiếp theo, đổi gear, nâng một kỹ năng | Battle + gear + feedback |
| **Mỗi ngày** | AFK, 2–3 phó bản hữu ích, một quyết định nâng cấp | Dungeons + daily mission + optional ads |
| **Mỗi tuần** | Hoàn thành mốc sưu tầm, thử build mới, thắng Boss khó hơn | Milestone + boss variants + weekly goals |

Giai đoạn đầu **không tạo “daily chores” dài**: người chơi vẫn hoàn thành phần thưởng cơ bản trong 5–10 phút; chơi lâu hơn là lựa chọn.

## 5.3. 15 phút đầu của game đầy đủ

Một game có nhiều hero **vẫn phải dễ hiểu**. Trong 15 phút đầu nên có:

| Thời điểm thiết kế | Người chơi thấy gì | Quy tắc |
| --- | --- | --- |
| 0–1 phút | Một trận đánh ngắn với 3 hero được giới thiệu hấp dẫn | Không khóa vào 10 màn thoại |
| 1–3 phút | Nhận và nâng cấp item, thấy hiệu quả trực quan | Thưởng thật, không fake preview |
| 3–5 phút | Mở Collection với **toàn bộ roster launch**, xem art/skill/nguồn sở hữu | Cho thấy chiều sâu sưu tầm ngay |
| 5–10 phút | Một lựa chọn chiến thuật: đổi hero/gear/spirit, miễn phí có đủ lựa chọn | Không phụ thuộc may mắn hay tiền nạp |
| 10–15 phút | Boss nhỏ, một món gear có ý nghĩa, mục tiêu dài hạn và hoạt động hằng ngày | Không ép xem ad/mua gói |

**Đây là yêu cầu UX của game đầy đủ, không phải nội dung phát hành thử.** Người chơi không nhất thiết sở hữu tất cả hero ngay, nhưng phải thấy chúng thực sự tồn tại trong game và có đường mở khóa rõ. Sau ngày phát hành có thể dùng telemetry để tối ưu onboarding, không trì hoãn sản xuất hero.

# 6. Monetization A — Rewarded ads

## 6.1. Nguyên tắc

- **Only opt-in**: nút “Watch an ad to get X”, thấy rõ X, không có popup ép.
- **Không** có forced interstitial/banner đè lên combat tại MVP.
- Không khóa truyện, chiến đấu, khả năng thắng hoặc việc dùng hero cốt lõi sau quảng cáo.
- Không gợi ý rằng bỏ qua quảng cáo sẽ mất thưởng cơ bản; người chơi vẫn được nhận thưởng gốc.
- Quảng cáo không tải được / offline → không mất tiến trình hoặc phần thưởng thường.
- Không cho xem quảng cáo vô hạn để bơm kinh tế.
- Test dùng **test ad unit**; không cho team tự xem/click quảng cáo thật để “tăng doanh thu”.

## 6.2. Các vị trí rewarded ads ở **bản phát hành chính thức**

| Placement đề xuất | Offer | Reward nguyên tắc | Cap thiết kế ban đầu |
| --- | --- | --- | --- |
| **RV_AFK_BONUS** | Khi nhận/tổng kết AFK | Thưởng thêm vàng trên eligible base, không thêm rare drop | 1/ngày |
| **RV_DUNGEON_EXTRA** | Sau khi hoàn tất phó bản thật | Thêm lượng nhỏ nguyên liệu đúng phó bản, cố định và được lưu ledger | 2/ngày |
| **RV_BOSS_CHEST** | Sau Boss đủ điều kiện | Một rương thưởng **có bảng phần thưởng công khai**, không bắt buộc, tránh premium gacha trá hình | 1/ngày |
| **RV_DAILY_BOOST** | Từ trang nhiệm vụ | Một buff/tiện ích có hạn, không vượt sức mạnh paywall | 1/ngày |

**Mục tiêu thương mại:** 2–4 vị trí khi ra mắt nếu được triển khai và cân bằng đầy đủ, trần tổng **3–5 cơ hội/người/ngày** để không quảng cáo quá nhiều. **Không tự bật cả bốn** khi chưa có thiết kế transaction, UX và privacy. Giá trị thưởng, cap chính xác, time reset, chống đồng hồ giả phải được ghi trong spec trước code.

Trọng tâm vẫn là **tự nguyện và không làm mất phần thưởng cơ bản**. Revenue không được tối ưu bằng buộc xem quảng cáo.

## 6.3. Giao dịch thưởng phải an toàn

Trình tự yêu cầu: kiểm user đã chủ động chọn, ad thực sự khả dụng, xem xong và callback đủ điều kiện → tạo **reward event ID / source / cap snapshot** → validate + commit một lần → thông báo thành công. Callback trùng hoặc crash/reopen không phát thưởng hai lần.

- Người dùng đóng trước điều kiện hoàn thành: không thưởng ad; phần thưởng cơ bản đã giữ.
- Quảng cáo không tải: thông báo gọn và vẫn chơi được.
- Đủ điều kiện đã được callback xác nhận nhưng ghi save lỗi: phải giữ khả năng retry/đối soát, **không mất thưởng im lặng**.
- Nếu muốn phòng gian lận mạnh, xem xét **SSV AdMob** qua backend; local-only không thể bảo đảm chống giả mạo hoàn toàn.
- Quảng cáo trên máy thật khi phát hành phải đi qua SDK và tài khoản quảng cáo hợp lệ, không có chức năng “simulated rewarded success” trong bản production.

Nguồn: https://support.google.com/admob/answer/7313578?hl=en  
API rewarded: https://developers.google.com/admob/android/rewarded  
Test ads: https://developers.google.com/admob/android/test-ads  
SSV: https://developers.google.com/admob/android/ssv

# 7. Monetization B — IAP có giá trị thật, không mở rộng sớm

## 7.1. Bộ sản phẩm IAP mục tiêu cho **ngày phát hành**

**Giá chỉ là khung làm việc ở US để thảo luận với cửa hàng; không phải giá chốt hay sản phẩm đã cấu hình.** Khi phát hành, giá hiển thị từ chính Play storefront và giao dịch phải được xác minh.

| Loại SKU đề xuất | Giá US thử trong tài liệu | Nội dung xác định | Mục tiêu |
| --- | --- | --- | --- |
| **Starter Bundle** | $1.99 | 1 gói nguyên liệu/hero-shard **xác định**, không random | Tạo lần mua đầu dễ hiểu |
| **Hero Growth Pack** | $4.99 | Nguyên liệu tăng cấp, thức tỉnh có định lượng rõ | Tăng tốc hợp lý |
| **Spirit Growth Pack** | $4.99 | Nguyên liệu tinh linh rõ nguồn/số lượng | Người yêu spirit |
| **Cosmetic Outfit** | $4.99–$9.99 | Skin/portrait/frame xác định, không pay-to-win | Doanh thu từ nhân vật đẹp |
| **Gear Development Pack** | $4.99 | Nguyên liệu gear xác định, không bảo đảm set hiếm | Tiện ích |
| **Welcome Collection Bundle** | $9.99 | Bộ vật phẩm xác định hoặc quyền **chọn** một hero trong danh sách cụ thể | Thúc đẩy sưu tầm nhưng không khóa hero |
| **Monthly Value Pass** | Chỉ khi sản phẩm/ngày thưởng đã làm hoàn chỉnh | Mốc quyền lợi rõ, xử lý thời gian/restore/refund | Doanh thu định kỳ |
| **Premium Summon Offer** | Chỉ khi pool, odds và billing đã hợp lệ | Quyền mua lượt random với odds/pity/giới hạn công bố | Có thể tăng doanh thu gacha, **không bắt buộc** để đủ 6–8 SKU |

**Chọn 6–8 SKU THỰC trong Launch Content Matrix** và chỉ hiện các món đã có store product + entitlement + test. Nếu chưa đủ chuẩn, **chưa được tuyên bố game có store hoạt động** và nên hoàn thiện trước khi công bố release date. Không coi bảng giá là yêu cầu implement ngay.

**Revenue mix:** Ad + IAP có thể đều xuất hiện từ ngày phát hành; không cần đợi một soft-launch để “mở dần mới đáng làm”. Chính sách store, backend và các kiểm thử thanh toán vẫn bắt buộc.

## 7.2. Những điều không được dùng để tăng doanh thu

- Hero mạnh bắt buộc mua để qua ải chính hoặc chơi event thường.
- Paid random không công bố tỉ lệ/pity/nguồn rơi.
- Gói tiền thật giả lập bằng cách cộng trực tiếp local save.
- VIP cấp cao auto-buff PvE vô hạn làm người không nạp gần như không có tiến độ.
- Countdown sale giả, gói “giảm 95%” không có giá cơ sở thật, popup ép nạp sau mỗi lần thua.
- Nhầm business plan “full launch” với quyền bỏ quy trình xác minh purchase, refund, consent và dữ liệu người dùng.

**Paid gacha là một công cụ kinh doanh tùy chọn** trong game sưu tầm hero, không phải trục cốt lõi bắt buộc; nếu làm phải có thiết kế xác suất/phân phối, disclosure và kiểm toán để tránh gian lận và trải nghiệm tồi.

## 7.3. Công nghệ mua hàng và lỗi “offline-only”

Gameplay có thể offline nhưng **IAP không thể chỉ là nút cộng vật phẩm vào save local**. Cần:
1. Cấu hình sản phẩm thật trong Play Console;
2. Play Billing tương thích Godot/Android export và cấu hình cửa hàng;
3. Verify giao dịch, chỉ grant khi trạng thái **PURCHASED**, không grant khi PENDING/cancelled;
4. Idempotency qua purchase token/order, giao đúng 1 lần; acknowledge/consume;
5. Xử lý refund, revoked, restore, pending và chuyển thiết bị;
6. Có quyền lợi/entitlement phục hồi được; mô hình account/backend phù hợp.

**Khuyến nghị an toàn:** Backend tối thiểu để xác minh và lưu entitlement/redeemed purchase token; **không đặt API secret trong APK hoặc save**. Không có backend thì khả năng chống giả, phục hồi xuyên thiết bị và xử lý refund rất hạn chế; việc phát hành IAP bằng local-only cần được xem xét rủi ro riêng và không phải lựa chọn mặc định của kế hoạch này.

Tham khảo: https://developer.android.com/google/play/billing/integrate và https://developer.android.com/google/play/billing/backend

# 8. Economy — Nguồn vào, bể tiêu và cân bằng

## 8.1. Không mở quá nhiều loại tiền

**Bản đang có:** vàng; tinh thạch/đá rèn; mảnh kỹ năng; nguyên liệu tinh linh; vé triệu hồi; 44 mẫu gear; nhiệm vụ và AFK.

Không tự thêm 5 currency mới chỉ để tạo 5 màn cửa hàng. Nếu cần premium currency về sau, phải có lý do rõ, bảng giá quy đổi, refund policy và kiểm soát debt trước.

| Resource | Sources miễn phí | Sinks | Quy tắc kiếm tiền |
| --- | --- | --- | --- |
| **Gold** | AFK, thắng ải, nhiệm vụ | Nâng cấp, summon thường, shop | Không bán gói vàng phá hoàn toàn tiến độ |
| **Gear materials** | Phó bản/first clear | Enhance + rank/crafting | Quảng cáo chỉ cho lượng **nhỏ, cố định** |
| **Hero/spirit shards** | Thu thập/summon, tiến trình | Awaken/evolve | Không khóa nhân vật thiết yếu sau paid random |
| **Summon tickets** | Tiến trình/nhiệm vụ | Banner thường | Nếu đưa vào gói bán, kiểm chính sách odds |
| **Cosmetics** | Sự kiện, quà, shop | Trang phục/avatar | SKU IAP ưu tiên, không buff gameplay độc quyền |

**Cần một economy sheet trước khi code monetization**: xác định nguồn/giờ, sink/giờ, time to upgrade, phân phối chiến lợi phẩm, trần AFK, thời gian farm và người chơi trả tiền được nhanh hơn bao nhiêu.

## 8.2. Quy tắc cân bằng

- Phần thưởng quảng cáo **không nhân ngẫu nhiên đồ hiếm** và không tích lũy khi đã vượt giới hạn.
- Người miễn phí có thể thắng mọi stage nội dung chính qua tiến trình hợp lý.
- Có hero miễn phí chắc chắn trong onboarding; không ép người chơi mới phải “may mắn” mới có một đội hình hoạt động tốt.
- Duplicates của hero/tinh linh và UID gear phải giữ đúng nguyên lý save hiện hành.
- Balance theo **đội hình thực tế và nguyên nhân thua**, không phải số lực chiến UI.
- Trần AFK hiện 2 giờ có thể khiến casual player quá mệt nếu nghỉ 6–8 giờ; **thử nghiệm nâng cap sau khi đo** chứ không đổi chỉ để có “mua thêm giờ”.
- Nếu phần thưởng ad giúp hoàn thành nâng cấp nhanh quá nhiều → giảm value hoặc cap, **không nerf game miễn phí để ép xem**.
- Cùng một sản phẩm IAP phải có quyền lợi và mô tả rõ trong UI, không có chỉ số ẩn.

## 8.3. Kiểm soát gian lận liên quan offline

Game local save + đồng hồ máy có thể bị chỉnh; các khoản AFK, vật phẩm thưởng ad hoặc purchase có rủi ro. Không nên bán **một premium virtual currency có giá trị lớn** trước khi có ledger đáng tin.

Phân loại các quyền lợi:
- **Free/offline:** có thể lưu local, chấp nhận một mức hack trong game single-player.
- **Rewarded ad:** cần SDK callback hợp lệ, cap/transaction và có thể bổ sung SSV.
- **Real-money entitlement:** cần giao dịch từ store và xác minh đáng tin, không dùng lệnh UI tự quyết.
- **Online competitive (nếu sau này):** cần hạ tầng server authority mới, ngoài MVP.

# 9. Unit Economics — Đừng nhầm lượt xem với lợi nhuận

## 9.1. Chỉ số kinh doanh

- **DAU / MAU**: unique active users/ngày hoặc tháng.
- **Retention D1/D7/D30**: tỷ lệ người trong *cùng install cohort* quay lại vào ngày 1/7/30; chọn phương pháp calendar-day hay rolling-day và dùng nhất quán.
- **Ad opportunity → request → fill → impression → earned reward → grant**: đủ funnel, không đồng nhất lượt bấm và tiền.
- **Impression eCPM**: doanh thu quảng cáo trên 1.000 impression, biến động theo địa lý và nhu cầu quảng cáo.
- **Ad ARPDAU** = ad revenue/DAU; **IAP ARPDAU** = recognized IAP revenue/DAU; báo gross/net rõ.
- **Payer conversion** = số người mua ít nhất một lần / cohort phù hợp.
- **CPI** = chi phí paid installs / installs từ campaign; **CAC** phải có attribution và chi phí khác.
- **D7/D30/D90 cumulative net LTV**: revenue attributable to one cohort chia cho installs cohort, sau ad network/store fees, refund, chargeback khi dữ liệu có.
- **Contribution margin**: trừ chi phí biến đổi, không gọi revenue là profit.

## 9.2. Phép tính minh họa riêng cho quảng cáo — KHÔNG PHẢI DỰ BÁO

Giả định đúng **1.000 DAU ổn định**, không tuyên bố đã có 1.000 DAU. Công thức:

**Ad revenue/day = DAU × share of DAU watching × ads per watching user/day × impression fill × eCPM / 1.000.**

| Kịch bản giả định | Share xem | Ads/người xem/ngày | Fill | eCPM giả định | USD/ngày | USD/30 ngày |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Thấp | 20% | 1,5 | 80% | $3 | **$0,72** | **$21,60** |
| Cơ sở | 35% | 2 | 90% | $8 | **$5,04** | **$151,20** |
| Cao | 50% | 3 | 95% | $15 | **$21,38** | **$641,25** |

**Đây chỉ là bảng độ nhạy**, không dự đoán mức fill/eCPM ở Mỹ. Người dùng có thể không xem quảng cáo; một số ad có thể không fill, và thay đổi chính sách/địa lý có thể làm giảm doanh thu.

**Ví dụ IAP độc lập:** 100 giao dịch × $4,99 = **$499 gross**; sau đó cần trừ phần platform fee thực tế theo chương trình áp dụng, thuế/refund/chi phí khác. Không được lấy $499 làm lợi nhuận. Không cộng ví dụ này vào ads để suy ra LTV cohort, vì chưa cùng tập người chơi và thời gian.

## 9.3. Quy tắc chi marketing

Nếu CPI quảng cáo thử nghiệm là **$1,50/install**, cần **net LTV của chính paid cohort lớn hơn $1,50** *cộng phần chi phí phục vụ/marketing khác* mới có cơ hội hòa vốn. Mức $1,50 ở đây **chỉ là ví dụ tính toán**, không là CPI thị trường.

**Không được** mua 5.000–10.000 installs chỉ vì AdMob hiện một ngày doanh thu tốt. Đợi đủ dữ liệu retention, LTV, xác suất gian lận và ổn định kỹ thuật.

# 10. Tiêu chuẩn chất lượng bản hoàn chỉnh và KPI sau phát hành

## 10.1. Cổng phát hành = sản phẩm đầy đủ, không phải retention của bản ít nội dung

| Gate | Điều kiện bắt buộc khi ra mắt |
| --- | --- |
| **CONTENT_COMPLETE** | 100% các hero/tinh linh/gear/stage/Boss/dungeon trong **Launch Content Matrix đã duyệt** có mặt và chơi được |
| **ART_COMPLETE** | Portrait/skill/battle visual/âm thanh/UI đúng chuẩn, không ảnh placeholder, art nhất quán |
| **PROGRESSION_COMPLETE** | F2P có đường mở khóa rõ, không bẫy paywall; economy source/sink, loot/drop và nhiệm vụ có test |
| **MONETIZATION_COMPLETE** | Các placements/SKU đã công bố đều hoạt động thật; verification, idempotency, refund/restore, privacy |
| **QUALITY_COMPLETE** | Không có lỗi blocker/crash nghiêm trọng trên thiết bị Android mục tiêu; không mất save/đồ; FPS/RAM ổn |
| **STORE_READY** | Store listing phản ánh đúng nội dung live, chính sách/phân loại tuổi/privacy hợp lệ |

Không có điều kiện **“phải đạt D1/D7 trong soft launch rồi mới được thêm hero”**. Người làm art có thể xây roster trước khi có người dùng công khai.

## 10.2. Chỉ số doanh thu và giữ chân **đo sau ngày ra mắt**

| Chỉ số | Mục tiêu tham vọng để tối ưu sau khi release | Diễn giải |
| --- | --- | --- |
| D1 | 28–30%+ | Mục tiêu nội bộ, không bảo đảm; so với benchmark cùng cohort và kênh |
| D7 | 8–10%+ | Đánh giá vòng lặp ngày/tuần, không là điều kiện tạo hero |
| D30 | 3%+ | Chỉ tính sau khi cohort đủ 30 ngày |
| Crash-free users | ≥99% | Tiếp tục theo dõi sau QA |
| Reward integrity | 0 lỗi duplicate/missing trong kiểm thử | Điều kiện phát hành ads |
| IAP integrity | 0 lỗi grant từ pending/cancel/replay trong kiểm thử | Điều kiện nhận tiền thật |
| IAP payer conversion | Quan sát thực | Không giả định trước |
| Ad ARPDAU / net LTV / CPI | Quan sát thực theo cohort | Quyết định **chi marketing**, không quyết định có làm art hay không |

Retention benchmarks tại GameAnalytics là tham chiếu toàn ngành, không là lời bảo đảm thành công.

**Không mua traffic lớn khi LTV chưa rõ**, nhưng không vì vậy cắt giảm game để đem ra bán sớm. Marketing paid có thể bắt đầu có kiểm soát ngay sau phát hành đầy đủ; tăng ngân sách sau khi có dữ liệu.

# 11. Analytics event plan — đủ để ra quyết định

**Tối thiểu nên đo (đặt tên/taxonomy ổn định):**

| Nhóm | Sự kiện | Thuộc tính cần có |
| --- | --- | --- |
| Activation | first_open, session_start, tutorial_step, tutorial_complete | app_version, platform, acquisition cohort (nếu có), elapsed |
| Progression | stage_start, stage_end, stage_fail, boss_clear | stage_id, attempt, team size, outcome, duration, fail_reason |
| Collection | hero_unlocked, spirit_equipped, equipment_equip, upgrade_spent | source, resource, amount, rarity, old/new level |
| AFK | afk_claim, afk_cap_reached | eligible minutes, base reward, cap |
| Rewards/ads | ad_offer_viewed, ad_opt_in, ad_load_success/fail, ad_impression, ad_earned, reward_granted | placement_id, event_id, failure_code, reward_amount |
| Purchase | paywall_view, product_tap, billing_started, purchased_verified, entitlement_granted, refund/revoke | sku, store, price/currency from storefront, transaction hash/status |
| Economy | currency_earned, currency_spent | currency, amount, source/sink, balance bucket |
| Product health | crash, ANR, save_commit_failed, resume_failed | anonymized error code, version, device tier |

**Quy tắc quyền riêng tư:** chỉ thu tối thiểu để đo sản phẩm; không gửi tên người chơi, nội dung save, dữ liệu thanh toán hoặc ID bí mật vào analytics. Đưa privacy policy và Data Safety disclosure phù hợp. Có lựa chọn privacy khi luật/khu vực yêu cầu.

**Khởi đầu tiết kiệm:** Nếu chưa sẵn sàng tích hợp analytics SDK, có thể xuất các event test từ profile giả lập và công cụ QA để kiểm logic, nhưng **không được nhận đó là D1/D7 thật**. Cần một nguồn telemetry hợp lệ (privacy-aware) khi soft launch.

# 12. Lộ trình **sản xuất nội bộ → Full Launch → vận hành**

Không có **public soft launch**, không có “game ít hero để test thị trường”. Các **milestone dưới đây chỉ là các đợt làm việc nội bộ**, không phải các sản phẩm được phát hành sớm.

## Phase A — Chốt sản phẩm và Launch Content Matrix

- Chốt **số lượng hero/tinh linh/set/region/stage/dungeon/Boss**, vai trò, nguồn sở hữu, độ hiếm, sức mạnh, cảm giác gameplay.
- Chốt chuẩn mỹ thuật: nhân vật nam/nữ đa dạng, một art style thống nhất, bộ portrait, battle sprite, skill FX, pose, visual skin; mức độ hoàn thiện của mỗi hero.
- Chốt lịch làm asset cho cả roster, pipeline art/import và ngân sách thật (ngày công/art/sprites/audio/tests). Không bắt đầu 30 hero mà chưa có quy trình kiểm tra.
- Chốt Ad/IAP UX, sản phẩm có sẵn ngày ra mắt và yêu cầu backend/store.

**Output:** bộ kế hoạch chi tiết để sản xuất **đủ nội dung một lần release**.

## Phase B — Sản xuất dàn hero và mỹ thuật theo lô NỘI BỘ

- Làm hero theo lô nhỏ trong repo/branch nội bộ để kiểm soát chất lượng và độ nhất quán, nhưng **đích là toàn bộ roster đã duyệt trước launch**.
- Mỗi hero: character brief, concept turnaround, portrait, trận chiến, idle/attack/hit/ultimate, 2 kỹ năng/kit (tùy hệ thống), cân bằng, test, asset provenance.
- Mỗi tinh linh: concept, animation, hỗ trợ, cấp/phát triển, giao ước/nội dung mô tả ngắn, test.
- Mỗi set gear: 4 slot, icon/ảnh, hiệu ứng cụ thể, nơi rơi, tương tác với hero/tinh linh.
- QA art/animation giúp tránh phải vẽ lại hàng loạt; **không đưa build thiếu nhân vật cho người chơi cuối để quyết định có làm tiếp hay không**.

## Phase C — Sản xuất campaign, Boss và dungeon

- Sản xuất số vùng/ải/Boss trong Launch Content Matrix, có phân cấp độ khó, cơ chế quái và đồ rơi đủ đa dạng.
- Viết **lore ngắn** theo vùng/nhân vật/gear như công cụ sản xuất, không tốn nguồn lực vào saga dài nếu không giúp gameplay.
- Có mục tiêu ngắn mỗi trận, mục tiêu tháng/tuần, thu thập, gallery, nhật ký đơn giản.
- Kiểm thực logic reward, encounter, không phát từ preview và không giả chức năng.

## Phase D — Hoàn tất kinh tế và hệ thống kiếm tiền

- Balance cho roster lớn, có nguồn nhận free toàn bộ vai trò căn bản.
- Hoàn thiện rewarded ads, rewarded transaction ledger, caps, fail path, policy, test ad units.
- Hoàn thiện Play Billing, backend verify, entitlement/restore, pending/refund, store configs; định giá và sản phẩm IAP thật.
- Hoàn thiện onboarding, F2P progression, nhiệm vụ và UX tránh người mới bị ngợp bởi roster.

## Phase E — QA kỹ thuật **nội bộ** và release candidate đầy đủ

- Chạy test Godot, tests riêng combat/campaign/gear/summon/supplies/ads/billing, Android devices, stress data lớn, offline/online.
- Kiểm tra nội bộ từng màn và 7–30 ngày tiến trình **bằng tài khoản kiểm thử**; đây **không phải triển khai thử công khai** và không là gate giữ chân người chơi thật.
- Kiểm thử purchases bằng sandbox/test license trong cửa hàng; không chạy thanh toán thật hoặc tự xem ads để kiếm doanh thu.
- Dọn blocker, QA tất cả nội dung, đối chiếu đầy đủ Launch Content Matrix.

## Phase F — Một lần ra mắt chính thức

- Đăng sản phẩm **đầy đủ** trên Google Play theo thị trường đã chọn, hiển thị toàn bộ dàn hero/spirits/gear và hoạt động đã làm.
- Store images/trailer có nội dung thật; có privacy policy, support, feedback và crash monitoring.
- Có thể dùng quảng bá organic trước ra mắt, nhưng không đưa game thiếu nội dung ra thị trường như bản thương mại.

## Phase G — Vận hành và tối ưu hậu phát hành

- Đo retention, ad ARPDAU, IAP conversion, net LTV, review; sửa bug và cân bằng.
- Bổ sung hero mới, skin mới, Boss/season mới **để làm game phong phú hơn**, không dùng dữ liệu giữ chân làm điều kiện cho roster gốc.
- Tăng paid marketing chỉ khi hiệu quả thực cho phép, không hứa lợi nhuận.

**Một bản phát hành nội dung đầy đủ đòi hỏi chi phí/thời gian sản xuất cao hơn.** Hãy lập ngân sách và production pipeline khả thi, không giả định 24–30 hero đẹp là công việc nhỏ.

# 13. Roadmap giao Codex — Full Content Production (không tự thực thi)

| Ưu tiên | Ticket nên có | Điều kiện bàn giao |
| --- | --- | --- |
| **P0** | **Launch Content Matrix** | Roster mục tiêu, tỉ lệ nam/nữ, 10–12 tinh linh, 10–12 set, stage/Boss/region/dungeon với ID dự kiến, art/gameplay/status |
| **P0** | **Character Art & Battle Production Standard** | Nét vẽ chuẩn, đầu vào asset, số pose/animation, hướng dẫn không recolor, checklist kiểm định |
| **P0** | **Economic balance sheet cho roster đầy đủ** | Sources/sinks, free unlock, pity, gear drop, AFK, thời gian phát triển, cả trường hợp IAP |
| **P1** | Full hero roster implementation | Từng hero có nguồn sở hữu thật, kĩ năng, animation, portrait, progression, test |
| **P1** | Spirit roster và gear sets | Nguồn nhận, vai trò, tính năng, art, tests |
| **P1** | Campaign 60–100 encounters, dungeon và Boss | Gameplay thật, reward thật, progression, tests |
| **P1** | UI/UX Collection/Shop/Summon/Formation | Dễ điều hướng roster lớn trên 540×960, không lag, không giá/offer giả |
| **P2** | Rewarded Ads production architecture | SDK/consent, 2–4 placement thật, transaction idempotent, test |
| **P2** | Billing + backend verify + entitlement | SKU thật, refund/restore, security, compliance |
| **P2** | Android QA + performance | Memory/FPS/device coverage, save migration, inventory scale |
| **P3** | Store listing & release readiness | Localization English US, review checklist, marketing creative có thật |
| **P4** | Post-launch business analytics | KPI, LTV/CPI, revenue split; tối ưu sau phát hành |

**Không có ticket “thử game 4 hero trước rồi mới được sản xuất hero tiếp”**. QA và đo chất lượng ở mỗi chặng nội bộ vẫn cần thiết để bảo đảm bản phát hành cuối thật sự hoàn chỉnh.

**Thứ tự thực tế có thể chạy song song**: art roster, cân bằng combat, world art, ad/billing kỹ thuật. Tất cả phải tích hợp và kiểm định trước khi ra mắt.

# 14. Rủi ro cần giải quyết trước khi nhận tiền thật

| Rủi ro | Hậu quả | Cách quản lý |
| --- | --- | --- |
| Game offline, save dễ chỉnh | Lạm phát tài nguyên/giả entitlement | Backend tối thiểu cho purchase; tách economy local và paid |
| Đồng hồ AFK local | Farm vàng/điều chỉnh cap | Cap, audit, giao dịch idempotent; không bán currency dễ hack |
| Roster đầu quá ít | Người chơi bỏ vì ít lựa chọn chiến thuật | Mở 1–2 lựa chọn miễn phí chất lượng trước khi đầu tư banner |
| Truyện quá dài | Bỏ tutorial trước trận đầu | Cảnh ngắn, skip và archive |
| Ads quá nhiều | Giảm D1/D7 và review | Rewarded only, cap nhỏ, tắt qua feature flag |
| IAP không xác minh | Fraud, refund, mất quyền lợi | Store verification + entitlement ledger |
| Monetization trước retention | Kiếm ít tiền rồi mất user | Gate retention trước scale |
| Số lượng art tăng | Quá tải sản xuất, không kịp cập nhật | Batch nhỏ có theme/gameplay rõ |
| Quyền riêng tư / target tuổi | Bị từ chối/phạt/ảnh hưởng ad fill | UMP/privacy/data safety và phân loại audience đúng |
| Store/platform thay đổi chính sách | Build bị từ chối hoặc không chi trả | Review policy hiện hành trước launch |

# 15. Chính sách và phát hành: checklist chặn ra mắt

- **Rewarded ads:** minh bạch phần thưởng, chủ động xem, có cách bỏ qua; không cản gameplay bình thường. AdMob rewarded policy: https://support.google.com/admob/answer/7313578?hl=en
- **Ads UX:** không chèn quảng cáo toàn màn hình bất ngờ giữa hành động hoặc đầu màn chơi. Google Play Ads policy: https://support.google.com/googleplay/android-developer/answer/9857753?hl=en
- **Google Play Billing:** dùng cơ chế phù hợp cho digital goods, đối chiếu quy định ngoại lệ theo thị trường, không tự tạo link thanh toán trái chính sách: https://support.google.com/googleplay/android-developer/answer/9858738?hl=en
- **Paid random rewards:** công bố odds gần giao dịch; nếu mở iOS, Apple cũng có quy định disclosure: https://developer.apple.com/app-store/review/guidelines/
- **Purchase lifecycle:** chỉ grant PURCHASED, xử lý PENDING, acknowledge/consume, refund: https://developer.android.com/google/play/billing/integrate
- **Privacy:** khai báo Data Safety, privacy policy, chọn đối tượng người chơi; UMP/consent khi cần và quyền chọn lại consent: https://developers.google.com/admob/android/privacy ; quy định bang Mỹ: https://developers.google.com/admob/android/privacy/us-states
- **Ad QA:** chỉ dùng test ads trong development: https://developers.google.com/admob/android/test-ads
- **Platform fees/tax:** dùng mức phí hiện áp dụng cho tài khoản/store/program và báo cáo tài chính thật; **không mặc định 15% hoặc 30% cho tất cả giao dịch**.
- **Không khuyến khích trẻ vị thành niên nạp/gacha:** đối tượng thiết kế dự kiến trưởng thành; nội dung và cài đặt age targeting phải khai báo đúng thực tế, không gắn nhãn “18+” giả.

# 16. Những quyết định quản trị bản Full Launch

| ID | Đề xuất cho lần chốt sau | Trạng thái |
| --- | --- | --- |
| **FL-01** | **Chỉ phát hành game đầy đủ, không public soft launch/roster nhỏ** | **ĐÃ ĐƯỢC CHỦ DỰ ÁN CHỈ ĐỊNH** |
| **FL-02** | Target launch: 24–30 hero, nam/nữ cân đối | Đề xuất để lập roster và ngân sách |
| **FL-03** | Target launch: 10–12 tinh linh, 10–12 bộ gear | Đề xuất |
| **FL-04** | Target launch: 6–8 vùng, 60–100 encounter, 8–12 Boss | Đề xuất |
| **FL-05** | 6–8 SKU và 2–4 ad placement thực, đều live ngày phát hành | Đề xuất, cần bảo mật/compliance |
| **FL-06** | Lore ngắn, hướng dẫn tạo nhân vật/gear/world thay vì saga dài | Hướng sản phẩm đã chỉ định |
| **FL-07** | QA/test nội bộ đầy đủ nhưng không phát hành bản ít nội dung ra người dùng | Đã chỉ định về phạm vi public launch; QA là yêu cầu kỹ thuật |
| **FL-08** | Giá, SKU, banner premium, tỷ lệ quay và ad cap cụ thể | Cần duyệt riêng |
| **FL-09** | Ngân sách/nhân lực/lịch tạo đủ assets và QA | Cần lập |
| **FL-10** | Bảo toàn save và lộ trình nâng cấp nội dung cũ | Cần duyệt kỹ thuật |

**Quyết định mới thay thế mọi câu trong V0.1 từng yêu cầu "đạt retention rồi mới làm đủ hero" hoặc "chỉ mở 2 SKU sau soft launch".**

# 17. Hành động kế tiếp có giá trị nhất

**Không mở một đợt thử nghiệm công khai ít nhân vật. Bắt đầu bằng sản xuất có kế hoạch cho bản phát hành hoàn chỉnh:**

1. Viết **LAUNCH_CONTENT_MATRIX.md**: tên/giới tính/role/nguyên tố/vũ khí cho 24–30 hero, tinh linh, gear, vùng, Boss, phó bản; trạng thái artwork/logic/test; số lượng/quality gate được chủ dự án duyệt.
2. Viết **CHARACTER_PRODUCTION_PIPELINE.md**: tiêu chuẩn mỹ thuật của từng hero, portrait/battle sprite, animation, biến thể skin, chất lượng hình ảnh, ngân sách asset và quy tắc kiểm định.
3. Viết **LAUNCH_GAME_DESIGN.md**: vòng lặp, hệ build, độ khó, triệu hồi, tiến trình, UI Collection, AFK và phần thưởng; tính toán đầy đủ cho lượng nội dung dự kiến.
4. Viết **MONETIZATION_IMPLEMENTATION_SPEC.md**: SKU thật, quảng cáo thưởng thật, Play Billing, SDK, entitlement backend, privacy, đơn giá, kiểm thử.
5. Sản xuất và tích hợp nội dung **theo lô NỘI BỘ**; chạy suite/test; chỉ công bố chính thức khi nội dung đã duyệt hoàn chỉnh.

**Nguyên tắc cuối:** *Launch with a world worth collecting. Monetize a polished game without compromising trust.*  
*Ra mắt một thế giới đáng để sưu tầm và kiếm tiền từ một trò chơi hoàn thiện, không đánh đổi lòng tin.*

