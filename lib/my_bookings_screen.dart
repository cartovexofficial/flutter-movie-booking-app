import 'package:flutter/material.dart';
import 'package:helloworld/booking_data.dart' as globals;

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Status"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: globals.userBookings.isEmpty
          ? const Center(child: Text("No bookings yet!"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: globals.userBookings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns like your screenshot
                childAspectRatio: 0.75, // Adjust height for status text
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, i) {
                final ticket = globals.userBookings[i];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- Icon with Status Badge ---
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            const Icon(Icons.movie_creation_outlined,
                                size: 60, color: Colors.grey),
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: ticket['status'] == 'Confirmed'
                                  ? Colors.green
                                  : Colors.orange,
                            )
                          ],
                        ),
                        const SizedBox(height: 10),

                        // --- Movie Name ---
                        Text(
                          ticket['movie'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // --- Seat Info ---
                        Text("Seats: ${ticket['seat']}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blueGrey)),

                        const SizedBox(height: 10),

                        // --- Status Text Label ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ticket['status'] == 'Confirmed'
                                ? Colors.green[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ticket['status'] == 'Confirmed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          child: Text(
                            ticket['status'] ?? 'Confirmed',
                            style: TextStyle(
                              color: ticket['status'] == 'Confirmed'
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),
                        Text(ticket['price'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
