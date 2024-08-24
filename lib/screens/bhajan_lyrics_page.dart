import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';

class BhajanLyricsPage extends StatefulWidget {
  final String title;
  final List<String> lyrics;

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
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateFavoriteStatus();
  }

  void _updateFavoriteStatus() {
    final bhajanListBloc = BlocProvider.of<BhajanListBloc>(context);
    if (bhajanListBloc.state is BhajanListLoaded) {
      final favorites = (bhajanListBloc.state as BhajanListLoaded).favorites;
      setState(() {
        _isFavorite = favorites.any((fav) =>
            fav['title'] == widget.title &&
            listEquals(fav['lyrics'] as List<String>, widget.lyrics));
      });
    }
  }

  void _toggleFavorite() {
    final bhajanListBloc = BlocProvider.of<BhajanListBloc>(context);
    bhajanListBloc.add(ToggleFavorite(widget.title, widget.lyrics));
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _adjustFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(12.0, 32.0);
    });
  }

  void _shareLyrics() {
    String lyrics = widget.lyrics.join('\n');
    String appLink =
        'https://play.google.com/store/apps/details?id=com.devgenix.bhajanarti'; // Replace with your actual app link
    Share.share(
        '${widget.title}\n\n$lyrics\n\nहमारे ऐप पर और भी भजन देखें और डाउनलोड करें ➡️: $appLink');
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
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.orange[400],
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: _toggleFavorite,
            ),
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

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
