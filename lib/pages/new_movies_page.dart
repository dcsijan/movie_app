import 'package:flutter/material.dart';
import '../widgets/app_ui.dart';

class NewMoviesPage extends StatefulWidget {
  const NewMoviesPage({super.key});

  @override
  State<NewMoviesPage> createState() => _NewMoviesPageState();
}

class _NewMoviesPageState extends State<NewMoviesPage> {
  bool loading = true;
  List movies = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await Future.delayed(const Duration(seconds: 1)); // TODO fetch real TMDB
    setState(() {
      movies = [
        {'title': 'New Movie', 'poster': null},
        {'title': 'Trending Action', 'poster': null},
      ];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        appBackground(),
        Column(
          children: const [
            const AppTopBar(title: "Trending"),
AppSearchBar(hintText: "Search Disabled on Home", enabled: false),

          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 140),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 0.6),
                  itemCount: movies.length,
                  itemBuilder: (_, i) => Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.movie,
                        color: Colors.white70, size: 40),
                  ),
                ),
        ),
      ],
    );
  }
}
