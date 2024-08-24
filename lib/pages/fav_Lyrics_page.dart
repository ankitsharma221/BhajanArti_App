import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class FavoriteLyricsPage extends StatefulWidget {
  final String title;
  final List<String> lyrics;

  const FavoriteLyricsPage({
    Key? key,
    required this.title,
    required this.lyrics,
  }) : super(key: key);

  @override
  _FavoriteLyricsPageState createState() => _FavoriteLyricsPageState();
}

class _FavoriteLyricsPageState extends State<FavoriteLyricsPage> {
  double _fontSize = 16.0;
  ScrollController _scrollController = ScrollController();

  void _adjustFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(12.0, 32.0);
    });
  }

  void _shareLyrics() {
    String lyrics = widget.lyrics.join('\n');
    String appLink =
        'https://yourapp.link'; // Replace with your actual app link
    Share.share(
        '${widget.title}\n\n$lyrics\n\nCheck out this Bhajan on our app: $appLink');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.orange[400],
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareLyrics,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFontSizeControls(),
          Expanded(
            child: _buildLyricsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () => _adjustFontSize(-2.0),
          ),
          Text('Font Size', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _adjustFontSize(2.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsView() {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _fontSize = (_fontSize * details.scale).clamp(12.0, 32.0);
        });
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.0),
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
    );
  }
}
