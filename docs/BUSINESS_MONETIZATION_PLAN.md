# Aternal Senia — Game Business & Monetization Plan

> **BUSINESS DESIGN V0.1 · 2026-11-08 · ĐỀ XUẤT / CHƯA TRIỂN KHAI**
>
> **Mục tiêu:** Xây dựng một game di động có khả năng giữ chân và tạo doanh thu bền vững từ **rewarded ads tự nguyện** và **in-app purchases (IAP)**. Cốt truyện, nhân vật, tinh linh và trang bị được thiết kế để phục vụ **vòng lặp chơi, sưu tầm và phát triển đội hình**, không phải mục đích tự thân.
>
> **Trọng tâm đầu tiên:** Android, thị trường Hoa Kỳ, người chơi trưởng thành yêu thích anime/fantasy và game auto/idle. Mở rộng iOS, quốc gia và phân khúc khác **chỉ sau kiểm chứng**. Không khẳng định kế hoạch này bảo đảm lợi nhuận.
>
> **QUAN TRỌNG CHO CODEX:** File này là **kế hoạch sản phẩm/kinh doanh**, không phải lệnh tự triển khai SDK, quảng cáo, thanh toán, gói nạp hoặc sửa cân bằng. Mọi giá bán, phần thưởng, giới hạn quảng cáo, KPI và mốc thời gian đều là **giả thuyết thử nghiệm**, phải được duyệt qua task riêng, có test và đo thực tế. Không tự cấp tiền/vật phẩm hoặc tạo màn mua hàng giả.
>
> **Không dùng lại** các Story Bible về *The World That Forgot Tomorrow* đã bị hủy. **Không ép câu chuyện mới theo các bản thảo đó.** Thông tin tình trạng game phải đối chiếu [GAME_STATE](GAME_STATE.md), [SYSTEMS](SYSTEMS.md) và code HEAD.

---

# 1. Quyết định chiến lược (Executive decision)

**Thể loại sản phẩm đề xuất:** **Hybrid Idle Fantasy RPG / Hero Collection Auto Battler** — game F2P thu thập hero, xây đội hình, nâng cấp trang bị/tinh linh, vượt ải, săn Boss, nhận AFK.

**Hai nguồn thu ưu tiên:**
1. **Rewarded ads**: giúp người chơi miễn phí tiến nhanh hơn chút ít, ở đúng ngữ cảnh nhận thưởng, không gián đoạn trận.
2. **IAP trực tiếp, minh bạch**: gói tân thủ có món **xác định**, skin/trang phục, gói tiện ích không áp đặt; các sản phẩm ngẫu nhiên/gacha trả tiền là dự án về sau, không phải MVP.

**Không làm ngay:** MMO, PvP real-time, guild/server xã hội, subscription phức tạp, VIP pay-to-win, premium gacha banner, 50 hero, 100 dungeon, 500 tầng tháp, Battle Pass khi chưa chứng minh giữ chân được người chơi.

**Quan điểm thiết kế:** Trải nghiệm miễn phí phải vui và có thể hoàn thành nội dung cốt lõi; mua hàng giúp hỗ trợ nhà phát triển, tăng tiện nghi, đa dạng hóa ngoại hình và có thể tăng tốc hợp lý — **không biến thành yêu cầu bắt buộc**.

**North Star kinh doanh:** **Giá trị người chơi tạo ra trong vòng đời (contribution LTV, sau phí liên quan) > chi phí thu hút người chơi (CAC) + chi phí phục vụ/phát triển**, trên **cùng cohort**; đồng thời không làm xấu retention, trải nghiệm và đánh giá. Giai đoạn đầu chỉ đo và học, **không mua lưu lượng lớn khi LTV chưa được đo**.

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

## 3.3. Ưu thế cạnh tranh cần kiểm chứng

- 2D fantasy anime chất lượng hình ảnh nhất quán; portrait 540×960.
- Đội hình gọn **3 hero + 1 tinh linh**, không ép học đội hình 5–7 người ngay.
- Gear có slot/set/hiệu ứng; chiến thuật rõ hơn chỉ số lực chiến.
- Chơi cốt lõi được **offline**; tính năng quảng cáo, IAP và đồng bộ giao dịch cần mạng.
- Vòng chơi ngắn, thưởng thật, không giới thiệu bằng 20 phút truyện.

**Rủi ro cạnh tranh:** gacha/idle RPG là thể loại đông đối thủ và tốn art/nội dung; chúng ta không thắng bằng số lượng hero ngay. Phải thắng ở **trải nghiệm đầu game dễ hiểu, chất lượng UI, cảm giác nâng cấp và độ ổn định**.

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

## 5.3. 15 phút đầu tiên phải có gì?

| Thời điểm thiết kế | Trải nghiệm bắt buộc | Không làm |
| --- | --- | --- |
| 0–1 phút | Vào trận đầu, đánh/nhìn được skill, hoàn thành nhanh | Bắt đọc lore dài, màn hình IAP |
| 1–3 phút | Nhận vật phẩm thật, nâng cấp và cảm thấy hiệu quả | Đổ 8 hệ thống cùng lúc |
| 3–5 phút | Thử ghép đội/đổi gear (nếu đã có đủ) | Buộc quay gacha để thắng |
| 5–10 phút | Mở một đồng đội/khả năng mới có **nguồn chắc chắn** (cần thiết kế và tài khoản mới test) | Cảm giác roster nghèo kéo dài |
| 10–15 phút | Thử thách mini-Boss, nhận quà và được chỉ rõ mục tiêu lần quay lại | Chặn bằng quảng cáo bắt buộc |

**Giả thuyết sản phẩm:** Người chơi hiểu và thắng trận đầu trong < 90 giây; hoàn thành hướng dẫn chính trong < 5 phút; không thấy lời mời trả tiền trước khi nhận thấy gameplay vui. Phải kiểm bằng test người chơi thật.

# 6. Monetization A — Rewarded ads

## 6.1. Nguyên tắc

- **Only opt-in**: nút “Watch an ad to get X”, thấy rõ X, không có popup ép.
- **Không** có forced interstitial/banner đè lên combat tại MVP.
- Không khóa truyện, chiến đấu, khả năng thắng hoặc việc dùng hero cốt lõi sau quảng cáo.
- Không gợi ý rằng bỏ qua quảng cáo sẽ mất thưởng cơ bản; người chơi vẫn được nhận thưởng gốc.
- Quảng cáo không tải được / offline → không mất tiến trình hoặc phần thưởng thường.
- Không cho xem quảng cáo vô hạn để bơm kinh tế.
- Test dùng **test ad unit**; không cho team tự xem/click quảng cáo thật để “tăng doanh thu”.

## 6.2. Placements thử nghiệm đầu tiên — rất ít, có định lượng

| Placement ID đề xuất | Khi nào mời | Reward đề xuất ban đầu | Cap thử nghiệm | Vì sao |
| --- | --- | --- | --- | --- |
| **RV_AFK_BONUS** | Sau khi đã nhận/thấy quà AFK cơ bản | **+50% vàng** trên lượng AFK đủ điều kiện, sau khi được duyệt cụ thể | 1 lần / 24h | Dễ hiểu, không cho premium currency |
| **RV_DUNGEON_EXTRA** | Sau khi một phó bản có thưởng thật được settle | **+1 nguyên liệu xác định** của đúng phó bản; không nhân rare drop | 2 lần / ngày | Có giá trị nhưng kiểm được nguồn/sink |

**Max khởi đầu: 3 rewarded ad opportunities/người/ngày.** Không mặc định họ sẽ xem cả 3. Daily reset/thời gian/cap cần định nghĩa rõ khi thực hiện.

**Không bật ngay**: free summon by ad, revive trận khó, x2 rare gear loot, unlock VIP, watch-to-retry liên tục. Có thể A/B test placement thứ ba sau khi dữ liệu xác nhận.

**Lưu ý kinh tế:** Ad thưởng tính từ *reward được thiết kế*, không phải nhân trực tiếp toàn bộ mốc AFK cũ có thể bị gian lận chỉnh đồng hồ. Định nghĩa một mức đủ điều kiện, cap và cách lưu idempotent trước khi code.

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

## 7.1. Một lộ trình SKU nhỏ

**Giá dưới đây là GIẢ THUYẾT tại US storefront, chưa thiết lập sản phẩm, chưa xử lý thuế/chiết khấu, chưa xác nhận tỷ lệ chuyển đổi.**

| Giai đoạn | SKU/nhãn đề xuất | Giá thử | Người mua nhận được gì | Lý do / guardrail |
| --- | --- | --- | --- | --- |
| **P2, sau billing** | **Starter Pack (once)** | **$1.99** | Một số **nguyên liệu xác định** + skin/icon nhỏ, không có random | Kiểm thử lần mua đầu; chỉ claim đúng 1 lần sau xác minh |
| **P2, sau billing** | **Founder Cosmetic Pack** | **$4.99** | Trang phục/portrait/frame mỹ thuật xác định, không cộng sức mạnh độc quyền | Doanh thu sưu tầm; quyền lợi khôi phục được |
| **P3, khi retention có dữ liệu** | **Convenience Bundle** | **$4.99–$9.99** | Nguyên liệu xác định, giới hạn giá trị không phá balance | Kiểm soát chênh lệch free/paid |
| **P3 trở đi** | **Rewarded Skip / No Forced Ads** | **TBD** | Chỉ xem xét cơ chế nhận thưởng quảng cáo hợp lý không phải xem; giới hạn như free | Phải mô hình hóa cannibalization ads, an toàn entitlement và refund |
| **P4** | **Monthly/Season Pass** | **TBD** | Phần thưởng xác định theo thời gian nếu có enough content | Chưa làm nếu chưa có D30 và khả năng live-ops |

**MVP IAP khuyến nghị:** chỉ 2 SKU đầu; không bắt đầu bằng 5 mức giá tiền tệ và gacha premium.

## 7.2. Các SKU không phù hợp để làm ngay

- Hero siêu mạnh chỉ có thể mua, làm cốt truyện chính không thể thắng miễn phí.
- Gói “cơ hội nhận hero cực hiếm” trong khi pool/rate không được công khai.
- Quay hiếm có premium currency được bán nhưng chưa tích hợp receipt/khóa giao dịch.
- Quà claim trùng khi restore, reinstall hoặc chuyển máy.
- Sự kiện đếm ngược giả, “90% OFF” không có giá cơ sở thực, popup mua lặp lại khi thua.
- VIP battle stats vô hạn không có trần tạo chênh lệch quá mức.

**Quy tắc paid random items:** Nếu sau này bán trực tiếp hoặc gián tiếp khả năng nhận vật phẩm ngẫu nhiên, phải công bố tỉ lệ rõ trước/gần điểm giao dịch; đối chiếu **Google Play Payments** và Apple App Review khi mở iOS. RNG phải được kiểm tra, không suy diễn rates từ screenshot.

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

# 10. KPI và cổng quyết định theo giai đoạn (Go/No-Go)

GameAnalytics 2026 dữ liệu toàn ngành làm đường tham chiếu, **không phải tiêu chuẩn bắt buộc** cho một game RPG Android Mỹ.

| Chỉ số | Cổng nội bộ muốn thử nghiệm | Nếu thấp |
| --- | --- | --- |
| **First battle finished** | ≥ 85% người bắt đầu tutorial | Sửa onboarding/touch/độ khó |
| **Tutorial complete** | ≥ 70% installs có sự kiện khởi tạo hợp lệ | Rút hướng dẫn, sửa UI |
| **D1** | **≥ 28–30%** (mục tiêu tham vọng) | Chưa thêm IAP; sửa phút đầu và tiến trình |
| **D7** | **≥ 8–10%** (mục tiêu thử nghiệm) | Chưa scale UA; sửa hoạt động ngày/tuần |
| **D30** | **≥ 3%** (stretch, cohort đủ chín) | Đừng mở pass/subscription phức tạp |
| **Crash-free users** | ≥ 99% | Ưu tiên ổn định |
| **Reward integrity** | 0 lỗi phát thưởng trùng hoặc thiếu sau callback đủ điều kiện (trong kiểm thử) | Block launch ads |
| **IAP integrity** | 0 cấp quyền lợi từ cancelled/pending/duplicate/replayed token (trong kiểm thử) | Block live IAP |
| **Review / complaint** | Không tăng mạnh báo cáo spam, ad fatigue, mất progress | Rollback monetization placement |

**Mốc retention này là quyết định thiết kế nội bộ**, không phải mức trung bình của ngành. Cần phân tổ theo **Android / US / nguồn cài / version / new vs existing**, tránh trộn traffic giá rẻ quốc gia khác để kết luận game phù hợp với Mỹ.

**Kích thước mẫu:** Đừng xem 30–50 bạn bè là kiểm chứng thị trường. Giai đoạn đầu phỏng vấn ~15–30 người cho chất lượng; để kết luận retention cần **hàng trăm đến hàng nghìn installs** cùng phân khúc và chờ cohort đủ D7/D30. Cần báo confidence interval và nguồn cài; quy mô cụ thể do ngân sách quyết định.

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

# 12. Quy trình soft launch và tối ưu

## Phase 0 — Product sanity (ưu tiên tuyệt đối)

- Chơi kiểm tra Android thật, 30 phút đầu và 7 ngày tài khoản test.
- Test người chưa biết game: họ có hiểu đội hình, nâng cấp và AFK?
- Sửa đoạn nào khiến người chơi không biết bấm tiếp.
- Có ít nhất một mini-Boss, một đồng đội miễn phí chắc chắn, một build khác chiến thuật.
- Chưa cần quảng cáo thật, chưa cần bán gì.

**Gate:** đủ rõ ràng và ổn định để có thể giữ chân; nếu không, sửa core loop.

## Phase 1 — Limited closed beta + đo retention

- Android closed test với người thật, hướng Mỹ; store listing English US, ảnh/video và mô tả đúng chức năng.
- Thu cohort có nguồn rõ, báo D1/D7; D30 chỉ báo sau khi đủ 30 ngày.
- Kiểm cân bằng free progression, nguồn/sink tài nguyên, bug/crash.
- Không diễn giải tỷ lệ của một nhóm quá nhỏ là thành công.
- Có privacy/data handling phù hợp trước khi thu analytics.

**Gate:** activation/retention đạt mục tiêu nội bộ hoặc có dấu hiệu cải thiện đáng tin.

## Phase 2 — Rewarded Ads MVP

- Chỉ RV_AFK_BONUS và RV_DUNGEON_EXTRA.
- So sánh nhóm đã nhìn thấy offer với nhóm không nhìn thấy (random assignment phù hợp, không chọn người trả tiền riêng làm nhóm).
- Đo adoption, fill, ad ARPDAU, retention, khiếu nại, lỗi reward.
- Nếu người chơi thấy quảng cáo phiền, giảm/tắt placement. Không thêm interstitial ép xem chỉ để kéo doanh thu ngắn hạn.

**Gate:** có thu nhập incremental mà không phá trải nghiệm, reward không trùng/thất lạc.

## Phase 3 — Secure IAP mini-store

- Chỉ 2 SKU xác định sau khi thiết lập thật trên Google Play và purchase verification.
- Test pending, cancel, duplicate, refund, restore, reinstall, chuyển máy, full bag, mất mạng.
- Theo dõi conversion và **mua lại** trên cùng cohort; không suy luận gói giá cao luôn tốt hơn.
- Người không mua vẫn tiến triển được.

**Gate:** không có lỗi giao tiền/quyền lợi, có nhu cầu thật và không làm giảm retention.

## Phase 4 — Paid acquisition có kiểm soát

- ASO và video gameplay 10–30 giây (đúng footage/trải nghiệm thật), trailer hero/boss, creator content.
- Thử vài thông điệp: **collect heroes / auto battler / idle progress / fantasy boss**. Không quảng cáo một tính năng chưa có.
- So sánh CPI, retention và cohort net LTV; chỉ tăng ngân sách khi có bằng chứng.
- Không spam review, cày quảng cáo, quảng bá bằng click gian lận hoặc mua traffic kém chất lượng.

## Phase 5 — Live ops và nội dung theo số liệu

- Thêm hero/skin/boss/mini-world **khi** dữ liệu chứng minh có người chơi quay lại.
- Test monthly pass, cosmetic drops, collection goals, limited events **không tạo FOMO giả**.
- Đánh giá các phó bản preview/gear dựa theo hiệu quả và chi phí nội dung thật.
- iOS chỉ khi có bằng chứng khả năng hoàn vốn với chi phí port/bảo trì.

# 13. Lộ trình triển khai ưu tiên cho Codex (không phải lệnh code ngay)

| Ưu tiên | Ticket kế hoạch | Bàn giao tối thiểu |
| --- | --- | --- |
| **P0** | Onboarding & first-10-minute audit | Báo cáo luồng người mới, cảnh thiếu thông tin, kế hoạch sửa, không giả reward |
| **P0** | Instrumentation schema & privacy design | Event taxonomy, cohort definitions, consent/data safety checklist |
| **P0** | Economy balance audit | Sources/sinks, thời gian nâng cấp, AFK cap sensitivity, free progression |
| **P1** | Mobile playtest & UX fixes | Thử Android thật, fix combat/UI/save, crash report |
| **P1** | Starter content | Tối ưu 1 mini-Boss + 1 unlock chắc chắn + 1 chiến thuật build |
| **P2** | Rewarded ads architecture | Plugin integration feasibility, callback/SSV/cap, reward transaction tests |
| **P2** | Ad placements controlled experiment | Hai placement, on/off flags, dashboards |
| **P3** | Billing feasibility & secure entitlement | Play Console setup checklist, backend purchase verify, restore/refund |
| **P3** | Two fixed SKUs | Paywall UX, US price from store, receipt and inventory atomic grant |
| **P4** | Cohort revenue dashboard & ASO testing | D1/D7/D30, ARPDAU, LTV vs CPI, build release report |
| **P5** | Roster/art expansion | Chỉ thêm nhân vật/tinh linh/trang bị có gameplay/business case |

Trước mỗi ticket: đọc AGENTS, GAME_STATE, TESTING, các tài liệu subsystem; viết test, chạy suite liên quan, bảo toàn save. Không triển khai tất cả trong một PR.

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

# 16. Danh sách quyết định mở

| ID | Câu hỏi | Khuyến nghị mặc định | Trạng thái |
| --- | --- | --- | --- |
| **BM-01** | Chỉ Android US khi thử hay thêm thị trường khác? | Android US trước | PROPOSED |
| **BM-02** | Ưu tiên ads hay IAP? | Hybrid, rewarded ads trước, IAP có verification sau | PROPOSED |
| **BM-03** | Số rewarded ads/ngày | Thử cap 3/ngày, 2 vị trí | PROPOSED |
| **BM-04** | Thời điểm bật monetization | Sau khi core loop/retention có dấu hiệu tích cực | PROPOSED |
| **BM-05** | Giá starter/cosmetic | $1.99 / $4.99 làm test, không phải giá đã bán | PROPOSED |
| **BM-06** | Nâng cap AFK lên 4–8h? | Đo trước, không cố tình gây bất tiện | PROPOSED |
| **BM-07** | Có premium currency/gacha trả tiền ngay? | Không ở MVP | PROPOSED |
| **BM-08** | Backend minimal purchase verification | Nên có trước live IAP; cần quyết định chi phí/hạ tầng | PROPOSED |
| **BM-09** | D1/D7/D30 gate | 28–30% / 8–10% / 3% là mục tiêu nội bộ | PROPOSED |
| **BM-10** | Mở rộng roster/trang bị khi nào? | Sau khi core loop và retention được xác minh | PROPOSED |

# 17. Hành động đầu tiên có tỷ suất học hỏi cao nhất

**Không thêm lore hoặc hero ngay.** Tạo **Product Validation Sprint**:

1. Chơi một tài khoản từ đầu trong 15 phút và một chu kỳ 7 ngày; ghi điểm dừng, nguồn/sink và khi nào có cảm giác “mình mạnh hơn”.
2. Thiết kế onboarding có **đồng đội hoặc lựa chọn chiến thuật mở chắc chắn**, không yêu cầu quay may rủi.
3. Viết event taxonomy và kế hoạch privacy/analytics trước soft launch.
4. Test người chơi thực, đo D1/D7, sửa hệ thống cốt lõi.
5. Chỉ sau đó đặc tả hai rewarded placements và gói IAP đầu tiên theo số liệu.

**Nguyên tắc chốt:** *Make a game people want to return to. Then offer fair ways to support it.*  
*Tạo một trò chơi khiến người ta muốn quay lại; sau đó cung cấp những cách kiếm tiền công bằng.*
