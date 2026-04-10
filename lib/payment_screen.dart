import 'package:flutter/material.dart';
// Import your global list to save the ticket
import 'package:helloworld/booking_data.dart' as globals;

class PaymentScreen extends StatelessWidget {
  final String movieName;
  final String seatNumber;
  final String price;

  const PaymentScreen(
      {super.key,
      required this.movieName,
      required this.seatNumber,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalize Payment"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Ticket Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(movieName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Seats Selected:",
                            style: TextStyle(color: Colors.grey)),
                        Text(seatNumber,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Payable:",
                            style: TextStyle(color: Colors.grey)),
                        Text(price,
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Scan QR to Pay via UPI",
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 15),

            // Dynamic QR Code (Generates based on the actual price)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=upi://pay?pa=manibhushan@upi&am=${price.replaceAll('₹', '')}',
                height: 200,
                width: 200,
              ),
            ),

            const SizedBox(height: 15),
            const Text("UPI ID: manibhushan@upi",
                style: TextStyle(
                    color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            // Confirm Payment Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // 1. ADD TO GLOBAL LIST (Maintains Status)
                  globals.userBookings.add({
                    'movie': movieName,
                    'seat': seatNumber,
                    'price': price,
                    'time': DateTime.now().toString().substring(0, 16),
                    'status': 'Confirmed',
                  });

                  // 2. SHOW FEEDBACK
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        "Payment Successful! Ticket added to My Bookings."),
                    backgroundColor: Colors.green,
                  ));

                  // 3. GO BACK TO HOME (Clears the stack)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("CONFIRM PAYMENT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
