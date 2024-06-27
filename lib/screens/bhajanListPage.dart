import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_bloc.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/pages/favorite_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'bhajan_title_page.dart';

class BhajanListPage extends StatelessWidget {
  BhajanListPage({Key? key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6), // Light Blue Grey
      appBar: AppBar(
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
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage()),
                  );
                },
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 28.0,
                )),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Container(
          color: const Color(0xFFEFF3F6), // Light Blue Grey
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.amber,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.blue),
                title: const Text('Favorite'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('About'),
                onTap: () {
                  // Navigate to About page
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.blue),
                title: const Text('FAQ'),
                onTap: () {
                  // Navigate to FAQ page
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('Share'),
                onTap: () {
                  // Perform Share action
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  _navigateToBhajanTitlePage(context, apiEndpoints[0],
                      title: "आरती");
                },
              ),
              RoomCard(
                title: "Chalisa",
                subtitle: "चालीसा",
                imagePath: "lib/assets/images/god_images/chalisa_image.jpg",
                onTap: () {
                  _navigateToBhajanTitlePage(context, apiEndpoints[1],
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
                    _navigateToBhajanTitlePage(context, apiEndpoints[2],
                        title: "श्री राम भजन");
                  },
                ),
                RoomCard(
                  title: "Devimaa Bhajan",
                  subtitle: "देवीमाँ भजन",
                  imagePath: "lib/assets/images/god_images/mata_image.jpg",
                  onTap: () {
                    _navigateToBhajanTitlePage(context, apiEndpoints[3],
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
                    _navigateToBhajanTitlePage(context, apiEndpoints[4],
                        title: "गणेश भजन");
                  },
                ),
                RoomCard(
                  title: "Khatu Shyam Bhajan",
                  subtitle: "खाटू श्याम भजन",
                  imagePath: "lib/assets/images/god_images/krishna_image.jpg",
                  onTap: () {
                    _navigateToBhajanTitlePage(context, apiEndpoints[5],
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
                    _navigateToBhajanTitlePage(context, apiEndpoints[6],
                        title: "लक्ष्मी भजन");
                  },
                ),
                RoomCard(
                  title: "Hanumanji Bhajan",
                  subtitle: "हनुमानजी भजन",
                  imagePath: "lib/assets/images/god_images/hanumanji_image.jpg",
                  onTap: () {
                    _navigateToBhajanTitlePage(context, apiEndpoints[7],
                        title: "हनुमानजी भजन");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBhajanTitlePage(BuildContext context, String apiEndpoint,
      {required String title}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BhajanTitlePage(title: title, apiUrl: apiEndpoint),
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
    Key? key,
  }) : super(key: key);

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
