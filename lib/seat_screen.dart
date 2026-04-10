import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:helloworld/app_theme.dart';
import 'package:helloworld/payment_screen.dart';
import 'package:helloworld/movie_data.dart';
import 'package:helloworld/cinema_data.dart';

class SeatScreen extends StatefulWidget {
  final Movie movie;
  final Cinema? cinema;

  const SeatScreen({super.key, required this.movie, this.cinema});

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen>
    with SingleTickerProviderStateMixin {
  List<int> selectedSeats = [];
  Set<int> bookedSeats = {};
  bool _arMode = false;

  late AnimationController _scanLineCtrl;

  static const int rows = 9;
  static const int colsPerRow = 8;
  static const int totalSeats = rows * colsPerRow;

  int getSeatPrice(int index) {
    int baseUnitPrice = widget.cinema?.priceFor('Regular') ?? widget.movie.basePrice;
    int row = index ~/ colsPerRow;
    if (row < 2) return (baseUnitPrice * 0.8).round(); // Silver
    if (row < 6) return baseUnitPrice; // Gold
    return (baseUnitPrice * 1.5).round(); // Platinum
  }

  String getSeatCategory(int index) {
    int row = index ~/ colsPerRow;
    if (row < 2) return 'Silver';
    if (row < 6) return 'Gold';
    return 'Platinum';
  }

  String getSeatName(int index) {
    int row = index ~/ colsPerRow;
    int col = index % colsPerRow;
    String rowLetter = String.fromCharCode(65 + row);
    return '$rowLetter${col + 1}';
  }

  int getTotalPrice() {
    int total = 0;
    for (int index in selectedSeats) {
      total += getSeatPrice(index);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    // Unique seed for realism
    int seed = widget.movie.title.length + (widget.cinema?.id.length ?? 7);
    final random = Random(seed);
    bookedSeats = {};
    for (int i = 0; i < 18; i++) {
      bookedSeats.add(random.nextInt(totalSeats));
    }

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    super.dispose();
  }

  void _onSeatTap(int index) {
    if (bookedSeats.contains(index)) return;
    HapticFeedback.lightImpact();
    setState(() {
      selectedSeats.contains(index)
          ? selectedSeats.remove(index)
          : selectedSeats.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.movie.title,
                style: AppTheme.label(16), overflow: TextOverflow.ellipsis),
            Text(widget.cinema?.name ?? 'PVR IMAX, Jaipur',
                style: AppTheme.body(11, color: AppTheme.textSecondary)),
          ],
        ),
        backgroundColor: AppTheme.surface,
        actions: [
          _buildARToggle(),
        ],
      ),
      body: Stack(
        children: [
          // Background atmospheric glow from screen
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  radius: 1.5,
                ),
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: 600.ms,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim), child: child),
                  ),
                  child: _arMode
                      ? _ARCinemaView(
                          key: const ValueKey('ar'),
                          scanLineCtrl: _scanLineCtrl,
                          bookedSeats: bookedSeats,
                          selectedSeats: selectedSeats,
                          onSeatTap: _onSeatTap,
                          getSeatCategory: getSeatCategory,
                        )
                      : _NormalSeatView(
                          key: const ValueKey('normal'),
                          bookedSeats: bookedSeats,
                          selectedSeats: selectedSeats,
                          onSeatTap: _onSeatTap,
                          getSeatCategory: getSeatCategory,
                        ),
                ),
              ),

              _buildBottomBar(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildARToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _arMode = !_arMode);
      },
      child: AnimatedContainer(
        duration: 400.ms,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: _arMode ? AppTheme.primaryGradient : null,
          color: _arMode ? null : AppTheme.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _arMode ? Colors.transparent : AppTheme.divider),
          boxShadow: _arMode ? AppTheme.glowShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _arMode ? Icons.view_in_ar_rounded : Icons.view_in_ar_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(_arMode ? 'AR ON' : 'AR View', style: AppTheme.label(11, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedSeats.isNotEmpty) _buildSelectedSeatsList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price Breakdown', style: AppTheme.body(11)),
                  const SizedBox(height: 4),
                  Text('₹${getTotalPrice()}', style: AppTheme.headline(26)),
                ],
              ),
              _buildCheckoutButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSeatsList() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedSeats.length,
        itemBuilder: (ctx, i) {
          final sIdx = selectedSeats[i];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
            ),
            child: Text(getSeatName(sIdx), style: AppTheme.label(13, color: AppTheme.primary)),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
        },
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      height: 56,
      width: 170,
      child: Container(
        decoration: selectedSeats.isEmpty
            ? BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(16))
            : AppTheme.primaryButtonDecoration,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: selectedSeats.isEmpty ? null : () => Navigator.push(context, CinemaRoute(page: PaymentScreen(movie: widget.movie, cinema: widget.cinema, selectedSeats: selectedSeats))),
          child: Text('Checkout →', style: AppTheme.label(15, color: Colors.white)),
        ),
      ).animate(target: selectedSeats.isEmpty ? 0 : 1).shimmer(duration: 2.seconds),
    );
  }
}

// ── Normal Seat View ──────────────────────────────────────────────────────────
class _NormalSeatView extends StatelessWidget {
  final Set<int> bookedSeats;
  final List<int> selectedSeats;
  final void Function(int) onSeatTap;
  final String Function(int) getSeatCategory;

  const _NormalSeatView({
    super.key,
    required this.bookedSeats,
    required this.selectedSeats,
    required this.onSeatTap,
    required this.getSeatCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _ScreenCurveIndicator(),
          const SizedBox(height: 40),
          _Legend(),
          const SizedBox(height: 40),
          
          _buildTheaterPlan(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTheaterPlan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: List.generate(9, (r) {
          final isRecliner = r >= 7;
          // Row Curvature: Outer rows are slightly more padded than middle rows to create an arc
          // This simulates a curved seating arrangement centered on the screen
          final double hPadding = (pow(r - 4, 2) / 4.0).toDouble();

          return Container(
            margin: EdgeInsets.only(bottom: isRecliner && r == 7 ? 35 : 18),
            padding: EdgeInsets.symmetric(horizontal: 10 + hPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row Label (Left)
                SizedBox(
                  width: 22,
                  child: Text(String.fromCharCode(65 + r), style: AppTheme.label(11, color: AppTheme.textSecondary)),
                ),
                const SizedBox(width: 4),

                // Seat Row with Aisle Gaps
                ..._buildRowWithAisles(r, isRecliner),

                const SizedBox(width: 4),
                // Row Label (Right)
                SizedBox(
                  width: 22,
                  child: Text(String.fromCharCode(65 + r), 
                      style: AppTheme.label(11, color: AppTheme.textSecondary), textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildRowWithAisles(int rowIdx, bool isRecliner) {
    final List<Widget> items = [];
    final int seatsInRow = 8;
    
    for (int colIdx = 0; colIdx < seatsInRow; colIdx++) {
      // Add Aisle Gaps: 2 seats | 4 seats | 2 seats
      if (colIdx == 2 || colIdx == 6) {
        items.add(const SizedBox(width: 20));
      }

      final index = rowIdx * 8 + colIdx;
      final isBooked = bookedSeats.contains(index);
      final isSelected = selectedSeats.contains(index);
      final category = getSeatCategory(index);

      items.add(
        Expanded(
          child: GestureDetector(
            onTap: () => onSeatTap(index),
            child: _TheaterSeat(
              isSelected: isSelected,
              isBooked: isBooked,
              category: category,
              isRecliner: isRecliner,
            ),
          ),
        ),
      );
    }
    return items;
  }
}

// ── Theater Seat Component ───────────────────────────────────────────────────
class _TheaterSeat extends StatelessWidget {
  final bool isSelected;
  final bool isBooked;
  final String category;
  final bool isRecliner;

  const _TheaterSeat({
    required this.isSelected,
    required this.isBooked,
    required this.category,
    required this.isRecliner,
  });

  @override
  Widget build(BuildContext context) {
    Color mainColor;
    if (isBooked) {
      mainColor = AppTheme.divider.withValues(alpha: 0.5);
    } else if (isSelected) {
      mainColor = AppTheme.primary;
    } else {
      mainColor = category == 'Platinum' 
          ? const Color(0xFF6B4EE0) 
          : category == 'Gold' ? const Color(0xFF2E4060) : const Color(0xFF1E2430);
    }

    return AnimatedScale(
      scale: isSelected ? 1.12 : 1.0,
      duration: 250.ms,
      curve: Curves.easeOutBack,
      child: Container(
        height: isRecliner ? 32 : 26,
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Realistic Drop Shadow
            Positioned(
              bottom: 1,
              child: Container(
                width: 22, height: 4,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
            // Seat Base
            Container(
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(isRecliner ? 8 : 5),
                boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)] : null,
              ),
            ),
            // Armrests (Architectural top-down indicator)
            Positioned(
              left: -1, right: -1, top: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Armrest(),
                  _Armrest(),
                ],
              ),
            ),
            // Backrest highlight
            Positioned(
              bottom: 4, left: 4, right: 4, height: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Icon indicators
            if (isBooked) 
              const Icon(Icons.close, size: 8, color: Colors.white24)
            else if (isRecliner)
              Icon(Icons.king_bed_rounded, size: 10, color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }
}

class _Armrest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4, height: 14,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

// ── AR Cinema View ────────────────────────────────────────────────────────────
class _ARCinemaView extends StatelessWidget {
  final AnimationController scanLineCtrl;
  final Set<int> bookedSeats;
  final List<int> selectedSeats;
  final void Function(int) onSeatTap;
  final String Function(int) getSeatCategory;

  const _ARCinemaView({
    super.key,
    required this.scanLineCtrl,
    required this.bookedSeats,
    required this.selectedSeats,
    required this.onSeatTap,
    required this.getSeatCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Perspective Grid floor
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: CustomPaint(painter: _GridFloorPainter()),
          ),
        ),

        Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-0.55),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ARScreen(scanLineCtrl: scanLineCtrl),
                const SizedBox(height: 40),
                
                SizedBox(
                  height: 420,
                  width: 360,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 64,
                    itemBuilder: (ctx, i) {
                      final isSelected = selectedSeats.contains(i);
                      final isBooked = bookedSeats.contains(i);
                      final row = i ~/ 8;
                      
                      return GestureDetector(
                        onTap: () => onSeatTap(i),
                        child: AnimatedContainer(
                          duration: 400.ms,
                          curve: Curves.elasticOut,
                          transform: Matrix4.translationValues(0, isSelected ? -20 : 0, 0),
                          decoration: BoxDecoration(
                            color: isBooked ? AppTheme.divider : (isSelected ? AppTheme.primary : AppTheme.card),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.8), blurRadius: 20)] : null,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: isBooked ? const Icon(Icons.person, size: 12, color: Colors.white10) : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GridFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;
    
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ARScreen extends StatelessWidget {
  final AnimationController scanLineCtrl;
  const _ARScreen({required this.scanLineCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 60)],
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
             Opacity(
               opacity: 0.6,
               child: Image.network('https://images.unsplash.com/photo-1485095329183-d0797cdc5a76?q=80&w=800', fit: BoxFit.cover, width: double.infinity),
             ),
             Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.bottomCenter, end: Alignment.topCenter,
                   colors: [AppTheme.primary.withValues(alpha: 0.3), Colors.transparent],
                 )
               ),
             ),
             AnimatedBuilder(
               animation: scanLineCtrl,
               builder: (ctx, child) => Positioned(
                 top: scanLineCtrl.value * 140,
                 left: 0, right: 0,
                 child: Container(
                   height: 4,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     boxShadow: [BoxShadow(color: AppTheme.primary, blurRadius: 20)],
                   ),
                 ),
               ),
             ),
             const Center(
               child: Text('LIVE VIEW SIMULATION', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.bold)),
             ),
          ],
        ),
      ),
    );
  }
}

// ── Shared UI Widgets ─────────────────────────────────────────────────────────

class _ScreenCurveIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(320, 40),
          painter: _ScreenArcPainter(),
        ),
        const SizedBox(height: 12),
        Text('CINEMA SCREEN', style: AppTheme.body(10, color: AppTheme.textSecondary).copyWith(letterSpacing: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ScreenArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF334155), Colors.white, Color(0xFF334155)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, -size.height * 0.2, size.width, size.height);
    
    // Outer Glow
    canvas.drawPath(path, Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..strokeWidth = 12);

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(color: const Color(0xFF1E2430), label: 'Available'),
          _LegendItem(color: AppTheme.primary, label: 'Selected'),
          _LegendItem(color: AppTheme.divider, label: 'Booked', isX: true),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isX;
  const _LegendItem({required this.color, required this.label, this.isX = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: isX ? const Icon(Icons.close, size: 10, color: Colors.white24) : null,
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.body(11, color: AppTheme.textPrimary)),
      ],
    );
  }
}
