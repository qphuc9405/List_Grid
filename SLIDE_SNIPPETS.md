# Mã nguồn trích dẫn đưa lên slide — Chủ đề 5

> Mã dưới đây trích từ project. Trong slide nên kèm ảnh chụp màn hình tương ứng và đánh dấu dòng quan trọng.

## Slide 1 — SingleChildScrollView: nội dung dài

```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    children: [
      Text(book.title),
      for (var i = 0; i < 12; i++) Text(book.description),
    ],
  ),
)
```

**Phân tích:** `SingleChildScrollView` chỉ nhận một `child`; `Column` cho phép có nhiều nội dung; phù hợp trang chi tiết, không dùng cho 10.000 hàng.

## Slide 2 — ListView thường

```dart
ListView(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  children: List.generate(6, (index) => ListTile(
    title: Text(repository.bookAt(index).title),
  )),
)
```

**Phân tích:** Danh sách ngắn được cung cấp sẵn; cha `SingleChildScrollView` chịu trách nhiệm cuộn dọc. `shrinkWrap` gây thêm chi phí bố cục nếu dữ liệu dài.

## Slide 3 — ListView.builder: lazy building

```dart
ListView.builder(
  controller: _scrollController,
  itemCount: _books.length,
  itemBuilder: (context, index) => _bookListCard(_books[index]),
)
```

**Phân tích:** Flutter gọi `itemBuilder` theo nhu cầu của viewport; khác với `ListView(children)` vì không cung cấp sẵn toàn bộ widget.

## Slide 4 — GridView.builder: lưới responsive

```dart
final columns = width >= 950 ? 4 : (width >= 650 ? 3 : 2);
GridView.builder(
  itemCount: _books.length,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    mainAxisExtent: 218,
  ),
  itemBuilder: (context, index) => _bookGridCard(_books[index]),
)
```

**Phân tích:** Cùng tập dữ liệu, thay đổi số cột theo `LayoutBuilder`, giữ số ô được dựng vừa đủ theo viewport.

## Slide 5 — Cuộn lồng 2 hướng

```dart
SingleChildScrollView(
  child: Column(children: [
    SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length - 1,
        itemBuilder: (context, i) => categoryTile(i),
      ),
    ),
    shortNonScrollableList,
  ]),
)
```

**Phân tích:** Cha cuộn dọc; con cuộn ngang; `SizedBox` cấp chiều cao hữu hạn; danh sách ngắn cùng chiều cuộn dọc phải vô hiệu thao tác cuộn riêng.

## Slide 6 — Lazy Data Loading và phân trang

```dart
void _onScroll() {
  if (!_scrollController.hasClients) return;
  if (_scrollController.position.extentAfter < 350 &&
      !_isLoading && _hasMore && _error == null) {
    _loadMore();
  }
}

final page = await _repository.fetchPage(
  total: _total,
  offset: _books.length,
  limit: 30,
  query: _query,
  category: _category,
);
```

**Phân tích:** Khi còn dưới 350 px tới cuối, tải thêm 30 bản ghi. `_isLoading` chống gửi request trùng; `_hasMore` đánh dấu hết dữ liệu. Lazy Data Loading **không đồng nghĩa** Lazy Building.

## Slide 7 — Danh sách rỗng và lỗi tải

```dart
if (_books.isEmpty && _isLoading) {
  return const Center(child: CircularProgressIndicator());
}
if (_books.isEmpty && _error != null) return _errorView();
if (_books.isEmpty) return emptyState;
```

**Phân tích:** Tách trạng thái Loading / Error / Empty / Success để tránh hiển thị màn trắng hoặc báo “trống” khi chưa tải xong.

## Slide 8 — CustomScrollView và Slivers

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(pinned: true, expandedHeight: 150),
    SliverToBoxAdapter(child: Text('Danh sách và lưới')),
    SliverGrid(delegate: gridDelegate, gridDelegate: layout),
    SliverList(delegate: listDelegate),
  ],
)
```

**Phân tích:** Nhiều kiểu nội dung ghép trong một viewport dọc, tránh phải lồng nhiều scroll view dọc độc lập. `gridDelegate`, `layout`, `listDelegate` đại diện các delegate đã cấu hình trong file `demos_screen.dart`.

## Slide 9 — Dữ liệu dài và kích thước không đều

```dart
ListView.builder(
  itemCount: _books.length,
  itemBuilder: (context, index) => ListTile(
    title: Text(_books[index].title),
    subtitle: Text(_books[index].description),
  ),
)
```

**Phân tích:** Không ép `itemExtent` khi nội dung có nhiều chiều cao khác nhau. Lưới dùng `mainAxisExtent` cố định kết hợp `maxLines` + `ellipsis` để tránh tràn.

## Slide 10 — Kịch bản đo và kết luận

- Chạy Profile Mode; so sánh 20 / 1.000 / 10.000 bản ghi.
- Đo frame time, bộ nhớ và số lần build khi cuộn.
- Không khẳng định `builder` luôn nhanh hơn trong mọi trường hợp; hiệu quả phụ thuộc độ phức tạp item và cách quản lý dữ liệu.
- Mọi kết quả FPS trong slide cần lấy từ Flutter DevTools, không tự ước lượng.
