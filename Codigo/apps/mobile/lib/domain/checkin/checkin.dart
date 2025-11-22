class Checkin {
  final String id;
  final String author; 
  final DateTime date;
  final double points;

  // A evidência do check-in (já que seu app tem modo 'Photo Streak')
  final String? imageUrl; 

  Checkin({
    required this.id,
    required this.author,
    required this.date,
    required this.points,
    this.imageUrl,
  });
}