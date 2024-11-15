class Refrigeration {
  final int? id;
  String title;
  String description;
  String capacity;
  String image;
  String temperature;
  String humidity;
  String lastMaintenance;
  String nextMaintenance;
  String model;
  String serialNumber;
  String installedDate;

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
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
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

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'title': title,
      'description': description,
      'capacity': capacity,
      'image': image,
      'temperature': temperature,
      'humidity': humidity,
      'lastMaintenance': lastMaintenance,
      'nextMaintenance': nextMaintenance,
      'model': model,
      'serialNumber': serialNumber,
      'installedDate': installedDate,
    };
  }
}

