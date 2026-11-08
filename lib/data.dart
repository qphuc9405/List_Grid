/// Dataset sinh tai may: khong can API, Internet hoac anh ngoai.
class Book {
  final int id;
  final String title;
  final String category;
  final String description;
  final double rating;

  const Book({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.rating,
  });
}

const categories = <String>[
  'Tất cả',
  'Lập trình',
  'Mạng máy tính',
  'Cơ sở dữ liệu',
  'Thiết kế UI',
];

class PageResult {
  final List<Book> items;
  final bool hasMore;
  const PageResult(this.items, this.hasMore);
}

class BookRepository {
  const BookRepository({this.latency = const Duration(milliseconds: 350)});

  /// Có thể đặt bằng Duration.zero khi kiểm thử, không cần chờ mạng giả lập.
  final Duration latency;

  static const _titles = <String>[
    'Flutter từ cơ bản đến nâng cao',
    'Clean Code và kỹ thuật lập trình',
    'Cấu trúc dữ liệu và giải thuật',
    'Mạng máy tính hiện đại',
    'Thiết kế giao diện người dùng',
    'Cơ sở dữ liệu ứng dụng',
    'Lập trình hướng đối tượng',
    'Kiến trúc phần mềm thực tế',
  ];

  Book bookAt(int id) {
    if (id < 0) throw RangeError.value(id, 'id', 'Phải không âm');
    final category = categories[1 + id % (categories.length - 1)];
    final longText = id % 3 == 0;
    return Book(
      id: id,
      title: '${_titles[id % _titles.length]} #${id + 1}',
      category: category,
      description: longText
          ? 'Tài liệu có mô tả dài: minh họa cách xử lý phần tử có chiều cao '
              'không đồng nhất, tự xuống dòng và tránh tràn chữ trên màn hình nhỏ.'
          : 'Tài liệu tham khảo cho sinh viên kỹ thuật máy tính.',
      rating: 3.5 + (id % 4) * 0.5,
    );
  }

  /// Pagination theo offset, không tạo toàn bộ Widget/Book cùng lúc.
  /// [total] là kích thước dataset mô phỏng: 20/100/1000/10000.
  Future<PageResult> fetchPage({
    required int total,
    required int offset,
    required int limit,
    required String query,
    required String category,
    bool simulateError = false,
  }) async {
    if (total < 0) throw RangeError.value(total, 'total', 'Phải không âm');
    if (offset < 0) throw RangeError.value(offset, 'offset', 'Phải không âm');
    if (limit <= 0) throw RangeError.value(limit, 'limit', 'Phải lớn hơn 0');
    await Future<void>.delayed(latency);
    if (simulateError) throw Exception('Lỗi mạng mô phỏng');

    final result = <Book>[];
    var skipped = 0;
    final keyword = query.trim().toLowerCase();
    for (var i = 0; i < total; i++) {
      final book = bookAt(i);
      if (category != 'Tất cả' && book.category != category) continue;
      if (keyword.isNotEmpty &&
          !book.title.toLowerCase().contains(keyword) &&
          !book.category.toLowerCase().contains(keyword)) {
        continue;
      }
      if (skipped < offset) {
        skipped++;
        continue;
      }
      result.add(book);
      if (result.length > limit) break; // thêm 1 để xác định hasMore
    }
    final hasMore = result.length > limit;
    if (hasMore) result.removeLast();
    return PageResult(result, hasMore);
  }
}
