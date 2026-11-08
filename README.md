# Chủ đề 5 — Danh sách, lưới dữ liệu và cuộn trong Flutter

Demo thư viện điện tử chạy **offline**, dùng dữ liệu giả lập, **không cần API và package bên ngoài** ở runtime.

## Chạy chương trình

Yêu cầu Flutter SDK tương thích Dart >=3.0. Dự án đã có cấu hình Android, Web và Linux.

```bash
flutter pub get
flutter run -d chrome
# hoặc: flutter run -d linux
# Android: flutter devices, sau đó flutter run -d <device-id>
```

Chạy từ thư mục gốc `flutter_topic5_library` (chứa pubspec.yaml).
Nếu lệnh trên thông báo lỗi, kiểm tra `flutter doctor` và Flutter SDK.

```bash
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```

Bản dựng Web nằm trong `build/web`; phục vụ thư mục này bằng HTTP server.
Cờ `--no-web-resources-cdn` giữ tài nguyên dựng hình trong bản dựng để không cần CDN.
Dữ liệu sách và biểu tượng không gọi mạng; trình duyệt vẫn cần tải ứng dụng từ server
ban đầu (không có cơ chế cài đặt/cache PWA để mở lại khi mất kết nối).
Android và Linux dùng dữ liệu cục bộ ngay khi chạy. Build Android cần Android SDK;
build Linux cần các công cụ và thư viện hệ thống được báo trong `flutter doctor`.

## Đẩy mã nguồn lên GitHub

### 1. Chuẩn bị repository

Cài Git, đăng nhập GitHub và tạo một repository mới, ví dụ `flutter_topic5_library`.
Chọn **Public** hoặc **Private** theo nhu cầu. Để repository trống khi tạo:
không thêm README, `.gitignore` hoặc License vì dự án đã có tệp sẵn ở máy.

Mở terminal tại thư mục dự án (nơi chứa `pubspec.yaml`). Kiểm tra Git:

```bash
git --version
git init
```

Nếu chưa cấu hình tên và email cho Git, chạy hai lệnh sau, thay bằng thông tin của bạn.
Cấu hình này chỉ áp dụng cho repository hiện tại:

```bash
git config user.name "Tên của bạn"
git config user.email "email-cua-ban@example.com"
```

### 2. Tạo commit đầu tiên

```bash
git add .
git status
git commit -m "Hoàn thiện demo thư viện Flutter chủ đề 5"
git branch -M main
```

Xem danh sách tệp trong `git status` trước khi commit. Các tệp `.gitignore` có sẵn
sẽ bỏ qua thư mục sinh tự động như `build/`, `.dart_tool/` và cấu hình Android
riêng của máy như `android/local.properties`. Giữ `pubspec.lock` trong mã nguồn
để các máy dùng cùng phiên bản dependency.

### 3. Kết nối và push lên GitHub

Thay `TEN_GITHUB` bằng tên tài khoản của bạn và dùng đúng URL repository vừa tạo:

```bash
git remote add origin https://github.com/TEN_GITHUB/flutter_topic5_library.git
git push -u origin main
```

Hoàn tất bước xác thực nếu Git yêu cầu. Sau khi push thành công, mở repository
trên GitHub để xem mã nguồn và README.

Nếu gặp `remote origin already exists`, kiểm tra địa chỉ hiện tại:

```bash
git remote -v
```

Nếu địa chỉ chưa đúng, cập nhật rồi push lại:

```bash
git remote set-url origin https://github.com/TEN_GITHUB/flutter_topic5_library.git
git push -u origin main
```

Nếu push bị từ chối vì repository trên GitHub đã có commit, dùng một repository
trống cho lần tải lên đầu tiên theo hướng dẫn này. Không cần dùng `--force`.

### 4. Đẩy các thay đổi tiếp theo

Sau khi sửa mã nguồn, chạy tại thư mục dự án:

```bash
git add .
git status
git commit -m "Mô tả thay đổi vừa thực hiện"
git push
```

## Những tính năng đã tích hợp

| Nội dung chủ đề | Vị trí minh họa |
|---|---|
| `SingleChildScrollView` | Chi tiết sách và màn Cuộn lồng |
| `ListView(children)` | Màn Cuộn lồng, 6 mục, `shrinkWrap` |
| `ListView.builder` | Màn Thư viện, nút List và dải danh mục ngang |
| `GridView.builder` | Màn Thư viện, nút Grid |
| `CustomScrollView`, `SliverGrid`, `SliverList` | Màn Sliver |
| Cuộn lồng hai hướng | Màn Cuộn lồng |
| Lazy Building | `itemBuilder` của List/Grid |
| Lazy Data Loading / Pagination | Repository trả 30 sách/trang + `extentAfter` |
| Dữ liệu 20/100/1000/10000 | Dropdown Dữ liệu |
| Tìm kiếm / lọc danh mục | TextField và ChoiceChip |
| Debounce tìm kiếm | Chờ 300ms sau khi ngừng gõ; bỏ kết quả truy vấn cũ |
| Empty / Loading / Error | Từ khóa không có kết quả / Spinner / Thử lỗi |
| Kích thước phần tử khác nhau | Mô tả dài/ngắn trong ListTile |
| Responsive Grid | LayoutBuilder chia 2/3/4 cột |
| Giữ state khi đổi tab | IndexedStack |
| ScrollController | Tải trang tiếp theo khi `extentAfter < 350` |

## Kịch bản demo khi thuyết trình

1. Chọn **20** bản ghi → List, kéo xuống → chuyển Grid.
2. Chọn **10.000** → ban đầu chỉ tải 30 bản ghi; cuộn để tự tải trang tiếp theo.
3. Nhập `khong-co-sach-nay` → Empty State → Xóa bộ lọc.
4. Nhấn **Thử lỗi** → Error State → **Thử lại**.
5. Nhấn một sách → trang chi tiết cuộn bằng SingleChildScrollView.
6. Mở tab **Cuộn lồng** → cuộn dọc trang / cuộn ngang danh mục.
7. Mở tab **Sliver** → SliverAppBar co giãn, SliverGrid + SliverList chung một vùng cuộn.

## Đánh giá hiệu năng

Dùng `flutter run --profile -d <device>` (thiết bị hỗ trợ profile mode), mở Flutter DevTools > Performance.
Đo thời gian khung hình (UI/raster), số frame vượt ngân sách 16,7 ms trên màn 60Hz, mức tiêu thụ bộ nhớ và số lần rebuild. Không dùng số liệu Debug Mode để kết luận hiệu năng thực tế.

Chú ý: 10.000 là số **bản ghi tiềm năng** trong repository mô phỏng, không phải số widget được tạo một lúc. `ListView.builder` chỉ đảm nhận lazy building; `fetchPage()` đảm nhận phân trang dữ liệu, hai kỹ thuật độc lập.

## Cấu trúc

```
lib/
  main.dart            # MaterialApp, NavigationBar, IndexedStack
  data.dart            # Model, bộ dữ liệu giả, Repository phân trang
  catalog_screen.dart  # List/Grid, tìm kiếm, tải thêm, Empty/Error/Loading
  demos_screen.dart    # Cuộn lồng, ListView thường, CustomScrollView và Slivers
test/
  repository_test.dart # Phân trang, lọc kết hợp, lỗi, tham số biên
  widget_test.dart     # Luồng giao diện, màn hình hẹp, bàn phím, hủy tác vụ
SLIDE_SNIPPETS.md      # Trích mã kèm lời phân tích để đưa lên slide
```

## Lưu ý giới hạn

- `fetchPage` dùng `Future.delayed` 350ms để mô phỏng độ trễ API, không gọi mạng thật.
- Khi chiều cao khả dụng dưới 400px (bàn phím hoặc màn hình ngang), thanh đầu rút gọn
  còn ô tìm kiếm; danh mục và chọn kích thước dữ liệu xuất hiện lại khi đủ chỗ.
- Tải thêm cũng kiểm tra sau khi đổi List/Grid hoặc thay đổi kích thước viewport,
  để lấp đầy màn hình lớn mà không cần kéo trước.
- Demo mô phỏng lỗi tải bằng nút **Thử lỗi**, phù hợp thuyết trình về state.
- Không có thông số FPS/latency đo sẵn; hãy đo bằng DevTools trên phần cứng thực tế.
- `shrinkWrap` chỉ dùng với danh sách 6 phần tử trên màn Nested; không áp dụng cho 10.000 mục.
