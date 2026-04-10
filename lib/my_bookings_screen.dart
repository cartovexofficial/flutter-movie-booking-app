import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:helloworld/app_theme.dart';
import 'package:helloworld/booking_data.dart' as globals;

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bookings = globals.userBookings;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('My Bookings', style: AppTheme.label(16)),
        backgroundColor: AppTheme.surface,
      ),
      body: bookings.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              itemCount: bookings.length,
              itemBuilder: (ctx, i) {
                return _buildTicketCard(bookings[i], i);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Icon(Icons.movie_creation_outlined,
                size: 48, color: AppTheme.textSecondary),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.95, end: 1.05, duration: 1200.ms),
          const SizedBox(height: 20),
          Text('No Bookings Yet', style: AppTheme.headline(22))
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Your booked tickets will appear here.\nGo grab a movie! 🎬',
            style: AppTheme.body(14),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, int i) {
    final isConfirmed = ticket['status'] == 'Confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassDecoration(radius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            children: [
              // ── Header strip ─────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isConfirmed
                        ? [const Color(0xFF0D3B25), const Color(0xFF1A6644)]
                        : [const Color(0xFF3B2A0D), const Color(0xFF66440D)],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.movie_filter_rounded,
                        color: isConfirmed
                            ? const Color(0xFF30D158)
                            : const Color(0xFFFFD700),
                        size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ticket['movie'] ?? '',
                        style: AppTheme.label(15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusBadge(
                        isConfirmed: isConfirmed,
                        label: ticket['status'] ?? 'Confirmed'),
                  ],
                ),
              ),

              // ── Details ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.theaters_rounded,
                      label: 'Cinema',
                      value: ticket['cinema'] ?? 'PVR IMAX, Jaipur',
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.event_seat_rounded,
                      label: 'Seats',
                      value: ticket['seat'] ?? '',
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Booked At',
                      value: ticket['time'] ?? '',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Amount Paid',
                              style: AppTheme.body(13)),
                          Text(
                            ticket['price'] ?? '',
                            style: AppTheme.headline(18)
                                .copyWith(color: const Color(0xFF30D158)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (i * 100).ms, duration: 500.ms)
        .slideY(begin: 0.15, end: 0, delay: (i * 100).ms, duration: 500.ms);
  }
}

// ── Status badge with pulsing dot ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isConfirmed;
  final String label;
  const _StatusBadge({required this.isConfirmed, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = isConfirmed ? const Color(0xFF30D158) : const Color(0xFFFFD700);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.7, end: 1.3, duration: 800.ms),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.label(11, color: color)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTheme.body(13)),
        Expanded(
          child: Text(value,
              style: AppTheme.label(13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
