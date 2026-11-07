# Âm thanh 0.5 · ElevenLabs

## Quy tắc rút từ repo tham khảo

Nguồn: [ANIMATION.md](https://github.com/tai23082004l02-svg/Tham-kh-o-game/blob/main/research/eternal-senia-2/ANIMATION.md),
`catalogs/verified_clip_samples.json`, `catalogs/asset_inventory.json`.

| Bằng chứng đã đọc | Kết luận được phép rút ra |
|---|---|
| anim_senia_none_tapatk_1, file 1201511d14bd42b47957156f12f3dac0 / PathID 1, dài ~0,633s: OnAnimInstantiateParticle(slash7) và OnAnimPlaySound(Sword_hit) tại 0s | Âm/particle được gọi bằng marker của clip; không chỉ trừ HP rồi phát một tone chung |
| anim_pt_hugo_atk, file 72cfb0d7ed39bf74f869dfca57c01c5c / 1, dài ~2,2s: Magic_ice cùng OnAnimAtkMultiple ở 1,0667s và 2s | Một hành động có thể có nhiều mốc đánh/âm; phải xử lý từng marker, không chỉ frame đầu |
| anim_senia_run dài ~0,333s, sample 30, không có event trong mẫu đã kiểm | Không tự kết luận run gốc có tiếng chân ở marker nào |
| Catalog có nhiều tên Sword_hit và AudioClip Magic_ice | Có nhiều mẫu âm; không chứng minh chính xác cách runtime chọn biến thể |

Đã mở **metadata AudioClip gốc** từ base.apk bằng UnityPy 1.25.4. Không sao chép
waveform gốc vào game mới, không khẳng định đã nghe mẫu tham khảo hoặc phục hồi
thuật toán trộn âm C#.

| AudioClip | Serialized file / PathID | Dài (giây) | Metadata |
|---|---|---:|---|
| Sword_hit_1 | 5cc92fa8cc829ea4190c4a0ba1cbaaff / 1 | 0,394739 | mono, 22050 Hz, 16 bit |
| Sword_hit_2 | 6dbf6ff4cde8e884c8c3f78517d07b5d / 1 | 0,383129 | như trên |
| Sword_hit_3 | d20eeb6f13e2930488b282e52388a0c6 / 1 | 0,374422 | như trên |
| Sword_hit2 | 041ef62f59f85f94d808fcefbd88f476 / 1 | 0,391837 | như trên |
| Sword_hit4 | 549a1dd3610467044b8036f0dce84a56 / 1 | 0,862041 | như trên |
| Magic_ice | 71504787ed1c8a84587a18f40804f0ca / 1 | 1,149388 | như trên |

Các mốc và công thức bên dưới là **thiết kế mới**, không gọi là timing gốc.

## Bộ âm ElevenLabs thực tế

Tạo qua [workflow dùng secret tại chỗ](https://github.com/tai23082004l02-svg/Live-Youtube-American/actions/runs/42337597428)
trên nhánh riêng `codex/aternal-elevenlabs-sfx-v1` của repo Live-Youtube-American.
`main` và game Live không được chỉnh. Secret chỉ được dùng bởi request HTTPS tới
`api.elevenlabs.io`; không xuất key, không chép key vào repo game hoặc artifact.

Batch `aternal-senia-elevenlabs-sfx-v1`: **39 yêu cầu, 39 HTTP 200**, model
`eleven_text_to_sound_v2`, tổng duration yêu cầu 40,5s, output `mp3_44100_128`.
Không tự retry request tạo âm hoặc rerun trả phí. Mỗi file có checksum gốc.

- **38 SFX**: ba biến thể vung/trúng kiếm, thương/trượng, cast/burst/heal,
  Lumi/Ash, đỡ đòn, khiên/phá khiên, cảnh báo/đập đất/phản đòn, quái tan biến,
  bước chân, vào trận/boss, thắng/thua, UI/thay đồ/rèn/nâng cấp/thưởng.
- **Một ambience rừng 12s**, yêu cầu loop, không nhạc nền hoặc giọng nói.
- Giữ 34 cue logic và pool/mix/timeline cũ; asset phát đã được thay hoàn toàn.

Nguồn và bằng chứng trong `art/audio/elevenlabs/`:
- `raw/*.mp3`: đúng bytes từ API, không chỉnh sửa.
- `receipt.json`: provider, batch, model, HTTP status, SHA256 và biên nhận.
- `request.json`: các prompt/duration thực sự được gửi; không chứa credential.
- `../provenance.json`: liên kết raw SHA với từng file runtime và phép xử lý.

`tools/import_elevenlabs_audio.py` xác minh đầy đủ receipt/hash rồi mới thay file
runtime: căn onset, bỏ khoảng im, rút độ dài bằng atempo giữ pitch khi cần, DC,
fade mép, normalize và đổi thành WAV mono PCM16 32000 Hz. Đây là **hậu kỳ âm
ElevenLabs**, không phải tổng hợp SFX thay thế bằng Python. Giữ raw để tinh lại
mà không gọi API thêm. Vài UI/footstep cần rút ngắn nhiều để hợp nhịp game.

Ambience đổi thành Ogg playback 2 kênh; giữ nguồn MP3 và loop flag trong receipt.
`tools/build_audio.py` của prototype nay từ chối ghi đè khi bộ runtime có provider
ElevenLabs. Không có fallback tự tạo âm bằng code, không gọi API khi chơi game.

Các file tone `art/hit.wav`, `heal.wav`, `hurt.wav`, `win.wav` còn là lịch sử
prototype, không được AudioDirector nạp hoặc phát.

## Timeline, quyền sở hữu và chống lặp

BattleModel thêm `cue` và `action_id` vào event có ID tăng dần. Action có cờ
`sound_fired` riêng với `hit`. Tiếng vung ở **hit marker −0,09s** (đòn thường
0,13s), impact tại hit thực (0,22s, lượng tử trong 1/60s). Cast tại lúc bắt đầu;
heal tại mốc hồi HP; burst phá khiên có cue riêng khi chuyển trạng thái.
Trợ chiến và boss có marker của model, bước chân chuyển đợt là thiết kế mới.

FrameLibrary/BattleView/Pose Lab không phát âm hay sửa HP. Seek/replay artwork
không thể gây hit hoặc phát lại SFX. AudioDirector tiêu thụ mỗi `(run,id)` một
lần, kể cả đang mute, nên mở lại âm không xả backlog. Bắt đầu run mới clear
con trỏ và dừng đuôi combat/result cũ. Kết quả phát từ event trận, không phát lại
khi retry ghi thưởng. UI thưởng/nâng đồ chỉ phát cue xác nhận sau commit thành công.

Biến thể và pitch nhỏ lấy từ bộ đếm trình bày riêng, **không tiêu thụ combat RNG**.
×1/×2/×3 chỉ làm marker đến sớm hơn theo đồng hồ mô phỏng; không đổi pitch cả bộ
âm. Tốc độ cao được bảo vệ bằng cooldown ngắn và giới hạn voice.

## Trộn âm và điều khiển

AudioDirector có pool 12 voice. Mỗi cue có gain, cooldown, số instance tối đa,
priority và bus. Cảnh báo/thủ thế/result có thể ngắt voice ưu tiên thấp; swing
không chen mất fanfare. Không sinh node audio mới cho từng lần đánh.

Bus FirstLightSFX có limiter ceiling −3 dB, threshold −6 dB. Source WAV có fade
đầu/cuối và peak khoảng −3,48 dBFS, gain cue thấp hơn; ambience bus độc lập. Mức
người chơi mặc định hiệu ứng 80%, rừng 35%. Điều này không bảo đảm âm lượng cảm
nhận trên mọi thiết bị; cần nghe và tinh tiếp bằng loa/tai nghe thật.

- Nút Âm bật/tắt dừng các voice ngay khi tắt; unmute không phát lại âm cũ.
- Nút ♫ mở bảng mức hiệu ứng/không gian, nghe thử, Áp dụng/Hủy.
- Bảng này tạm dừng trận. Preview vẫn nghe được qua nhánh UI. Hủy trả mức đã lưu.
- Pause hoặc mở trang quản lý dừng clock và pause tail combat; UI vẫn hoạt động.
- Ambience tiếp tục khi pause trên màn rừng; dừng ở trang quản lý/khu vực khác.
- Mức 0 và master off dừng nguồn tương ứng. Đóng game dừng/clear stream.

Hai field volume là **tùy chọn** trong save v2: save cũ thiếu field dùng mặc định,
không reset hoặc đổi vị trí save. Áp dụng ba giá trị cùng một transaction;
preview không ghi file theo từng tick slider. Save lỗi không trừ/đổi thiết lập.

## Kiểm chứng và nghe thử

- 93 assertions ở `tests/audio.gd`: timeline, action ID, hit, pause, mute,
  chống lặp/backlog, ưu tiên/giới hạn pool, RNG, ×1/×2/×3, volume và save cũ.
- `tests/validate_audio.py`: đủ file, PCM format, peak/headroom, DC, fade và onset.
- Regression 81 assertions, mechanics và campaign vẫn đạt.
- `tests/audio_capture.gd` dùng **AudioEffectRecord trên mixer Godot thật**,
  driver Dummy, X11/Mesa; ghi trận, boss, kết quả và reward, chụp menu âm.
- [Đoạn ghi trong game](audio/combat-preview.wav), downmix mono 22050 Hz để chia sẻ.
- [Số đo capture](audio/verification.json), [trace marker](audio/capture-trace.json),
  [ảnh menu](previews/audio-settings.png). Capture thử: xem số đo thực tế trong verification.json; số đo không thay thế đánh giá chất âm bằng người nghe.

Chưa nghe qua loa vật lý hoặc thử điện thoại; không tuyên bố âm đã được mastering
cho thiết bị thật. Chưa có nhạc nền dài, voice hay reverb theo phòng động.

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script tests/audio.gd
python3 tests/validate_audio.py
# Cần display; nơi lưu mặc định user://first_light_previews:
godot --path . --script tests/audio_capture.gd
```

Tái nhập mà không tốn thêm lượt API:
```sh
python3 tools/import_elevenlabs_audio.py /duong/dan/artifact-da-giai-nen \
  --request art/audio/elevenlabs/request.json \
  --run-url https://github.com/tai23082004l02-svg/Live-Youtube-American/actions/runs/42337597428
```

Cần numpy và ffmpeg cho hậu kỳ; runtime chỉ cần Godot. Để tạo âm mới cần yêu cầu
batch mới qua workflow có secret; không lấy secret ra hoặc tự retry batch cũ.
