import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topic5_library/main.dart';

void main() {
  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(const Topic5App());
    await tester.pumpAndSettle();
  }

  testWidgets('Có ba tab, giữ tìm kiếm và vị trí cuộn khi chuyển tab',
      (tester) async {
    await openApp(tester);
    expect(find.text('Thư viện sách điện tử'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.drag(
        find.byKey(const PageStorageKey('list')), const Offset(0, -600));
    await tester.pumpAndSettle();
    final controller = tester
        .widget<ListView>(find.byKey(const PageStorageKey('list')))
        .controller!;
    final offset = controller.offset;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('Cuộn lồng'));
    await tester.pumpAndSettle();
    expect(find.text('Cuộn lồng nhau'), findsOneWidget);
    await tester.tap(find.text('Sliver'));
    await tester.pumpAndSettle();
    expect(find.text('CustomScrollView'), findsOneWidget);
    await tester.tap(find.text('Thư viện'));
    await tester.pumpAndSettle();
    expect(controller.offset, offset);
  });

  testWidgets('Tìm kiếm rỗng và xóa bộ lọc', (tester) async {
    await openApp(tester);
    await tester.enterText(find.byType(TextField), 'khong-co-sach-nay');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy sách phù hợp'), findsOneWidget);
    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pumpAndSettle();
    expect(find.text('Đã tải: 30 / 1000 bản ghi mẫu'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
  });

  testWidgets('Truy vấn mới bỏ qua kết quả tải cũ', (tester) async {
    await openApp(tester);
    await tester.enterText(find.byType(TextField), 'Flutter');
    await tester.pump(const Duration(milliseconds: 310));
    await tester.enterText(find.byType(TextField), 'khong-co-sach-nay');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy sách phù hợp'), findsOneWidget);
    expect(find.textContaining('Flutter từ cơ bản'), findsNothing);
    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pumpAndSettle();
    expect(find.text('Đã tải: 30 / 1000 bản ghi mẫu'), findsOneWidget);
  });

  testWidgets('Hiển thị lỗi và thử lại thành công', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Thử lỗi'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải dữ liệu (lỗi mô phỏng)'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Đã tải: 30 / 1000 bản ghi mẫu'), findsOneWidget);
  });

  testWidgets('Chuyển Grid, mở chi tiết và quay lại', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();
    expect(find.byKey(const PageStorageKey('grid')), findsOneWidget);
    await tester.tap(find.text('Flutter từ cơ bản đến nâng cao #1'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết sách'), findsOneWidget);
    expect(find.textContaining('Đánh giá: 3.5'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const PageStorageKey('grid')), findsOneWidget);
  });

  testWidgets('Cuộn tự tải trang tiếp theo', (tester) async {
    await openApp(tester);
    final controller = tester
        .widget<ListView>(find.byKey(const PageStorageKey('list')))
        .controller!;
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Đã tải: 60 / 1000 bản ghi mẫu'), findsOneWidget);
    // Dừng hiệu chỉnh vị trí cuộn và đợi request tiền tải còn lại hoàn tất.
    controller.jumpTo(0);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  });

  testWidgets('Đổi kích thước dữ liệu và lọc danh mục', (tester) async {
    await openApp(tester);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20').last);
    await tester.pumpAndSettle();
    expect(find.text('Đã tải: 20 / 20 bản ghi mẫu'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Lập trình'));
    await tester.pumpAndSettle();
    expect(find.text('Đã tải: 5 / 20 bản ghi mẫu'), findsOneWidget);
  });

  for (final size in [
    const Size(320, 640),
    const Size(700, 800),
    const Size(1000, 800),
    const Size(640, 300)
  ]) {
    testWidgets('Bố cục List/Grid không tràn ở $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await openApp(tester);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Màn hình nhỏ khi mở bàn phím không tràn', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await openApp(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hủy màn hình khi đang tìm kiếm không để lại timer',
      (tester) async {
    await openApp(tester);
    await tester.enterText(find.byType(TextField), 'Flutter');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
