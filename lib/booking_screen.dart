import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:helloworld/app_theme.dart';
import 'package:helloworld/seat_screen.dart';

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
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('Booking Details', style: AppTheme.label(16)),
        backgroundColor: AppTheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie hero tile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.glassDecoration(radius: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.movie_filter_rounded,
                      color: AppTheme.primary, size: 40),
                  const SizedBox(height: 16),
                  Text(movieName,
                      style: AppTheme.headline(24),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('Price per seat: $price',
                      style: AppTheme.label(16, color: AppTheme.primary)),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassDecoration(radius: 20),
              child: Column(
                children: [
                  _DetailRow(icon: Icons.theater_comedy_rounded, label: 'Venue', value: 'PVR IMAX, Jaipur'),
                  const Divider(color: AppTheme.divider, height: 24),
                  _DetailRow(icon: Icons.access_time_rounded, label: 'Show Time', value: '6:00 PM, Today'),
                  const Divider(color: AppTheme.divider, height: 24),
                  _DetailRow(icon: Icons.language_rounded, label: 'Language', value: 'Hindi'),
                  const Divider(color: AppTheme.divider, height: 24),
                  _DetailRow(icon: Icons.hd_rounded, label: 'Format', value: 'IMAX 3D'),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0, delay: 150.ms),

            const Spacer(),

            // CTA button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: AppTheme.primaryButtonDecoration,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    CinemaRoute(
                        page: SeatScreen(
                            movieName: movieName, price: price)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_seat_rounded,
                          color: Colors.white),
                      const SizedBox(width: 10),
                      Text('Select Seats',
                          style: AppTheme.label(16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 300.ms),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 12),
        Text('$label  ', style: AppTheme.body(14)),
        Expanded(
          child: Text(value,
              style: AppTheme.label(14),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
