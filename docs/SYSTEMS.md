# Hệ thống 0.2

## Phân lớp

- `GameCatalog`: nạp JSON bất biến, chuẩn hóa số nguyên JSON, kiểm ID/drop/skill.
- `ProgressStore`: owns profile, derived stats, transaction, migration/backup.
- `BattleModel`: snapshot run, RNG, HP/SP, combo, skill, assist, enemy/boss, result.
- `FrameLibrary`: preload texture, chọn frame theo duration; không gây damage.
- `BattleView`: frame, socket vũ khí, nền, hiệu ứng và số nổi.
- `main.gd`: màn hình, điều khiển, câu chuyện, âm thanh và nối các module.

Không có tài nguyên network, SDK, tài khoản, quảng cáo hoặc phí runtime.

## Quy tắc chiến đấu mới

Fixed step 1/60 giây. ×2/×3 chạy nhiều step; pause ngừng clock của trận. Windup
đặt action ID, hit marker và wave đích. Một marker chỉ resolve một lần. Khi quái
chết, action cũ bị bỏ; không đánh xuyên sang quái mới. Render/seek frame không
sửa HP. Khi chuyển đợt có 0,8 giây chạy tới, không nhận command tấn công.

- Combo: 1 / 1,12 / 1,24 × ATK; tự đánh mỗi 0,85s; tap sớm nhất 0,38s.
- Crit: tỷ lệ riêng hero; hệ số 1,6. Assist không crit.
- Khắc chế: lửa > tự nhiên > nước > lửa, ánh sáng ↔ bóng tối; damage ×1,2.
- Damage sau khắc chế: trừ stage ID ×1,5, tối thiểu 1; khiên còn ×0,35.
- Đòn địch: max(1, ATK − thủ), sau đó thủ thế còn ×0,2; chu kỳ 3s.
- Boss smash: damage ×1,5. Shield: khiên 2,8s đầu mỗi chu kỳ, burst phá khiên
  đến hết trận boss. Counter: dùng đòn kỹ năng khi charge (sau 2s) bị phản 65% ATK.
- SP: tối đa 100, hồi 6/s, mỗi combo thêm 4. Skill dùng 20 / 25 / 35 SP.
- Skill nâng mỗi cấp thêm 12% power. Eira +12% skill; Mira +25% heal; Ryn crit 18%.
- Vũ khí hiếm: cooldown ×0,92. Các số này cần cân bằng bằng thử người chơi thật.

## Nhân vật và trang bị

HP hero tăng 25/cấp, ATK 4/cấp, thủ 1/cấp. Cấp tối đa 100. Vàng để tăng cấp là
30 × cấp hiện tại, XP 15 × cấp. Kỹ năng tối đa 10, cost 25 × cấp vàng. Assist tối
đa 20, cost 35 × cấp vàng.

Mỗi item có UID, base ID, enhance và rank. Equipment chứa UID theo hero/slot;
không thể trang bị cùng UID cho hai người. Vũ khí phải đúng lớp. Không phân giải
đồ đang mặc. Nâng hệ số item = 1 + enhance ×0,18 + (rank−1) ×0,5. Cường hóa cost
20 × (enhance+1) vàng +1 shard, tối đa +10. Tiến bậc cost 80 ×rank vàng +4 ×rank
shard, tối đa rank 3. Rèn cost 65 vàng +3 shard. Túi 40 món.

Snapshot stat được chốt lúc tạo run và ghi cùng ID/seed; không đọc lại stat từ
UI mỗi hit. Thay đổi build khóa trong run; XP/nhiệm vụ không sửa snapshot.

## Transaction và khôi phục

1. Deep copy profile; kiểm điều kiện, tính thay đổi trên bản copy.
2. Validate candidate; ghi `.tmp`, flush, đọc lại và validate.
3. Nếu save hiện tại hợp lệ: copy sang `.bak`; lỗi backup thì dừng.
4. Rename file tạm vào file chính; chỉ sau thành công mới đổi profile RAM.

Không đảm bảo chống mất điện ở mức filesystem/fsync directory trên mọi OS;
đã kiểm lỗi ghi bằng fault injection và backup trong Linux. Save hỏng không tự
reset. Backup hợp lệ được dùng sau khi giữ file hỏng ở `.corrupt.<ticks>`.
Future schema khóa ghi. Migration v1 giữ nguyên vàng/cấp và file gốc.

Run pending được giữ qua restart. Chơi lại từ đầu run với cùng seed/snapshot.
Settle ghi ví, XP, item, metrics, first clear, story flag, settled ID và clear
pending trong cùng candidate. Settle lại ID đã nhận không đổi ví. IDs gần nhất
được giữ 64 mục; ID cũ không còn pending cũng không thể nhận lại. Loot seed dùng
RNG riêng với lựa chọn đều trong pool 5 món. Túi đầy đổi drop thành 3 shard.

Nhiệm vụ giữ claimed IDs. Tiếp tế tính floor(clamp(now−last, 0, 7200)/60) ×
ải cao nhất mở ×2 vàng; claim ghi timestamp cùng vàng. Tích trong lúc chơi lẫn
khi đóng game. Giờ âm không thưởng; đây không phải cơ chế chống chỉnh đồng hồ.

## Kiểm chứng

Regression 81 assertions; mechanics kiểm thủ, thua, khiên/phá khiên/phản đòn
và 15 tổ hợp hero/stage với build mạnh; campaign kiểm profile mới vượt 5 ải chỉ
dùng thưởng thu được, reload giữa ải. UI flow dùng X11/Mesa thực, thao tác signal
nút, chụp màn hình tab/truyện/trận/boss/result/quest/đổi nhân vật. Kiểm hình trực
tiếp đã phát hiện và sửa bar overlap và crop pose chết. Chưa thử thiết bị thật.

## Mở rộng 0.7

`Expansion` quản lý các giao dịch học/chọn nhánh, tiến hóa đồng hành, thành tựu và schema mở rộng. `game/data/expansion.json` ghép với catalogue nền; có builder `tools/build_expansion.py`. Save hiện v3 tại đường dẫn cũ, đọc v2 và giữ pending snapshot; chi tiết công thức, mode, phần thưởng và migration ở [EXPANSION.md](EXPANSION.md).
