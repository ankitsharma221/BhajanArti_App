import 'package:bhajan_arti/pages/youtubePlayer_page.dart';
import 'package:bhajan_arti/screens/bhajan_lyrics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BhajanTitlePage extends StatefulWidget {
  final String title;
  final String apiUrl;
  final String youtubePlaylistUrl;

  const BhajanTitlePage({
    Key? key,
    required this.title,
    required this.apiUrl,
    required this.youtubePlaylistUrl,
  }) : super(key: key);

  @override
  _BhajanTitlePageState createState() => _BhajanTitlePageState();
}

class _BhajanTitlePageState extends State<BhajanTitlePage> {
  String _searchText = "";
  List<Map<String, dynamic>> _youtubeVideos = [];
  List<Map<String, dynamic>> _allBhajans = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<BhajanListBloc>(context).add(FetchBhajans(widget.apiUrl));
    _fetchYouTubeVideos();
  }

  Future<void> _fetchYouTubeVideos() async {
    try {
      final response = await http.get(Uri.parse(widget.youtubePlaylistUrl));
      if (response.statusCode == 200) {
        setState(() {
          _youtubeVideos =
              json.decode(response.body)['items'].cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception(
            'Failed to load YouTube videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching YouTube videos: $e');
      // Handle error: show a snackbar, retry mechanism, or any appropriate action
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange[300],
          title: Text(
            widget.title,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, size: 40),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: DataSearch(
                    setSearchText: setSearchText,
                    allBhajans: _allBhajans,
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Bhajans"),
              Tab(text: "YouTube Videos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBhajanList(),
            _buildYouTubeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBhajanList() {
    return BlocBuilder<BhajanListBloc, BhajanListState>(
      builder: (context, state) {
        if (state is BhajanListInitial) {
          // Trigger loading on initial state
          BlocProvider.of<BhajanListBloc>(context)
              .add(FetchBhajans(widget.apiUrl));
        }

        if (state is BhajanListLoading || state is BhajanListInitial) {
          return ListView.builder(
            itemCount: 10, // Show 10 placeholder tiles
            itemBuilder: (context, index) {
              return _buildLoadingTile();
            },
          );
        } else if (state is BhajanListLoaded) {
          _allBhajans = state.data
              .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
          var filteredData = _allBhajans
              .where(
                (item) => item['title']
                    .toLowerCase()
                    .contains(_searchText.toLowerCase()),
              )
              .toList();

          return ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final bhajan = filteredData[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BhajanLyricsPage(
                        title: bhajan['title'] as String,
                        lyrics:
                            (bhajan['lyrics'] as List<dynamic>).cast<String>(),
                      ),
                    ),
                  );
                },
                child: BhajanListItem(
                  title: bhajan['title'] as String,
                  isFavorite: bhajan['isFavorite'] ?? false,
                  onTapFavorite: () {
                    BlocProvider.of<BhajanListBloc>(context).add(
                      ToggleFavorite(
                        bhajan['title'] as String,
                        (bhajan['lyrics'] as List<dynamic>).cast<String>(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return Center(child: Text('Unexpected state'));
      },
    );
  }

  Widget _buildLoadingTile() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 10,
      child: ListTile(
        tileColor: Color.fromARGB(255, 255, 244, 244),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: ShimmerLoading(
          child: Container(
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
        title: ShimmerLoading(
          child: Container(
            height: 16,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
        trailing: ShimmerLoading(
          child: Container(
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildYouTubeList() {
    if (_youtubeVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFoldingCube(
              color: Colors.orange,
              size: 50.0,
            ),
            SizedBox(height: 20),
            Text(
              "Loading YouTube videos",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _youtubeVideos.length,
      itemBuilder: (context, index) {
        final video = _youtubeVideos[index]['snippet'];
        final contentDetails = _youtubeVideos[index]['contentDetails'];
        final videoId =
            contentDetails != null ? contentDetails['videoId'] : null;

        if (videoId == null) {
          return SizedBox.shrink();
        }

        return YouTubeVideoItem(
          video: video as Map<String, dynamic>,
          videoId: videoId as String,
          youtubePlaylistUrl: widget.youtubePlaylistUrl,
        );
      },
    );
  }

  void setSearchText(String searchText) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _searchText = searchText;
      });
    });
  }
}

class YouTubeVideoItem extends StatefulWidget {
  final Map<String, dynamic> video;
  final String videoId;
  final String youtubePlaylistUrl;

  const YouTubeVideoItem({
    Key? key,
    required this.video,
    required this.videoId,
    required this.youtubePlaylistUrl,
  }) : super(key: key);

  @override
  _YouTubeVideoItemState createState() => _YouTubeVideoItemState();
}

class _YouTubeVideoItemState extends State<YouTubeVideoItem> {
  bool _isLoading = false;

  void _navigateToVideoPlayer() {
    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YouTubePlayerPage(
          videoId: widget.videoId,
          apiUrl: widget.youtubePlaylistUrl,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToVideoPlayer,
      child: Stack(
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl:
                        widget.video['thumbnails']['medium']['url'] as String,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    widget.video['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: SpinKitFoldingCube(
                    color: Colors.orange,
                    size: 50.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final Function(String) setSearchText;
  final List<Map<String, dynamic>> allBhajans;

  DataSearch({required this.setSearchText, required this.allBhajans});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
  }

  @override
  String get searchFieldLabel => 'Search bhajans...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          setSearchText(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setSearchText(query);
      close(context, '');
    });

    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestions = query.isEmpty
        ? []
        : allBhajans.where((bhajan) {
            return bhajan['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          }).map((bhajan) {
            return Map<String, dynamic>.from(bhajan);
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(Icons.music_note),
          title: RichText(
            text: TextSpan(
              text: suggestion['title'].substring(0, query.length),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: suggestion['title'].substring(query.length),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          onTap: () {
            query = suggestion['title'];
            showResults(context);
          },
        );
      },
    );
  }
}

class BhajanListItem extends StatelessWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback onTapFavorite;

  const BhajanListItem({
    required this.title,
    required this.isFavorite,
    required this.onTapFavorite,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 10,
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        child: ListTile(
          tileColor: Color.fromARGB(255, 255, 244, 244),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Icon(Icons.music_note, color: Colors.orange),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: onTapFavorite,
          ),
        ),
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}
