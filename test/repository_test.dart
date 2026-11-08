import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topic5_library/data.dart';

void main() {
  const repository = BookRepository(latency: Duration.zero);

  Future<PageResult> fetch({
    int total = 100,
    int offset = 0,
    int limit = 30,
    String query = '',
    String category = 'Tất cả',
    bool simulateError = false,
  }) =>
      repository.fetchPage(
        total: total,
        offset: offset,
        limit: limit,
        query: query,
        category: category,
        simulateError: simulateError,
      );

  test('Các trang không trùng hoặc bỏ sót sách, trang cuối hết dữ liệu',
      () async {
    final ids = <int>[];
    var hasMore = true;
    while (hasMore) {
      final page = await fetch(offset: ids.length);
      ids.addAll(page.items.map((book) => book.id));
      hasMore = page.hasMore;
    }
    expect(ids, List.generate(100, (index) => index));
  });

  test('Dataset nhỏ, rỗng và offset vượt cuối', () async {
    final small = await fetch(total: 20);
    expect(small.items, hasLength(20));
    expect(small.hasMore, isFalse);
    for (final page in [await fetch(total: 0), await fetch(offset: 100)]) {
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    }
    final exact = await fetch(total: 30);
    expect(exact.items, hasLength(30));
    expect(exact.hasMore, isFalse);
  });

  test('Tìm kiếm bỏ khoảng trắng, không phân biệt hoa thường', () async {
    final page = await fetch(query: '  FLUTTER  ');
    expect(page.items, isNotEmpty);
    expect(page.items.every((book) => book.title.contains('Flutter')), isTrue);
    expect((await fetch(query: 'khong-co-sach-nay')).items, isEmpty);
  });

  test('Phân trang tính offset sau khi lọc kết hợp tên và danh mục', () async {
    final expected = List.generate(100, repository.bookAt)
        .where((book) =>
            book.category == 'Lập trình' &&
            book.title.toLowerCase().contains('flutter'))
        .map((book) => book.id)
        .toList();
    final ids = <int>[];
    var hasMore = true;
    while (hasMore) {
      final page = await fetch(
        category: 'Lập trình',
        query: 'flutter',
        offset: ids.length,
        limit: 3,
      );
      ids.addAll(page.items.map((book) => book.id));
      hasMore = page.hasMore;
    }
    expect(ids, expected);
    final byCategory = await fetch(category: 'Mạng máy tính');
    expect(byCategory.items, isNotEmpty);
    expect(byCategory.items.every((book) => book.category == 'Mạng máy tính'),
        isTrue);
  });

  test('Lỗi giả lập không làm hỏng lần tải tiếp theo', () async {
    await expectLater(fetch(simulateError: true), throwsException);
    expect((await fetch()).items, hasLength(30));
  });

  test('Từ chối tham số phân trang không hợp lệ', () async {
    await expectLater(fetch(total: -1), throwsRangeError);
    await expectLater(fetch(offset: -1), throwsRangeError);
    await expectLater(fetch(limit: 0), throwsRangeError);
    await expectLater(fetch(limit: -1), throwsRangeError);
    expect(() => repository.bookAt(-1), throwsRangeError);
  });

  test('Dữ liệu xác định, mô tả có chiều cao khác nhau, đánh giá hợp lệ', () {
    expect(repository.bookAt(0).title, repository.bookAt(0).title);
    expect(repository.bookAt(0).description.length,
        greaterThan(repository.bookAt(1).description.length));
    for (var id = 0; id < 100; id++) {
      final book = repository.bookAt(id);
      expect(book.id, id);
      expect(categories, contains(book.category));
      expect(book.rating, inInclusiveRange(0, 5));
    }
  });
}
