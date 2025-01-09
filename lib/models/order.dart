// lib/models/delivery_order.dart

import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_item.dart';
import '../models/payment_model.dart';
import '../models/status_long_model.dart';

enum OrderStatus {
  pending, // Pendiente de asignación
  assigned, // Asignado a repartidor
  inProgress, // En camino
  delivered, // Entregado
  cancelled // Cancelado
}

class DeliveryOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final GeoPoint? customerLocation; // Opcional del primer modelo
  final DateTime createdAt;
  OrderStatus status;
  
  // Campos del primer modelo (opcionales)
  final String? storeName;
  final String? storeAddress;
  final GeoPoint? storeLocation;
  
  // Campos del segundo modelo (opcionales)
  final List<OrderItem>? items;
  final double? subtotal;
  final double? tax;
  final double? deliveryFee;
  final double total;
  final String deliveryPersonId;
  final String? notes;
  final bool isPaid;
  final List<StatusLog>? statusHistory;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;

  DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.customerLocation,
    required this.createdAt,
    required this.status,
    this.storeName,
    this.storeAddress,
    this.storeLocation,
    this.items,
    this.subtotal,
    this.tax,
    this.deliveryFee,
    required this.total,
    required this.deliveryPersonId,
    this.notes,
    this.isPaid = false,
    this.statusHistory,
    this.paymentMethod,
    this.paymentReference,
  });

  factory DeliveryOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DeliveryOrder(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      customerLocation: data['customerLocation'],
      createdAt: (data['createdAt'] ?? data['orderDate'] as Timestamp).toDate(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      storeName: data['storeName'],
      storeAddress: data['storeAddress'],
      storeLocation: data['storeLocation'],
      items: data['items'] != null
          ? (data['items'] as List).map((item) => OrderItem.fromMap(item)).toList()
          : null,
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      deliveryPersonId: data['deliveryPersonId'],
      notes: data['notes'],
      isPaid: data['isPaid'] ?? false,
      statusHistory: data['statusHistory'] != null
          ? (data['statusHistory'] as List)
              .map((log) => StatusLog.fromMap(log))
              .toList()
          : null,
      paymentMethod: data['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${data['paymentMethod']}',
              orElse: () => PaymentMethod.values.first,
            )
          : null,
      paymentReference: data['paymentReference'],
    );
  }

  Map<String, dynamic> toMap(Map<String, dynamic> data) {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerLocation': customerLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'storeLocation': storeLocation,
      'items': items?.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryPersonId': deliveryPersonId,
      'notes': notes,
      'isPaid': isPaid,
      'statusHistory': statusHistory?.map((log) => log.toMap()).toList(),
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'paymentReference': paymentReference,
    };
  }

  // Métodos de utilidad del primer modelo
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFFA000);
      case OrderStatus.assigned:
        return const Color(0xFF2196F3);
      case OrderStatus.inProgress:
        return const Color(0xFF4CAF50);      
      case OrderStatus.delivered:
        return const Color(0xFF00C853);
      case OrderStatus.cancelled:
        return const Color(0xFFE53935);
    }
  }

  String getStatusText() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.assigned:
        return 'Asignado';
      case OrderStatus.inProgress:
        return 'Recogido';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  bool get isActive {
    return status == OrderStatus.pending ||
           status == OrderStatus.assigned ||
           status == OrderStatus.inProgress ;
  }

  // Método del segundo modelo
  void updateStatus(OrderStatus newStatus, String updatedBy) {
    status = newStatus;
    statusHistory?.add(
      StatusLog(
        status: newStatus,
        timestamp: DateTime.now(),
        updatedBy: updatedBy,
      ),
    );
  }

  // Métodos de cálculo de distancia y tiempo de entrega
  int getEstimatedDeliveryTime() {
    if (storeLocation != null && customerLocation != null) {
      final distance = _calculateDistance(
        storeLocation!.latitude,
        storeLocation!.longitude,
        customerLocation!.latitude,
        customerLocation!.longitude,
      );
      return (distance * 2).round();
    }
    return 30;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * 
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(1 - a), sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}