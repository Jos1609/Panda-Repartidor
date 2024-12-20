class DeliveryStats {
  final int totalDeliveries;
  final double totalEarnings;
  final double rating;
  final int onlineHours;
  final int cancelledOrders;

  DeliveryStats({
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.rating,
    required this.onlineHours,
    required this.cancelledOrders,
  });

  factory DeliveryStats.fromMap(Map<String, dynamic> map) {
    return DeliveryStats(
      totalDeliveries: map['totalDeliveries'] ?? 0,
      totalEarnings: map['totalEarnings']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
      onlineHours: map['onlineHours'] ?? 0,
      cancelledOrders: map['cancelledOrders'] ?? 0,
    );
  }
}