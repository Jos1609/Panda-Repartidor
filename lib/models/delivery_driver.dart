class DeliveryDriver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isAvailable;

  DeliveryDriver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.isAvailable = true,
  });

  factory DeliveryDriver.fromMap(Map<String, dynamic> map) {
    return DeliveryDriver(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isAvailable': isAvailable,
    };
  }
}