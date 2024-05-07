import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../bloc/bhajanList/bhjan_list_bloc.dart';
import 'bhajan_title_page.dart';

class BhajanListPage extends StatelessWidget {
  BhajanListPage({Key? key});

  final BhajanListBloc _bhajanListBloc = BhajanListBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bhajanListBloc,
      child: BlocConsumer<BhajanListBloc, BhajanListState>(
        listener: (context, state) {
          if (state is BhajanListLoaded) {
            navigateToBhajanTitlePage(context, state.data);
          }
        },
        builder: (context, state) {
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
                        // Navigate to Favorite page
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
                      onTap: () => _bhajanListBloc
                          .add(FetchBhajans('http://localhost:3000/songs')),
                    ),
                    RoomCard(
                      title: "Chalisa",
                      subtitle: "चालीसा",
                      imagePath:
                          "lib/assets/images/god_images/chalisa_image.jpg",
                      onTap: () => _bhajanListBloc
                          .add(FetchBhajans('http://localhost:3000/titles')),
                    ),
                  ]),
                  Row(
                    children: [
                      RoomCard(
                        title: "Sree Ram Bhajan",
                        subtitle: "श्री राम भजन",
                        imagePath:
                            "lib/assets/images/god_images/sreeram_image.jpg",
                        onTap: () => _bhajanListBloc
                            .add(FetchBhajans('http://localhost:3000/rams')),
                      ),
                      RoomCard(
                        title: "Devimaa Bhajan",
                        subtitle: "देवीमाँ भजन",
                        imagePath:
                            "lib/assets/images/god_images/mata_image.jpg",
                        onTap: () => _bhajanListBloc
                            .add(FetchBhajans('http://localhost:3000/Ma')),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      RoomCard(
                        title: "Ganesh Bhajan",
                        subtitle: "गणेश भजन",
                        imagePath:
                            "lib/assets/images/god_images/ganesh_image.jpg",
                        onTap: () => _bhajanListBloc
                            .add(FetchBhajans('http://localhost:3000/ganesh')),
                      ),
                      RoomCard(
                        title: "Khatu Shyam Bhajan",
                        subtitle: "खाटू श्याम भजन",
                        imagePath:
                            "lib/assets/images/god_images/krishna_image.jpg",
                        onTap: () => _bhajanListBloc.add(
                            FetchBhajans('http://localhost:3000/khatushyams')),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      RoomCard(
                        title: "Laxmi Bhajan",
                        subtitle: "लक्ष्मी भजन",
                        imagePath:
                            "lib/assets/images/god_images/laxmi_image.jpg",
                        onTap: () => _bhajanListBloc
                            .add(FetchBhajans('http://localhost:3000/laxmi')),
                      ),
                      RoomCard(
                        title: "Hanumanji Bhajan",
                        subtitle: "हनुमानजी भजन",
                        imagePath:
                            "lib/assets/images/god_images/hanumanji_image.jpg",
                        onTap: () => _bhajanListBloc.add(
                            FetchBhajans('http://localhost:3000/khatushyams')),
                      ),
                    ],
                  ),
                ],
                // Add other RoomRows with respective RoomCards here
              ),
            ),
          );
        },
      ),
    );
  }

  void navigateToBhajanTitlePage(BuildContext context, List<dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BhajanTitlePage(data: data),
      ),
    );
  }
}

class RoomRow extends StatelessWidget {
  final List<Widget> children;

  const RoomRow({Key? key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
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
