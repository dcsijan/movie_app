import 'package:flutter/material.dart';
import '../widgets/app_ui.dart';
import 'movie_player.dart';
import 'movie_link.dart';
import 'tmdb_trending.dart';

class HomeTrendingPage extends StatefulWidget {
  const HomeTrendingPage({super.key});

  @override
  State<HomeTrendingPage> createState() => _HomeTrendingPageState();
}

class _HomeTrendingPageState extends State<HomeTrendingPage> {
  List<Map<String, dynamic>> _trending = [];
  List<Map<String, dynamic>> _popular = [];
  List<Map<String, dynamic>> _topRated = [];

  bool _loading = true;
  String? _error;

  String? _selectedUrl;
  bool _loadingUrl = false;
  final GlobalKey<MoviePlayerState> _playerKey = GlobalKey<MoviePlayerState>();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        fetchTrendingMovies(),
        fetchPopularMovies(),
        fetchTopRatedMovies(),
      ]);

      if (!mounted) return;
      setState(() {
        _trending = results[0];
        _popular = results[1];
        _topRated = results[2];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load movies';
      });
    }
  }

  Future<void> _onMovieTap(Map<String, dynamic> movie) async {
    try {
      setState(() {
        _selectedUrl = null;
        _loadingUrl = true;
      });

      final code = movie['tmdb_code'];
      final url = await movie_ink(code);

      if (!mounted) return;
      setState(() {
        _selectedUrl = url;
        _loadingUrl = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingUrl = false);
    }
  }

  void _closePlayer() {
    setState(() => _selectedUrl = null);
  }

  // ---------- HORIZONTAL SECTION (PORTRAIT) ----------

  Widget _buildHorizontalSection(
    String title,
    List<Map<String, dynamic>> movies,
  ) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.swipe, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 12, right: 24),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final poster = movie['poster_url'];
              final name = movie['movie_name'] ?? '';
              final year = (movie['year'] ?? '').toString();

              return GestureDetector(
                onTap: () => _onMovieTap(movie),
                child: Container(
                  width: 115,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (poster != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            poster,
                            height: 115,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Icon(Icons.movie,
                              size: 38, color: Colors.white70),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      if (year.isNotEmpty)
                        Text(
                          year,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 9,
                          ),
                        ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap to play',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  // ---------- MINI GRID (LANDSCAPE) ----------

Widget _buildMiniScrollSection(String title, List<Map<String, dynamic>> movies) {
  if (movies.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      SizedBox(
        height: 135, // 🔥 smaller than before (less height)
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(right: 12),
          itemCount: movies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final movie = movies[index];
            final poster = movie['poster_url'];
            final name = movie['movie_name'] ?? '';

            return GestureDetector(
              onTap: () => _onMovieTap(movie),
              child: Container(
                width: 85, // 🎯 SMALLER width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.06),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      poster != null
                          ? Image.network(
                              poster,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.black38,
                              child: const Icon(Icons.movie,
                                  color: Colors.white70, size: 24),
                            ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: const Text(
                            'Play',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

  // ---------- PORTRAIT ----------

  Widget _buildPortraitLayout() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 35),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHorizontalSection('Trending Today', _trending),
                _buildHorizontalSection('Popular Movies', _popular),
                _buildHorizontalSection('Top Rated (Old)', _topRated),
              ],
            ),
          ),
        ),
        if (_selectedUrl != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: MoviePlayer(
              key: _playerKey,
              url: _selectedUrl!,
              onClose: _closePlayer,
            ),
          ),
      ],
    );
  }

  // ---------- LANDSCAPE ----------

  Widget _buildLandscapeLayout() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.white70)),
      );
    }

    return Row(
      children: [
        // 🎬 BIG PLAYER SIDE
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: _selectedUrl != null
                ? MoviePlayer(
                    key: _playerKey,
                    url: _selectedUrl!,
                    onClose: _closePlayer,
                  )
                : Center(
                    child: Text(
                      'Tap a movie to play',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ),

        // 🎞 MINI GRID LIST
        Expanded(
  flex: 2,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(0, 16, 8, 16),
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMiniScrollSection('Trending Today', _trending),
          _buildMiniScrollSection('Popular Movies', _popular),
          _buildMiniScrollSection('Top Rated (Old)', _topRated),
        ],
      ),
    ),
  ),
),

      ],
    );
  }

  // ----------- MAIN BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        appBackground(),
        OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitLayout()
                : _buildLandscapeLayout();
          },
        ),

        if (_loadingUrl && _selectedUrl == null)
          Container(
            color: Colors.black38,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
