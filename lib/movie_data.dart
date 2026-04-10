/// Complete Bollywood + Hollywood movie database with REAL movie posters
library movie_data;

class Movie {
  final String id;
  final String title;
  final String genre;
  final String tag;
  final String language;
  final String duration;
  final String rating;
  final String year;
  final String posterUrl;
  final String description;
  final List<String> cast;
  final int basePrice;

  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.tag,
    required this.language,
    required this.duration,
    required this.rating,
    required this.year,
    required this.posterUrl,
    required this.description,
    required this.cast,
    required this.basePrice,
  });
}

const List<Movie> allMovies = [

  // ❌ FAKE MOVIES → Placeholder Posters
  Movie(
    id: 'dhurandhar2',
    title: 'Dhurandhar 2: The Final Stand',
    genre: 'Action / Crime',
    tag: 'Blockbuster',
    language: 'Hindi',
    duration: '2h 55m',
    rating: '9.2',
    year: '2025',
    posterUrl: 'https://wsrv.nl/?url=https://placehold.co/400x600/png?text=Dhurandhar+2',
    description: 'The highly anticipated sequel. Dhurandhar returns to conquer the underworld.',
    cast: ['Superstar', 'Action Hero', 'Leading Lady'],
    basePrice: 400,
  ),

  Movie(
    id: 'dhurandhar',
    title: 'Dhurandhar',
    genre: 'Action / Drama',
    tag: 'Trending',
    language: 'Hindi',
    duration: '3h 10m',
    rating: '8.9',
    year: '2024',
    posterUrl: 'https://wsrv.nl/?url=https://placehold.co/400x600/png?text=Dhurandhar',
    description: 'The epic origin story of the fiercest warrior.',
    cast: ['Superstar', 'Veteran Actor', 'Rising Star'],
    basePrice: 320,
  ),

  // ✅ REAL MOVIES → REAL POSTERS

  Movie(
    id: 'fighter',
    title: 'Fighter',
    genre: 'Action / War',
    tag: 'Blockbuster',
    language: 'Hindi',
    duration: '2h 46m',
    rating: '7.8',
    year: '2024',
    posterUrl: 'https://wsrv.nl/?url=https://upload.wikimedia.org/wikipedia/en/d/df/Fighter_film_teaser.jpg',
    description: 'Top Indian Air Force aviators come together to form a highly trained squad.',
    cast: ['Hrithik Roshan', 'Deepika Padukone', 'Anil Kapoor'],
    basePrice: 320,
  ),

  Movie(
    id: 'kalki',
    title: 'Kalki 2898 AD',
    genre: 'Sci-Fi / Epic',
    tag: 'Trending',
    language: 'Telugu / Hindi',
    duration: '2h 50m',
    rating: '8.4',
    year: '2024',
    posterUrl: 'https://wsrv.nl/?url=https://upload.wikimedia.org/wikipedia/en/4/4f/Kalki_2898_AD_release_poster.jpg',
    description: 'A modern-day avatar of Vishnu descends on Earth to protect the world.',
    cast: ['Prabhas', 'Amitabh Bachchan', 'Kamal Haasan'],
    basePrice: 350,
  ),

  Movie(
    id: 'jawan',
    title: 'Jawan',
    genre: 'Action / Thriller',
    tag: 'Blockbuster',
    language: 'Hindi',
    duration: '2h 49m',
    rating: '8.2',
    year: '2023',
    posterUrl: 'https://wsrv.nl/?url=https://upload.wikimedia.org/wikipedia/en/3/39/Jawan_film_poster.jpg',
    description: 'A man is driven by a personal vendetta to rectify wrongs in society.',
    cast: ['Shah Rukh Khan', 'Nayanthara', 'Vijay Sethupathi'],
    basePrice: 300,
  ),

  Movie(
    id: 'stree2',
    title: 'Stree 2',
    genre: 'Horror / Comedy',
    tag: 'Trending',
    language: 'Hindi',
    duration: '2h 20m',
    rating: '8.5',
    year: '2024',
    posterUrl: 'https://wsrv.nl/?url=https://upload.wikimedia.org/wikipedia/en/0/05/Stree_2_poster.jpg',
    description: 'The terrifying legend of Stree returns.',
    cast: ['Rajkummar Rao', 'Shraddha Kapoor', 'Pankaj Tripathi'],
    basePrice: 280,
  ),

  Movie(
    id: 'pathaan',
    title: 'Pathaan',
    genre: 'Action / Thriller',
    tag: 'Blockbuster',
    language: 'Hindi',
    duration: '2h 26m',
    rating: '8.0',
    year: '2023',
    posterUrl: 'https://wsrv.nl/?url=https://upload.wikimedia.org/wikipedia/en/c/c3/Pathaan_film_poster.jpg',
    description: 'An Indian spy takes on mercenaries.',
    cast: ['Shah Rukh Khan', 'Deepika Padukone', 'John Abraham'],
    basePrice: 300,
  ),

  Movie(
    id: 'dunki',
    title: 'Dunki',
    genre: 'Comedy / Drama',
    tag: 'Comedy',
    language: 'Hindi',
    duration: '2h 41m',
    rating: '7.5',
    year: '2023',
    posterUrl: 'https://wsrv.nl/?url=https://upload.wikimedia.org/wikipedia/en/4/40/Dunki_film_poster.jpg',
    description: 'Four friends chase their dream to go abroad.',
    cast: ['Shah Rukh Khan', 'Taapsee Pannu', 'Vicky Kaushal'],
    basePrice: 270,
  ),
];

/// 🔍 FILTER FUNCTIONS

List<Movie> getMoviesByTag(String tag) =>
    tag == 'All'
        ? allMovies
        : allMovies.where((m) => m.tag == tag).toList();

List<Movie> getTrending() =>
    allMovies.where((m) =>
        m.tag == 'Trending' || m.tag == 'Blockbuster').toList();

List<Movie> getNewReleases() =>
    allMovies.where((m) =>
        m.tag == 'New Release' || m.year == '2024').toList();