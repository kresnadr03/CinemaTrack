class Movie {
  final String id;
  final String title;
  final String genre;
  final String status; // "belum" atau "sudah"
  final String? note;
  final String? posterUrl;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.status,
    this.note,
    this.posterUrl,
  });

  factory Movie.fromMap(String id, Map<String, dynamic> data) {
    return Movie(
      id: id,
      title: data['title'] ?? '',
      genre: data['genre'] ?? '',
      status: data['status'] ?? 'belum',
      note: data['note'],
      posterUrl: data['posterUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'genre': genre,
      'status': status,
      'note': note,
      'posterUrl': posterUrl,
    };
  }
}
