class Activity {
  final String id; 
  final String imageUrl;
  final String title;
  final String category;
  final String location;
  final int minPeople;
  final double price;

  Activity({
    required this.id, 
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.location,
    required this.minPeople,
    required this.price,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      minPeople: json['minPeople'],
      price: json['price'].toDouble(),
    );
  }
}
