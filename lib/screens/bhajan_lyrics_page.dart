import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';

class BhajanLyricsPage extends StatefulWidget {
  final String title;
  final List<dynamic> lyrics;

  const BhajanLyricsPage({
    Key? key,
    required this.title,
    required this.lyrics,
  }) : super(key: key);

  @override
  _BhajanLyricsPageState createState() => _BhajanLyricsPageState();
}

class _BhajanLyricsPageState extends State<BhajanLyricsPage> {
  double _fontSize = 16.0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Initialize favorite status based on bloc state
    _updateFavoriteStatus();
  }

  void _updateFavoriteStatus() {
    final bhajanListBloc = BlocProvider.of<BhajanListBloc>(context);
    if (bhajanListBloc.state is BhajanListLoaded) {
      final favorites = (bhajanListBloc.state as BhajanListLoaded).favorites;
      setState(() {
        _isFavorite = favorites.contains(widget.title);
      });
    }
  }

  void _toggleFavorite() {
    final bhajanListBloc = BlocProvider.of<BhajanListBloc>(context);
    final isCurrentlyFavorite = _isFavorite;
    setState(() {
      _isFavorite = !isCurrentlyFavorite;
    });

    // Dispatch an event to toggle the favorite status in the bloc
    bhajanListBloc.add(ToggleFavorite(widget.title));
  }

  void _zoomIn() {
    setState(() {
      _fontSize = (_fontSize + 2.0).clamp(16.0, 50.0); // Increase font size
    });
  }

  void _zoomOut() {
    setState(() {
      _fontSize = (_fontSize - 2.0).clamp(16.0, 50.0); // Decrease font size
    });
  }

  void _shareLyrics() {
    String lyrics = widget.lyrics.join('\n');
    String appLink =
        'https://yourapp.link'; // Replace with your actual app link
    Share.share('$lyrics\n\nCheck out this Bhajan on our app: $appLink');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BhajanListBloc, BhajanListState>(
      listener: (context, state) {
        if (state is BhajanListLoaded) {
          _updateFavoriteStatus();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.amber, // App bar color
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ), // Padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // Align icons
                  children: [
                    IconButton(
                      icon: Icon(Icons.zoom_out),
                      onPressed: _zoomOut,
                      iconSize: MediaQuery.of(context).size.width /
                          11, // Adjust icon size
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      onPressed: _toggleFavorite,
                      iconSize: MediaQuery.of(context).size.width /
                          11, // Adjust icon size
                    ),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: _shareLyrics,
                      iconSize: MediaQuery.of(context).size.width /
                          11, // Adjust icon size
                    ),
                    IconButton(
                      icon: Icon(Icons.zoom_in),
                      onPressed: _zoomIn,
                      iconSize: MediaQuery.of(context).size.width /
                          11, // Adjust icon size
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    setState(() {
                      _fontSize = 16.0 * details.scale.clamp(0.5, 5.0);
                    });
                  },
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.lyrics.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            widget.lyrics[index],
                            style: TextStyle(fontSize: _fontSize),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
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
