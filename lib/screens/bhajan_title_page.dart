import 'package:bhajan_arti/screens/bhajan_lyrics_page.dart';
import 'package:flutter/material.dart';

class BhajanTitlePage extends StatelessWidget {
  final List<dynamic> data;

  const BhajanTitlePage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bhajan'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BhajanLyricsPage(
                    title: data[index]['title'],
                    lyrics: data[index]['lyrics'],
                  ),
                ),
              );
            },
            child: BhajanListItem(
              title: data[index]['title'],
            ),
          );
        },
      ),
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
          'lib/assets/images/cover.png', // Placeholder image
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
