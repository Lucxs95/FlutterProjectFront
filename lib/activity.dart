class Activity {
  final String id; // Ajout de l'identifiant
  final String imageUrl;
  final String title;
  final String category;
  final String location;
  final int minPeople;
  final double price;

  Activity({
    required this.id, // Assurez-vous d'inclure l'id dans le constructeur
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.location,
    required this.minPeople,
    required this.price,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'], // Assurez-vous que votre JSON contient un champ 'id'
      imageUrl: json['imageUrl'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      minPeople: json['minPeople'],
      price: json['price'].toDouble(),
    );
  }
}
