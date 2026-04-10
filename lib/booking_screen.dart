import 'package:flutter/material.dart';
import 'seat_screen.dart';

class BookingScreen extends StatelessWidget {
  final String movieName;
  final String price;

  const BookingScreen({
    super.key,
    required this.movieName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.movie, size: 100),
            const SizedBox(height: 20),
            Text(
              movieName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Price: $price",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text("Theater: PVR Cinemas"),
            const Text("Show Time: 6:00 PM"),
            const Spacer(),
            ElevatedButton(
              child: const Text("Select Seat"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SeatScreen(
                      movieName: movieName,
                      price: price,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
