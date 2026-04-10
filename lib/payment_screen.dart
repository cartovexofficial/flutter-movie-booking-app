import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:helloworld/app_theme.dart';
import 'package:helloworld/booking_data.dart' as globals;
import 'package:helloworld/movie_data.dart';
import 'package:helloworld/cinema_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helloworld/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Movie movie;
  final Cinema? cinema;
  final List<int> selectedSeats;

  const PaymentScreen({
    super.key,
    required this.movie,
    this.cinema,
    required this.selectedSeats,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanCtrl;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  String get _seatString {
    return widget.selectedSeats.map((s) {
      int row = s ~/ 8;
      int col = s % 8;
      String rowLetter = String.fromCharCode(65 + row);
      return '$rowLetter${col + 1}';
    }).join(', ');
  }
  
  String get _priceString {
    int baseUnitPrice = widget.cinema?.priceFor('Regular') ?? widget.movie.basePrice;
    return '₹${baseUnitPrice * widget.selectedSeats.length}';
  }

  void _confirmPayment() async {
    setState(() => _confirmed = true);
    globals.userBookings.add({
      'movie': widget.movie.title,
      'cinema': widget.cinema?.name ?? 'PVR IMAX, Jaipur',
      'seat': _seatString,
      'price': _priceString,
      'time': DateTime.now().toString().substring(0, 16),
      'status': 'Confirmed',
    });

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    
    // Get username from SharedPreferences so we can redirect to Home
    final prefs = await SharedPreferences.getInstance();
    final String username = prefs.getString('user_id') ?? 'Guest';

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Booking confirmed! Enjoy the movie!')),
    );
    
    // Redirect to home screen and clear stack so back button doesn't go to payment
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=upi://pay?pa=manibhushan@upi&am=${_priceString.replaceAll('₹', '')}';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('Finalize Payment', style: AppTheme.label(16)),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          children: [
            // ── Ticket Card ───────────────────────────────────────────
            _buildTicketCard().animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 30),

            // ── QR Section ────────────────────────────────────────────
            Text('Scan to Pay via UPI',
                style: AppTheme.label(15))
                .animate()
                .fadeIn(delay: 200.ms),

            const SizedBox(height: 6),
            Text('Point your payment app camera at the QR code',
                style: AppTheme.body(12))
                .animate()
                .fadeIn(delay: 300.ms),

            const SizedBox(height: 20),

            _buildQRBox(qrUrl)
                .animate()
                .fadeIn(delay: 350.ms, duration: 500.ms)
                .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    delay: 350.ms),

            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('manibhushan@upi',
                  style: AppTheme.label(14, color: AppTheme.accent)),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 40),

            // ── Confirm button ────────────────────────────────────────
            _buildConfirmButton()
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: AppTheme.glassDecoration(radius: 24),
          child: Column(
            children: [
              // Header bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.movie_filter_rounded,
                        color: Colors.white70, size: 20),
                    const SizedBox(height: 8),
                    Text(widget.movie.title,
                        style: AppTheme.headline(20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('${widget.movie.language} • ${widget.movie.genre}',
                        style: AppTheme.body(12, color: Colors.white70)),
                  ],
                ),
              ),

              // Perforated divider
              _PerforatedDivider(),

              // Ticket details
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    _TicketRow(
                      label: 'Seats',
                      value: _seatString,
                    ),
                    const SizedBox(height: 12),
                    _TicketRow(
                      label: 'Venue',
                      value: widget.cinema != null ? widget.cinema!.name : 'PVR IMAX, Jaipur',
                    ),
                    const SizedBox(height: 12),
                    _TicketRow(
                      label: 'Show Time',
                      value: '6:00 PM, Today',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Payable',
                              style: AppTheme.body(14)),
                          Text(_priceString,
                              style: AppTheme.headline(22)
                                  .copyWith(color: const Color(0xFF30D158))),
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
    );
  }

  Widget _buildQRBox(String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: AppTheme.glowShadow,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(url,
                width: 200, height: 200, errorBuilder: (_, __, ___) {
              return Container(
                width: 200,
                height: 200,
                color: Colors.white,
                child: const Icon(Icons.qr_code_2, size: 120),
              );
            }),
          ),
          // Animated scan line
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (_, __) => Positioned(
              top: _scanCtrl.value * 196,
              left: 0,
              right: 0,
              child: Container(
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primary.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: _confirmed
          ? Center(
              child: const CircularProgressIndicator(color: AppTheme.primary))
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF30D158), Color(0xFF25A244)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF30D158).withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _confirmPayment,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text('CONFIRM PAYMENT',
                        style: AppTheme.label(16, color: Colors.white)),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Perforated Divider ────────────────────────────────────────────────────────
class _PerforatedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          // Left notch
          Container(
            width: 20,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.bg,
              borderRadius:
                  BorderRadius.horizontal(right: Radius.circular(14)),
            ),
          ),
          // Dashed line
          Expanded(
            child: LayoutBuilder(builder: (_, constraints) {
              final dashCount = (constraints.maxWidth / 12).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  dashCount,
                  (_) => Container(
                    width: 6,
                    height: 1.5,
                    color: AppTheme.divider,
                  ),
                ),
              );
            }),
          ),
          // Right notch
          Container(
            width: 20,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.bg,
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final String label;
  final String value;
  const _TicketRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.body(13)),
        Text(value, style: AppTheme.label(13)),
      ],
    );
  }
}
