import 'package:flutter/material.dart';
import 'payment_screen.dart';

class SeatScreen extends StatefulWidget {
  final String movieName;
  final String price;

  const SeatScreen({super.key, required this.movieName, required this.price});

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  List<int> selectedSeats = [];

  int getTotalPrice() {
    int basePrice = int.parse(widget.price.replaceAll('₹', ''));
    return basePrice * selectedSeats.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Select Seats"), backgroundColor: Colors.redAccent),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
              width: 300,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(10))),
          const Text("SCREEN",
              style: TextStyle(letterSpacing: 5, color: Colors.grey)),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 48,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemBuilder: (context, index) {
                bool isSelected = selectedSeats.contains(index);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected
                        ? selectedSeats.remove(index)
                        : selectedSeats.add(index);
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                        child: Text("${index + 1}",
                            style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total: ₹${getTotalPrice()}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: selectedSeats.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            movieName: widget.movieName,
                            seatNumber:
                                selectedSeats.map((s) => s + 1).join(", "),
                            price: "₹${getTotalPrice()}",
                          ),
                        ),
                      );
                    },
              child:
                  const Text("Pay Now", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
