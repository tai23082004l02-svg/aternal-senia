# Aternal Senia — Launch Content Matrix
## Full Content Launch · Art / Characters / Spirits / Gear / Regions / Bosses / Dungeons

> **CONTENT DESIGN DRAFT V0.1 · 2026-11-08 · PROPOSED — CHƯA ĐƯỢC DUYỆT VÀ CHƯA TRIỂN KHAI**
>
> **Đây là bộ nội dung hướng tới một lần phát hành chính thức hoàn chỉnh**, không phải bản soft launch có vài hero. **Chủ dự án sẽ xem bản này trước khi cho Codex triển khai**; đến lúc đó Codex chỉ nên đọc và đánh giá, **không tự sửa code, asset, shop, summon, data, save hoặc mở quảng cáo/IAP**.
>
> **Nguồn dữ liệu chi tiết có cấu trúc:** [CONTENT_REGISTRY_DRAFT.json](launch/CONTENT_REGISTRY_DRAFT.json). JSON này là **registry cho nhà thiết kế**, không phải game/data/catalog.json, không có số cân bằng cuối cùng và **cấm import thẳng vào runtime**.
>
> **Định hướng kinh doanh:** [BUSINESS_MONETIZATION_PLAN.md](BUSINESS_MONETIZATION_PLAN.md) V0.2. **Trạng thái hệ thống cũ:** [GAME_STATE.md](GAME_STATE.md); [CHARACTER_BIBLE.md](CHARACTER_BIBLE.md) là chân dung bốn nhân vật *đang có*.
>
> **Không sử dụng** đại truyện đã hủy *The World That Forgot Tomorrow*. Lore mới chỉ nhằm cung cấp bối cảnh tạo nhân vật, quái, tinh linh, di vật, các vùng và sự kiện để chơi; không đầu tư một saga dài khi chưa phục vụ nội dung gameplay.

## A. Mục tiêu rõ ràng

**Product pitch cho US audience:** “Collect a dazzling cast of heroes and spirits. Forge powerful sets, build your three-hero squad, and conquer seven fantasy realms in fast auto-battles.”

**Thẩm mỹ:** Fantasy anime 2D vẽ tay, nhân vật đẹp, gương mặt và hình thể người lớn rõ nét, trang phục đủ chi tiết, mỗi hero có silhouette dễ nhận ra; chân dung chất lượng cao, chiến đấu chibi vừa phải. Navy/teal/ivory/gold là ngôn ngữ thương hiệu, còn mỗi nhân vật có accent hue riêng để không chìm vào một bảng màu.

**Kế hoạch cấu trúc:** 
- 24 hero **12 nam, 12 nữ**, 6 Affinity × 4 hero, cả vai trò cận chiến, tanker, healer, caster, assassin, breaker và ranged.
- 12 tinh linh, **2 cho mỗi Affinity**, 1 spirit đi cùng 3 hero; có thể thu thập, nâng cấp và tạo combo.
- 12 set trang bị, **mỗi set có 4 slot (weapon / armor / boots / accessory) = 48 thiết kế món set**; thêm đồ không theo set nếu có nguồn công dụng rõ.
- 7 vùng fantasy có bản sắc, **12 encounter/vùng = 84 stage chính**, không cộng phó bản vào con số này.
- 12 Boss riêng biệt: **7 Boss kết vùng** + **5 Boss đặc biệt**.
- 8 dungeon/activities **thực sự chơi được**; một số boss/encounter lặp lại có biến thể, không biến preview stage0 thành “đã có”.
- 12 concept trang phục premium (phải là thiết kế trang phục mới, không chỉ recolor) và 12 palette variant có thể kiếm miễn phí.
- Ra mắt với reward ads và IAP đã kiểm chứng **nếu tất cả hạng mục thương mại đều đạt chuẩn store, an toàn giao dịch và quyền riêng tư**.

**Số lượng trên là đề xuất để owner duyệt thành phạm vi launch chính thức.** Mục đích không phải cắt bớt roster vì thiếu số liệu retention; điều chỉnh hợp lý chỉ dựa trên quyết định sản xuất/chất lượng/ngân sách của owner, không tự phát hành game nửa vời.

## B. Luật thiết kế gameplay và nội dung

- **Team:** tối đa 3 hero + 1 spirit; không khóa bắt buộc class hoặc role.
- **Affinity dự kiến:** Light, Fire, Water, Nature, Storm, Shadow. Đây là sáu định hướng nhân vật/biểu tượng, **không khẳng định sáu hệ đã được Godot hỗ trợ**. Trước code phải định nghĩa tương khắc/bonus/validation/UI và mapping từ các element hiện hữu.
- **Hero rarity:** cân nhắc giữ **5★ cơ bản cho toàn bộ hero** (theo cơ chế hiện tại), tách rarity/tiến hóa sao của spirit và năm bậc gear; quyết định thật trong Launch Game Design. Không đánh đồng sức mạnh với “nữ đẹp hơn/nam đẹp hơn” hoặc biến một giới tính thành vai trò cố định.
- **Vũ khí:** mỗi hero có visual weapon riêng; gear slot vẫn là weapon/armor/boots/accessory. Nếu thêm bow, dagger, chakram, firearm, gauntlet…, phải thiết kế weapon eligibility/animation/renderer rõ; không tự dùng một ID sword cũ với biểu tượng súng rồi coi là xong.
- **Kỹ năng bản thảo:** mỗi hero có 1 Active, 1 Ultimate và 1 Passive concept, kết hợp auto attack. **Không có scaling, cooldown, target selection, status stacking cuối cùng ở đây.** Codex phải chờ combat/ability spec.
- **Đội hình người mới:** hero được mở khóa chắc chắn bằng tiến độ, không cần vận may để có đủ đội. Hero chưa sở hữu phải có cách nhận rõ ràng; người chơi có thể ngắm dàn 24 hero trong Gallery ngay từ ngày đầu.
- **Premium:** trang phục khác art, không buff chiến đấu; gói IAP cụ thể minh bạch, không buộc mua để thắng mọi stage cốt lõi. Paid random chỉ khi đã có odds/pity/disclosure được duyệt.
- **Offline-first:** game/battle/PvE/gear chạy offline, nhưng AdMob, Play Billing, xác thực giao dịch, giá và refund cần mạng và giải pháp bảo mật phù hợp.

## C. Hệ thống tiếp cận đội hình (không phải phát tất cả hero miễn phí)

**8 hero có thể nhận chắc chắn qua tiến trình:** Eira (R1-01), Caelan (R1-03), Selene (R1-06), Ryn (R2-06), Mira (R3-06), Nara (R4-06), Zeph (R5-06), Aveline (R7-06). **16 hero khác** có thể có từ banner và/hoặc tích lũy mảnh, chọn nhân vật qua hoạt động miễn phí được cân bằng. Không có hero chiến đấu chỉ bán bằng tiền thật.

**6 spirit nhận chắc chắn:** Lumi, Ash, Nix, Moss, Piko, Umbra theo milestones trong registry. **6 spirit khác** qua bond quest, sưu tầm hoặc mảnh/tài nguyên tích lũy. Tinh linh không phải gacha-only nếu một vai trò thiết yếu cho người chơi không nạp.

**Đề xuất tutorial:** R1-01 cấp Eira (hoặc sở hữu mặc định), R1-03 Caelan, R1-06 Selene. Tất cả 24 hero có gallery/skills/nguồn nhận từ đầu; vẫn cần vài màn để học các vai trò, không cần tặng tất cả một lúc.

**Luật sở hữu/save:** Các mốc trên là **thiết kế mới** và có thể khác unlock của runtime 0.37; tuyệt đối không đổi reward/hero ID, tự grant lại hoặc làm mất sở hữu cũ khi chưa có migration đã duyệt.

---

# 1. HERO ROSTER — 24 NHÂN VẬT

**Bảng roster chính:** Hxx là mã **quy hoạch**, không phải ID save hoặc ID catalogue. Giới tính là cách nhân vật tự thể hiện trong roster art; tất cả được thiết kế là người trưởng thành trong phiên bản ra mắt để tránh nhầm lẫn về tạo hình.

| Mã | Hero | Giới | Vùng | Affinity | Vai trò | Vũ khí | Nguồn sở hữu |
| --- | --- | --- | --- | --- | --- | --- | --- |
| H01 | Eira | Nữ | R1 | Light | Duelist | Dawnveil sword | Chắc chắn R1-01 |
| H02 | Caelan | Nam | R1 | Light | Vanguard | Kite shield + longsword | Chắc chắn R1-03 |
| H03 | Selene | Nữ | R1 | Light | Healer | Bell staff | Chắc chắn R1-06 |
| H04 | Lucien | Nam | R1 | Light | Buffer | Rapier + mirror | Triệu hồi / mảnh |
| H05 | Ryn | Nữ | R2 | Fire | Bruiser | Phoenix spear | Chắc chắn R2-06 |
| H06 | Lyra | Nữ | R2 | Fire | Striker | Twilight spear | Triệu hồi / mảnh |
| H07 | Varik | Nam | R2 | Fire | Breaker | Forge hammer | Triệu hồi / mảnh |
| H08 | Seraphine | Nữ | R2 | Fire | Mage AoE | Fan of ember sigils | Triệu hồi / mảnh |
| H09 | Mira | Nữ | R3 | Water | Healer Control | Moon-tide staff | Chắc chắn R3-06 |
| H10 | Iona | Nữ | R3 | Water | Controller | Crystal chakram | Triệu hồi / mảnh |
| H11 | Eldrin | Nam | R3 | Water | Support | Flask crossbow | Triệu hồi / mảnh |
| H12 | Kieran | Nam | R7 | Water | Ranged DPS | Runic hand-cannon | Triệu hồi / mảnh |
| H13 | Nara | Nữ | R4 | Nature | Ranged DPS | Antler longbow | Chắc chắn R4-06 |
| H14 | Fenric | Nam | R4 | Nature | Summoner | Beast whistle + shortbow | Triệu hồi / mảnh |
| H15 | Halden | Nam | R4 | Nature | Tank | Livingwood tower shield | Triệu hồi / mảnh |
| H16 | Orla | Nữ | R6 | Nature | Bruiser | Stone fists | Triệu hồi / mảnh |
| H17 | Kaia | Nữ | R5 | Storm | Assassin | Twin crescent blades | Triệu hồi / mảnh |
| H18 | Zeph | Nam | R5 | Storm | Duelist | Wind saber | Chắc chắn R5-06 |
| H19 | Talos | Nam | R5 | Storm | Caster | Storm tuning forks | Triệu hồi / mảnh |
| H20 | Aveline | Nữ | R7 | Storm | Guardian | Winged halberd | Chắc chắn R7-06 |
| H21 | Vespera | Nữ | R6 | Shadow | Debuffer | Shadow lantern | Triệu hồi / mảnh |
| H22 | Rook | Nam | R6 | Shadow | Tank | Obsidian greatsword | Triệu hồi / mảnh |
| H23 | Orin | Nam | R6 | Shadow | Assassin | Twin daggers | Triệu hồi / mảnh |
| H24 | Dorian | Nam | R7 | Shadow | Controller | Chain scythe | Triệu hồi / mảnh |

## 1.1. Brief ngoại hình và bộ kỹ năng cho từng hero

**Phần kỹ năng là định hướng khác biệt gameplay, chưa phải công thức damage.** Mỗi hero khi sản xuất phải có portrait full/half-body, card collection, face icon, battle action pack, vũ khí cùng nhận diện và video/ảnh showcase nội bộ. Đội hình nam/nữ đều có vai trò chống chịu, DPS, hỗ trợ và pháp thuật.

| Mã · tên | Silhouette / art identity | Active concept | Ultimate concept | Passive concept |
| --- | --- | --- | --- | --- |
| H01 Eira | Silver bob, blue-violet eyes, ivory armor, midnight-violet cape | Lightstep Cut: mark front foe | First Light: sweeping burst + self ward | Marked target takes extra skill hit |
| H02 Caelan | Tall broad-shouldered knight, braided ash-blond hair, blue kite shield | Shield Line: protect weakest ally | Unbroken Dawn: team barrier + brief guard | Guard reduces damage to rear allies |
| H03 Selene | Copper curls, ivory choir mantle, floating brass bell ribbons | Healing Bell: restore lowest HP | Grace Chorus: group heal + cleanse one debuff | Healing stronger on low HP ally |
| H04 Lucien | Sleek dark hair, white officer coat, golden half-mask at hip | Mirror Feint: expose enemy | Radiant Accord: team crit window | Expose raises coordinated damage |
| H05 Ryn | Wine-red shoulder-length waves + small braid, phoenix hairpin, maroon cape, age 27 | Ember Guard: strike + self shield | Phoenix Spearfall: front AoE + burn | Resists damage after skill |
| H06 Lyra | High long brown-red ponytail, amber eyes, crimson cape, age 24 | Flare Thrust: fast repeat hit | Twilight Comet: execute low-HP enemy | Hits gain damage below target HP threshold |
| H07 Varik | Bald with flame-colored beard, iron apron armor, huge one-hand hammer | Armor Crack: reduce defense | Crucible Quake: stagger frontline | Deals bonus damage to shielded targets |
| H08 Seraphine | Tall dark-skinned mage, copper geometric braids, coal-black gown | Ash Circle: spreading burn | Red Meridian: ignite all active burns | Burn effects stack within cap |
| H09 Mira | Teal shoulder-bob, silver moon circlet, aquamarine eyes | Tidepulse: heal or strike | Mirror Sanctuary: heal + ward allies | Healing scales with supportive play |
| H10 Iona | Pale lilac side-braid, layered fisherman-blue cloak, orbiting ring | Frostglass: slow target | Frozen Reflection: freeze short window | Slow foes take enhanced support damage |
| H11 Eldrin | Silver-rim spectacles, flowing navy apron, catalyst flasks | Tide Reagent: reduce foe ATK | Alchemical Flood: cleanse + amplify heals | Uses potion synergy without consuming supplies |
| H12 Kieran | Seaworn coat, silver-blue prosthetic bracer, compact rune gun | Condensed Shot: pierce backline | Blue Comet: multiple aimed shots | Rewards focused targeting |
| H13 Nara | Warm brown skin, asymmetric green braids, leaf-etched bow | Rootshot: root one foe | Spring Volley: target marked enemies | Critical hits extend root briefly with cap |
| H14 Fenric | Rugged ranger, loose dark hair, fur-lined moss mantle | Wolf Call: brief companion hit | Wild Hunt: coordinated team attacks | Summons are timed effects, not extra permanent battle slots |
| H15 Halden | Older burly druid, white beard, bark armor | Barkguard: damage reduction | Great Canopy: group barrier + taunt-like protect | Counterattack after guarding |
| H16 Orla | Short stocky dark-skinned fighter, moss-stone gauntlets, olive cropped cape | Stonehook: pull focus | Heart of Bedrock: brief fortify + crush | Resists interrupts at low HP |
| H17 Kaia | Platinum high short pigtails, cobalt scarf, electric-blue twin blades | Static Dash: jump to backline | Storm Split: multi-hit burst | Consecutive hits build haste to cap |
| H18 Zeph | Long white ponytail, turquoise sleeveless coat, slim saber | Windstep: evade next hit chance | Skybreak: pierce exposed foe | Dodge gives short speed boost |
| H19 Talos | Tall bronze-skinned scholar, large ear-cuffs, blue rune coat | Resonant Spark: chain two foes | Thunder Choir: stun brief and chain damage | Chain prioritizes marked opponents |
| H20 Aveline | Tall golden-haired sky sentinel, white wing-shoulder mantle | Skyguard: intercept hit | Heaven's Circuit: team shield + haste | Shielded allies resist control briefly |
| H21 Vespera | Long black-violet hair, crescent eyepatch jewelry, layered purple robe | Veil Hex: weaken attack | Nightfall: mass weaken + blind-like miss chance | Debuffs have bounded uptime |
| H22 Rook | Broad male with raven feather collar, heavy charcoal armor | Dreadguard: redirect threat | Black Bastion: counter + shield | Shield scales with hits actually received |
| H23 Orin | Slender male with white undercut, violet hood, etched knives | Silent Cut: debuff isolated enemy | Eclipse Step: execute exposed foe | Backline damage bonus with cap |
| H24 Dorian | Older male with iron-grey curls, clockwork chains, indigo coat | Gravity Snare: slow multi-target | Eventide Lock: delay enemy skills | Control bosses via reduced effect duration |

## 1.2. Bốn hero cũ và ranh giới thiết kế lại

| ID runtime hiện có | Concept launch | Điều kiện không được làm sai |
| --- | --- | --- |
| eira | H01 Eira, Light Duelist | Giữ nhận diện hiện tại **cho đến khi owner duyệt redesign**: bob bạc, áo giáp ngà, cape tím-xanh, kiếm Dawnveil |
| ryn | H05 Ryn, Fire Bruiser | Giữ **tóc đỏ rượu ngang vai + bím nhỏ + kẹp phượng** và tuổi 27; không thay thành đuôi ngựa Lyra |
| lyra | H06 Lyra, Fire Striker | Giữ tóc nâu đỏ **đuôi ngựa cao dài**, tuổi 24; dù cùng Fire/Spear vẫn phải có skill và animation khác Ryn |
| mira | H09 Mira, Water Healer/Control | Giữ tóc teal gọn, vòng trán mặt trăng bạc, trang phục ngà/xanh; không thêm mũ pháp sư lớn |

Bốn design có thể **được thay đổi khi chủ dự án quyết định**, nhưng chưa có quyền tự overwrite asset/ID/rarity/owned progress; phải thông qua redesign brief và migration riêng.

## 1.3. Phân bố vai trò

- **Light (4):** Eira, Caelan, Selene, Lucien — tấn công đúng mục tiêu, bảo vệ, hồi phục, buff.
- **Fire (4):** Ryn, Lyra, Varik, Seraphine — bruiser, execute, phá giáp, thiêu đốt diện rộng.
- **Water (4):** Mira, Iona, Eldrin, Kieran — heal/control, giảm sức mạnh địch, bắn tầm xa.
- **Nature (4):** Nara, Fenric, Halden, Orla — cung thủ, triệu hồi tạm, chống chịu, cận chiến.
- **Storm (4):** Kaia, Zeph, Talos, Aveline — assassin, dodge, chain, đội hình haste.
- **Shadow (4):** Vespera, Rook, Orin, Dorian — weaken, tank, assassination, trì hoãn kỹ năng.

**Combo mẫu (sẽ cần combat balance):**
- Caelan + Seraphine + Mira + Ash: frontline bảo vệ + burn AoE + hồi phục.
- Halden + Nara + Kaia + Piko: root target, bảo vệ người đánh xa, tạo nhịp đánh nhanh.
- Rook + Iona + Lyra + Nocti: tank + slow + kết liễu + né đòn.
- Aveline + Kieran + Lucien + Lumi: shield/haste + bắn mục tiêu + crit buff + cứu nguy.

Đây là các **đội hình minh họa có thể sở hữu**, không phải party cốt truyện bắt buộc và chưa được kiểm thử cân bằng.

## 1.4. Nguyên tắc tránh hero “đẹp nhưng vô dụng”

- 24 hero không có bộ skill trùng nguyên xi, chỉ đổi tên và màu hiệu ứng.
- Hai hero cùng class phải khác ở **targeting, timing, synergy hoặc cơ chế chống Boss**.
- Mỗi hero cần 1 điểm yếu hoặc trade-off; không có nhân vật luôn tối ưu trong mọi đội hình.
- Mỗi hero cần một đoạn lore 2–4 câu và một collection quote, **không cần chương truyện cá nhân dài**.
- Cần thu âm/SFX hoặc tận dụng hiệu ứng chuẩn có license đúng; asset mới không làm thay đổi âm gốc khi chưa có ticket.

---

# 2. SPIRIT ROSTER — 12 TINH LINH

**1 spirit được trang bị vào đội tối đa 3 hero.** Một spirit hỗ trợ một quyết định build, không chỉ cộng ATK giống tất cả các con khác. Lumi/Ash là spirit runtime hiện có; tên và art khác đều là đề xuất mới.

| Mã | Tên | Affinity | Vai trò | Tạo hình | Hiệu ứng chiến đấu dự kiến | Nguồn |
| --- | --- | --- | --- | --- | --- | --- |
| S01 | Lumi | Light | Restoration | Small teal-gold winged fairy | Pulse heal plus low-HP shield | Chắc chắn R1-01 |
| S02 | Solis | Light | Barrier | Round sun-lantern moth with golden ring wings | Protect weakest ally at the start of a wave | Bond / mảnh |
| S03 | Ash | Fire | AoE Offense | Orange-gold miniature phoenix | Phoenix burst strikes multiple enemies | Chắc chắn R2-12 |
| S04 | Cindlet | Fire | Burn Support | Magma salamander with glowing crystalline frill | Apply burn plus burst on existing burn | Bond / mảnh |
| S05 | Nix | Water | Cleanse | Transparent blue seahorse-dragon with pearl belly | Remove one debuff and heal a little | Chắc chắn R3-12 |
| S06 | Glacia | Water | Slow | Six-point ice-star sprite with bell-feet | Brief slow and temporary frost barrier | Bond / mảnh |
| S07 | Moss | Nature | Regeneration | Leaf-eared miniature deer with root antlers | Regeneration over several seconds | Chắc chắn R4-12 |
| S08 | Bramble | Nature | Counter Guard | Round bark turtle with bright sprout shell | Grant counter shield on focused hero | Bond / mảnh |
| S09 | Piko | Storm | Haste | Electric-yellow feathered sparrow | Short team attack-speed buff | Chắc chắn R5-12 |
| S10 | Aeon | Storm | Energy | Floating twin-tuning crystal rings | Grant bounded SP on skill hit | Bond / mảnh |
| S11 | Umbra | Shadow | Debuff | Small purple two-tailed fox with a star eye | Weaken highest-ATK foe | Chắc chắn R6-12 |
| S12 | Nocti | Shadow | Evasion | Velvet-black moon bat with silver ears | Grant temporary evade to most threatened ally | Bond / mảnh |

**Asset minimum/spirit:** portrait/collection, 1 bộ sprite chiến đấu với idle/cast/hit, 1 VFX signature, icon kỹ năng và mô tả nguồn mở. Spirit mới không được biến thành sprite phượng lửa/tiên teal đổi màu đơn thuần. Các kỹ năng cleanse/haste/energy cần được định nghĩa theo model; spirit rarity SR/SSR/UR **chưa tự phân bổ** cho tinh linh mới.

**Sự khác biệt quan trọng:** Ash là phượng lửa (không phải nam cung thủ), Lumi là fairy healing; giữ nguyên nhận diện runtime khi chưa được owner duyệt redesign.

---

# 3. GEAR MATRIX — 12 SET, 48 MÓN THEO BỘ

**Mỗi set gồm đúng bốn slot**: Weapon, Armor, Boots, Accessory. Tên slot là chuẩn dự kiến; artwork không nhất thiết vẽ 4 bộ giáp toàn thân giống nhau. Mỗi set phải có **4 icon khác biệt + signature glow/theme + mô tả 2pc/4pc rõ + nguồn rơi có thể farm**.

**Cần lưu ý:** Hiện game có 6 bộ với ID dawn/ember/tide/grove/storm/moon. Các tên dưới đây **không phải lệnh rename**, cũng không chứng minh 48 gear mới đã có. Mọi mapping, UID, rank, rarity và đồ đang mặc cần kế hoạch chuyển đổi riêng.

| Set | Tên | Nơi | Bonus 2 món — concept | Bonus 4 món — concept | Nguồn |
| --- | --- | --- | --- | --- | --- |
| G01 | Dawn Oath | R1 | 2pc Max HP | 4pc Ultimate grants short self-and-neighbor barrier with cooldown | Campaign R1 + regional gear chest |
| G02 | Ember Pact | R2 | 2pc Attack | 4pc Apply a short burn on skill, capped stacks | Campaign R2 + forge dungeon |
| G03 | Tideweave | R3 | 2pc Healing output | 4pc First allied cleanse grants brief team defense buff | Campaign R3 + water dungeon |
| G04 | Thornwatch | R4 | 2pc Damage reduction | 4pc After taking several hits, counter once with cooldown | Campaign R4 + nature dungeon |
| G05 | Thunderstride | R5 | 2pc Attack speed | 4pc After ultimate, grant bounded haste to team | Campaign R5 + storm dungeon |
| G06 | Nightglass | R6 | 2pc Critical rate | 4pc Crit marks enemy for next ally damage with cooldown | Campaign R6 + shadow dungeon |
| G07 | Astral Ward | R7 | 2pc Shield strength | 4pc When ally near defeat, shield them once per battle | Campaign R7 + tower |
| G08 | Iron Resolve | D01 | 2pc Defense | 4pc Break enemy shield to gain short guard | Ironbound Titan in D01 |
| G09 | Phoenix Crest | D07 | 2pc Skill damage | 4pc First below-threshold HP grants short shield once per battle; no resurrection | Eclipse Serpent in D07 |
| G10 | Deep Current | D05 | 2pc SP regeneration | 4pc Skill hit returns SP with per-interval cap | Obsidian Basilisk in D05 |
| G11 | Rift Hunter | D07 | 2pc Single-target damage | 4pc Bonus boss damage after landing multiple unique hits; cap | Rift Devourer in D07 |
| G12 | Harmony Sigil | D08 | 2pc Support effect duration | 4pc Different hero affinities grant bounded team buff | Starfall Hydra in D08 |

## 3.1. Quy tắc kinh tế và art gear

- **48 set-item concept** = 12 × 4; cần thiết kế ít nhất **48 icon** và metadata rõ ràng, không mặc định mỗi món là một rarity mới.
- **Rarity 3–7** trong hệ gear hiện tại là cấp riêng. Cần phân bố rarity/pool/drop và cap riêng trước khi code; **không áp đặt** set hiếm luôn mạnh hơn mọi build khác.
- Dùng tính năng farm thật từ campaign hoặc dungeon. Không cho item có nguồn trên một phó bản chưa có gameplay.
- Skill cơ bản vẫn hoạt động với không mặc đủ set; set 4pc làm build khác đi nhưng không được bắt buộc cho story clear.
- Tránh hiệu ứng “revive” tùy tiện. **Phoenix Crest chỉ kích hoạt shield một lần**, không hồi sinh. Cần global cap/cooldown, thứ tự hiệu ứng, test double proc trước khi áp dụng.
- **Weapon types mới** (bow, chakram, hammer, gauntlet, cannon) cần contract eligibility/renderer/socket; 4 ô trang bị không tự giải quyết việc hiển thị đúng vũ khí.
- Không bán thẳng gear exclusive gây nghẽn tiến độ F2P. Mua nguyên liệu số lượng xác định có thể được cân nhắc sau economy spec.

## 3.2. Mapping sơ bộ với sáu set đã có, CHƯA DUYỆT

| Runtime set ID | Launch design phù hợp để thảo luận | Trạng thái |
| --- | --- | --- |
| dawn | G01 Dawn Oath | Candidate — kiểm bonus và migration |
| ember | G02 Ember Pact | Candidate — đổi mechanics phải giữ save |
| tide | G03 Tideweave | Candidate — kiểm các món đang thuộc set |
| grove | G04 Thornwatch | Candidate — kiểm artwork & effects |
| storm | G05 Thunderstride | Candidate — kiểm Attack Speed/cooldown |
| moon | G06 Nightglass | Candidate **khác biệt chủ đề**, chỉ dùng nếu owner duyệt; có thể giữ Moonstar làm set riêng thay một set khác |

**Không sửa set_id hoặc đẩy item sang set mới chỉ vì bảng candidate.** Đối với trang bị đã có người sở hữu, có thể chọn legacy mapping hoặc conversion với bản ghi bảo toàn tài sản.

---

# 4. SEVEN REGIONS — 7 VÙNG, 84 ENCOUNTER

**Lore nhẹ, đủ làm art và nhiệm vụ:** Một đoàn thám hiểm đi qua bảy vùng để thu thập bảy *Realm Seals*, mở cánh cổng tới Astral Spire, nơi bảo vệ kho báu và ngăn một hiểm họa đang lan ra. Đây là marketing/world premise **tạm thời**, không dùng nội dung các bản Story Bible đã hủy. Không đặt ra lịch sử 600 năm hoặc âm mưu cần đọc hàng trăm trang.

Công thức một region: phong cảnh riêng → nhóm quái riêng → chiến thuật riêng → gặp hero/spirit → một Boss đẹp → set gear/tài nguyên → vùng kế.

| Vùng | Tên | Mỹ thuật chủ đạo | Hook gameplay/lore | Nhóm quái concept | Boss | Set |
| --- | --- | --- | --- | --- | --- | --- |
| R1 | Dawnvale Frontier | Golden grasslands and moonlit watchtowers | Border guardians investigate a broken beacon | Lightward patrol; dusk moth; ancient sentry; shielded pilgrim | Dawn Colossus | Dawn Oath |
| R2 | Emberfall Citadel | Crimson volcanic forge-city and rail bridges | Two rival lancer companies must stop a runaway furnace | Ember jackal; furnace imp; ash guard; magma crawler | Furnace Monarch | Ember Pact |
| R3 | Glassmere Coast | Salt-blue harbors and crystalline mirror caverns | The tides reveal a sea gate to a lost vault | Tide crawler; mirror eel; coral knight; mist oracle | Mirror Leviathan | Tideweave |
| R4 | Thornwild Canopy | Giant roots, bioluminescent leaves and canopy villages | The wild forest resists hunters draining its springs | Briar hound; spore lizard; vine construct; moss bandit | Briar Matriarch | Thornwatch |
| R5 | Stormreach Peaks | Suspended bridges and thunder observatories | Broken wind relays threaten sky caravans | Gale harpy; stormling; cliff raider; lightning crab | Storm Roc | Thunderstride |
| R6 | Duskhaven Hollow | Black-violet ruins and moonstone catacombs | An order of collectors steals forbidden relics | Shade wisp; dusk knight; blind crawler; lantern phantom | Night Archivist | Nightglass |
| R7 | Astral Spire | Floating gold-white observatory city over a starry void | The seven seals open a sky citadel and final guardian trial | Astral drone; prism beast; sky acolyte; chain sentinel | Astral Warden | Astral Ward |

## 4.1. Stage plan — 84 sân đấu, không phải 84 bản sao

**Mỗi vùng có 12 encounter và 1 Boss chính ở màn 12**. Các màn 01–11 phải thay đổi tình huống thật: enemy targeting, bảo vệ mục tiêu, cơ chế môi trường, các nhóm địch kết hợp, elite, mini-boss, tài nguyên hoặc điều kiện thắng. Tên từng màn và beat đặc biệt ở dưới là **scenario brief**; chưa phải battle encounter config hay kịch bản thoại đầy đủ.

**Quy tắc stage:** 01 mở vùng; 02 skirmish; 03 hazard; 04 elite; 05 defense; 06 tiến trình/hero; 07 ambush; 08 mixed trait; 09 gate; 10 mini-boss; 11 pre-boss; 12 region boss. **Trong mỗi vùng phải có art và chiến thuật riêng**, không nhân 12 lần một boss với HP tăng tuyến tính.

### R1 — Dawnvale Frontier

| Stage ID | Tên | Loại | Thiết kế / tình huống riêng |
| --- | --- | --- | --- |
| R1-01 | Lantern Road | intro | Introduce patrol light shields |
| R1-02 | East Watch | skirmish | Guarded sentry in front row |
| R1-03 | Lightwell Crossing | hazard | Caelan joins; lightwell beams split targets |
| R1-04 | Bronze Sentries | elite | Defeat shield captain with break windows |
| R1-05 | Quiet Farmland | defense | Protect caravan through farmstead |
| R1-06 | Belfry Approach | recruit_or_milestone | Selene joins; healing bell tutorial |
| R1-07 | Broken Patrol | ambush | Dusk ambush targets backline |
| R1-08 | Sunstone Terrace | mixed | Alternating shielded enemies |
| R1-09 | Pilgrim Gate | gate | Unlock watchtower gate relay |
| R1-10 | Bellkeeper's Trial | mini_boss | Bellkeeper elite with timed ward |
| R1-11 | Golden Causeway | pre_boss | Resource planning before colossus |
| R1-12 | Dawn Colossus | regional_boss | Boss phases: shield and weakpoint |

### R2 — Emberfall Citadel

| Stage ID | Tên | Loại | Thiết kế / tình huống riêng |
| --- | --- | --- | --- |
| R2-01 | Coal Trail | intro | Ember imp packs cross burning trail |
| R2-02 | Forge Bazaar | skirmish | Disarm forge convoy |
| R2-03 | Ashrail Junction | hazard | Rail heat vents force target choice |
| R2-04 | Cinder Hounds | elite | Cinder guard with breakable plates |
| R2-05 | Magma Foundry | defense | Save smiths under fire |
| R2-06 | Lancer Outpost | recruit_or_milestone | Ryn joins; burn/shield tutorial |
| R2-07 | Flame Vent | ambush | Ash jackals attack the rear |
| R2-08 | Molten Lift | mixed | Burners paired with shield guards |
| R2-09 | Smokerail Crossing | gate | Molten gate opens after timed adds |
| R2-10 | Inferno Trial | mini_boss | Magma elite with overheating |
| R2-11 | Crown Furnace | pre_boss | Prepare frost/cleanse options |
| R2-12 | Furnace Monarch | regional_boss | Boss overheats and opens vulnerable core |

### R3 — Glassmere Coast

| Stage ID | Tên | Loại | Thiết kế / tình huống riêng |
| --- | --- | --- | --- |
| R3-01 | Blue Harbor | intro | Harbor ambush near tide |
| R3-02 | Moonlit Pier | skirmish | Coral shield line |
| R3-03 | Prism Tide | hazard | Prism tide copies one enemy |
| R3-04 | Reef Knights | elite | Reef knight elite needs focus |
| R3-05 | Sunken Stairs | defense | Protect lighthouse lens |
| R3-06 | Tide Observatory | recruit_or_milestone | Mira joins; tide/heal tutorial |
| R3-07 | Saltglass Cavern | ambush | Mirror eel targets healer |
| R3-08 | Hall of Echoes | mixed | Mist caster and coral knight combo |
| R3-09 | Pearl Current | gate | Pearl gate with reflection order |
| R3-10 | Reflection Trial | mini_boss | Tidal phantom mini-boss |
| R3-11 | Leviathan Gate | pre_boss | Set anti-decoy target order |
| R3-12 | Mirror Leviathan | regional_boss | Boss mirror decoys and cleanse timing |

### R4 — Thornwild Canopy

| Stage ID | Tên | Loại | Thiết kế / tình huống riêng |
| --- | --- | --- | --- |
| R4-01 | Moss Lantern | intro | Wandering briar beasts |
| R4-02 | Canopy Bridge | skirmish | Root snare under canopy |
| R4-03 | Hollow Burrow | hazard | Spore clouds force frontline cover |
| R4-04 | Spore Ring | elite | Vine knight regenerates |
| R4-05 | Spring Grove | defense | Protect sacred spring |
| R4-06 | Ranger Lodge | recruit_or_milestone | Nara joins; root/mark tutorial |
| R4-07 | Root Labyrinth | ambush | Bandit ambush atop bridges |
| R4-08 | Fungal Basin | mixed | Moss shield + toxic spore pack |
| R4-09 | Verdant Gate | gate | Unlock ancient root gate |
| R4-10 | Thorn Trial | mini_boss | Wildwood elite summons spores |
| R4-11 | Heartwood Stair | pre_boss | Preparation to counter vines |
| R4-12 | Briar Matriarch | regional_boss | Boss roots ground then summons bloom adds |

### R5 — Stormreach Peaks

| Stage ID | Tên | Loại | Thiết kế / tình huống riêng |
| --- | --- | --- | --- |
| R5-01 | Thunder Path | intro | Gale harpies from ridge |
| R5-02 | Sky Caravan | skirmish | Stormling chain damage |
| R5-03 | Static Pass | hazard | Static fog changes target priority |
| R5-04 | Gale Nest | elite | Cliff raider elite dodge window |
| R5-05 | Storm Bridge | defense | Protect sky caravan |
| R5-06 | Wind Shrine | recruit_or_milestone | Zeph joins; evasive duel tutorial |
| R5-07 | Cloudcut Ridge | ambush | Lightning dive from backline |
| R5-08 | Spark Furnace | mixed | Crab armor and harpy combo |
| R5-09 | Tempest Gate | gate | Tempest gate charges between waves |
| R5-10 | Thunder Trial | mini_boss | Storm champion interrupts casters |
| R5-11 | Roc's Ascent | pre_boss | Prepare speed and shield answers |
| R5-12 | Storm Roc | regional_boss | Boss charged dive with interrupt cue |

### R6 — Duskhaven Hollow

| Stage ID | Tên | Loại | Thiết kế / tình huống riêng |
| --- | --- | --- | --- |
| R6-01 | Black Lantern | intro | Lantern phantoms escort traveler |
| R6-02 | Moonfall Alley | skirmish | Shade patrol with blind attack |
| R6-03 | Silent Catacombs | hazard | Catacomb darkness reduces aim |
| R6-04 | Shade Citadel | elite | Obsidian sentinel elite |
| R6-05 | Obsidian Hall | defense | Defend refuge against thieves |
| R6-06 | Hollow Refuge | recruit_or_milestone | Relic/selector milestone without forced hero |
| R6-07 | Veil Market | ambush | Assassins ambush low-HP healer |
| R6-08 | Forgotten Chapel | mixed | Debuff caster plus armor knight |
| R6-09 | Nightglass Gate | gate | Open Nightglass seal under pressure |
| R6-10 | Dusk Trial | mini_boss | Archive sentinel tests cleanse |
| R6-11 | Archive Threshold | pre_boss | Stealth squad before main archive |
| R6-12 | Night Archivist | regional_boss | Boss summons corrupted pages, silence window |

### R7 — Astral Spire

| Stage ID | Tên | Loại | Thiết kế / tình huống riêng |
| --- | --- | --- | --- |
| R7-01 | Starward Dock | intro | Astral drones escort arrival |
| R7-02 | Cloud Beacon | skirmish | Floating bridges force positioning |
| R7-03 | Prism Hall | hazard | Prism hazards reveal mixed affinity |
| R7-04 | Aether Bridge | elite | Sky acolyte elite shield |
| R7-05 | Sevenfold Gallery | defense | Protect unstable seal conduit |
| R7-06 | Winged Bastion | recruit_or_milestone | Aveline joins; barrier/haste tutorial |
| R7-07 | Chain Corridor | ambush | Chain sentinels focus weak target |
| R7-08 | Astral Garden | mixed | Four-element combo tests synergies |
| R7-09 | Sky Seal | gate | Open seventh seal through combat |
| R7-10 | Celestial Trial | mini_boss | Celestial elite tests counters |
| R7-11 | Spire Heart | pre_boss | Rest and final build selection |
| R7-12 | Astral Warden | regional_boss | Final Boss 3 phases using region lessons |

**Các cột stage chỉ mô tả gameplay định hướng.** Trước khi lập trình 84 màn, phải có riêng enemy table (stats, phases, targeting, reward, first-clear, retry, unlock, drops, expected duration), cân bằng đường cong và test mỗi encounter. Không lấp 84 màn bằng 84 ảnh nền đẹp mà không có mechanic thật.

**Mốc nhận nhân vật chắc chắn:** R1-01 Eira, R1-03 Caelan, R1-06 Selene, R2-06 Ryn, R3-06 Mira, R4-06 Nara, R5-06 Zeph, R7-06 Aveline. **Milestone spirit** được ghi trong JSON; cần gameplay mapping để quy định có trả trực tiếp/qua quest/qua reward panel.

---

# 5. BOSS MATRIX — 12 TRẬN BOSS RIÊNG

**7 Boss campaign và 5 Boss đặc biệt**, không nói đây là 12 skin của cùng mô hình. Mỗi Boss cần silhouette, portrait, bộ animation/tấn công riêng, một telegraph đọc được trên màn hình nhỏ, cách khắc chế và thưởng định danh.

| Boss | Tên | Xuất hiện | Cơ chế chiến đấu nhận diện | Set rơi quan trọng |
| --- | --- | --- | --- | --- |
| B01 | Dawn Colossus | campaign:R1-12 | Layered protective shields and visible armor weakpoint | Dawn Oath |
| B02 | Furnace Monarch | campaign:R2-12 | Overheat telegraph and burn lanes | Ember Pact |
| B03 | Mirror Leviathan | campaign:R3-12 | Reflection decoys and cleansing windows | Tideweave |
| B04 | Briar Matriarch | campaign:R4-12 | Root trap and minion blooms | Thornwatch |
| B05 | Storm Roc | campaign:R5-12 | Charged dive telegraph and interruption window | Thunderstride |
| B06 | Night Archivist | campaign:R6-12 | Summon pages and temporary silence with clear counters | Nightglass |
| B07 | Astral Warden | campaign:R7-12 | Three phases mixing telegraphs learned across regions | Astral Ward |
| B08 | Ironbound Titan | dungeon:D01 | Heavy armor breaking and stagger timing | Iron Resolve |
| B09 | Obsidian Basilisk | dungeon:D05 | Gaze focus and dodge timing | Deep Current |
| B10 | Eclipse Serpent | dungeon:D07 | Poison stacks and clearable shadow hazards | Phoenix Crest |
| B11 | Rift Devourer | dungeon:D07 | Debuff consumption and targeted adds | Rift Hunter |
| B12 | Starfall Hydra | dungeon:D08 | Multi-head cycle with focus damage and reviveable heads not heroes | Harmony Sigil |

**Cơ chế Boss phải công bằng trong Auto Battle:** khi có telegraph cần tối thiểu một cách đối phó bằng đội hình/trait/spirit/Ultimate timing chứ không đòi thao tác phản xạ chính xác dưới 0,2 giây. Boss rớt rare material theo bảng xác suất và bảo đảm progression rõ; chi tiết odds/drop, pity nếu có sẽ được phê duyệt trong economy spec.

**Khác biệt giữa Boss và enemy thường:** Boss có intro art, ít nhất 2 phase hoặc một biến cố ở ngưỡng HP, 2 hành động đặc trưng, VFX, icon kỹ năng và một phần thưởng liên quan. Không dùng quái thường phóng to thay Boss.

---

# 6. DUNGEON MATRIX — 8 HOẠT ĐỘNG CÓ THỂ CHƠI

Không tính 8 phó bản vào 84 stage campaign; không quảng cáo hoạt động chỉ có preview là playable. Có cooldown/reset dự kiến, nguồn thưởng, thời lượng và giới hạn thật trước release.

| Dungeon | Tên | Vật liệu/đồ rơi | Chu kỳ dự kiến | Boss/cơ chế chính | Mở sau |
| --- | --- | --- | --- | --- | --- |
| D01 | Ancient Forge | Gear forging stone and Iron Resolve set | Daily repeatable | Ironbound Titan | R2-12 |
| D02 | Abyssal Waters | Spirit upgrade materials and water set fragments | Daily repeatable | Mirror Leviathan rematch | R3-12 |
| D03 | Sylvan Trial | Hero XP and nature materials | Daily repeatable | Briar Matriarch rematch | R4-12 |
| D04 | Tempest Circuit | Skill materials and storm components | Daily repeatable | Storm Roc rematch | R5-12 |
| D05 | Shadow Vault | Accessory crafting and Deep Current set | Daily repeatable | Obsidian Basilisk | R6-12 |
| D06 | Astral Gauntlet | Weekly boss medal and selector fragments | Weekly repeatable | Rotating regional boss variants | R7-12 |
| D07 | Rift Hunts | Special boss gear fragments for Rift Hunter and Phoenix Crest | Rotating repeatable | Eclipse Serpent; Rift Devourer | R5-12 |
| D08 | Echo Spire | 30 fixed floors and account-bound milestone cosmetics | Finite challenge with replay loot cap | Starfall Hydra | R7-12 |

**Tách mục đích:**
- D01/D05/D07/D08 là các trục săn Boss/gear/sưu tầm.
- D02/D03/D04 cho nguyên liệu phát triển spirit/hero/skill.
- D06 là boss gauntlet định kỳ, thưởng selector fragments có thể farm.
- D08 **30 tầng cố định** là nội dung bổ sung ngoài 84 stage, không gắn nhãn “endless 500 tầng” nếu chưa làm thật.
- Daily/weekly cap là logic sản phẩm cần kiểm thật; vì game offline, tuyệt đối không neo **paid entitlement hoặc paid currency** vào đồng hồ thiết bị có thể bị chỉnh. Lịch reset và chống giả cần spec.

**Không chỉ vẽ 8 tấm bản đồ phó bản:** mỗi Dungeon phải vào trận, xử lý thua/thắng, settle reward, đánh lại, giới hạn/ngày và kiểm lỗi đầy túi.

---

# 7. CONTENT PRODUCTION — ĐỦ HOÀN CHỈNH ĐỂ PHÁT HÀNH

## 7.1. Asset budget theo hạng mục (số lượng đầu ra tối thiểu)

| Nhóm | Kỳ vọng đầu ra | Ghi chú |
| --- | --- | --- |
| Hero | 24 portrait chất lượng cao, 24 battle sprite-pack có đủ idle/attack/skill/ultimate/hit/KO, 24 face icon, 24 Collection card | 4 hero hiện có có thể giữ nếu đủ chuẩn; các hero khác phải làm thật |
| Tinh linh | 12 creature concepts, 12 sprites/animation packs, 12 effect packs, 12 collection portraits | Lumi/Ash có ảnh hiện tại nhưng chưa được coi là đủ art mới |
| Trang bị | Ít nhất **48 icon** theo 12 set + set badge/art key; unique/non-set là thêm nếu duyệt | Không dùng 1 icon chung cho 4 slot |
| Regions | 7 visual key art; gợi ý ít nhất 3 scene background variant/vùng = **21 background** | Đủ nhận diện 84 stage mà không cần 84 bức tranh hoàn toàn khác |
| Enemies | **28 loại quái thường + 7 elite concept** (4 common + 1 elite/vùng) | Cần kỹ năng/animation phân biệt, không chỉ màu |
| Boss | 12 bản character/boss art + battle actors + telegraph/effect sheets | 7 region + 5 special |
| Outfit monetization | 12 premium costume designs, **có icon/portrait/battle appearance thật**, cộng 12 palette variant kiếm được | Skin không cộng stat; mỗi premium costume có production cost riêng |
| UI/UX | Gallery đủ 24 hero, 12 spirit, 12 set, 7 region; team, summon, reward, shop, ad opt-in và IAP receipt | Mọi nút chức năng thật và có fallbacks |

**Đây là khối lượng đáng kể**, đặc biệt với mỗi hero có nhiều pose. Để tránh hàng trăm art assets bị lệch chuẩn, cần một art style guide/pipeline kiểm soát trước khi sản xuất đồng loạt. Có thể làm nội bộ từng lô để kiểm, nhưng **không công khai bản chỉ có lô đầu**.

## 7.2. Cosmetic line (12 premium, không phải skin chỉ nhuộm lại)

**Gói trang phục đề xuất**: Eira *Moonlight Commander*; Ryn *Phoenix Festival*; Mira *Deepsea Oracle*; Lyra *Crimson Champion*; Caelan *Ivory Guardian*; Seraphine *Ember Queen*; Iona *Winter Masquerade*; Nara *Forest Empress*; Kaia *Storm Idol*; Vespera *Night Duchess*; Zeph *Sky Wanderer*; Aveline *Celestial Vanguard*.

**12 palette variant kiếm miễn phí** nên gắn với các nhân vật còn lại qua campaign, collection hoặc challenge, có art được duyệt và không mang nhãn “premium outfit” giả.

**Quy định mỹ thuật:** tất cả hero người trưởng thành; không sao chép nhân vật anime/franchise có bản quyền; art/voice/music phải có provenance và quyền sử dụng thương mại; portrait/sprite cùng một gương mặt, màu tóc, trang phục; mọi skin premium phải đổi chi tiết trang phục đủ rõ ràng trên avatar, Collection lẫn trận.

## 7.3. Nội dung cốt truyện — vừa đủ hỗ trợ phát triển game

**Không hồi sinh Story Bible vừa bị xóa.** Chỉ cần:
- 1 premise 1 trang cho 7 vùng và lý do có Boss.
- Mỗi vùng: opening 3–6 đoạn thoại ngắn, một midpoint và ending 3–6 đoạn.
- Mỗi hero: tiểu sử 2–4 câu, 1 collection quote, nơi xuất thân, sự kiện mở khóa/summon.
- Mỗi tinh linh: vài câu về nguồn gốc và kiểu giao ước/đồng hành.
- Mỗi set: 1–2 câu lore cho 4 phần, cùng motif phục trang/quái/Boss.
- Skip/Archive dialogue để farm không bị cản.

**Không buộc mọi hero là người trong cùng một party truyện.** Party chiến đấu được người chơi tự xây; roster sở hữu không đồng nghĩa nhân vật xuất hiện trong từng cutscene.

---

# 8. MONETIZATION & SOURCES CHO BẢN FULL LAUNCH

**Kinh doanh ngày ra mắt** theo kế hoạch riêng: 2–4 vị trí rewarded ads tự nguyện và 6–8 SKU IAP thật **chỉ khi đã hợp lệ và kiểm chứng**. Các SKU kiểu *starter, hero growth, spirit growth, cosmetic outfit, gear materials, welcome selector*, và những sản phẩm như pass/premium summon **nếu hoàn thiện đầy đủ**.

**Gắn trực tiếp với nội dung matrix:**
- Một người xem ad sau dungeon có thể nhận **một lượng nguyên liệu xác định** trong bảng thưởng dungeon, không x2 mọi drop boss.
- Gói hero growth dùng nguyên liệu progression thật cho 24 hero, không tạo currency vô dụng.
- Gói spirit dùng vật liệu thật cho 12 spirit; không cho spirit giả không có skill/animation.
- Outfit premium là nguồn tiền dựa trên **sự hấp dẫn của hero**, không yêu cầu hero mạnh hơn.
- Welcome selector: nếu bán, danh sách được chọn phải ghi rõ và **có đường F2P** tương ứng, không bán ngẫu nhiên bị hiểu nhầm.
- Premium summon nếu bán lượt random: hiển thị odds, pool/pity và chính sách refund/restore rõ trước giao dịch.
- Có một lớp **content ownership vs payment entitlement** tách bạch. Không cấp premium gear/skins qua lệnh UI local không qua receipt verification.
- **Cấm:** quảng cáo bắt buộc giữa trận, phần thưởng ads không đến, thanh toán thành công không nhận đồ, offer giả, giá không từ storefront, thiếu privacy/consent, dùng dữ liệu giả làm revenue.

## 8.1. Những bảng cân bằng vẫn cần sản xuất trước khi Codex code

Bảng này **chưa chứa số damage, HP, cost, drop rate cuối cùng**. Cần các artefact:
- Hero Combat Ability Spec (damage formula, target logic, cooldown, status cap, Ultimate meter, shield/cleanse rules, offense/heal balance).
- Realm Encounter Balance (84 stages × enemies/waves/hazards/reward/HP/ATK/lv/unlocks).
- Boss Pattern Spec (12 bosses × phases/telegraphs/resists/multi-target/reward).
- Gear Stat & Drop Sheet (48 items × rarity/2pc/4pc/proc cap/cost/drop).
- Spirit Stat & Acquisition (12 spirits × effect/timing/SP/cost/rarity/upgrade).
- Economy & IAP Product Sheet (gold/materials inflow/sinks, ad reward caps, prices from store, F2P/paid progression).
- Art Production Specs (24 hero turnarounds, 12 spirit, 12 Boss, 48 gear icons, source/provenance).
- Save & Migration Spec (legacy IDs, owned heroes, UID gear, pity, pending run, no double rewards).

**Đây là bước tách cần thiết trước khi “Codex triển khai”**: Matrix là **cái gì phải có**, các spec kia quyết định **chúng hoạt động thế nào**, từ đó mới có thể code và test đáng tin.

---

# 9. SAFE MIGRATION — GAME 0.37 ĐƯỢC XỬ LÝ RA SAO?

| Tài sản hiện có | Thiết kế trong matrix | Hành động có thể nghiên cứu sau khi duyệt |
| --- | --- | --- |
| Eira, Ryn, Mira, Lyra | H01/H05/H09/H06 | Có thể giữ ID và art rồi nâng kỹ năng; redesign chỉ khi owner chọn |
| Lumi, Ash | S01/S03 | Giữ quyền sở hữu/rarity, mở rộng kit nếu đã có đặc tả |
| 6 set cũ | G01–G06 mapping **chỉ là candidate** | Bảo toàn set_id, UID, level, rank, bonus; không chuyển tự phát |
| 5 stage chính + 10 branch | 84 campaign stages mới | Cần **stage ID mapping**, progression/claimed/first-clear migration và backwards compatibility |
| 3 dungeon thật, 12 preview | 8 dungeon thật theo kế hoạch mới | Tái sử dụng nếu cơ chế có ích, không gắn stage0 thành playable |
| Save v12, pending run, inventory UID | Thiết kế mới chưa có schema | Viết migration độc lập, giữ backup/corrupt/future-version, không reset người chơi |
| 8 supplies đang có | Resource economy mới | Chỉ giữ/bỏ/sửa có lý do về gameplay, migration và item sources |
| VIP UI đang khóa | Store/monetization thật | Chỉ mở khi có cấp/quyền lợi/prices/billing verified; không giả VIP |

**Dữ liệu hiện tại không phải canon bắt buộc của thế giới mới**, nhưng vẫn là **tài sản kỹ thuật cần an toàn** cho save cũ. Không được viện lý do “cốt truyện không cần” để xóa thẳng item mà người chơi sở hữu.

---

# 10. QUY TRÌNH SẢN XUẤT NỘI BỘ — CHỈ PHÁT HÀNH KHI XONG

**Không có soft launch ít hero, không public bản nháp.** Các đợt dưới đây là các công đoạn nội bộ, có thể song song một phần:

1. **Owner duyệt Matrix:** hero, giới, tên, vai trò, spirit, gear, vùng, Boss, dungeon, stage, số lượng skin, nguồn unlock.
2. **Khóa mỹ thuật:** sample hero nam/nữ, ngôn ngữ trang phục/affinity, source art, pose count, battle readability. Kiểm nội bộ, không phải phát hành thử.
3. **Khóa combat/economy specs:** kỹ năng, status, các loại vũ khí, boss counters, nguồn rơi, F2P progression và gói IAP.
4. **Sản xuất đủ nội dung:** 24 hero, 12 spirit, 12 set, 7 vùng/84 stage, 12 Boss, 8 dungeon, cosmetic/store.
5. **Tích hợp + QA theo subsystem:** verify combat/formation/summon/inventory/AFK/rewards/owned IDs; import art đúng nguồn, không dùng placeholder khi phát hành.
6. **Monetization thực:** Ad SDK + opt-in + callback/tracking; Google Play Billing + backend verification/entitlements/refund/restore; UI/consent.
7. **Release candidate đầy đủ:** 100% matrix đã duyệt playable, Android device QA, stress roster lớn, không crash, không mất save, phần thưởng/giao dịch không duplicate.
8. **Một lần phát hành chính thức:** Store listing dùng nội dung có thật; sau đó phát triển thêm hero, skin, sự kiện dựa trên chiến lược dài hạn.

## 10.1. Tiêu chuẩn nghiệm thu — Codex phải chứng minh

| ID | Điều kiện PASS khi release candidate |
| --- | --- |
| L-01 | 24/24 hero có art đạt chuẩn, sở hữu thật, skill kit khác nhau, chiến đấu được, quản lý đội hình/save được |
| L-02 | 12/12 tinh linh có hiệu ứng, animation và nguồn nhận thật; đội 3 hero + 1 spirit hoạt động |
| L-03 | 12 set × 4 slot đủ 48 gear item; có nguồn farm, bonus 2/4, UID/rarity/rank/enhance ổn |
| L-04 | 7 vùng ×12 = **84 stage campaign** có enemy/encounter/reward/unlock thật; không placeholder |
| L-05 | 12 Boss có art, pattern, telegraph, counterplay và loot thực |
| L-06 | 8 dungeon có điều kiện vào, kết quả, nhận thưởng, giới hạn và lưu tiến trình thật |
| L-07 | 12 premium outfit + 12 earnable palette variant được truy cập và thể hiện đúng trong portrait/battle |
| L-08 | New player có 8 hero guaranteed theo milestones trong kế hoạch và không cần trả tiền để vượt toàn campaign |
| L-09 | Store/SKU và rewarded ads đã được tích hợp/duyệt/kiểm thử, không có grant giả hoặc duplicate |
| L-10 | Save old version được migrate an toàn; item UID, heroes, spirits, pity, pending run, transactions bảo toàn hoặc có phương án owner duyệt |
| L-11 | Android thật đạt chuẩn crash/performance, UX, touch, offline/online và English (US) |
| L-12 | Không vi phạm asset copyright, odds disclosure, ads opt-in, Play Billing, privacy policy; support và store listing sẵn sàng |

**PASS các điều kiện trên cần bằng chứng thực tế**, không chỉ một bảng “đã xong” hoặc screenshot concept. Nếu asset nặng làm FPS thấp, sửa asset optimization trước khi ra mắt, **không lặng lẽ cắt nội dung đã chốt**.

---

# 11. NHỮNG QUYẾT ĐỊNH OWNER CÒN PHẢI CHỐT

| ID | Vấn đề | Mặc định cho bản thiết kế | Chưa được tự kết luận |
| --- | --- | --- | --- |
| D-01 | Quy mô roster | 24 hero / 12 male + 12 female | Có tăng tới 30 hero không? |
| D-02 | Affinities | 6 hệ ×4 hero | Sẽ thiết kế tương khắc hay chỉ đặc tính khác nhau? |
| D-03 | Hero rarity | Đề xuất uniform 5★ lúc tuyển, awakening riêng | Có chia tier summon hay không? |
| D-04 | Legacy four heroes | Giữ ID/tạo hình để bắt đầu, cho phép redesign có duyệt | Có xóa/đổi tên hay thay art không? |
| D-05 | Gacha/free path | 8 guaranteed, 16 banner+shards không độc quyền trả tiền | Pity/shard costs/drop/selector details |
| D-06 | Số set | 12 full set, 48 items | Giữ/đổi cụ thể sáu set cũ |
| D-07 | Stages/region | 7 vùng, 84 campaign | Số wave và miniboss cho từng stage |
| D-08 | Boss | 7 main + 5 extra | Cân bằng, cách mở farm và unique drops |
| D-09 | Dungeons | 8 hoạt động | Reset limits và reward rates |
| D-10 | Cosmetics | 12 bespoke premium + 12 free variants | Giá, hero targets, ảnh và bonus (đề xuất cosmetic only) |
| D-11 | Launch monetization | Rewarded ads + 6–8 SKU IAP thực | Giá/SDK/backend, IAP có premium summon hay không |
| D-12 | Game storage | Duy trì save cũ bằng migration kiểm chứng | Mô hình backend entitlement khi có paid items |

**Tất cả hiện ở trạng thái đề xuất để bạn duyệt trước khi giao Codex.** Không có lý do viết thêm cốt truyện dài để trì hoãn việc sản xuất nhân vật đẹp; bước thiết kế kế tiếp là **Character Art Production Bible** và **Combat/Balance Specification**.

---

*The fantasy is the reward. The collection is the journey. The quality must be there on day one.*

