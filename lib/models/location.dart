class Location {
  final double latitude;
  final double longitude;

  const Location({
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => '($latitude, $longitude)';
}
