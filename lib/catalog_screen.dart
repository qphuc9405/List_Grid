import 'dart:async';

import 'package:flutter/material.dart';
import 'data.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _repository = BookRepository();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  static const _pageSize = 30;

  List<Book> _books = [];
  int _total = 1000;
  String _category = 'Tất cả';
  String _query = '';
  bool _gridMode = false;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  bool _failNextRequest = false;
  int _requestGeneration = 0;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _requestGeneration++; // vô hiệu hóa kết quả Future cũ
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.positions.length != 1) return;
    if (_scrollController.position.extentAfter < 350 &&
        !_isLoading &&
        _hasMore &&
        _error == null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    final generation = _requestGeneration;
    final simulateError = _failNextRequest;
    _failNextRequest = false;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final page = await _repository.fetchPage(
        total: _total,
        offset: _books.length,
        limit: _pageSize,
        query: _query,
        category: _category,
        simulateError: simulateError,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _books = [..._books, ...page.items];
        _hasMore = page.hasMore;
        _isLoading = false;
      });
      _scheduleViewportCheck();
    } catch (e) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // Kiểm tra cả khi viewport lớn hoặc vừa chuyển sang Grid, chưa có thao tác cuộn.
  void _scheduleViewportCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScroll();
    });
  }

  void _reload({bool simulateError = false}) {
    _searchDebounce?.cancel();
    _failNextRequest = simulateError;
    _requestGeneration++; // kết quả tải cũ sẽ bị bỏ qua
    setState(() {
      _books = [];
      _hasMore = true;
      _isLoading = false;
      _error = null;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;
        final compact = constraints.maxHeight < 400;
        final columns = constraints.maxWidth >= 950 ? 4 : (isWide ? 3 : 2);
        return Column(
          children: [
            _header(constraints.maxWidth >= 900, compact: compact),
            if (!compact) _categoryChips(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text('Đã tải: ${_books.length} / $_total bản ghi mẫu',
                      style: Theme.of(context).textTheme.bodySmall),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: false,
                          icon: Icon(Icons.view_list),
                          label: Text('List')),
                      ButtonSegment(
                          value: true,
                          icon: Icon(Icons.grid_view),
                          label: Text('Grid')),
                    ],
                    selected: {_gridMode},
                    onSelectionChanged: (value) {
                      setState(() => _gridMode = value.first);
                      _scheduleViewportCheck();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
                child: NotificationListener<ScrollMetricsNotification>(
              onNotification: (_) {
                _scheduleViewportCheck();
                return false;
              },
              child: _content(columns),
            )),
          ],
        );
      },
    );
  }

  Widget _header(bool isWide, {required bool compact}) {
    final search = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Tìm tên sách hoặc danh mục',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Xóa tìm kiếm',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _query = '';
                  _reload();
                },
              ),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        _searchDebounce?.cancel();
        // Bỏ kết quả cũ ngay khi gõ, chỉ gửi truy vấn sau khi ngừng gõ.
        _requestGeneration++;
        setState(() {
          _query = value;
          _books = [];
          _isLoading = true;
          _error = null;
        });
        _searchDebounce = Timer(const Duration(milliseconds: 300), _reload);
      },
    );
    final controls = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dữ liệu:'),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _total,
              items: [20, 100, 1000, 10000]
                  .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                  .toList(),
              onChanged: (n) {
                if (n == null) return;
                _total = n;
                _reload();
              },
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            _reload(simulateError: true);
          },
          icon: const Icon(Icons.error_outline),
          label: const Text('Thử lỗi'),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact)
            Text('Thư viện sách điện tử',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          if (!compact) const SizedBox(height: 8),
          if (compact)
            search
          else if (isWide)
            Row(children: [
              Expanded(flex: 2, child: search),
              const SizedBox(width: 12),
              SizedBox(width: 310, child: controls)
            ])
          else ...[search, controls],
        ],
      ),
    );
  }

  Widget _categoryChips() {
    // Cuộn ngang: một trục khác với List/Grid cuộn dọc.
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final name = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(name),
              selected: _category == name,
              onSelected: (_) {
                _category = name;
                _reload();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _content(int columns) {
    if (_books.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_books.isEmpty && _error != null) return _errorView();
    if (_books.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.search_off, size: 56),
          const SizedBox(height: 8),
          const Text('Không tìm thấy sách phù hợp'),
          TextButton(
              onPressed: () {
                _searchController.clear();
                _query = '';
                _category = 'Tất cả';
                _reload();
              },
              child: const Text('Xóa bộ lọc')),
        ]),
      );
    }
    // Footer dùng thêm 1 ô nếu đang tải, lỗi hoặc còn trang mới.
    final showFooter = _isLoading || _error != null || _hasMore;
    final count = _books.length + (showFooter ? 1 : 0);
    if (_gridMode) {
      return GridView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        key: const PageStorageKey('grid'),
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 218,
        ),
        itemCount: count,
        itemBuilder: (context, index) =>
            index == _books.length ? _footer() : _bookGridCard(_books[index]),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      key: const PageStorageKey('list'),
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      // Không dùng itemExtent: mô tả sách có chiều cao biến đổi.
      itemCount: count,
      itemBuilder: (context, index) =>
          index == _books.length ? _footer() : _bookListCard(_books[index]),
    );
  }

  Widget _bookListCard(Book book) {
    return Card(
      key: ValueKey(book.id),
      child: ListTile(
        leading: CircleAvatar(child: Text('${book.id + 1}')),
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(book.category),
          Text(book.description), // dài/ngắn: tự đo chiều cao
        ]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openDetail(book),
      ),
    );
  }

  Widget _bookGridCard(Book book) {
    return Card(
      key: ValueKey(book.id),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetail(book),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book, size: 44, color: Colors.teal),
            )),
            const SizedBox(height: 6),
            Text(book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(book.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  Widget _footer() {
    if (_error != null) {
      return Center(
          child: TextButton.icon(
        onPressed: _loadMore,
        icon: const Icon(Icons.refresh),
        label: const Text('Lỗi tải trang. Nhấn để thử lại'),
      ));
    }
    if (_isLoading)
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    return Center(
        child: TextButton(
            onPressed: _loadMore, child: const Text('Tải thêm dữ liệu')));
  }

  Widget _errorView() => Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 52),
          const Text('Không thể tải dữ liệu (lỗi mô phỏng)'),
          FilledButton(onPressed: _loadMore, child: const Text('Thử lại'))
        ],
      ));

  void _openDetail(Book book) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Chi tiết sách')),
              // Một child là Column; SingleChildScrollView cho phép nội dung dài cuộn.
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.menu_book,
                          size: 100, color: Colors.teal.shade700),
                      const SizedBox(height: 16),
                      Text(book.title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      Text(
                          'Danh mục: ${book.category} | Đánh giá: ${book.rating}'),
                      const SizedBox(height: 20),
                      for (var i = 0; i < 12; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text('${i + 1}. ${book.description}'),
                        ),
                    ]),
              ),
            )));
  }
}
