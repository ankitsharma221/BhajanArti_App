import 'package:bhajan_arti/pages/fav_Lyrics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';
import 'package:bhajan_arti/screens/bhajan_lyrics_page.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> localFavorites = [];

  @override
  Widget build(BuildContext context) {
    return BlocListener<BhajanListBloc, BhajanListState>(
      listener: (context, state) {
        if (state is BhajanListLoaded) {
          setState(() {
            localFavorites = List.from(state.favorites);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Favorites',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        body: BlocBuilder<BhajanListBloc, BhajanListState>(
          builder: (context, state) {
            if (state is BhajanListInitial) {
              BlocProvider.of<BhajanListBloc>(context).add(LoadFavorites());
              return Center(child: CircularProgressIndicator());
            } else if (state is BhajanListLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is BhajanListLoaded) {
              if (localFavorites.isEmpty) {
                localFavorites = List.from(state.favorites);
              }

              if (localFavorites.isEmpty) {
                return Center(child: Text('No favorites yet.'));
              }

              return ListView.builder(
                itemCount: localFavorites.length,
                itemBuilder: (context, index) {
                  final bhajan = localFavorites[index];
                  return _buildBhajanCard(context, bhajan, index);
                },
              );
            } else if (state is BhajanListError) {
              return Center(child: Text('Failed to load favorites'));
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildBhajanCard(
      BuildContext context, Map<String, dynamic> bhajan, int index) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(
          Icons.music_note,
          color: Colors.orange,
        ),
        title: Text(
          bhajan['title'].toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoriteLyricsPage(
              title: bhajan['title'].toString(),
              lyrics: bhajan['lyrics'].cast<String>(),
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          onPressed: () {
            BlocProvider.of<BhajanListBloc>(context).add(
              ToggleFavorite(
                bhajan['title'].toString(),
                bhajan['lyrics'].cast<String>(),
              ),
            );
            setState(() {
              localFavorites.removeAt(index);
            });
          },
        ),
      ),
    );
  }
}
