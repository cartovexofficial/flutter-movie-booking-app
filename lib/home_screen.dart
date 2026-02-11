import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _lastVisit = "Fetching...";
  List<Map<String, String>> _movies = [];

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastVisit = prefs.getString('last_visit_time') ?? "First time visiting!";
    });

    String currentTime = DateTime.now().toString().split('.')[0];
    await prefs.setString('last_visit_time', "Last seen: $currentTime");

    // Simulating API Call
    await Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          // UPDATED MOVIE DATA WITH INR PRICES (₹)
          _movies = [
            {
              "title": "Captain America: BNW",
              "price": "₹450",
              "image":
                  "https://upload.wikimedia.org/wikipedia/en/2/23/Captain_America_Brave_New_World_poster.jpg"
            },
            {
              "title": "Superman (2025)",
              "price": "₹500",
              "image":
                  "https://upload.wikimedia.org/wikipedia/en/3/3d/Superman_%282025_film%29_poster.jpg"
            },
            {
              "title": "Avatar: Fire & Ash",
              "price": "₹800",
              "image":
                  "https://upload.wikimedia.org/wikipedia/en/5/54/Avatar_The_Way_of_Water_poster.jpg"
            },
            {
              "title": "Mufasa: Lion King",
              "price": "₹350",
              "image":
                  "https://upload.wikimedia.org/wikipedia/en/c/c8/Mufasa_The_Lion_King_poster.jpg"
            },
            {
              "title": "Fantastic Four",
              "price": "₹420",
              "image":
                  "https://upload.wikimedia.org/wikipedia/en/0/07/The_Fantastic_Four_First_Steps_poster.jpg"
            },
            {
              "title": "Thunderbolts*",
              "price": "₹380",
              "image":
                  "https://upload.wikimedia.org/wikipedia/en/6/63/Thunderbolts%2A_poster.jpg"
            },
          ];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.username}"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Icon(Icons.account_circle, size: 60, color: Colors.white),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Last Login"),
              subtitle: Text(_lastVisit),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Last Visit Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Colors.amber[100],
            child: Text(
              _lastVisit,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.brown),
            ),
          ),

          // Movie Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65, // Taller cards for Movie Posters
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _movies.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Movie Poster
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  _movies[i]['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                      child: Icon(Icons.movie_creation,
                                          size: 50, color: Colors.grey)),
                                ),
                              ),
                            ),
                            // Details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    _movies[i]['title']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _movies[i]['price']!,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white),
                                      child: const Text("Book"),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
