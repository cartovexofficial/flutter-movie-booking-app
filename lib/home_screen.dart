import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:helloworld/app_theme.dart';
import 'package:helloworld/movie_data.dart';
import 'package:helloworld/cinema_data.dart';
import 'package:helloworld/my_bookings_screen.dart';
import 'package:helloworld/seat_screen.dart';
import 'package:helloworld/chat_bot_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Location state ──────────────────────────────────────────────────────
  String _city = 'Detecting…';
  String _fullLocation = 'Detecting location…';
  bool _locationLoading = true;

  // ── Cinema state ────────────────────────────────────────────────────────
  List<Cinema> _nearbyCinemas = [];
  Cinema? _selectedCinema;

  // ── Movie state ─────────────────────────────────────────────────────────
  bool _imagesLoading = true;
  int _selectedCategoryIdx = 0;
  int _featuredIdx = 0;
  late PageController _pageCtrl;

  final List<String> _categories = [
    'All', 'Trending', 'Blockbuster', 'Action', 'Comedy', 'New Release', 'Epic',
  ];

  List<Movie> get _filteredMovies {
    if (_selectedCategoryIdx == 0) return allMovies;
    return getMoviesByTag(_categories[_selectedCategoryIdx]);
  }

  List<Movie> get _heroMovies => getTrending();

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88);
    _detectLocation();
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => mounted ? setState(() => _imagesLoading = false) : null,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Location / Geocoding via Nominatim (works on all platforms, no API key)
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _detectLocation() async {
    try {
      // 1. Check / request permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('Permission denied forever');
      }

      // 2. Get coordinates
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      // 3. Reverse geocode via OpenStreetMap Nominatim (free, no API key, CORS-ok)
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${pos.latitude}&lon=${pos.longitude}'
        '&format=json&accept-language=en',
      );
      final res = await http
          .get(url, headers: {'User-Agent': 'CinemaBook/2026'})
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        final city = (addr['city'] ??
                addr['town'] ??
                addr['village'] ??
                addr['county'] ??
                'Your City') as String;
        final state = (addr['state'] ?? '') as String;
        if (mounted) {
          setState(() {
            _city = city;
            _fullLocation = '$city, $state'.replaceAll(', ', ' ').trim();
            _locationLoading = false;
            _nearbyCinemas = getCinemasForCity(city);
          });
        }
      } else {
        throw Exception('Nominatim error ${res.statusCode}');
      }
    } catch (e) {
      // Friendly fallback with manual change option
      if (mounted) {
        setState(() {
          _city = 'Jaipur';
          _fullLocation = 'Jaipur, Rajasthan';
          _locationLoading = false;
          _nearbyCinemas = getCinemasForCity('Jaipur');
        });
      }
    }
  }

  void _showCityPicker() {
    final cities = cinemasByCity.keys.toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Select Your City', style: AppTheme.headline(18)),
          const SizedBox(height: 12),
          ...cities.map((c) => ListTile(
                leading: const Icon(Icons.location_city_rounded,
                    color: AppTheme.primary),
                title: Text(c, style: AppTheme.label(15)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _city = c;
                    _fullLocation = c;
                    _nearbyCinemas = getCinemasForCity(c);
                  });
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BOOK: show cinema picker then navigate
  // ──────────────────────────────────────────────────────────────────────────
  void _bookMovie(Movie movie) {
    if (_nearbyCinemas.isEmpty) {
      Navigator.push(context,
          CinemaRoute(page: SeatScreen(movie: movie, cinema: null)));
      return;
    }
    _showCinemaPicker(movie);
  }

  void _showCinemaPicker(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Choose Cinema in $_city',
                          style: AppTheme.headline(17))),
                  Text('${_nearbyCinemas.length} nearby',
                      style: AppTheme.body(12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _nearbyCinemas.length,
                itemBuilder: (_, i) {
                  final cinema = _nearbyCinemas[i];
                  final price = cinema.priceFor('Regular') +
                      (movie.basePrice - 200).clamp(0, 150);
                  return _CinemaPickerCard(
                    cinema: cinema,
                    moviePrice: price,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          CinemaRoute(
                              page: SeatScreen(
                                  movie: movie, cinema: cinema)));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 100)),

          // Location chip
          SliverToBoxAdapter(child: _buildLocationChip()),

          // AR promo banner
          SliverToBoxAdapter(child: _buildARPromoBanner()),

          // Hero banner
          SliverToBoxAdapter(child: _buildHeroBanner()),

          // Section: Nearby Cinemas
          SliverToBoxAdapter(child: _buildNearbyCinemasSection()),

          // Category chips
          SliverToBoxAdapter(child: _buildCategoryBar()),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Now Showing', style: AppTheme.headline(18)),
                  Text('${_filteredMovies.length} films',
                      style: AppTheme.body(13)),
                ],
              ),
            ),
          ),

          // Movie grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _imagesLoading
                    ? _buildShimmerCard()
                    : _buildMovieCard(_filteredMovies[i], i),
                childCount:
                    _imagesLoading ? 4 : _filteredMovies.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() => AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: AppTheme.bg.withValues(alpha: 0.7)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${widget.username.split('@')[0]} 👋',
                style: AppTheme.label(17)),
            Text('What will you watch today?', style: AppTheme.body(12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded,
                color: AppTheme.textPrimary),
            onPressed: () => Navigator.push(context,
                CinemaRoute(page: const MyBookingsScreen())),
          ),
          const SizedBox(width: 4),
        ],
      );

  // ── FAB ────────────────────────────────────────────────────────────────────
  Widget _buildFAB() => Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.glowShadow,
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
          label:
              Text('Help', style: AppTheme.label(14, color: Colors.white)),
          onPressed: () => Navigator.push(
              context, CinemaRoute(page: const ChatBotScreen())),
        ),
      );

  // ── Location chip ──────────────────────────────────────────────────────────
  Widget _buildLocationChip() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: GestureDetector(
          onTap: _showCityPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _locationLoading
                    ? const SizedBox(
                        width: 8, height: 8,
                        child: CircularProgressIndicator(
                            color: AppTheme.primary, strokeWidth: 1.5))
                    : Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFF30D158),
                            shape: BoxShape.circle),
                      )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.8, end: 1.3, duration: 900.ms),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_rounded,
                    color: AppTheme.primary, size: 14),
                const SizedBox(width: 4),
                Text(_fullLocation,
                    style: AppTheme.body(13, color: AppTheme.textPrimary)),
                const SizedBox(width: 6),
                const Icon(Icons.expand_more_rounded,
                    color: AppTheme.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0);

  // ── AR Promo Banner ────────────────────────────────────────────────────────
  Widget _buildARPromoBanner() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.15),
                const Color(0xFF4A1A8C).withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.view_in_ar_rounded,
                    color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✨ AR Cinema View',
                        style: AppTheme.label(13,
                            color: AppTheme.primary)),
                    Text(
                        'See your seats in 3D! Tap "AR View" while selecting seats.',
                        style: AppTheme.body(11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Try Now',
                    style: AppTheme.label(11, color: Colors.white)),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 150.ms)
          .slideX(begin: 0.1, end: 0, delay: 150.ms);

  // ── Hero Banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() => SizedBox(
        height: 250,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _heroMovies.length,
                onPageChanged: (i) => setState(() => _featuredIdx = i),
                itemBuilder: (_, i) {
                  final m = _heroMovies[i];
                  return AnimatedBuilder(
                    animation: _pageCtrl,
                    builder: (_, child) {
                      double scale = 1.0;
                      if (_pageCtrl.position.haveDimensions) {
                        scale = (1 -
                                (_pageCtrl.page! - i).abs() * 0.06)
                            .clamp(0.92, 1.0);
                      }
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: GestureDetector(
                      onTap: () => _bookMovie(m),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Poster image
                              Image.network(
                                m.posterUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, prog) =>
                                    prog == null
                                        ? child
                                        : _shimmerBox(),
                                errorBuilder: (_, __, ___) =>
                                    _posterFallback(m),
                              ),
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.9),
                                    ],
                                    stops: const [0.35, 1.0],
                                  ),
                                ),
                              ),
                              // Movie info overlay
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(m.tag,
                                          style: AppTheme.label(9,
                                              color: Colors.white)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(m.title,
                                        style: AppTheme.headline(17),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(m.genre,
                                        style: AppTheme.body(11)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            color: AppTheme.accent,
                                            size: 14),
                                        const SizedBox(width: 3),
                                        Text(m.rating,
                                            style: AppTheme.label(12)),
                                        const SizedBox(width: 6),
                                        Text('• ${m.duration}',
                                            style: AppTheme.body(11)),
                                        const SizedBox(width: 6),
                                        Text(
                                            '• From ₹${m.basePrice}',
                                            style: AppTheme.body(11,
                                                color: AppTheme.primary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _heroMovies.length,
                (i) => AnimatedContainer(
                  duration: 300.ms,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _featuredIdx ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _featuredIdx
                        ? AppTheme.primary
                        : AppTheme.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);

  // ── Nearby Cinemas Section ─────────────────────────────────────────────────
  Widget _buildNearbyCinemasSection() {
    if (_locationLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Shimmer.fromColors(
          baseColor: AppTheme.card,
          highlightColor: AppTheme.surface,
          child: Container(
              height: 130,
              decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16))),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cinemas Near You', style: AppTheme.headline(17)),
              GestureDetector(
                onTap: _showCityPicker,
                child: Text('Change City',
                    style: AppTheme.body(13, color: AppTheme.primary)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _nearbyCinemas.length,
            itemBuilder: (_, i) {
              final cinema = _nearbyCinemas[i];
              return _CinemaCard(cinema: cinema, index: i)
                  .animate()
                  .fadeIn(delay: (i * 80).ms)
                  .slideX(begin: 0.15, end: 0, delay: (i * 80).ms);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  // ── Category chips ─────────────────────────────────────────────────────────
  Widget _buildCategoryBar() => SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final selected = i == _selectedCategoryIdx;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIdx = i),
              child: AnimatedContainer(
                duration: 250.ms,
                margin: const EdgeInsets.only(
                    right: 10, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  gradient: selected ? AppTheme.primaryGradient : null,
                  color: selected ? null : AppTheme.card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppTheme.divider,
                  ),
                  boxShadow: selected ? AppTheme.glowShadow : null,
                ),
                child: Center(
                  child: Text(
                    _categories[i],
                    style: AppTheme.label(13,
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary),
                  ),
                ),
              ),
            );
          },
        ),
      ).animate().fadeIn(delay: 250.ms);

  // ── Movie Card ─────────────────────────────────────────────────────────────
  Widget _buildMovieCard(Movie m, int i) => GestureDetector(
        onTap: () => _bookMovie(m),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: Image.network(
                        m.posterUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (_, child, prog) =>
                            prog == null ? child : _shimmerBox(),
                        errorBuilder: (_, __, ___) => _posterFallback(m),
                      ),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(m.tag,
                            style: AppTheme.label(9,
                                color: Colors.white)),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 10, color: Colors.black),
                            const SizedBox(width: 2),
                            Text(m.rating,
                                style: AppTheme.label(9,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.title,
                        style: AppTheme.label(12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(m.genre,
                        style: AppTheme.body(10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('From ₹${m.basePrice}',
                        style: AppTheme.label(11,
                            color: AppTheme.primary)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: DecoratedBox(
                        decoration: AppTheme.primaryButtonDecoration,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _bookMovie(m),
                          child: Text('Book Now',
                              style: AppTheme.label(11,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: (80 + i * 80).ms, duration: 400.ms)
          .slideY(
              begin: 0.2,
              end: 0,
              delay: (80 + i * 80).ms,
              duration: 400.ms);

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _buildShimmerCard() => Shimmer.fromColors(
        baseColor: AppTheme.card,
        highlightColor: AppTheme.surface,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  Widget _shimmerBox() => Shimmer.fromColors(
        baseColor: AppTheme.card,
        highlightColor: AppTheme.surface,
        child: Container(color: AppTheme.card),
      );

  /// Gradient fallback when poster image fails to load
  Widget _posterFallback(Movie m) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _genreGradient(m.genre),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_filter_rounded,
                  color: Colors.white54, size: 40),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(m.title,
                    style: AppTheme.label(13),
                    textAlign: TextAlign.center,
                    maxLines: 3),
              ),
            ],
          ),
        ),
      );

  List<Color> _genreGradient(String genre) {
    if (genre.contains('Action') || genre.contains('War'))
      return [const Color(0xFF1a1a2e), const Color(0xFF8B0000)];
    if (genre.contains('Comedy') || genre.contains('Romance'))
      return [const Color(0xFF1a1a2e), const Color(0xFF7B2D8B)];
    if (genre.contains('Historical') || genre.contains('Epic'))
      return [const Color(0xFF1a1a2e), const Color(0xFF8B5E00)];
    if (genre.contains('Drama'))
      return [const Color(0xFF1a1a2e), const Color(0xFF00538B)];
    if (genre.contains('Animation'))
      return [const Color(0xFF1a1a2e), const Color(0xFF1B5E20)];
    return [const Color(0xFF1a1a2e), const Color(0xFF3D0066)];
  }
}

// ── Cinema Card (horizontal scroll) ───────────────────────────────────────────
class _CinemaCard extends StatelessWidget {
  final Cinema cinema;
  final int index;
  const _CinemaCard({required this.cinema, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.theaters_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cinema.name,
                        style: AppTheme.label(12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppTheme.accent, size: 12),
                        const SizedBox(width: 2),
                        Text(cinema.rating, style: AppTheme.body(11)),
                        const SizedBox(width: 6),
                        Text('${cinema.distanceKm} km',
                            style: AppTheme.body(11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Facilities
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: cinema.facilities.take(3).map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Text(
                  '${facilityEmoji(f)} $f',
                  style: AppTheme.body(9),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          Text(
            'From ₹${cinema.categoryPrices['Regular'] ?? 200}',
            style: AppTheme.label(12, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}

// ── Cinema Picker Card (bottom sheet) ─────────────────────────────────────────
class _CinemaPickerCard extends StatelessWidget {
  final Cinema cinema;
  final int moviePrice;
  final VoidCallback onTap;
  const _CinemaPickerCard({
    required this.cinema,
    required this.moviePrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cinema.name, style: AppTheme.label(15)),
                      const SizedBox(height: 2),
                      Text(cinema.address,
                          style: AppTheme.body(11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.accent, size: 13),
                      const SizedBox(width: 3),
                      Text(cinema.rating, style: AppTheme.label(12)),
                    ]),
                    Text('${cinema.distanceKm} km',
                        style: AppTheme.body(11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: cinema.facilities.map((f) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Text('${facilityEmoji(f)} $f',
                          style: AppTheme.body(9)),
                    )).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('From', style: AppTheme.body(10)),
                    Text('₹$moviePrice',
                        style: AppTheme.headline(18)
                            .copyWith(color: AppTheme.primary)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
