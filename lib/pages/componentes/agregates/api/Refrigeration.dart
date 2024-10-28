class Refrigeration {
  final int id;
  final String title;
  final String description;
  final String capacity;
  final String image;
  final String temperature;
  final String humidity;
  final String lastMaintenance;
  final String nextMaintenance;
  final String model;
  final String serialNumber;
  final String installedDate;

  Refrigeration({
    required this.id,
    required this.title,
    required this.description,
    required this.capacity,
    required this.image,
    required this.temperature,
    required this.humidity,
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.model,
    required this.serialNumber,
    required this.installedDate,
  });

  factory Refrigeration.fromJson(Map<String, dynamic> json) {
    return Refrigeration(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      capacity: json['capacity'] as String,
      image: json['image'] as String,
      temperature: json['temperature'] as String,
      humidity: json['humidity'] as String,
      lastMaintenance: json['lastMaintenance'] as String,
      nextMaintenance: json['nextMaintenance'] as String,
      model: json['model'] as String,
      serialNumber: json['serialNumber'] as String,
      installedDate: json['installedDate'] as String,
    );
  }
}