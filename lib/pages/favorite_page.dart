import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';
import 'package:bhajan_arti/screens/bhajan_lyrics_page.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: BlocBuilder<BhajanListBloc, BhajanListState>(
        builder: (context, state) {
          if (state is BhajanListLoaded) {
            final favoriteBhajans = state.data
                .where((bhajan) => bhajan['isFavorite'] == true)
                .toList();

            if (favoriteBhajans.isEmpty) {
              return Center(
                child: Text('No favorites yet.'),
              );
            } else {
              return ListView.builder(
                itemCount: favoriteBhajans.length,
                itemBuilder: (context, index) {
                  final favoriteBhajan = favoriteBhajans[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 10,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () {
                        // Navigate to the lyrics page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BhajanLyricsPage(
                              title: favoriteBhajan['title'],
                              lyrics: favoriteBhajan['lyrics'],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        leading: Icon(Icons.music_note, color: Colors.orange),
                        title: Text(
                          favoriteBhajan['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            favoriteBhajan['isFavorite']
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            // Implement toggle favorite logic here
                            BlocProvider.of<BhajanListBloc>(context).add(
                              ToggleFavorite(favoriteBhajan['title']),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
