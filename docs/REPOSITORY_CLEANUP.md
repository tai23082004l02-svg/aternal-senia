# Dọn repo2026-11-08

Mốc nguồn: `8422241ab7c6361b215b235d75208425d1597207`, game0.37.0/savev12.
Không đổi gameplay, catalogue, save, config/name, thiết kế hoặc tài nguyên runtime đang dùng.

## Bỏ và gom

- 142 đường dẫn cũ rời cây:133 file media (129 output docs và4 WAV prototype không dùng),
 5 JSON chuyển vị trí,2 workflow nhánh cũ và2 runner CI trùng lặp.
- Tổng kích thước đường dẫn rời cây **56.247.160 byte**;5 JSON được giữ ở verification/,
 cộng một ít tài liệu/tool mới. Checkout giảm khoảng56 MB, trên30% so với173.835.039 byte ban đầu.
- Xóa docs/previews/ và docs/audio/ khỏi bản hiện tại; cập nhật toàn bộ link ảnh/video/
 âm minh họa sang commit cố định và ghi [danh mục lưu trữ](ARCHIVED_MEDIA.md).
- Chuyển5 JSON chứng cứ sang docs/verification/, giữ nguyên nội dung.
- Bỏ art/hit.wav, heal.wav, hurt.wav, win.wav:AudioDirector không nạp chúng,
 không có tham chiếu runtime/manifest/builder còn hoạt động.
- Giữ tools/build_audio.py như guard từ chối lệnh synth cũ, bỏ mã tổng hợp prototype.
- Hợp nhất runner/workflow thành tools/check_project.py và verify.yml; output
 work/checks/artifact, CI contents:read và không tự push.
- README/AGENTS được viết lại theo cơ chế hiện hành; thêm GAME_STATE, SYSTEMS hiện tại,
 INDEX, REPOSITORY_MAP, TESTING, ANDROID_TERMUX và CHANGELOG.
- SYSTEMS0.2 giữ trong history/ cho BattleModel legacy, có nhãn rõ.

## Giữ lại có chủ đích

Code/runtime, tests và .uid; toàn bộ PNG canon và provenance;46 WAV đang dùng,
ambience/music Ogg; raw ElevenLabs/receipt/hash/request, kể cả lỗi401 lịch sử;
catalogue/encounters/dungeon preview; builder metadata/importer; concept Eira;
SVG/clips fallback đang được FrameLibrary load trước PNG override.

Không xóa tài nguyên chỉ vì không xuất hiện trong một lệnh tìm tên: có load động,
alias, override, nguồn builder hoặc dữ liệu migration. Không chỉnh pixel hoặc
encode lại tranh/âm thanh để “nén cho nhẹ” trong đợt này.

## Ngăn nặng lại

.gitignore loại work/cache/build/export/APK/save/secret. docs/.gdignore tránh
Godot import concept/tài liệu không dùng khi chơi. tools/verify_repo.py kiểm
tracked output, link nội bộ/resource literal/JSON. CI xuất artifact giữ7 ngày.

tools/export_android.sh tạo một thư mục mới, chỉ project/game/art từ HEAD đã commit;
không có Git history, docs/tests/output. Có kiểm import cả bản xuất trong CI.

## Giới hạn và kiểm chứng

Xóa ở HEAD **không thu nhỏ blob lịch sử trong .git**; lịch sử vẫn giữ nguyên,
không force push/filter-repo. Muốn tải bản hiện tại nhẹ hơn dùng clone --depth1,
hoặc bản xuất runtime cho điện thoại. git pull/giải nén chồng không dọn các bản
export cũ; mở thư mục mới do script in ra.

Kiểm tra bắt buộc: link/resource/JSON, Python/shell, import repo và export Android,
40 suite Godot, hash/raw/mixer audio, tracked-source diff. Kết quả thực tế nằm trong phần dưới. Chưa kiểm điện thoại thật.

## Kết quả đã chạy

[Lượt Project verification](https://github.com/tai23082004l02-svg/aternal-senia/actions/runs/42455715609), commit nguồn
`aa53624864c277673ddf5d0aefb08a2328c10e98`: **40/40 suite PASS**,
Godot4.6.3/Ubuntu24.04/Xvfb/Mesa. Đã kiểm link/resource/JSON, cú pháp Python/shell,
import repo và bản xuất runtime, hash ElevenLabs, cùng git diff không thay nguồn.

Tại commit kiểm tra:705→582 file,173.835.039→117.649.906 byte;
giảm56.185.133 byte (**32,32%**). Bản phát hành chỉ thêm đoạn biên bản này vào tài liệu.
Toàn bộ game/, asset PNG và art/audio/ cùng UID giữ nguyên SHA so với mốc nguồn;
chỉ4 WAV prototype không dùng rời art/.

Mixer capture21,269s, peak−7,341dBFS,0 mẫu clipping, tối đa6/12 voice.
Đây là kiểm PCM trên Linux, không phải đã nghe loa/kiểm cảm ứng trên điện thoại.
Artifact `project-verification-42455715609` chứa ảnh/log/results/PCM, giữ7 ngày.
