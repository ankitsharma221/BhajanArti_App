import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/pages/favorite_page.dart';
import 'package:bhajan_arti/pages/quotes_page.dart';
import 'package:bhajan_arti/screens/bhajan_title_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share/share.dart';

import '../pages/wallpaper_page.dart';

class BhajanListPage extends StatefulWidget {
  BhajanListPage({Key? key});

  @override
  _BhajanListPageState createState() => _BhajanListPageState();
}

class _BhajanListPageState extends State<BhajanListPage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    BhajanListContent(),
    WallpaperPage(),
    GodQuotesPage(),
    FavoritePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  void _preloadImages() {
    final List<String> imagePaths = [
      'lib/assets/images/god_images/arti_image.jpg',
      'lib/assets/images/god_images/chalisa_image.jpg',
      'lib/assets/images/god_images/sreeram_image.jpg',
      'lib/assets/images/god_images/mata_image.jpg',
      'lib/assets/images/god_images/ganesh_image.jpg',
      'lib/assets/images/god_images/krishna_image.jpg',
      'lib/assets/images/god_images/laxmi_image.jpg',
      'lib/assets/images/god_images/hanumanji_image.jpg',
    ];

    for (String path in imagePaths) {
      precacheImage(AssetImage(path), context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleMenuAction(String result) {
    switch (result) {
      case 'Share':
        _shareApp();
        break;
      case 'Copyright':
        _showCopyrightDialog();
        break;
      default:
        break;
    }
  }

  void _shareApp() {
  final RenderBox box = context.findRenderObject() as RenderBox;
  Share.share(
    'Check out the BhajanAarti app for amazing bhajans and aartis! Download now: https://play.google.com/store/apps/details?id=com.devgenix.bhajanarti',
    subject: 'BhajanAarti App',
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}


  void _showCopyrightDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Copyright Information'),
          content: Text(
            'All content in this app is used with permission. If you believe any content is used without permission, please contact us at aannkkiitt321@gmail.com.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 245, 244, 244), // Light Blue Grey
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage(
                'lib/assets/images/cover.png'), // Replace with your image path
          ),
        ),
        title: const Text(
          'BhajanAarti',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onSelected: _handleMenuAction,
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'Share',
                  child: Text('Share App'),
                ),
                const PopupMenuItem<String>(
                  value: 'Copyright',
                  child: Text('Copyright'),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.orange[400],
        elevation: 0,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallpaper),
            label: 'Wallpaper',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'God Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class BhajanListContent extends StatelessWidget {
  final List<String> apiEndpoints = [
    dotenv.env['Aarti_API']!,
    dotenv.env['Chalisa']!,
    dotenv.env['Ram']!,
    dotenv.env['Ma']!,
    dotenv.env['Ganesh']!,
    dotenv.env['khatuShyam']!,
    dotenv.env['Laxmi']!,
    dotenv.env['Hanumanji']!,
  ];

  final List<String> youtubeApiEndpoints = [
    dotenv.env['Youtube_Api_1']!,
    dotenv.env['Youtube_Api_2']!,
    dotenv.env['Youtube_Api_3']!,
    dotenv.env['Youtube_Api_4']!,
    dotenv.env['Youtube_Api_5']!,
    dotenv.env['Youtube_Api_6']!,
    dotenv.env['Youtube_Api_7']!,
    dotenv.env['Youtube_Api_8']!,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            RoomCard(
              title: "Aarti",
              subtitle: "आरती",
              imagePath: "lib/assets/images/god_images/arti_image.jpg",
              onTap: () {
                _navigateToBhajanTitlePage(
                    context, apiEndpoints[0], youtubeApiEndpoints[0],
                    title: "आरती");
              },
            ),
            RoomCard(
              title: "Chalisa",
              subtitle: "चालीसा",
              imagePath: "lib/assets/images/god_images/chalisa_image.jpg",
              onTap: () {
                _navigateToBhajanTitlePage(
                    context, apiEndpoints[1], youtubeApiEndpoints[1],
                    title: "चालीसा");
              },
            ),
          ]),
          Row(
            children: [
              RoomCard(
                title: "Sree Ram Bhajan",
                subtitle: "श्री राम भजन",
                imagePath: "lib/assets/images/god_images/sreeram_image.jpg",
                onTap: () {
                  _navigateToBhajanTitlePage(
                      context, apiEndpoints[2], youtubeApiEndpoints[2],
                      title: "श्री राम भजन");
                },
              ),
              RoomCard(
                title: "Devimaa Bhajan",
                subtitle: "देवीमाँ भजन",
                imagePath: "lib/assets/images/god_images/mata_image.jpg",
                onTap: () {
                  _navigateToBhajanTitlePage(
                      context, apiEndpoints[3], youtubeApiEndpoints[3],
                      title: "देवीमाँ भजन");
                },
              ),
            ],
          ),
          Row(
            children: [
              RoomCard(
                title: "Ganesh Bhajan",
                subtitle: "गणेश भजन",
                imagePath: "lib/assets/images/god_images/ganesh_image.jpg",
                onTap: () {
                  _navigateToBhajanTitlePage(
                      context, apiEndpoints[4], youtubeApiEndpoints[4],
                      title: "गणेश भजन");
                },
              ),
              RoomCard(
                title: "Khatu Shyam Bhajan",
                subtitle: "खाटू श्याम भजन",
                imagePath: "lib/assets/images/god_images/krishna_image.jpg",
                onTap: () {
                  _navigateToBhajanTitlePage(
                      context, apiEndpoints[5], youtubeApiEndpoints[5],
                      title: "खाटू श्याम भजन");
                },
              ),
            ],
          ),
          Row(
            children: [
              RoomCard(
                title: "Laxmi Bhajan",
                subtitle: "लक्ष्मी भजन",
                imagePath: "lib/assets/images/god_images/laxmi_image.jpg",
                onTap: () {
                  _navigateToBhajanTitlePage(
                      context, apiEndpoints[6], youtubeApiEndpoints[6],
                      title: "लक्ष्मी भजन");
                },
              ),
              RoomCard(
                title: "Hanumanji Bhajan",
                subtitle: "हनुमानजी भजन",
                imagePath: "lib/assets/images/god_images/hanumanji_image.jpg",
                onTap: () {
                  _navigateToBhajanTitlePage(
                      context, apiEndpoints[7], youtubeApiEndpoints[7],
                      title: "हनुमानजी भजन");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToBhajanTitlePage(
      BuildContext context, String apiEndpoint, String youtubeApiEndpoint,
      {required String title}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BhajanTitlePage(
          title: title,
          apiUrl: apiEndpoint,
          youtubePlaylistUrl: youtubeApiEndpoint,
        ),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const RoomCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  height: MediaQuery.of(context).size.width / 2 - 20,
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
