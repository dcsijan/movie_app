import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/app_ui.dart';
import 'movie_player.dart';
import 'movie_link.dart';
import 'search_service.dart';

class SearchWatchPage extends StatefulWidget {
  const SearchWatchPage({super.key});

  @override
  State<SearchWatchPage> createState() => _SearchWatchPageState();
}

class _SearchWatchPageState extends State<SearchWatchPage> {
  List<Map<String, dynamic>> _movies = [];

  bool _isSearching = false;
  String? _errorMessage;

  Timer? _debounce;

  String? _selectedUrl;
  bool _isUrlLoading = false;

  final GlobalKey<MoviePlayerState> _playerKey = GlobalKey<MoviePlayerState>();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ---------- SEARCH ----------

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMovies(text.trim());
    });
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _movies = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final moviesData = await TMDB(query);
      if (!mounted) return;
      setState(() {
        _movies = moviesData;
        if (_movies.isEmpty) {
          _errorMessage = 'No movies found for “$query”.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Try again.');
    } finally {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  // ---------- STREAM ----------

  Future<void> _onMovieTap(Map<String, dynamic> movie) async {
    try {
      setState(() {
        _errorMessage = null;
        _isUrlLoading = true;
        _selectedUrl = null;
      });

      final code = movie['tmdb_code'];
      final url = await movie_ink(code);

      if (!mounted) return;

      if (url == null || url.isEmpty) {
        setState(() {
          _isUrlLoading = false;
          _errorMessage = 'Unable to load this stream.';
        });
        return;
      }

      setState(() {
        _selectedUrl = url;
        _isUrlLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUrlLoading = false;
        _errorMessage = 'Error loading stream. Try another movie.';
      });
    }
  }

  void _closePlayer() {
    setState(() => _selectedUrl = null);
  }

  bool get hasPlayer => _selectedUrl != null;

  // ---------- UI WIDGETS ----------

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for a movie...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _movieCard(Map<String, dynamic> movie) {
    final posterUrl = movie['poster_url'];
    final title = movie['movie_name'] ?? 'Unknown title';
    final code = movie['tmdb_code'].toString();
    final year = (movie['year'] ?? '').toString();

    return GestureDetector(
      onTap: () => _onMovieTap(movie),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: posterUrl != null
                  ? Image.network(
                      posterUrl,
                      width: 90,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 90,
                      height: 120,
                      color: Colors.black26,
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white54,
                        size: 30,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (year.isNotEmpty)
                          Text(
                            year,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        if (year.isNotEmpty) const SizedBox(width: 10),
                        Text(
                          'Code: $code',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          size: 18,
                          color: Colors.greenAccent.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to play',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyContent() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Start typing to search for movies.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _movies.length,
      itemBuilder: (context, index) => _movieCard(_movies[index]),
    );
  }

  Widget _buildPlayer({
    EdgeInsets padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  }) {
    if (_selectedUrl == null) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: MoviePlayer(
        key: _playerKey,
        url: _selectedUrl!,
        onClose: _closePlayer,
      ),
    );
  }

  // ---------- LAYOUTS ----------

  Widget _portraitLayout() {
    return Stack(
      children: [
        appBackground(),
        Column(
          children: [
            const AppTopBar(title: 'Search Movies'),
            _searchBar(),
            Expanded(child: _bodyContent()),
            _buildPlayer(),
          ],
        ),
        if (_isUrlLoading && _selectedUrl == null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _landscapeLayout() {
    return Stack(
      children: [
        appBackground(),
        SafeArea(
          child: Column(
            children: [
              // Search bar at the top, full width
              _searchBar(),
              const SizedBox(height: 8),
              // Main content row
              Expanded(
                child: Row(
                  children: [
                    // LEFT: Player or "Select a movie..."
                    Expanded(
                      flex: 2,
                      child: hasPlayer
                          ? _buildPlayer(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 8, 16),
                            )
                          : Center(
                              child: Text(
                                'Select a movie to start playing.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),
                    // RIGHT: List or "Start typing..." text at same vertical level
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(8, 8, 16, 16),
                        child: _bodyContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isUrlLoading && _selectedUrl == null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final portrait = orientation == Orientation.portrait;
          return portrait ? _portraitLayout() : _landscapeLayout();
        },
      ),
    );
  }
}
