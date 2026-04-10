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
  // Seats 12-18 are "already booked" by others
  final Set<int> bookedSeats = {12, 13, 17, 28, 29, 38};
  bool _arMode = false;

  late AnimationController _scanLineCtrl;

  int getTotalPrice() {
    int baseUnitPrice = widget.cinema?.priceFor('Regular') ?? widget.movie.basePrice;
    return baseUnitPrice * selectedSeats.length;
  }

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    super.dispose();
  }

  void _onSeatTap(int index) {
    if (bookedSeats.contains(index)) return;
    HapticFeedback.selectionClick();
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
        title: Text(widget.movie.title,
            style: AppTheme.label(16), overflow: TextOverflow.ellipsis),
        backgroundColor: AppTheme.surface,
        actions: [
          // AR Toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _arMode = !_arMode);
            },
            child: AnimatedContainer(
              duration: 300.ms,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: _arMode ? AppTheme.primaryGradient : null,
                color: _arMode ? null : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        _arMode ? Colors.transparent : AppTheme.divider),
                boxShadow: _arMode ? AppTheme.glowShadow : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _arMode
                        ? Icons.view_in_ar_rounded
                        : Icons.view_in_ar_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _arMode ? 'AR ON' : 'AR View',
                    style: AppTheme.label(12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: 450.ms,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: _arMode
                  ? _ARCinemaView(
                      key: const ValueKey('ar'),
                      scanLineCtrl: _scanLineCtrl,
                      bookedSeats: bookedSeats,
                      selectedSeats: selectedSeats,
                      onSeatTap: _onSeatTap,
                    )
                  : _NormalSeatView(
                      key: const ValueKey('normal'),
                      bookedSeats: bookedSeats,
                      selectedSeats: selectedSeats,
                      onSeatTap: _onSeatTap,
                    ),
            ),
          ),

          // ── Bottom bar ────────────────────────────────────────────────
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
            top: BorderSide(color: AppTheme.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected seat list
          if (selectedSeats.isNotEmpty) ...[
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: selectedSeats.map((s) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDim,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary),
                    ),
                    child: Text('S${s + 1}',
                        style: AppTheme.label(11, color: AppTheme.primary)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: AppTheme.body(12)),
                  AnimatedSwitcher(
                    duration: 300.ms,
                    child: Text(
                      '₹${getTotalPrice()}',
                      key: ValueKey(getTotalPrice()),
                      style: AppTheme.headline(22),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                width: 160,
                child: DecoratedBox(
                  decoration: selectedSeats.isEmpty
                      ? BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(14))
                      : AppTheme.primaryButtonDecoration,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: selectedSeats.isEmpty
                        ? null
                        : () => Navigator.push(
                              context,
                              CinemaRoute(
                                page: PaymentScreen(
                                  movie: widget.movie,
                                  cinema: widget.cinema,
                                  selectedSeats: selectedSeats,
                                ),
                              ),
                            ),
                    child: Text(
                      selectedSeats.isEmpty
                          ? 'Select Seats'
                          : 'Pay Now →',
                      style: AppTheme.label(14,
                          color: selectedSeats.isEmpty
                              ? AppTheme.textSecondary
                              : Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Normal Seat View ──────────────────────────────────────────────────────────
class _NormalSeatView extends StatelessWidget {
  final Set<int> bookedSeats;
  final List<int> selectedSeats;
  final void Function(int) onSeatTap;

  const _NormalSeatView({
    super.key,
    required this.bookedSeats,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Screen indicator
        _ScreenIndicator(),
        const SizedBox(height: 24),

        // Legend
        _Legend(),
        const SizedBox(height: 16),

        // Seat grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 48,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 1),
            itemBuilder: (_, i) {
              final isBooked = bookedSeats.contains(i);
              final isSelected = selectedSeats.contains(i);

              Color seatColor;
              if (isBooked) {
                seatColor = AppTheme.surface;
              } else if (isSelected) {
                seatColor = AppTheme.primary;
              } else {
                seatColor = const Color(0xFF1C2B4A);
              }

              return GestureDetector(
                onTap: () => onSeatTap(i),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: seatColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.6)
                          : isBooked
                              ? AppTheme.divider
                              : const Color(0xFF2A4A7A),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            )
                          ]
                        : null,
                  ),
                  child: isBooked
                      ? const Icon(Icons.close, color: Color(0xFF4A4A5A), size: 12)
                      : null,
                ),
              )
                  .animate()
                  .fadeIn(delay: (i * 12).ms, duration: 300.ms)
                  .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      delay: (i * 12).ms,
                      duration: 300.ms,
                      curve: Curves.easeOutBack);
            },
          ),
        ),
      ],
    );
  }
}

// ── AR Cinema View ────────────────────────────────────────────────────────────
class _ARCinemaView extends StatelessWidget {
  final AnimationController scanLineCtrl;
  final Set<int> bookedSeats;
  final List<int> selectedSeats;
  final void Function(int) onSeatTap;

  const _ARCinemaView({
    super.key,
    required this.scanLineCtrl,
    required this.bookedSeats,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bg,
      child: Column(
        children: [
          // AR label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.view_in_ar_rounded,
                          color: AppTheme.primary, size: 14),
                      const SizedBox(width: 6),
                      Text('AR Cinema View',
                          style: AppTheme.label(12, color: AppTheme.primary)),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 700.ms)
                    .then()
                    .fadeOut(duration: 700.ms),
                const SizedBox(width: 10),
                Text('Tap seats to select',
                    style: AppTheme.body(12)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(-0.38),
                child: Column(
                  children: [
                    // ── AR Screen with scan-line ──────────────────────
                    _ARScreen(scanLineCtrl: scanLineCtrl),
                    const SizedBox(height: 8),

                    // ── AR Seat Grid ──────────────────────────────────
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 48,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                                childAspectRatio: 1),
                        itemBuilder: (_, i) {
                          final isBooked = bookedSeats.contains(i);
                          final isSelected = selectedSeats.contains(i);

                          Color col;
                          if (isBooked) {
                            col = AppTheme.surface;
                          } else if (isSelected) {
                            col = AppTheme.primary;
                          } else {
                            // Row-based color gradient for depth
                            final row = i ~/ 8;
                            final depth = (row / 5).clamp(0.0, 1.0);
                            col = Color.lerp(
                                const Color(0xFF0D3B6E),
                                const Color(0xFF1A6EBC),
                                depth)!;
                          }

                          return GestureDetector(
                            onTap: () => onSeatTap(i),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              decoration: BoxDecoration(
                                color: col,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                          .withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: isSelected ? 1.5 : 0.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.6),
                                          blurRadius: 10,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AR Screen widget with scan-line ──────────────────────────────────────────
class _ARScreen extends StatelessWidget {
  final AnimationController scanLineCtrl;
  const _ARScreen({required this.scanLineCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _CinemaScreenPainter(scanLineCtrl),
        child: AnimatedBuilder(
          animation: scanLineCtrl,
          builder: (_, __) => Stack(
            children: [
              // scan line
              Positioned(
                left: 0,
                right: 0,
                top: scanLineCtrl.value * 70,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.primary.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CinemaScreenPainter extends CustomPainter {
  final Animation<double> animation;
  _CinemaScreenPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Screen arc background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A2A50), Color(0xFF0D4080)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height)
      ..quadraticBezierTo(
          size.width * 0.5, -size.height * 0.25, size.width * 0.95, size.height)
      ..close();

    canvas.drawPath(path, bgPaint);

    // Glowing border
    final borderPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);

    // SCREEN text
    final tp = TextPainter(
      text: TextSpan(
        text: 'S C R E E N',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 11,
          letterSpacing: 5,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
    );

    // Projector-light cone from top
    final lightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08 + animation.value * 0.04),
          Colors.transparent,
        ],
        center: const Alignment(0, -3),
        radius: 3.5,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), lightPaint);
  }

  @override
  bool shouldRepaint(covariant _CinemaScreenPainter old) => true;
}

// ── Legend ────────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: const Color(0xFF1C2B4A), label: 'Available'),
        const SizedBox(width: 16),
        _LegendItem(color: AppTheme.primary, label: 'Selected'),
        const SizedBox(width: 16),
        _LegendItem(color: AppTheme.surface, label: 'Booked'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white12),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.body(11)),
      ],
    );
  }
}

// ── Screen indicator ──────────────────────────────────────────────────────────
class _ScreenIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.65,
          height: 4,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text('SCREEN', style: AppTheme.body(11, color: AppTheme.textSecondary).copyWith(letterSpacing: 6)),
      ],
    );
  }
}
