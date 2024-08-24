import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerPage extends StatefulWidget {
  final String videoId;
  final String apiUrl;

  const YouTubePlayerPage({
    Key? key,
    required this.videoId,
    required this.apiUrl,
  }) : super(key: key);

  @override
  _YouTubePlayerPageState createState() => _YouTubePlayerPageState();
}

class _YouTubePlayerPageState extends State<YouTubePlayerPage> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isFullScreen = _controller.value.isFullScreen;
    _updateSystemOverlays();
  }

  void _updateSystemOverlays() {
    SystemChrome.setEnabledSystemUIMode(
      _isFullScreen ? SystemUiMode.immersive : SystemUiMode.edgeToEdge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                progressColors: ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
                aspectRatio:
                    orientation == Orientation.portrait ? 16 / 9 : 16 / 9,
                onReady: () {
                  _controller.addListener(_listener);
                },
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    player,
                    if (!_isFullScreen) _buildControls(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isPlaying ? _controller.pause() : _controller.play();
                _isPlaying = !_isPlaying;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.skip_previous),
            color: Colors.white,
            onPressed: () => _controller.seekTo(Duration.zero),
          ),
          IconButton(
            icon: Icon(Icons.skip_next),
            color: Colors.white,
            onPressed: () => _controller.seekTo(_controller.metadata.duration),
          ),
          IconButton(
            icon:
                Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            color: Colors.white,
            onPressed: () => _controller.toggleFullScreenMode(),
          ),
        ],
      ),
    );
  }

  void _listener() {
    setState(() {
      _isFullScreen = _controller.value.isFullScreen;
      _isPlaying = _controller.value.isPlaying;
      _updateSystemOverlays();
    });
  }
}
