import 'package:bhajan_arti/screens/bhajan_lyrics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';

class BhajanTitlePage extends StatefulWidget {
  final String title;
  final String apiUrl;

  const BhajanTitlePage({Key? key, required this.title, required this.apiUrl})
      : super(key: key);

  @override
  _BhajanTitlePageState createState() => _BhajanTitlePageState();
}

class _BhajanTitlePageState extends State<BhajanTitlePage> {
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    BlocProvider.of<BhajanListBloc>(context).add(FetchBhajans(widget.apiUrl));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BhajanListBloc, BhajanListState>(
      builder: (context, state) {
        if (state is BhajanListInitial || state is BhajanListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BhajanListLoaded) {
          var filteredData = state.data
              .where((item) => item['title']
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold)),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    size: 40,
                  ),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: DataSearch(
                        setSearchText: setSearchText,
                        allBhajans: state.data.cast<Map<String, dynamic>>(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final bhajan = filteredData[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BhajanLyricsPage(
                          title: bhajan['title'],
                          lyrics: bhajan['lyrics'],
                        ),
                      ),
                    );
                  },
                  child: BhajanListItem(
                    title: bhajan['title'],
                    isFavorite: bhajan['isFavorite'] ?? false,
                    onTapFavorite: () {
                      BlocProvider.of<BhajanListBloc>(context)
                          .add(ToggleFavorite(bhajan['title']));
                    },
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text('Unexpected state'));
      },
    );
  }

  void setSearchText(String searchText) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _searchText = searchText;
      });
    });
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
        icon: const Icon(Icons.clear),
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
                .startsWith(query.toLowerCase());
          }).map((bhajan) {
            // Manually convert each map to Map<String, dynamic>
            return Map<String, dynamic>.from(bhajan);
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BhajanLyricsPage(
                  title: suggestion['title'],
                  lyrics: suggestion['lyrics'],
                ),
              ),
            );
          },
          child: BhajanListItem(
            title: suggestion['title'],
            isFavorite: suggestion['isFavorite'] ?? false,
            onTapFavorite: () {
              BlocProvider.of<BhajanListBloc>(context)
                  .add(ToggleFavorite(suggestion['title']));
            },
          ),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: const Icon(Icons.music_note, color: Colors.orange),
          title: Text(
            title,
            style: const TextStyle(
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
