import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';
import 'package:bhajan_arti/screens/bhajan_lyrics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BhajanTitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BhajanListBloc, BhajanListState>(
      builder: (context, state) {
        if (state is BhajanListInitial) {
          return Center(child: CircularProgressIndicator());
        } else if (state is BhajanListLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is BhajanListLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bhajan'),
            ),
            body: ListView.builder(
              itemCount: state.data.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BhajanLyricsPage(
                          title: state.data[index]['title'],
                          lyrics: state.data[index]['lyrics'],
                        ),
                      ),
                    );
                  },
                  child: BhajanListItem(
                    title: state.data[index]['title'],
                  ),
                );
              },
            ),
          );
        } else if (state is BhajanListError) {
          return Center(child: Text('Failed to fetch data'));
        } else {
          return Center(child: Text('Unknown state'));
        }
      },
    );
  }
}

class BhajanListItem extends StatelessWidget {
  final String title;

  const BhajanListItem({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          'lib/assets/images/cover.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    );
  }
}
