import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'demos_screen.dart';

void main() => runApp(const Topic5App());

class Topic5App extends StatelessWidget {
  const Topic5App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Topic 5 - Thư viện sách',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xfff6f8fa),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex, // duy trì state và vị trí cuộn giữa các tab
          children: const [
            CatalogScreen(),
            NestedDemoScreen(),
            SliverDemoScreen()
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.library_books), label: 'Thư viện'),
          NavigationDestination(
              icon: Icon(Icons.swap_vert), label: 'Cuộn lồng'),
          NavigationDestination(icon: Icon(Icons.view_agenda), label: 'Sliver'),
        ],
      ),
    );
  }
}
