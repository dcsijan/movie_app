import 'package:flutter/material.dart';
import 'package:better_player_pro/better_player_pro.dart';

class MoviePlayer extends StatefulWidget {
  final String url;
  final VoidCallback? onClose;

  const MoviePlayer({
    super.key,
    required this.url,
    this.onClose,
  });

  @override
  State<MoviePlayer> createState() => MoviePlayerState();
}

//  👇 was: class _MoviePlayerState ...
class MoviePlayerState extends State<MoviePlayer> {
  BetterPlayerController? _controller;
  bool _isBuffering = true;

  void Function(BetterPlayerEvent)? _listener;

  @override
  void initState() {
    super.initState();
    _initController(widget.url);
  }

  @override
  void didUpdateWidget(covariant MoviePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _disposeController();
      _initController(widget.url);
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    if (_controller != null && _listener != null) {
      _controller!.removeEventsListener(_listener!);
    }
    _listener = null;
    _controller?.dispose();
    _controller = null;
  }

  void _initController(String url) {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
    );

    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enablePlayPause: true,
          enableProgressBar: true,
          enableProgressText: true,
          enableFullscreen: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    _listener = (event) {
      if (!mounted) return;
      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.initialized:
        case BetterPlayerEventType.play:
        case BetterPlayerEventType.bufferingEnd:
          setState(() => _isBuffering = false);
          break;
        case BetterPlayerEventType.bufferingStart:
          setState(() => _isBuffering = true);
          break;
        default:
          break;
      }
    };

    controller.addEventsListener(_listener!);

    setState(() {
      _controller = controller;
      _isBuffering = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              BetterPlayer(controller: _controller!),
              if (_isBuffering)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
