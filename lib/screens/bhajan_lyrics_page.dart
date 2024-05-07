import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share/share.dart';

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

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
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
    Share.share('Check out this Bhajan Lyrics'); // Share message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.lyrics.length,
                  itemBuilder: (context, index) {
                    return Text(
                      widget.lyrics[index],
                      style: TextStyle(fontSize: _fontSize),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
