import 'dart:ui'; // Required for the Glassmorphism effect
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:helloworld/my_bookings_screen.dart';
import 'package:helloworld/seat_screen.dart';
import 'package:helloworld/chat_bot_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = "Detecting location...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
      List<Placemark> p =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentLocation = "${p[0].locality}, ${p[0].administrativeArea}";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = "Jaipur, Rajasthan";
          _isLoading = false;
        });
      }
    }
  }

  final List<Map<String, String>> movies = [
    {
      'title': 'Sitaare Zameen Par',
      'price': '₹300',
      'img': 'https://picsum.photos/seed/1/400/600',
      'tag': 'Trending'
    },
    {
      'title': 'Jolly LLB 3',
      'price': '₹280',
      'img': 'https://picsum.photos/seed/2/400/600',
      'tag': 'Comedy'
    },
    {
      'title': 'Chhaava',
      'price': '₹320',
      'img': 'https://picsum.photos/seed/3/400/600',
      'tag': 'Action'
    },
    {
      'title': 'Dhurandhar',
      'price': '₹350',
      'img': 'https://picsum.photos/seed/4/400/600',
      'tag': 'Epic'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep dark modern background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        title: Text("Hello, ${widget.username.split('@')[0]}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5252),
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: const Text("Help", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatBotScreen())),
      ),
      body: CustomScrollView(
        slivers: [
          // Modern Location Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFFF5252)),
                  const SizedBox(width: 10),
                  Text(_isLoading ? "Fetching..." : _currentLocation,
                      style: const TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          // Bento Grid for Movies
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24)),
                                child: Image.network(movies[i]['img']!,
                                    fit: BoxFit.cover, width: double.infinity),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(movies[i]['tag']!,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movies[i]['title']!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1),
                              const SizedBox(height: 4),
                              Text(movies[i]['price']!,
                                  style: const TextStyle(
                                      color: Color(0xFFFF5252),
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF5252),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => SeatScreen(
                                              movieName: movies[i]['title']!,
                                              price: movies[i]['price']!))),
                                  child: const Text("Book Now",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: movies.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
