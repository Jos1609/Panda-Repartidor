
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,    // Asignado pero no recogido
  picked,     // Recogido del restaurante
  delivering, // En camino al cliente
  completed,  // Entregado
  cancelled   // Cancelado
}

class DeliveryOrder {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final GeoPoint restaurantLocation;
  final String customerName;
  final String customerAddress;
  final GeoPoint customerLocation;
  final String customerPhone;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? notes;

  DeliveryOrder({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantLocation,
    required this.customerName,
    required this.customerAddress,
    required this.customerLocation,
    required this.customerPhone,
    required this.total,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  factory DeliveryOrder.fromMap(Map<String, dynamic> map) {
    return DeliveryOrder(
      id: map['id'],
      restaurantName: map['restaurantName'],
      restaurantAddress: map['restaurantAddress'],
      restaurantLocation: map['restaurantLocation'],
      customerName: map['customerName'],
      customerAddress: map['customerAddress'],
      customerLocation: map['customerLocation'],
      customerPhone: map['customerPhone'],
      total: map['total'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notes: map['notes'],
    );
  }
}