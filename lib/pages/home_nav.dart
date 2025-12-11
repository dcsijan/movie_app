import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'home_trending_page.dart';
import 'search_watch_page.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _index = 1;

  final List<Widget> _pages = const [
    ProfilePage(),
    HomeTrendingPage(),
    SearchWatchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          iconTheme: const IconThemeData(size: 18),
        ),
        child: SizedBox(
          height: 52,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: const Color(0xFF121212),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            selectedFontSize: 10,
            unselectedFontSize: 9,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              BottomNavigationBarItem(icon: Icon(Icons.local_movies), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            ],
          ),
        ),
      ),
    );
  }
}
