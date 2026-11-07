# Đối chiếu nguồn tham khảo

Nguồn: `tai23082004l02-svg/Tham-kh-o-game`, nhánh main đọc ngày 07/11/2026.
Bộ nghiên cứu dẫn nguồn commit `0b67b56bff375da5660f425d269529c67f688744`.
[Điểm bắt đầu](https://github.com/tai23082004l02-svg/Tham-kh-o-game/blob/main/research/eternal-senia-2/START_HERE.md).

Các số hàng dưới đây chỉ mô tả catalog nghiên cứu, không phải số nội dung đã
triển khai trong game mới hoặc số mục chắc chắn mở được trong game gốc.

| Nguồn trong research/eternal-senia-2 | Điều rút ra | Triển khai mới |
|---|---|---|
| ARCHITECTURE / core_class_map | Main hero + assist; combo, kỹ năng, sự kiện hit | BattleModel + View; command kiểm điều kiện; fixed step |
| DATA_MODEL / table_schemas: partner 70, partnerclass 10 | Đồng hành có vai trò, model, kỹ năng, bậc | 2 trợ chiến, mở khóa và cấp riêng |
| weapon 180 / weapon_stat 100 | Loại, nguyên tố, stat, vật liệu, animation | 6 vũ khí, giới hạn lớp, nâng/tiến bậc, nội tại hiếm |
| skill 20 / passive 605 | Dữ liệu kỹ năng, cooldown, loại, hiệu ứng | 3 kỹ năng, nội tại 3 hero, mốc hit model sở hữu |
| map 45 / area 1167 / mob_group 755 | Map → nhóm quái → mob | 5 khu × 3 đợt, 3 cơ chế boss |
| mob 673 / mob_stats 120 | Base và stat tách riêng | Stat quái trong stage, sprite quái tách biệt |
| dropgroup 303 / chest 319 | Drop có ID/weight; chưa rõ công thức pity | Loot seed đều trong pool mới; không gacha/pity phỏng đoán |
| quest 40 / tutorial 53 | Metric, mục tiêu, thưởng, hướng dẫn | 5 mục tiêu nhận một lần; hướng dẫn trước trận |
| chapter 27 / section 156 / dialog 12303 | Truyện trước/sau, mở khóa | 10 đoạn mới; journal, cờ đã xem |
| offline_reward 100 | Thưởng có trần; thuật toán gốc chưa biết | Tiếp tế 2 giờ; claim timestamp cùng transaction |
| ANIMATION / GRAPHICS_WORKFLOW | Sprite có source rect, trim offset, pivot; clip có event | Canvas chuẩn, socket vũ khí theo frame, clip duration riêng |

## Đã mở tài nguyên trực tiếp trong lượt này

Ba part archive khớp SHA256 từ `catalogs/provenance.json`. Chỉ trích `base.apk`
và các serialized asset/resource cần cho sprite; không đọc save/token/khóa.
Dùng UnityPy 1.25.4, `Sprite.image` để xử lý ảnh thay vì chia lưới hay crop alpha.
Đã xem contact sheet thực của các mục sau trong thư mục nghiên cứu cục bộ:

| Sprite | Serialized file / PathID | Rect nguồn | Ảnh UnityPy trả về | textureRectOffset |
|---|---|---|---|---|
| senia_run_01 | a7bf8eb8e9b55a74d9c4e49076a7fc88 / 2 | 900×600 | 300×353 | 288.0761, 17.1128 |
| senia_run_02 | 75c7734079ec12a4b901c90a7f8565d5 / 2 | 900×600 | 292×368 | 294.0363, 17.0761 |
| senia_run_03 | 33088b85410d30d4883ba773bc9a56cc / 2 | 900×600 | 360×370 | 227.0761, 17.0268 |
| swd_d_06 | 8722cc0068c1d6445afc4e41e94bd7c7 / 2 | 200×200 | 188×177 | 7.0761, 10.0564 |

Pivot các mẫu là (0.5, 0.5). Kích thước ảnh trim và offset khác nhau chứng minh
căn giữa ảnh trim không giữ nguyên vị trí source. Việc xem này là đối chiếu pose
và metadata, **không** phải phục hồi playback chính xác từ compressed curve.
Không đưa các ảnh gốc này vào source/game hoặc đầu ra phát hành.

## Giới hạn bằng chứng

`dump.cs` có khai báo, không có đầy đủ thân hàm C#. Damage, crit, loot, hồi chiêu,
khắc chế và offline trong game mới là công thức tự thiết kế. Không gọi chúng là
công thức Eternal Senia 2. Tài nguyên gốc được dùng cho nghiên cứu tĩnh; artwork,
tên, truyện, data và âm thanh ở repo triển khai được tạo riêng.

Bản này bao phủ các nhóm hệ thống chính bằng nội dung nhỏ có thể chơi; không
chuyển nguyên hàng nghìn dữ liệu/asset từ catalog sang game mới.

## Mở rộng 0.7

Đã áp dụng thêm cấu trúc `skillclass`/`passive`/`rune_*`, `ability`/`partner_rankup`, `realm`/`godRealm`/`platinumTrial`, hai nhóm skill trong `weapon`, `partner_collect`, `chapter`/`section`. Triển khai sáu nhánh chọn kỹ năng cho từng hero, ba bậc đồng hành, ba phụ bản, sáu trait vũ khí, bộ sưu tập/sáu thành tựu và mười màn truyện nhánh. Công thức, chi phí, nội dung và cân bằng đều thiết kế riêng; xem [EXPANSION.md](EXPANSION.md).

## Mở rộng 0.8

Đọc lại repo tham khảo tại `2c7af38c4c208656703814f64b05dfe0bd54844e`:
`statspoint` (lv/statspoint/stats_req) làm cơ sở cấu trúc cho phân bổ thuộc tính
theo cấp; `mob`/`mob_stats`/`dropgroup` gợi ý gom thông tin boss vào sổ tay đọc
catalogue. Quy tắc 2 điểm/cấp, bonus HP/ATK/phòng thủ, hoàn miễn phí và UI sổ tay
là thiết kế mới. Xem [TRAINING.md](TRAINING.md) cho cơ chế save và kiểm chứng.
