/// City-wise cinema database with cinema-specific pricing
library cinema_data;

class Cinema {
  final String id;
  final String name;
  final String address;
  final String city;
  final List<String> facilities; // IMAX, 4DX, Dolby Atmos, etc.
  final String rating;
  final double distanceKm; // Will be overridden dynamically
  final Map<String, int> categoryPrices; // 'Regular'|'Premium'|'IMAX'|'4DX' -> ₹

  const Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.facilities,
    required this.rating,
    required this.distanceKm,
    required this.categoryPrices,
  });

  /// Returns price for a given movie's base price + cinema multiplier
  int priceFor(String seatType) =>
      categoryPrices[seatType] ?? categoryPrices['Regular'] ?? 200;
}

const Map<String, List<Cinema>> cinemasByCity = {
  // ── Jaipur ──────────────────────────────────────────────────────────────
  'Jaipur': [
    Cinema(
      id: 'pvr_jaipur',
      name: 'PVR Crystal Palm',
      address: 'Crystal Palm Mall, Sirsi Road, Jaipur',
      city: 'Jaipur',
      facilities: ['Dolby Atmos', '4K Laser', 'Recliner'],
      rating: '4.3',
      distanceKm: 2.1,
      categoryPrices: {'Regular': 200, 'Premium': 320, 'IMAX': 420},
    ),
    Cinema(
      id: 'raj_mandir',
      name: 'Raj Mandir Cinema',
      address: 'Bhagwan Das Road, C-Scheme, Jaipur',
      city: 'Jaipur',
      facilities: ['Heritage', 'Dolby Sound', 'Balcony'],
      rating: '4.7',
      distanceKm: 3.4,
      categoryPrices: {'Regular': 150, 'Premium': 250, 'IMAX': 0},
    ),
    Cinema(
      id: 'inox_jaipur',
      name: 'INOX Jaipur',
      address: 'Gaurav Tower, Malviya Nagar, Jaipur',
      city: 'Jaipur',
      facilities: ['Dolby Atmos', '4K', 'GTX'],
      rating: '4.1',
      distanceKm: 5.8,
      categoryPrices: {'Regular': 180, 'Premium': 290, 'IMAX': 380},
    ),
    Cinema(
      id: 'cinepolis_jaipur',
      name: 'Cinépolis Jaipur',
      address: 'World Trade Park, Malviya Nagar, Jaipur',
      city: 'Jaipur',
      facilities: ['4DX', 'VIP', 'Dolby Atmos', 'Recliner'],
      rating: '4.5',
      distanceKm: 6.2,
      categoryPrices: {'Regular': 220, 'Premium': 350, 'IMAX': 440, '4DX': 550},
    ),
  ],

  // ── Delhi ────────────────────────────────────────────────────────────────
  'Delhi': [
    Cinema(
      id: 'pvr_cp',
      name: 'PVR Connaught Place',
      address: 'Odeon Building, Connaught Place, New Delhi',
      city: 'Delhi',
      facilities: ['IMAX', 'Dolby Atmos', 'Recliner'],
      rating: '4.4',
      distanceKm: 1.5,
      categoryPrices: {'Regular': 250, 'Premium': 380, 'IMAX': 500},
    ),
    Cinema(
      id: 'pvr_ambience',
      name: 'PVR Ambience Mall',
      address: 'Ambience Mall, Vasant Kunj, New Delhi',
      city: 'Delhi',
      facilities: ['4DX', 'Luxe', 'IMAX', 'Dolby Vision'],
      rating: '4.6',
      distanceKm: 8.2,
      categoryPrices: {'Regular': 270, 'Premium': 420, 'IMAX': 540, '4DX': 620},
    ),
    Cinema(
      id: 'cinepolis_delhi',
      name: 'Cinépolis Vegas Mall',
      address: 'Vegas Mall, Dwarka, New Delhi',
      city: 'Delhi',
      facilities: ['4DX', 'Recliner', 'Dolby Atmos'],
      rating: '4.2',
      distanceKm: 12.1,
      categoryPrices: {'Regular': 230, 'Premium': 360, 'IMAX': 0, '4DX': 580},
    ),
  ],

  // ── Mumbai ───────────────────────────────────────────────────────────────
  'Mumbai': [
    Cinema(
      id: 'pvr_phoenix',
      name: 'PVR IMAX Phoenix',
      address: 'Phoenix Mills, Lower Parel, Mumbai',
      city: 'Mumbai',
      facilities: ['IMAX', 'Dolby Atmos', '4K Laser', 'Luxe'],
      rating: '4.7',
      distanceKm: 3.2,
      categoryPrices: {'Regular': 280, 'Premium': 420, 'IMAX': 580},
    ),
    Cinema(
      id: 'regal_mumbai',
      name: 'Regal Cinema',
      address: 'Colaba, Mumbai',
      city: 'Mumbai',
      facilities: ['Heritage', 'Dolby Sound', 'Balcony'],
      rating: '4.5',
      distanceKm: 5.1,
      categoryPrices: {'Regular': 200, 'Premium': 300, 'IMAX': 0},
    ),
    Cinema(
      id: 'inox_nariman',
      name: 'INOX Nariman Point',
      address: 'NCE Square, Nariman Point, Mumbai',
      city: 'Mumbai',
      facilities: ['4DX', 'Dolby Atmos', 'ScreenX'],
      rating: '4.3',
      distanceKm: 4.8,
      categoryPrices: {'Regular': 260, 'Premium': 390, 'IMAX': 500, '4DX': 620},
    ),
  ],

  // ── Bengaluru ────────────────────────────────────────────────────────────
  'Bengaluru': [
    Cinema(
      id: 'pvr_garuda',
      name: 'PVR Garuda Mall',
      address: 'Garuda Mall, Magrath Road, Bengaluru',
      city: 'Bengaluru',
      facilities: ['IMAX', '4DX', 'Dolby Atmos'],
      rating: '4.4',
      distanceKm: 2.7,
      categoryPrices: {'Regular': 220, 'Premium': 360, 'IMAX': 480, '4DX': 560},
    ),
    Cinema(
      id: 'inox_garuda',
      name: 'INOX Garuda Mall',
      address: 'Garuda Mall, Magrath Road, Bengaluru',
      city: 'Bengaluru',
      facilities: ['Dolby Atmos', 'Recliner', '4K'],
      rating: '4.2',
      distanceKm: 2.8,
      categoryPrices: {'Regular': 200, 'Premium': 320, 'IMAX': 430},
    ),
  ],

  // ── Hyderabad ────────────────────────────────────────────────────────────
  'Hyderabad': [
    Cinema(
      id: 'pvr_inorbit',
      name: 'AMB Cinemas PVR IMAX',
      address: 'AMB Mall, Gachibowli, Hyderabad',
      city: 'Hyderabad',
      facilities: ['IMAX', '4DX', 'Dolby Atmos', 'Luxe Recliner'],
      rating: '4.8',
      distanceKm: 4.5,
      categoryPrices: {'Regular': 240, 'Premium': 380, 'IMAX': 520, '4DX': 620},
    ),
    Cinema(
      id: 'cinepolis_hyd',
      name: 'Cinépolis Inorbit',
      address: 'Inorbit Mall, Madhapur, Hyderabad',
      city: 'Hyderabad',
      facilities: ['4DX', 'VIP', 'Dolby Atmos'],
      rating: '4.3',
      distanceKm: 6.1,
      categoryPrices: {'Regular': 210, 'Premium': 340, 'IMAX': 430, '4DX': 580},
    ),
  ],

  // ── Chennai ──────────────────────────────────────────────────────────────
  'Chennai': [
    Cinema(
      id: 'spi_sathyam',
      name: 'SPI Sathyam Cinemas',
      address: 'Royapettah, Chennai',
      city: 'Chennai',
      facilities: ['IMAX', 'Dolby Atmos', '4DX', 'Luxe'],
      rating: '4.6',
      distanceKm: 3.0,
      categoryPrices: {'Regular': 200, 'Premium': 340, 'IMAX': 460, '4DX': 560},
    ),
    Cinema(
      id: 'rohini_chennai',
      name: 'Rohini Silver Screens',
      address: 'Koyambedu, Chennai',
      city: 'Chennai',
      facilities: ['Dolby Atmos', 'Recliner', '4K'],
      rating: '4.4',
      distanceKm: 8.3,
      categoryPrices: {'Regular': 180, 'Premium': 290, 'IMAX': 0},
    ),
  ],

  // ── Pune ────────────────────────────────────────────────────────────────
  'Pune': [
    Cinema(
      id: 'pvr_phoenix_pune',
      name: 'PVR Phoenix Pune',
      address: 'Phoenix Market City, Nagar Road, Pune',
      city: 'Pune',
      facilities: ['IMAX', '4DX', 'Dolby Atmos'],
      rating: '4.3',
      distanceKm: 3.9,
      categoryPrices: {'Regular': 220, 'Premium': 350, 'IMAX': 470, '4DX': 560},
    ),
    Cinema(
      id: 'city_pride_pune',
      name: 'City Pride Multiplex',
      address: 'Kothrud, Pune',
      city: 'Pune',
      facilities: ['Dolby Sound', '4K', 'Recliner'],
      rating: '4.1',
      distanceKm: 5.5,
      categoryPrices: {'Regular': 180, 'Premium': 280, 'IMAX': 0},
    ),
  ],
};

/// Get cinemas for a given city (case-insensitive partial match)
List<Cinema> getCinemasForCity(String city) {
  if (city.isEmpty) return cinemasByCity['Jaipur']!;

  // Direct match
  for (final key in cinemasByCity.keys) {
    if (city.toLowerCase().contains(key.toLowerCase()) ||
        key.toLowerCase().contains(city.toLowerCase())) {
      return cinemasByCity[key]!;
    }
  }

  // Common alias lookups
  final aliases = {
    'bangalore': 'Bengaluru',
    'bengaluru': 'Bengaluru',
    'new delhi': 'Delhi',
    'bombay': 'Mumbai',
    'madras': 'Chennai',
    'deccan': 'Hyderabad',
  };
  for (final entry in aliases.entries) {
    if (city.toLowerCase().contains(entry.key)) {
      return cinemasByCity[entry.value] ?? cinemasByCity['Jaipur']!;
    }
  }

  // Default
  return cinemasByCity['Jaipur']!;
}

/// Facility icon helper
String facilityEmoji(String facility) {
  switch (facility.toLowerCase()) {
    case 'imax':       return '🎯';
    case '4dx':        return '💺';
    case 'dolby atmos':return '🔊';
    case 'dolby vision':return '👁';
    case 'recliner':   return '🛋';
    case 'luxe':       return '✨';
    case 'vip':        return '👑';
    case 'heritage':   return '🏛';
    case '4k':
    case '4k laser':   return '📽';
    case 'screenx':    return '📐';
    default:           return '🎬';
  }
}
