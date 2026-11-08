import 'package:flutter/material.dart';
import 'data.dart';

/// Demo cuộn lồng: cuộn dọc bên ngoài, cuộn ngang bên trong.
/// Chỉ dùng shrinkWrap cho danh sách rất ngắn (6 phần tử).
class NestedDemoScreen extends StatelessWidget {
  const NestedDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = BookRepository();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cuộn lồng nhau',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
              'Cuộn dọc trang, sau đó vuốt ngang dải danh mục bên dưới.'),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length - 1,
              itemBuilder: (context, index) => Container(
                width: 155,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder, size: 36, color: Colors.teal),
                      const SizedBox(height: 8),
                      Text(categories[index + 1], textAlign: TextAlign.center),
                    ]),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Danh sách ngắn: ListView(children)',
              style: Theme.of(context).textTheme.titleMedium),
          const Text(
              'shrinkWrap + NeverScrollableScrollPhysics: cha cuộn dọc.'),
          const SizedBox(height: 8),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(6, (index) {
              final book = repository.bookAt(index);
              return Card(
                  child: ListTile(
                leading: const Icon(Icons.book),
                title: Text(book.title),
                subtitle: Text(book.description),
              ));
            }),
          ),
          const SizedBox(height: 12),
          const Text(
              'Lưu ý: Không dùng cách lồng shrinkWrap này cho 10.000 phần tử. '
              'Hãy chuyển sang CustomScrollView + Slivers ở tab bên cạnh.'),
        ],
      ),
    );
  }
}

/// Trộn header, lưới và danh sách trong MỘT vùng cuộn để tránh
/// hai vùng cuộn dọc độc lập tranh chấp gesture và layout.
class SliverDemoScreen extends StatelessWidget {
  const SliverDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = BookRepository();
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('CustomScrollView'),
            background: ColoredBox(color: Color(0xffb2dfdb)),
          ),
        ),
        const SliverToBoxAdapter(
            child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('SliverGrid (12 mục) + SliverList (100 mục) '
              'cùng sử dụng một viewport.'),
        )),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverLayoutBuilder(builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final columns = width >= 850 ? 4 : (width >= 520 ? 3 : 2);
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 110,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => Card(
                    child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_stories, color: Colors.teal),
                    Text('Sách ${index + 1}'),
                  ]),
                )),
                childCount: 12,
              ),
            );
          }),
        ),
        const SliverToBoxAdapter(
            child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Danh sách SliverList bên dưới'),
        )),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = repo.bookAt(index + 100);
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(book.title),
                subtitle: Text(book.description),
              );
            },
            childCount: 100,
          ),
        ),
      ],
    );
  }
}
